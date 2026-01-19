#!/usr/bin/env node
/**
 * OPENCODE COBOL EDITION - COPILOT SDK BRIDGE
 * 
 * Bridges COBOL TUI to GitHub Copilot via the official SDK.
 * Usage:
 *   node copilot-bridge.js chat "message" [model]
 *   node copilot-bridge.js clear
 *   node copilot-bridge.js status
 */

import { CopilotClient } from "@github/copilot-sdk";
import { readFileSync, writeFileSync, existsSync, mkdirSync } from "fs";
import { dirname, join } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const DATA_DIR = join(__dirname, "..", "DATA");
const HISTORY_FILE = join(DATA_DIR, "history.json");

// Ensure DATA directory exists
if (!existsSync(DATA_DIR)) {
    mkdirSync(DATA_DIR, { recursive: true });
}

// History management
function loadHistory() {
    try {
        if (existsSync(HISTORY_FILE)) {
            return JSON.parse(readFileSync(HISTORY_FILE, "utf8"));
        }
    } catch (e) {}
    return { messages: [] };
}

function saveHistory(history) {
    writeFileSync(HISTORY_FILE, JSON.stringify(history, null, 2));
}

function clearHistory() {
    saveHistory({ messages: [] });
    console.log("History cleared");
}

function addMessage(role, content) {
    const history = loadHistory();
    history.messages.push({ role, content });
    saveHistory(history);
}

// Main chat function using Copilot SDK
async function chat(message, model = "gpt-5") {
    const client = new CopilotClient({
        logLevel: "error",
        autoStart: true,
    });

    try {
        // Create session with specified model
        const session = await client.createSession({
            model: model,
            systemMessage: {
                content: "You are OpenCode COBOL Edition, an AI coding assistant. Be helpful and concise."
            }
        });

        // Add user message to history
        addMessage("user", message);

        // Collect response
        let response = "";
        let currentModel = model;
        
        const done = new Promise((resolve, reject) => {
            const timeout = setTimeout(() => {
                reject(new Error("Timeout waiting for response"));
            }, 120000); // 2 minute timeout

            session.on((event) => {
                if (event.type === "assistant.message") {
                    response = event.data.content;
                    if (event.data.model) {
                        currentModel = event.data.model;
                    }
                } else if (event.type === "assistant.message_delta") {
                    // Streaming chunk - accumulate
                    response += event.data.deltaContent || "";
                } else if (event.type === "session.idle") {
                    clearTimeout(timeout);
                    resolve();
                } else if (event.type === "error") {
                    clearTimeout(timeout);
                    reject(new Error(event.data?.message || "Unknown error"));
                }
            });
        });

        // Send message and wait
        await session.send({ prompt: message });
        await done;

        // Save response to history
        if (response) {
            addMessage("assistant", response);
        }

        // Clean up
        await session.destroy();
        await client.stop();

        // Output response with model info
        console.log(`[Model: ${currentModel}]`);
        console.log(response || "No response received");

    } catch (error) {
        await client.stop().catch(() => {});
        console.error(`Error: ${error.message}`);
        process.exit(1);
    }
}

// Check status
async function status() {
    const client = new CopilotClient({
        logLevel: "error",
        autoStart: true,
    });

    try {
        const pong = await client.ping("test");
        await client.stop();
        console.log("OK:copilot:connected");
    } catch (error) {
        await client.stop().catch(() => {});
        console.log(`NO_KEY:copilot:${error.message}`);
    }
}

// Main
async function main() {
    const [,, cmd, ...args] = process.argv;

    switch (cmd) {
        case "chat":
            const message = args[0];
            const model = args[1] || "gpt-5";
            if (!message) {
                console.error("Usage: copilot-bridge.js chat <message> [model]");
                process.exit(1);
            }
            await chat(message, model);
            break;
            
        case "clear":
            clearHistory();
            break;
            
        case "status":
            await status();
            break;
            
        default:
            console.log("Usage: copilot-bridge.js <chat|clear|status>");
            console.log("");
            console.log("  chat MSG [MODEL]  - Send message to Copilot");
            console.log("  clear             - Clear conversation history");
            console.log("  status            - Check connection status");
            console.log("");
            console.log("Models: gpt-5, gpt-5-mini, claude-sonnet-4.5, etc.");
            break;
    }
}

main().catch(console.error);
