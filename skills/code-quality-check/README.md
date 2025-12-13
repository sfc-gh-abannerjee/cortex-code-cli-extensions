# code-quality-check

Comprehensive code quality gate for TypeScript, Python, Rust, and Go projects.

## Overview

This skill performs pre-commit validation to ensure code meets quality standards before opening pull requests or committing changes. It runs security checks, linting, type checking, tests, and builds in a single workflow.

## Features

### Core Checks
- **🔒 Security**: Scans git staging area for secrets/credentials (`.env`, credentials files)
- **🎨 Linting**: ESLint, Ruff, Clippy, golangci-lint
- **🔍 Type Checking**: TypeScript, mypy
- **✅ Testing**: Detects test failures across frameworks (Jest, pytest, cargo test, go test)
- **🏗️ Build**: Validates production builds complete successfully

### Advanced Features
- **🤖 Auto-Fix Mode**: Automatically applies safe fixes for linting/formatting issues
- **📊 Metrics Tracking**: Records quality trends over time with visual indicators (↑ ↓ →)
- **⚙️ Configuration**: Customize behavior via `.cortex/code-quality-config.json`
- **🚦 Quality Gates**: 7-level verdict system (READY → NEEDS_ATTENTION → BLOCKED)

## Installation

```bash
# Copy to Cortex Code skills directory
mkdir -p ~/.snowflake/cortex/skills
cp -r skills/code-quality-check ~/.snowflake/cortex/skills/

# Verify
ls ~/.snowflake/cortex/skills/code-quality-check/SKILL.md
```

## Usage

### Basic Invocation

```bash
cortex
> /skill code-quality-check
# or
> Run code quality checks
```

### With Auto-Fix

```bash
cortex
> Run code quality checks and fix issues
# or
> Run quality checks in auto-fix mode
```

### In CI/CD

The skill can be invoked programmatically via Cortex Code CLI:

```bash
# In GitHub Actions, GitLab CI, etc.
cortex chat --message "Run code quality checks" --skill code-quality-check
```

## Configuration

### Optional: Create Configuration File

```bash
mkdir -p .cortex
cat > .cortex/code-quality-config.json <<'JSON'
{
  "auto_fix": {
    "enabled": true,
    "allow": ["linting", "formatting"],
    "deny": ["dependencies", "security", "tests"]
  },
  "metrics": {
    "enabled": true,
    "history_limit": 30
  },
  "quality_gates": {
    "block_on_security": true,
    "block_on_build_failure": true,
    "block_on_test_failures": true,
    "block_on_type_errors": true,
    "block_on_linting_errors": true,
    "allow_warnings": true
  }
}
JSON

# Commit to git (shared team settings)
git add .cortex/code-quality-config.json
git commit -m "Add code quality configuration"
```

### Git Setup

Add metrics file to `.gitignore` (personal, not shared):

```bash
echo ".cortex/quality-history.json" >> .gitignore
git add .gitignore
git commit -m "Ignore personal quality metrics"
```

## Output Format

### Standard Report

```
=================================================
           CODE QUALITY REPORT
=================================================

📁 PROJECT TYPE: TypeScript/Next.js

🔍 QUALITY CHECKS:
-------------------

🔒 SECURITY:  ✅ No secrets in staging area

🎨 LINTING:   ⚠️  WARNINGS (0 errors, 3 warnings)
   - Use explicit types instead of 'any' (3 occurrences)

🔍 TYPE CHECK: ✅ 0 errors

✅ TESTS:     ✅ PASSING (24 passing, 0 failing)

🏗️  BUILD:     ✅ SUCCESS

-------------------
📊 METRICS TRENDS (Last 5 runs):
  Linting Errors:   0 → 0 → 0 → 0 → 0  →
  Type Errors:      2 → 1 → 0 → 0 → 0  ↓
  Test Failures:    0 → 0 → 0 → 0 → 0  →
  
VERDICT: ⚠️  NEEDS ATTENTION (warnings present)

💡 Recommendation: Address linting warnings before PR
=================================================
```

### With Auto-Fix Applied

```
🤖 AUTO-FIX MODE ENABLED

Applying fixes...
  ✓ Fixed 12 ESLint issues (formatting)
  ✓ Fixed 3 Ruff issues (unused imports)
  
Re-running checks...

[Updated report showing fixes]

VERDICT: ✅ READY (all checks passing)
```

## Quality Gates

The skill uses a 7-level verdict system:

| Priority | Verdict | Trigger | Blocks PR? |
|----------|---------|---------|------------|
| 1 | ❌ BLOCKED (security issues) | Secrets in staging | ✅ Yes |
| 2 | ❌ BLOCKED (build failed) | Build exit code ≠ 0 | ✅ Yes |
| 3 | ❌ BLOCKED (tests failing) | Test exit code ≠ 0 | ✅ Yes |
| 4 | ❌ BLOCKED (type errors) | TypeScript/mypy errors | ✅ Yes |
| 5 | ❌ BLOCKED (linting errors) | ESLint/Ruff errors | ✅ Yes |
| 6 | ⚠️ NEEDS ATTENTION | Warnings only | 🟡 Configurable |
| 7 | ✅ READY | All passing | ❌ No |

