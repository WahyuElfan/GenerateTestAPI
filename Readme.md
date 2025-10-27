# Generate Postman Script via Gemini API

This Bash script is used to generate automated scripts (Postman test or Node.js `axios`) using the Google Gemini API, based on prompts written in the `prompt.txt` file.


---

## Key Features

**Direct integration with Gemini API** — turn prompts into automated scripts
**Two output modes:**
- Postman (with `pm.test`, `pm.expect`)
- Node.js (with `axios` or `fetch`)
**Automatic script style detection**
**Automatic API key handling** — read from `.profile` or manually input
**Automatic log history** — only saves the last 100 entries
**Automatically move Node.js output to a separate file**
**Compatible:** Linux, macOS, and Git Bash on Windows

---

## Folder Structure

```bash
GenerateTestAPI/
┣ logs
 ┃ ┗ generate_history.log       # History of generated results
 ┣ .profile                     # Saving API KEY
 ┣ generate_postman_script.sh   # Main script
 ┣ postman_script.js            # Main output (Postman)
 ┣ prompt.txt                   # User prompt file
 ┣ raw_response.js              # Results of Gemini
 ┣ raw_response_node.js         # The result is Node.js
 ┗ Readme.md                    # Documentation


1. Install Dependency
- jq
- curl
- bash

2. If jq is missing, install it with:
- Ubuntu/Debian: sudo apt install jq
- Mac: brew install jq
- Windows (Git Bash): choco install jq

3. Check Version
- jq --version
- curl --version

```

---
### How to use

1. Write the prompt in the prompt.txt file
2. Run script 
    - ./generate_postman_script.sh
3. If the prompt doesn't mention script styles, there are options:
    - Select style script:
        1) Postman
        2) Node.js
        3) Lanjut tanpa perubahan
4. Run with the --no-send option for preview mode.
    - ./generate_postman_script.sh --no-send


