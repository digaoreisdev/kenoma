# Kenoma - Regras Globais de Comportamento do Workspace

## Autonomous Task Execution
* When a "TASK ORDER" is provided, execute the entire lifecycle autonomously: code changes, headless test verification, git commit, and git push.
* Do NOT stop to ask for authorization or approval before executing steps or pushing commits to remote.
* If tests fail, diagnose and fix them autonomously until they pass.
* Only ask questions if there is a blocking technical conflict or ambiguity that cannot be resolved programmatically.
* Always respond strictly using the 4-line protocol established in `Engines.md` v0.25:
  STATUS: PASS / FAIL
  FILES: [comma-separated list of modified/created files]
  ACTIONS: [1 to 2 technical sentences in English summarizing the code changes]
  COMO TESTAR: [1 to 2 direct sentences in PT-BR explaining the exact key to press or scene to run]