**Highest priority verdict wins.** Security issues always block, even if all other checks pass.

## Supported Ecosystems

| Language/Framework | Linting | Type Check | Tests | Build |
|-------------------|---------|------------|-------|-------|
| **TypeScript/Next.js** | ESLint | tsc | Jest/Vitest | npm run build |
| **Python** | Ruff | mypy | pytest | N/A |
| **Rust** | Clippy | rustc | cargo test | cargo build |
| **Go** | golangci-lint | go vet | go test | go build |

## Auto-Fix Capabilities

### What Gets Auto-Fixed

**ESLint:**
- Code formatting (Prettier rules)
- Import sorting
- Unused variable removal
- Quote style consistency

**Ruff:**
- Import sorting (isort)
- Unused imports
- Line length formatting
- Trailing whitespace

**What NEVER Gets Auto-Fixed:**
- Security issues (require manual review)
- Type errors (need human judgment)
- Test failures (need debugging)
- Dependency issues (version conflicts)

### Auto-Fix Confirmation

When auto-fix mode is enabled, the skill will:
1. Show proposed fixes
2. Ask for confirmation (unless `auto_approve: true` in config)
3. Apply fixes
4. Re-run checks to verify fixes worked
5. Report updated metrics

## Metrics Tracking

The skill maintains a history file at `.cortex/quality-history.json`:

```json
{
  "runs": [
    {
      "timestamp": "2025-01-15T10:30:00Z",
      "project_type": "TypeScript/Next.js",
      "security_status": "PASS",
      "linting_errors": 0,
      "linting_warnings": 3,
      "type_errors": 0,
      "tests_passing": 24,
      "tests_failing": 0,
      "build_status": "PASS",
      "verdict": "NEEDS_ATTENTION"
    }
  ]
}
```

**History Management:**
- Keeps last 30 runs (configurable)
- Trend analysis: ↑ (increasing), ↓ (decreasing), → (stable)
- Auto-created on first run
- **Add to .gitignore** (personal metrics)

## Troubleshooting

### Skill Not Detecting My Test Framework

**Solution:** Check that your test command exits with code 0 on success, non-zero on failure.

```bash
# Verify manually
npm test
echo $?  # Should be 0 if passing, 1 if failing
```

### Auto-Fix Not Working

**Possible causes:**
1. Config file has `auto_fix.enabled: false`
2. User prompt didn't include fix keywords ("fix", "apply fixes")
3. Issues are not auto-fixable (security, tests, types)

**Solution:** Enable in config or use explicit prompt:
```
Run quality checks and apply fixes
```

### Build Always Passes Even When It Fails

**Issue:** Build command might suppress errors.

**Solution:** Check your `package.json` or build script doesn't use `|| exit 0` or similar.

### Metrics Not Saving

**Check:**
1. `.cortex/` directory exists
2. Write permissions on directory
3. `metrics.enabled: true` in config

## Examples

### Pre-Commit Hook

```bash
# .git/hooks/pre-commit
#!/bin/bash
cortex chat --message "Run code quality checks" --skill code-quality-check

if [ $? -ne 0 ]; then
  echo "❌ Quality checks failed. Fix issues before committing."
  exit 1
fi
```

### GitHub Actions

```yaml
name: Code Quality

on: [pull_request]

jobs:
  quality-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install Cortex Code
        run: |
          # Install cortex CLI
      - name: Run Quality Checks
        run: |
          cortex chat --message "Run code quality checks" --skill code-quality-check
```

### VS Code Task

```json
{
  "label": "Quality Check",
  "type": "shell",
  "command": "cortex chat --message '/skill code-quality-check'",
  "group": {
    "kind": "test",
    "isDefault": true
  }
}
```

## Best Practices

1. **Run before every PR**: Make it part of your workflow
2. **Commit config, ignore metrics**: Share team settings, keep personal progress private
3. **Fix warnings early**: Don't let them accumulate
4. **Use auto-fix for simple issues**: Save time on formatting/imports
5. **Review metrics trends**: Track improvement over time
6. **Customize for your team**: Adjust quality gates to match standards

## Changelog

### v2.0 (Current)
- ✅ Added auto-fix mode with interactive confirmation
- ✅ Added metrics tracking with trend analysis
- ✅ Added configuration file support
- ✅ Added 7-level quality gate system
- ✅ Improved verdict priority ordering
- ✅ Fixed exit code capture bugs

### v1.0 (Original)
- Basic security, linting, type checking, tests, build
- Single verdict: PASS/FAIL
- No configuration or metrics

## Contributing

Found a bug or want to add support for a new ecosystem? Contributions welcome!

1. Test your changes thoroughly
2. Update this README with new features
3. Add examples for new use cases
4. Submit PR with clear description

## License

[Your license here]
