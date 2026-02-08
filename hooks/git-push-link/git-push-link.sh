#!/bin/bash
# Hook: git-push-link.sh
# Event: PostToolUse (Bash, mcp__GitKraken__git_push)
# Purpose: Detect successful git push and output repo link reminder

set -euo pipefail

# Read JSON input from stdin
INPUT=$(cat)

# Extract tool name and cwd
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

# Get the directory from tool input (handles GitKraken)
DIRECTORY=$(echo "$INPUT" | jq -r '.tool_input.directory // empty')

# Function to get repo URL from a directory
get_repo_url() {
    local dir="$1"
    local remote_url=""
    
    if [ -n "$dir" ] && [ -d "$dir" ]; then
        remote_url=$(git -C "$dir" config --get remote.origin.url 2>/dev/null) || true
    fi
    
    if [ -n "$remote_url" ]; then
        # Convert SSH URL to HTTPS if needed
        if echo "$remote_url" | grep -q "^git@"; then
            echo "$remote_url" | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//'
        else
            echo "$remote_url" | sed 's/\.git$//'
        fi
    fi
}

# Function to extract directory from bash command
extract_dir_from_command() {
    local cmd="$1"
    local fallback="$2"
    
    # Try to extract directory from "cd /path && ..." pattern
    # Use [^&;]* to match path until && or ; 
    # Note: Use * not \+ for POSIX sed compatibility
    local cd_dir=""
    cd_dir=$(echo "$cmd" | sed -n 's/.*cd[[:space:]]*\([^&;]*\).*/\1/p' | head -1 | xargs 2>/dev/null) || true
    
    if [ -n "$cd_dir" ] && [ -d "$cd_dir" ]; then
        echo "$cd_dir"
    elif [ -n "$fallback" ] && [ -d "$fallback" ]; then
        echo "$fallback"
    fi
}

# Handle GitKraken git_push tool
if [ "$TOOL_NAME" = "mcp__GitKraken__git_push" ]; then
    REPO_URL=$(get_repo_url "$DIRECTORY")
    if [ -n "$REPO_URL" ]; then
        echo "{\"decision\": \"approve\", \"continue\": true, \"reason\": \"Git push successful. **Repository:** $REPO_URL\"}"
        exit 0
    fi
fi

# Handle Bash tool with git push command
if [ "$TOOL_NAME" = "Bash" ]; then
    COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
    TOOL_RESPONSE=$(echo "$INPUT" | jq -r '.tool_response // empty')
    
    # Check if this was a git push command
    if echo "$COMMAND" | grep -qE 'git[[:space:]]+push'; then
        # Check if push was successful (no error indicators)
        if ! echo "$TOOL_RESPONSE" | grep -qiE '(error|fatal|rejected|failed)'; then
            # Extract directory from command or fall back to cwd
            PUSH_DIR=$(extract_dir_from_command "$COMMAND" "$CWD")
            REPO_URL=$(get_repo_url "$PUSH_DIR")
            
            if [ -n "$REPO_URL" ]; then
                echo "{\"decision\": \"approve\", \"continue\": true, \"reason\": \"Git push successful. **Repository:** $REPO_URL\"}"
                exit 0
            fi
        fi
    fi
fi

# Default: approve and continue
echo '{"decision": "approve", "continue": true}'
exit 0
