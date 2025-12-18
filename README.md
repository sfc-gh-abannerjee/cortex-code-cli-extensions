# Cortex Code CLI Extensions

**A curated collection of custom skills and agents that extend [Snowflake Cortex Code CLI](https://docs.snowflake.com/user-guide/snowflake-cortex/cortex-code) capabilities.**

**Author:** Abhinav Bannerjee (abhinav.bannerjee@snowflake.com)  
**Maintained by:** Snowflake Solutions Engineering

---

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://snow.gitlab-dedicated.com/snowflakecorp/SE/sales-engineering/cortex-code-cli-extensions.git
cd cortex-code-cli-extensions

# Install a skill (example: code-quality-check)
mkdir -p ~/.snowflake/cortex/skills
cp -r skills/code-quality-check ~/.snowflake/cortex/skills/

# Verify installation
ls ~/.snowflake/cortex/skills/code-quality-check/SKILL.md

# Use in Cortex Code
cortex
> Run code quality checks before I commit
```

---

## 📦 Available Extensions

### Skills

| Skill | Status | Description |
|-------|--------|-------------|
| **[code-quality-check](./skills/code-quality-check/)** | ✅ Available | Comprehensive pre-commit validation with auto-fix, metrics tracking, and 7-level quality gates for TypeScript, Python, Rust, and Go |
| **[snowflake-diagnostics](./skills/snowflake-diagnostics/)** | ✅ Available | Diagnose and troubleshoot Snowflake connection issues, permissions, warehouse status, and object accessibility |
| **[snowflake-performance-analysis](./skills/snowflake-performance-analysis/)** | ✅ Available | Analyze query performance, warehouse sizing, memory spilling, partition pruning, and cost optimization |
| **[multi-env-deployment](./skills/multi-env-deployment/)** | ✅ Available | Safely deploy Snowflake artifacts (Streamlit, SPCS, UDFs, tables) across dev/staging/prod environments |

### Agents

| Agent | Status | Description |
|-------|--------|-------------|
| **spcs-deployment-expert** | 🚧 Coming Soon | Expert agent for Snowpark Container Services deployment and troubleshooting |

---

## 📚 Documentation

- **[Comprehensive Guide (Google Doc)](https://docs.google.com/document/d/1-g_vJSC8XOcANfd8Dww6hr00C01Bg-9697LCzL1tV1I/edit?usp=sharing)** - Complete reference covering:
  - Skill creation best practices and design patterns
  - Installation methods (personal vs. project-level)
  - Troubleshooting common issues
  - When to create skills vs. agents
  - Advanced topics (progressive loading, explicit registration)

- **Individual Skill Documentation** - Each skill directory contains:
  - `README.md` - User-facing documentation with examples, installation, and usage
  - `SKILL.md` - The actual skill definition file for Cortex Code CLI
  - Configuration examples and templates (where applicable)

---

## 🎯 Featured Skills

### code-quality-check
**Pre-commit quality gate for TypeScript, Python, Rust, and Go projects**

- 🔒 **Security scanning** - Detects secrets in staging area
- 🎨 **Linting** - ESLint, Ruff, Clippy, golangci-lint
- 🔍 **Type checking** - TypeScript, mypy
- ✅ **Test execution** - Detects failures across frameworks
- 🏗️ **Build verification** - Validates production builds
- 🤖 **Auto-fix mode** - Automatically applies safe fixes
- 📊 **Metrics tracking** - Trend analysis with history

**[Full Documentation →](./skills/code-quality-check/README.md)**

### snowflake-diagnostics
**6-step troubleshooting workflow for Snowflake infrastructure**

- Connection verification and authentication testing
- Role & privilege analysis with SHOW commands
- Warehouse status checks and configuration validation
- Database/schema context verification
- Object accessibility testing with grants analysis

**[Full Documentation →](./skills/snowflake-diagnostics/README.md)**

### snowflake-performance-analysis
**Query profiling and warehouse optimization**

- Memory spilling detection and warehouse sizing recommendations
- Partition pruning analysis and clustering key optimization
- Cache hit rate monitoring and improvement strategies
- Cost optimization with credit consumption analysis
- Query profile analysis with ACCOUNT_USAGE metrics

**[Full Documentation →](./skills/snowflake-performance-analysis/README.md)**

### multi-env-deployment
**Safe deployments across dev/staging/prod**

- Artifact detection (Streamlit, SPCS, UDFs, tables)
- Environment-specific configuration management
- Pre-deployment validation and security checks
- Post-deployment testing and smoke tests
- Rollback procedures and deployment reporting

**[Full Documentation →](./skills/multi-env-deployment/README.md)**

---

## 🛠️ Installation

### Prerequisites
- [Cortex Code CLI](https://docs.snowflake.com/user-guide/snowflake-cortex/cortex-code) installed
- Git (for cloning)

### Installation Methods

**Method 1: Personal Installation (All Projects)**
```bash
# Install to personal Cortex Code directory
mkdir -p ~/.snowflake/cortex/skills
cp -r skills/<skill-name> ~/.snowflake/cortex/skills/
```

**Method 2: Project-Level Installation (Team Shared)**
```bash
# Install to project directory
mkdir -p .cortex/skills
cp -r skills/<skill-name> .cortex/skills/
git add .cortex/skills/
git commit -m "Add <skill-name> for team"
```

**Method 3: Symlink for Development**
```bash
# Link for easier updates during development
ln -s $(pwd)/skills/<skill-name> ~/.snowflake/cortex/skills/<skill-name>
```

**See [Comprehensive Guide (Google Doc)](https://docs.google.com/document/d/1-g_vJSC8XOcANfd8Dww6hr00C01Bg-9697LCzL1tV1I/edit?usp=sharing) for detailed installation instructions and priority order.**

---

## 🧩 Creating Your Own Extensions

Want to create a custom skill or agent? See [Comprehensive Guide (Google Doc)](https://docs.google.com/document/d/1-g_vJSC8XOcANfd8Dww6hr00C01Bg-9697LCzL1tV1I/edit?usp=sharing) for:

- **Skill creation best practices**
- **When to create a skill vs. agent**
- **SKILL.md template and structure**
- **Workflow design patterns**
- **Testing and debugging techniques**

### Quick Template

```markdown
# my-skill

Brief description of what this skill does.

## When to Invoke

Use this skill when:
- [Trigger condition 1]
- [Trigger condition 2]

## Workflow

1. **Step 1**: What to do first
2. **Step 2**: What to do next
3. **Step 3**: Final output

## Output Format

```
[Example output]
```
```

---

## 🤝 Contributing

We welcome contributions! Here's how to add a new skill or agent:

### Adding a New Skill

1. **Create skill directory**
   ```bash
   mkdir -p skills/your-skill-name
   ```

2. **Add required files**
   - `SKILL.md` - The skill definition
   - `README.md` - User documentation
   - Configuration examples (if applicable)

3. **Test thoroughly**
   - Install in your Cortex Code environment
   - Validate behavior with real use cases
   - Document edge cases

4. **Submit changes**
   ```bash
   git add skills/your-skill-name
   git commit -m "Add your-skill-name skill"
   git push
   ```

5. **Update catalog** - Add your skill to the table in this README

### Quality Standards

- ✅ Clear trigger conditions in skill description
- ✅ Step-by-step workflow documentation
- ✅ Example outputs and error handling
- ✅ Configuration examples where applicable
- ✅ Tested in real projects

---

## 🐛 Troubleshooting

### Skill Not Loading

**Check installation location:**
```bash
ls ~/.snowflake/cortex/skills/<skill-name>/SKILL.md
# or
ls .cortex/skills/<skill-name>/SKILL.md
```

**Verify file naming:**
- File must be named exactly `SKILL.md` (case-sensitive)
- No extra extensions (not `SKILL.md.txt`)

**Test skill invocation:**
```bash
cortex
> /skill <skill-name>
```

**See [Comprehensive Guide (Google Doc)](https://docs.google.com/document/d/1-g_vJSC8XOcANfd8Dww6hr00C01Bg-9697LCzL1tV1I/edit?usp=sharing) for detailed debugging steps.**

---

## 📖 Resources

- [Cortex Code Documentation](https://docs.snowflake.com/user-guide/snowflake-cortex/cortex-code)
- [Cortex Code Skills Guide](https://docs.snowflake.com/user-guide/snowflake-cortex/cortex-code/skills)
- [Comprehensive Guide (Google Doc)](https://docs.google.com/document/d/1-g_vJSC8XOcANfd8Dww6hr00C01Bg-9697LCzL1tV1I/edit?usp=sharing) - Full reference documentation

---

## 📧 Support

**Questions or issues?**
- Slack: @abhinav.bannerjee
- Email: abhinav.bannerjee@snowflake.com
- GitLab: Open an issue in this repository

---

## 📝 License

Internal use within Snowflake. See your employment agreement for details.

---

**Happy coding! 🚀**

*Built with ❤️ by Snowflake Sales Engineering*
