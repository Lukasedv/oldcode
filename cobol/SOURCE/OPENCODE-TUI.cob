       IDENTIFICATION DIVISION.
       PROGRAM-ID. OPENCODE-TUI.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT AI-RESPONSE-FILE ASSIGN TO WS-RESPONSE-PATH
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  AI-RESPONSE-FILE.
       01  AI-RESPONSE-RECORD      PIC X(200).

       WORKING-STORAGE SECTION.
       01  WS-RUNNING              PIC 9 VALUE 1.
       01  WS-CURRENT-AGENT        PIC X(10) VALUE "BUILD".
       01  WS-CURRENT-MODEL        PIC X(20) VALUE "gpt-5".
       01  WS-USER-INPUT           PIC X(72) VALUE SPACES.
       01  WS-HEADER-LINE          PIC X(78).
       01  WS-STATUS-LINE          PIC X(78).
       01  WS-BORDER-LINE          PIC X(78).
       01  WS-DISPLAY-LINE         PIC X(74).
       01  WS-I                    PIC 999 VALUE 0.
       01  WS-J                    PIC 999 VALUE 0.
       01  WS-ROW                  PIC 99 VALUE 0.
       01  WS-COL                  PIC 99 VALUE 0.
       01  WS-VERSION              PIC X(12) VALUE "0.2.0-COBOL".
       01  WS-CURRENT-TIME.
           05  WS-HOUR             PIC 99.
           05  WS-MINUTE           PIC 99.
           05  WS-SECOND           PIC 99.
           05  FILLER              PIC X(2).
       01  WS-RESPONSE-INDEX       PIC 9 VALUE 1.
       01  WS-TEMP-STR             PIC X(200).
       01  WS-AI-CMD               PIC X(500).
       01  WS-RESPONSE-PATH        PIC X(100) 
           VALUE "/tmp/opencode-cobol-response.txt".
       01  WS-FILE-STATUS          PIC XX VALUE SPACES.
       01  WS-AI-RESPONSE          PIC X(4000) VALUE SPACES.
       01  WS-RESP-LINE            PIC X(200).
       01  WS-RESP-LEN             PIC 9999 VALUE 0.
       01  WS-RESP-POS             PIC 9999 VALUE 1.
       01  WS-LINE-LEN             PIC 99 VALUE 74.
       01  WS-LINES-USED           PIC 99 VALUE 0.
       01  WS-MAX-LINES            PIC 99 VALUE 14.
       01  WS-AI-ENABLED           PIC 9 VALUE 0.
       01  WS-SCRIPT-DIR           PIC X(200).
       01  WS-CHUNK                PIC X(74).
       01  WS-LAST-ROLE            PIC X(10) VALUE SPACES.

       SCREEN SECTION.
       01  CLEAR-SCREEN.
           05  BLANK SCREEN.
       01  HEADER-DISPLAY.
           05  LINE 1 COLUMN 1 PIC X(78) FROM WS-HEADER-LINE
               REVERSE-VIDEO.
       01  BORDER-TOP.
           05  LINE 2 COLUMN 1 PIC X(78) FROM WS-BORDER-LINE
               FOREGROUND-COLOR 6.
       01  CHAT-LABEL.
           05  LINE 3 COLUMN 2 VALUE "CHAT - GitHub Copilot"
               FOREGROUND-COLOR 3 HIGHLIGHT.
       01  BORDER-MID.
           05  LINE 18 COLUMN 1 PIC X(78) FROM WS-BORDER-LINE
               FOREGROUND-COLOR 6.
       01  INPUT-PROMPT.
           05  LINE 19 COLUMN 2 VALUE ">" FOREGROUND-COLOR 2 HIGHLIGHT.
       01  INPUT-FIELD.
           05  LINE 19 COLUMN 4 PIC X(72) USING WS-USER-INPUT
               AUTO.
       01  BORDER-BOTTOM.
           05  LINE 21 COLUMN 1 PIC X(78) FROM WS-BORDER-LINE
               FOREGROUND-COLOR 6.
       01  HELP-LINE.
           05  LINE 22 COLUMN 1
               VALUE " /help | /model | /clear | /quit"
               FOREGROUND-COLOR 7.
       01  STATUS-DISPLAY.
           05  LINE 24 COLUMN 1 PIC X(78) FROM WS-STATUS-LINE
               REVERSE-VIDEO.

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           PERFORM INITIALIZE-APPLICATION
           PERFORM MAIN-LOOP UNTIL WS-RUNNING = 0
           PERFORM CLEANUP-APPLICATION
           STOP RUN.

       INITIALIZE-APPLICATION.
           MOVE ALL "-" TO WS-BORDER-LINE
           ACCEPT WS-SCRIPT-DIR FROM ENVIRONMENT "OPENCODE_COBOL_DIR"
           IF WS-SCRIPT-DIR = SPACES
               MOVE "/root/projects/oldcode/cobol" TO WS-SCRIPT-DIR
           END-IF
           PERFORM BUILD-HEADER-LINE
           ACCEPT WS-CURRENT-TIME FROM TIME
           PERFORM BUILD-STATUS-LINE
           MOVE SPACES TO WS-AI-RESPONSE
           MOVE "OpenCode COBOL ready! Copilot SDK connected."
               TO WS-AI-RESPONSE
           MOVE 1 TO WS-AI-ENABLED
           MOVE "SYSTEM" TO WS-LAST-ROLE
           DISPLAY CLEAR-SCREEN
           DISPLAY HEADER-DISPLAY
           DISPLAY BORDER-TOP
           DISPLAY CHAT-LABEL
           DISPLAY BORDER-MID
           DISPLAY INPUT-PROMPT
           DISPLAY BORDER-BOTTOM
           DISPLAY HELP-LINE
           DISPLAY STATUS-DISPLAY
           PERFORM DISPLAY-RESPONSE.

       BUILD-HEADER-LINE.
           MOVE SPACES TO WS-HEADER-LINE
           STRING " OPENCODE " DELIMITED SIZE
                  WS-VERSION DELIMITED SPACE
                  " | " DELIMITED SIZE
                  WS-CURRENT-AGENT DELIMITED SPACE
                  " | Model: " DELIMITED SIZE
                  WS-CURRENT-MODEL DELIMITED SPACE
                  INTO WS-HEADER-LINE
           END-STRING.

       MAIN-LOOP.
           MOVE SPACES TO WS-USER-INPUT
           ACCEPT INPUT-FIELD
           IF WS-USER-INPUT NOT = SPACES
              PERFORM PROCESS-INPUT
           END-IF
           ACCEPT WS-CURRENT-TIME FROM TIME
           PERFORM BUILD-STATUS-LINE
           DISPLAY CLEAR-SCREEN
           DISPLAY HEADER-DISPLAY
           DISPLAY BORDER-TOP
           DISPLAY CHAT-LABEL
           DISPLAY BORDER-MID
           DISPLAY INPUT-PROMPT
           DISPLAY BORDER-BOTTOM
           DISPLAY HELP-LINE
           DISPLAY STATUS-DISPLAY
           PERFORM DISPLAY-RESPONSE.

       BUILD-STATUS-LINE.
           MOVE SPACES TO WS-STATUS-LINE
           IF WS-AI-ENABLED = 1
               STRING " Copilot | " DELIMITED SIZE
                      WS-HOUR DELIMITED SIZE
                      ":" DELIMITED SIZE
                      WS-MINUTE DELIMITED SIZE
                      ":" DELIMITED SIZE
                      WS-SECOND DELIMITED SIZE
                      " | Online" DELIMITED SIZE
                      INTO WS-STATUS-LINE
               END-STRING
           ELSE
               STRING " Copilot | " DELIMITED SIZE
                      WS-HOUR DELIMITED SIZE
                      ":" DELIMITED SIZE
                      WS-MINUTE DELIMITED SIZE
                      ":" DELIMITED SIZE
                      WS-SECOND DELIMITED SIZE
                      " | Use /login" DELIMITED SIZE
                      INTO WS-STATUS-LINE
               END-STRING
           END-IF.

       PROCESS-INPUT.
           EVALUATE TRUE
              WHEN WS-USER-INPUT(1:5) = "/quit"
                 MOVE 0 TO WS-RUNNING
              WHEN WS-USER-INPUT(1:5) = "/exit"
                 MOVE 0 TO WS-RUNNING
              WHEN WS-USER-INPUT(1:5) = "/help"
                 PERFORM SHOW-HELP
              WHEN WS-USER-INPUT(1:6) = "/clear"
                 PERFORM CLEAR-CHAT
              WHEN WS-USER-INPUT(1:6) = "/model"
                 PERFORM SWITCH-MODEL
              WHEN OTHER
                 PERFORM SEND-TO-AI
           END-EVALUATE.

       SEND-TO-AI.
           PERFORM CALL-COPILOT-API.

       CALL-COPILOT-API.
           MOVE "USER" TO WS-LAST-ROLE
           MOVE WS-USER-INPUT TO WS-AI-RESPONSE
           DISPLAY CLEAR-SCREEN
           DISPLAY HEADER-DISPLAY
           DISPLAY BORDER-TOP
           DISPLAY CHAT-LABEL
           DISPLAY BORDER-MID
           DISPLAY INPUT-PROMPT
           DISPLAY BORDER-BOTTOM
           DISPLAY HELP-LINE
           DISPLAY STATUS-DISPLAY
           PERFORM DISPLAY-RESPONSE
           MOVE SPACES TO WS-STATUS-LINE
           STRING " Copilot | Thinking... " DELIMITED SIZE
                  INTO WS-STATUS-LINE
           END-STRING
           DISPLAY STATUS-DISPLAY
           MOVE SPACES TO WS-AI-CMD
           STRING WS-SCRIPT-DIR DELIMITED SPACE
                  "/ai-bridge.sh chat " DELIMITED SIZE
                  WS-CURRENT-MODEL DELIMITED SPACE
                  " '" DELIMITED SIZE
                  WS-USER-INPUT DELIMITED "  "
                  "' > " DELIMITED SIZE
                  WS-RESPONSE-PATH DELIMITED SPACE
                  " 2>&1" DELIMITED SIZE
                  INTO WS-AI-CMD
           END-STRING
           CALL "SYSTEM" USING WS-AI-CMD
           PERFORM READ-AI-RESPONSE.

       READ-AI-RESPONSE.
           MOVE SPACES TO WS-AI-RESPONSE
           MOVE 0 TO WS-RESP-LEN
           OPEN INPUT AI-RESPONSE-FILE
           IF WS-FILE-STATUS = "00"
               PERFORM UNTIL WS-FILE-STATUS NOT = "00"
                   READ AI-RESPONSE-FILE INTO WS-RESP-LINE
                       AT END
                           EXIT PERFORM
                       NOT AT END
                           IF WS-RESP-LEN < 3800
                               IF WS-RESP-LEN > 0
                                   ADD 1 TO WS-RESP-LEN
                                   MOVE " " TO 
                                       WS-AI-RESPONSE(WS-RESP-LEN:1)
                               END-IF
                               MOVE FUNCTION LENGTH(
                                   FUNCTION TRIM(WS-RESP-LINE))
                                   TO WS-J
                               IF WS-J > 0
                                   STRING WS-AI-RESPONSE DELIMITED "  "
                                          WS-RESP-LINE DELIMITED "  "
                                          INTO WS-AI-RESPONSE
                                   END-STRING
                                   ADD WS-J TO WS-RESP-LEN
                               END-IF
                           END-IF
                   END-READ
               END-PERFORM
               CLOSE AI-RESPONSE-FILE
           ELSE
               MOVE "Error: Could not read response" 
                   TO WS-AI-RESPONSE
           END-IF
           MOVE "ASSISTANT" TO WS-LAST-ROLE.

       DISPLAY-RESPONSE.
           MOVE 5 TO WS-ROW
           MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-AI-RESPONSE))
               TO WS-RESP-LEN
           IF WS-RESP-LEN = 0
               EXIT PARAGRAPH
           END-IF
           EVALUATE WS-LAST-ROLE
               WHEN "USER"
                   DISPLAY "You:" LINE 4 COLUMN 2
                       WITH FOREGROUND-COLOR 2 HIGHLIGHT
               WHEN "ASSISTANT"
                   DISPLAY "Copilot:" LINE 4 COLUMN 2
                       WITH FOREGROUND-COLOR 5 HIGHLIGHT
               WHEN "SYSTEM"
                   DISPLAY "System:" LINE 4 COLUMN 2
                       WITH FOREGROUND-COLOR 3 HIGHLIGHT
           END-EVALUATE
           MOVE 1 TO WS-RESP-POS
           MOVE 0 TO WS-LINES-USED
           PERFORM UNTIL WS-RESP-POS > WS-RESP-LEN 
                      OR WS-LINES-USED >= WS-MAX-LINES
               MOVE SPACES TO WS-CHUNK
               IF WS-RESP-POS + WS-LINE-LEN - 1 <= WS-RESP-LEN
                   MOVE WS-AI-RESPONSE(WS-RESP-POS:WS-LINE-LEN)
                       TO WS-CHUNK
               ELSE
                   MOVE WS-AI-RESPONSE(WS-RESP-POS:) TO WS-CHUNK
               END-IF
               DISPLAY WS-CHUNK LINE WS-ROW COLUMN 3
               ADD 1 TO WS-ROW
               ADD 1 TO WS-LINES-USED
               ADD WS-LINE-LEN TO WS-RESP-POS
           END-PERFORM.

       SHOW-HELP.
           MOVE "SYSTEM" TO WS-LAST-ROLE
           MOVE "Commands: /help /model /clear /quit"
              TO WS-AI-RESPONSE.

       CLEAR-CHAT.
           MOVE SPACES TO WS-AI-CMD
           STRING WS-SCRIPT-DIR DELIMITED SPACE
                  "/ai-bridge.sh clear > /dev/null 2>&1" DELIMITED SIZE
                  INTO WS-AI-CMD
           END-STRING
           CALL "SYSTEM" USING WS-AI-CMD
           MOVE "SYSTEM" TO WS-LAST-ROLE
           MOVE "Chat history cleared." TO WS-AI-RESPONSE.

       SWITCH-MODEL.
           IF WS-CURRENT-MODEL = "gpt-5"
               MOVE "gpt-5-mini" TO WS-CURRENT-MODEL
           ELSE IF WS-CURRENT-MODEL = "gpt-5-mini"
               MOVE "claude-sonnet-4.5" TO WS-CURRENT-MODEL
           ELSE
               MOVE "gpt-5" TO WS-CURRENT-MODEL
           END-IF
           END-IF
           PERFORM BUILD-HEADER-LINE
           MOVE "SYSTEM" TO WS-LAST-ROLE
           MOVE SPACES TO WS-AI-RESPONSE
           STRING "Model switched to: " DELIMITED SIZE
                  WS-CURRENT-MODEL DELIMITED SPACE
                  INTO WS-AI-RESPONSE
           END-STRING.



       CLEANUP-APPLICATION.
           DISPLAY CLEAR-SCREEN
           DISPLAY "Thank you for using OpenCode COBOL Edition!"
              LINE 12 COLUMN 18
           DISPLAY "STOP RUN." LINE 14 COLUMN 35.

       END PROGRAM OPENCODE-TUI.
