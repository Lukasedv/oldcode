       IDENTIFICATION DIVISION.
       PROGRAM-ID. OPENCODE-TUI.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-RUNNING              PIC 9 VALUE 1.
       01  WS-CURRENT-MODE         PIC X(10) VALUE "CHAT".
       01  WS-CURRENT-AGENT        PIC X(10) VALUE "BUILD".
       01  WS-USER-INPUT           PIC X(72) VALUE SPACES.
       01  WS-MESSAGE-COUNT        PIC 99 VALUE 0.
       01  WS-MESSAGES.
           05  WS-MESSAGE OCCURS 10 TIMES.
               10  WS-MSG-ROLE     PIC X(10).
               10  WS-MSG-TEXT     PIC X(60).
       01  WS-HEADER-LINE          PIC X(78).
       01  WS-STATUS-LINE          PIC X(78).
       01  WS-BORDER-LINE          PIC X(78).
       01  WS-DISPLAY-LINE         PIC X(78).
       01  WS-I                    PIC 99 VALUE 0.
       01  WS-ROW                  PIC 99 VALUE 0.
       01  WS-VERSION              PIC X(12) VALUE "0.0.1-COBOL".
       01  WS-CURRENT-TIME.
           05  WS-HOUR             PIC 99.
           05  WS-MINUTE           PIC 99.
           05  WS-SECOND           PIC 99.
           05  FILLER              PIC X(2).
       01  WS-RESPONSE-INDEX       PIC 9 VALUE 1.
       01  WS-TEMP-STR             PIC X(78).

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
           05  LINE 3 COLUMN 2 VALUE "CHAT - Messages:"
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
               VALUE " /help: Commands | /tab: Agent | /clear | /quit"
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
           MOVE SPACES TO WS-HEADER-LINE
           STRING " OPENCODE " DELIMITED SIZE
                  WS-VERSION DELIMITED SPACE
                  " | Agent: " DELIMITED SIZE
                  WS-CURRENT-AGENT DELIMITED SPACE
                  " | Mode: " DELIMITED SIZE
                  WS-CURRENT-MODE DELIMITED SIZE
                  INTO WS-HEADER-LINE
           END-STRING
           ACCEPT WS-CURRENT-TIME FROM TIME
           MOVE SPACES TO WS-STATUS-LINE
           STRING " COBOL Edition | " DELIMITED SIZE
                  WS-HOUR DELIMITED SIZE
                  ":" DELIMITED SIZE
                  WS-MINUTE DELIMITED SIZE
                  ":" DELIMITED SIZE
                  WS-SECOND DELIMITED SIZE
                  " | Ready" DELIMITED SIZE
                  INTO WS-STATUS-LINE
           END-STRING
           MOVE 1 TO WS-MESSAGE-COUNT
           MOVE "SYSTEM" TO WS-MSG-ROLE(1)
           MOVE "Welcome to OpenCode COBOL Edition! Type /help."
               TO WS-MSG-TEXT(1)
           DISPLAY CLEAR-SCREEN
           DISPLAY HEADER-DISPLAY
           DISPLAY BORDER-TOP
           DISPLAY CHAT-LABEL
           DISPLAY BORDER-MID
           DISPLAY INPUT-PROMPT
           DISPLAY BORDER-BOTTOM
           DISPLAY HELP-LINE
           DISPLAY STATUS-DISPLAY
           PERFORM DISPLAY-MESSAGES.

       MAIN-LOOP.
           MOVE SPACES TO WS-USER-INPUT
           ACCEPT INPUT-FIELD
           IF WS-USER-INPUT NOT = SPACES
              PERFORM PROCESS-INPUT
           END-IF
           ACCEPT WS-CURRENT-TIME FROM TIME
           MOVE SPACES TO WS-STATUS-LINE
           STRING " COBOL Edition | " DELIMITED SIZE
                  WS-HOUR DELIMITED SIZE
                  ":" DELIMITED SIZE
                  WS-MINUTE DELIMITED SIZE
                  ":" DELIMITED SIZE
                  WS-SECOND DELIMITED SIZE
                  " | Ready" DELIMITED SIZE
                  INTO WS-STATUS-LINE
           END-STRING
           DISPLAY CLEAR-SCREEN
           DISPLAY HEADER-DISPLAY
           DISPLAY BORDER-TOP
           DISPLAY CHAT-LABEL
           DISPLAY BORDER-MID
           DISPLAY INPUT-PROMPT
           DISPLAY BORDER-BOTTOM
           DISPLAY HELP-LINE
           DISPLAY STATUS-DISPLAY
           PERFORM DISPLAY-MESSAGES.

       PROCESS-INPUT.
           EVALUATE TRUE
              WHEN WS-USER-INPUT(1:5) = "/quit"
                 MOVE 0 TO WS-RUNNING
              WHEN WS-USER-INPUT(1:5) = "/exit"
                 MOVE 0 TO WS-RUNNING
              WHEN WS-USER-INPUT(1:5) = "/help"
                 PERFORM SHOW-HELP
              WHEN WS-USER-INPUT(1:6) = "/clear"
                 PERFORM CLEAR-MESSAGES
              WHEN WS-USER-INPUT(1:4) = "/tab"
                 PERFORM SWITCH-AGENT
              WHEN OTHER
                 PERFORM ADD-USER-MESSAGE
                 PERFORM GENERATE-AI-RESPONSE
           END-EVALUATE.

       ADD-USER-MESSAGE.
           IF WS-MESSAGE-COUNT < 10
              ADD 1 TO WS-MESSAGE-COUNT
           ELSE
              PERFORM SHIFT-MESSAGES
           END-IF
           MOVE "USER" TO WS-MSG-ROLE(WS-MESSAGE-COUNT)
           MOVE WS-USER-INPUT TO WS-MSG-TEXT(WS-MESSAGE-COUNT).

       SHIFT-MESSAGES.
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
              MOVE WS-MSG-ROLE(WS-I + 1) TO WS-MSG-ROLE(WS-I)
              MOVE WS-MSG-TEXT(WS-I + 1) TO WS-MSG-TEXT(WS-I)
           END-PERFORM.

       GENERATE-AI-RESPONSE.
           IF WS-MESSAGE-COUNT < 10
              ADD 1 TO WS-MESSAGE-COUNT
           ELSE
              PERFORM SHIFT-MESSAGES
           END-IF
           MOVE "ASSISTANT" TO WS-MSG-ROLE(WS-MESSAGE-COUNT)
           EVALUATE WS-RESPONSE-INDEX
              WHEN 1
                 MOVE "I am OpenCode COBOL Edition. How can I help?"
                    TO WS-MSG-TEXT(WS-MESSAGE-COUNT)
              WHEN 2
                 MOVE "COBOL: Common Business Oriented Language, 1959!"
                    TO WS-MSG-TEXT(WS-MESSAGE-COUNT)
              WHEN 3
                 MOVE "Processing via legacy mainframe logic..."
                    TO WS-MSG-TEXT(WS-MESSAGE-COUNT)
              WHEN 4
                 MOVE "PERFORM UNTIL END-OF-TASK... Complete!"
                    TO WS-MSG-TEXT(WS-MESSAGE-COUNT)
              WHEN 5
                 MOVE "Did you know? 95% of ATM transactions use COBOL!"
                    TO WS-MSG-TEXT(WS-MESSAGE-COUNT)
           END-EVALUATE
           ADD 1 TO WS-RESPONSE-INDEX
           IF WS-RESPONSE-INDEX > 5
              MOVE 1 TO WS-RESPONSE-INDEX
           END-IF.

       DISPLAY-MESSAGES.
           MOVE 5 TO WS-ROW
           PERFORM VARYING WS-I FROM 1 BY 1
              UNTIL WS-I > WS-MESSAGE-COUNT OR WS-ROW > 16
              MOVE SPACES TO WS-DISPLAY-LINE
              STRING WS-MSG-ROLE(WS-I) DELIMITED SPACE
                     ": " DELIMITED SIZE
                     WS-MSG-TEXT(WS-I) DELIMITED SIZE
                     INTO WS-DISPLAY-LINE
              END-STRING
              DISPLAY WS-DISPLAY-LINE LINE WS-ROW COLUMN 2
              ADD 1 TO WS-ROW
           END-PERFORM.

       SHOW-HELP.
           IF WS-MESSAGE-COUNT < 10
              ADD 1 TO WS-MESSAGE-COUNT
           ELSE
              PERFORM SHIFT-MESSAGES
           END-IF
           MOVE "SYSTEM" TO WS-MSG-ROLE(WS-MESSAGE-COUNT)
           MOVE "Commands: /help /clear /tab /quit - Or type to chat"
              TO WS-MSG-TEXT(WS-MESSAGE-COUNT).

       CLEAR-MESSAGES.
           MOVE 1 TO WS-MESSAGE-COUNT
           MOVE "SYSTEM" TO WS-MSG-ROLE(1)
           MOVE "Chat cleared. Ready for new conversation."
              TO WS-MSG-TEXT(1).

       SWITCH-AGENT.
           IF WS-CURRENT-AGENT = "BUILD"
              MOVE "PLAN" TO WS-CURRENT-AGENT
           ELSE
              MOVE "BUILD" TO WS-CURRENT-AGENT
           END-IF
           MOVE SPACES TO WS-HEADER-LINE
           STRING " OPENCODE " DELIMITED SIZE
                  WS-VERSION DELIMITED SPACE
                  " | Agent: " DELIMITED SIZE
                  WS-CURRENT-AGENT DELIMITED SPACE
                  " | Mode: " DELIMITED SIZE
                  WS-CURRENT-MODE DELIMITED SIZE
                  INTO WS-HEADER-LINE
           END-STRING
           IF WS-MESSAGE-COUNT < 10
              ADD 1 TO WS-MESSAGE-COUNT
           ELSE
              PERFORM SHIFT-MESSAGES
           END-IF
           MOVE "SYSTEM" TO WS-MSG-ROLE(WS-MESSAGE-COUNT)
           MOVE SPACES TO WS-MSG-TEXT(WS-MESSAGE-COUNT)
           STRING "Switched to agent: " DELIMITED SIZE
                  WS-CURRENT-AGENT DELIMITED SIZE
                  INTO WS-MSG-TEXT(WS-MESSAGE-COUNT)
           END-STRING.

       CLEANUP-APPLICATION.
           DISPLAY CLEAR-SCREEN
           DISPLAY "Thank you for using OpenCode COBOL Edition!"
              LINE 12 COLUMN 18
           DISPLAY "STOP RUN." LINE 14 COLUMN 35.

       END PROGRAM OPENCODE-TUI.
