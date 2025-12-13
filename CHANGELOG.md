# Changelog

All notable changes to Cortex Code CLI Extensions will be documented in this file.

## [Unreleased]

### Agents Coming Soon
- spcs-deployment-expert - SPCS deployment and troubleshooting

## [1.0.0] - 2025-12-13

### Added
- Initial release with 4 production-ready skills
- Complete documentation for all skills (README.md per skill)
- Repository structure for skills and agents
- GitLab compliance (repo_meta.yaml, .gitignore)

### Skills
- **code-quality-check v2.0**
  - Security scanning (secrets detection)
  - Linting (ESLint, Ruff, Clippy, golangci-lint)
  - Type checking (TypeScript, mypy)
  - Test execution with failure detection
  - Build verification
  - Auto-fix mode with interactive confirmation
  - Metrics tracking with trend analysis
  - 7-level quality gate system
  - Configuration via `.cortex/code-quality-config.json`
  - Support for TypeScript, Python, Rust, Go
  - 100% test coverage validated

- **snowflake-diagnostics v1.0**
  - 6-step diagnostic workflow
  - Connection verification
  - Role & privilege analysis
  - Warehouse status checks
  - Database/schema context validation
  - Object accessibility testing

- **snowflake-performance-analysis v1.0**
  - Query profile analysis
  - Memory spilling detection
  - Partition pruning optimization
  - Cache hit rate monitoring
  - Warehouse sizing recommendations
  - Cost optimization analysis

- **multi-env-deployment v1.0**
  - Multi-environment deployment (dev/staging/prod)
  - Support for Streamlit, SPCS, UDFs, tables
  - Pre-deployment validation
  - Post-deployment testing
  - Rollback procedures
