# git-push-link

**Automatically displays repository URLs after successful `git push` commands.**

This PostToolUse hook detects successful git push operations and surfaces the repository URL in the Cortex Code response, making it easy to share links with teammates or verify pushes.

---

## Features

- Detects `git push` commands (including `--force-with-lease`, `-u`, etc.)
- Works with both Bash tool and GitKraken MCP `git_push` tool
- Extracts directory from `cd /path && git push` patterns
- Falls back to session working directory (`cwd`) when needed
- Converts SSH URLs to HTTPS for clickable links
- Suppresses URL on failed/rejected pushes (error detection)
- Graceful handling of missing fields and edge cases

---

## Example Output

After a successful push, you'll see:

```
Git push successful. **Repository:** https://github.com/your-org/your-repo
```

---

## Installation

### Prerequisites

- [Cortex Code CLI](https://docs.snowflake.com/user-guide/snowflake-cortex/cortex-code) installed
- `jq` installed (for JSON parsing)
  ```bash
  # macOS
  brew install jq
  
  # Ubuntu/Debian
  sudo apt-get install jq
  ```

### Step 1: Copy the Hook Script

```bash
# Create hooks directory if it doesn't exist
mkdir -p ~/.snowflake/cortex/hooks

# Copy the hook script
cp hooks/git-push-link/git-push-link.sh ~/.snowflake/cortex/hooks/

# Make it executable
chmod +x ~/.snowflake/cortex/hooks/git-push-link.sh
```

### Step 2: Configure hooks.json

Create or update `~/.snowflake/cortex/hooks.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "/Users/YOUR_USERNAME/.snowflake/cortex/hooks/git-push-link.sh",
            "timeout": 5,
            "enabled": true
          }
        ]
      },
      {
        "matcher": "mcp__GitKraken__git_push",
        "hooks": [
          {
            "type": "command",
            "command": "/Users/YOUR_USERNAME/.snowflake/cortex/hooks/git-push-link.sh",
            "timeout": 5,
            "enabled": true
          }
        ]
      }
    ]
  }
}
```

**Important:** Replace `YOUR_USERNAME` with your actual username, or use the full absolute path to the script.

### Step 3: Verify Installation

```bash
# Test the hook manually
echo '{"tool_name":"Bash","tool_input":{"command":"git push"},"tool_response":"main -> main","cwd":"'$(pwd)'"}' | ~/.snowflake/cortex/hooks/git-push-link.sh
```

Expected output (if in a git repo):
```json
{"decision": "approve", "continue": true, "reason": "Git push successful. **Repository:** https://github.com/..."}
```

---

## How It Works

### Hook Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    PostToolUse Event                         │
├─────────────────────────────────────────────────────────────┤
│  1. Receive JSON input with tool_name, tool_input,          │
│     tool_response, and cwd                                   │
│                                                              │
│  2. Check if tool is Bash or mcp__GitKraken__git_push       │
│                                                              │
│  3. For Bash: Check if command contains "git push"          │
│                                                              │
│  4. Check tool_response for error indicators                │
│     (error, fatal, rejected, failed)                        │
│                                                              │
│  5. Extract directory from:                                  │
│     - GitKraken: tool_input.directory                       │
│     - Bash: "cd /path && ..." pattern, or fallback to cwd   │
│                                                              │
│  6. Get remote URL: git -C <dir> config --get remote.origin │
│                                                              │
│  7. Convert SSH to HTTPS if needed                          │
│                                                              │
│  8. Return JSON with repository URL in reason field         │
└─────────────────────────────────────────────────────────────┘
```

### Input JSON Structure

```json
{
  "tool_name": "Bash",
  "tool_input": {
    "command": "cd /path/to/repo && git push"
  },
  "tool_response": "To https://github.com/org/repo.git\n   abc123..def456  main -> main",
  "cwd": "/current/working/directory",
  "session_id": "...",
  "hook_event_name": "PostToolUse"
}
```

### Output JSON Structure

**On successful push:**
```json
{
  "decision": "approve",
  "continue": true,
  "reason": "Git push successful. **Repository:** https://github.com/org/repo"
}
```

**On non-push or failed push:**
```json
{
  "decision": "approve",
  "continue": true
}
```

---

## Supported Patterns

| Command Pattern | Supported |
|-----------------|-----------|
| `git push` | Yes |
| `git push origin main` | Yes |
| `git push -u origin feature` | Yes |
| `git push --force-with-lease` | Yes |
| `cd /path && git push` | Yes |
| `cd /path && git add . && git commit -m "msg" && git push` | Yes |
| GitKraken MCP `git_push` | Yes |

---

## Error Detection

The hook will **not** display a URL if the push response contains:
- `error`
- `fatal`
- `rejected`
- `failed`

This prevents false positives on failed push attempts.

---

## Troubleshooting

### Hook Not Triggering

1. **Check hooks.json syntax:**
   ```bash
   cat ~/.snowflake/cortex/hooks.json | jq .
   ```

2. **Verify script is executable:**
   ```bash
   ls -la ~/.snowflake/cortex/hooks/git-push-link.sh
   chmod +x ~/.snowflake/cortex/hooks/git-push-link.sh
   ```

3. **Check absolute path in hooks.json** - Relative paths don't work

4. **Restart Cortex Code** - Hooks config is loaded at session start

### URL Not Appearing

1. **Verify you're in a git repository** with a remote:
   ```bash
   git config --get remote.origin.url
   ```

2. **Check for error keywords** in push output that might suppress the URL

3. **Test the hook manually:**
   ```bash
   echo '{"tool_name":"Bash","tool_input":{"command":"git push"},"tool_response":"main -> main","cwd":"'$(pwd)'"}' | ~/.snowflake/cortex/hooks/git-push-link.sh
   ```

### Debug Mode

Enable Cortex Code debug logging:
```bash
SNOVA_DEBUG=true cortex
```

---

## Best Practices Applied

This hook follows Cortex Code hook best practices:

1. **Fast execution** - 5 second timeout, minimal processing
2. **Exit code 0** - Always approves (non-blocking)
3. **Graceful fallbacks** - Handles missing fields without crashing
4. **POSIX compliance** - Uses `[[:space:]]` not `\s`, `*` not `\+`
5. **set -euo pipefail** - Strict error handling with `|| true` guards
6. **Absolute paths** - Required for hook scripts

---

## Contributing

Found a bug or have an improvement? 

1. Test your changes with the test cases in the script
2. Ensure POSIX compliance (works on macOS and Linux)
3. Submit a merge request

---

## Author

**Abhinav Bannerjee** (abhinav.bannerjee@snowflake.com)

---

## License

Apache License 2.0. See [LICENSE](../../LICENSE) for details.
