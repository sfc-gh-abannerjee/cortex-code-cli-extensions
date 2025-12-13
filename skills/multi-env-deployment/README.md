# Multi-Environment Deployment Skill

Safely deploy Snowflake artifacts (Streamlit apps, SPCS services, UDFs, tables) across multiple environments (dev, staging, prod) with validation, testing, and rollback procedures.

## Features

- **Multi-Environment Support**: Deploy across dev, staging, prod
- **Artifact Type Detection**: Auto-detect Streamlit, SPCS, UDFs, tables
- **Pre-Deployment Validation**: Security checks, dependency verification
- **Environment-Specific Config**: Manage configs per environment
- **Post-Deployment Testing**: Automated smoke tests
- **Rollback Procedures**: Safe rollback on failures
- **Structured Reporting**: Track what was deployed where

## Installation

### Personal Installation (All Projects)

```bash
# Copy to personal skills directory
cp -r skills/multi-env-deployment ~/.snowflake/cortex/skills/
```

### Project-Level Installation (Team-Shared)

```bash
# Copy to project skills directory
cp -r skills/multi-env-deployment .cortex/skills/
git add .cortex/skills/multi-env-deployment
git commit -m "Add multi-env-deployment skill"
```

### Symlink Method (Developers)

```bash
# Link from personal directory to project
ln -s ~/.snowflake/cortex/skills/multi-env-deployment .cortex/skills/
```

## When to Use

The skill automatically activates when you need:

- Deploy across multiple environments
- Promote artifacts from dev to staging to prod
- Manage environment-specific configurations
- Safely deploy with validation and rollback

### Example Prompts

```
"Deploy to prod"
"Promote to staging"
"Multi-environment deployment"
"Deploy across accounts"
"Deploy this Streamlit app to dev and staging"
```

## Workflow Steps

### 1. Environment Discovery & Validation

Identify and validate target environments:

```bash
# List available connections
snowflake_connections_list
```

**Common environment patterns**:
- **Same account, different databases**: `DEV_DB`, `STAGING_DB`, `PROD_DB`
- **Different accounts**: Separate Snowflake connections per environment
- **Hybrid**: Different accounts for prod, shared account for dev/staging

**Validation checks**:
- Connection access for each environment
- User has necessary privileges
- Target databases/schemas exist

### 2. Artifact Type Detection

Automatically identifies what's being deployed:

#### Streamlit Apps
- **Files**: `streamlit_app.py`, `environment.yml`, `requirements.txt`
- **Deployment**: Upload to stage → CREATE STREAMLIT
- **Testing**: Run locally first, then in each environment

#### SPCS Services
- **Files**: `spec.yaml`, Dockerfile, application code
- **Deployment**: Build image → push to registry → CREATE SERVICE
- **Testing**: Verify service endpoints, check logs

#### UDFs/Procedures
- **Files**: `.sql` files or Python/Java handlers
- **Deployment**: Execute CREATE FUNCTION/PROCEDURE DDL
- **Testing**: Run test queries in each environment

#### Generic Artifacts
- **Files**: Any files to upload to stages
- **Deployment**: PUT files to stage
- **Testing**: Verify file accessibility

#### Other Objects
- **Tables, views, schemas, roles, grants**
- **Deployment**: Execute DDL statements
- **Testing**: Verify object existence and accessibility

### 3. Pre-Deployment Checks

For each environment:

```sql
-- Verify target database/schema exists
SHOW DATABASES LIKE '<target_db>';
SHOW SCHEMAS LIKE '<target_schema>' IN DATABASE <target_db>;

-- Check warehouse availability
SHOW WAREHOUSES;

-- Verify current role has necessary privileges
SHOW GRANTS TO ROLE <current_role>;
```

**Security checks**:
- ✓ No secrets/credentials in code
- ✓ Environment-specific configs externalized
- ✓ Proper grants/roles defined

**Dependency checks**:
- ✓ Required stages exist
- ✓ Required tables/views available
- ✓ External dependencies accessible

### 4. Environment-Specific Configuration

Three configuration patterns supported:

#### Pattern 1: Config Files Per Environment
```
config/
├── dev.yaml
├── staging.yaml
└── prod.yaml
```

#### Pattern 2: Environment Variables
```python
import os
SNOWFLAKE_ENV = os.getenv('SNOWFLAKE_ENV', 'dev')
DB_NAME = f"{SNOWFLAKE_ENV.upper()}_DB"
```

#### Pattern 3: Parameterized SQL
```sql
-- Use variables for environment-specific values
SET db_name = 'DEV_DB';
USE DATABASE IDENTIFIER($db_name);
```

### 5. Deployment Execution

#### Streamlit App Deployment

```bash
# For each environment connection
snow streamlit deploy \
  --connection <env_connection> \
  --database <db> \
  --schema <schema> \
  --replace \
  <app_name>
```

Or using SQL:
```sql
CREATE OR REPLACE STREAMLIT <app_name>
  ROOT_LOCATION = '@<stage>/<path>'
  MAIN_FILE = 'streamlit_app.py'
  QUERY_WAREHOUSE = <warehouse>;
```

#### SPCS Service Deployment

```bash
# Build and push image
docker build -t <image> .
docker tag <image> <registry>/<image>:<env>
docker push <registry>/<image>:<env>

# Deploy service
snow service create <service_name> \
  --connection <env_connection> \
  --compute-pool <pool> \
  --spec-path spec.yaml \
  --min-instances 1 \
  --max-instances 3
```

#### UDF/Procedure Deployment

```sql
-- Switch to target environment
USE ROLE <role>;
USE WAREHOUSE <warehouse>;
USE DATABASE <database>;
USE SCHEMA <schema>;

-- Deploy function
CREATE OR REPLACE FUNCTION <name>(<params>)
  RETURNS <type>
  LANGUAGE PYTHON
  RUNTIME_VERSION = '3.9'
  HANDLER = '<handler>'
  PACKAGES = (<packages>)
AS
$$
<code>
$$;
```

### 6. Post-Deployment Testing

#### Streamlit Apps
- Access app URL: `https://<account>.snowflakecomputing.com/streamlit/<app>`
- Verify UI loads
- Test key user flows
- Check data connectivity

#### SPCS Services
```sql
-- Check service status
SHOW SERVICES LIKE '<service_name>';

-- Verify service is RUNNING
DESC SERVICE <service_name>;

-- Check logs
CALL SYSTEM$GET_SERVICE_LOGS('<service_name>', 0, '<container>', 50);

-- Test endpoints
SELECT SYSTEM$SEND_REQUEST('<service_endpoint>', 'GET', {});
```

#### UDFs/Procedures
```sql
-- Test function
SELECT <function_name>(<test_inputs>);

-- Verify output
-- Check performance
SHOW FUNCTIONS LIKE '<function_name>';
```

### 7. Rollback Procedures

If deployment fails:

#### For Streamlit
```sql
-- Restore previous version
CREATE OR REPLACE STREAMLIT <app_name>
  FROM '@<stage>/<previous_version>';
```

#### For SPCS
```sql
-- Roll back to previous spec
ALTER SERVICE <service_name>
  FROM SPECIFICATION_FILE = '@<stage>/<previous_spec.yaml>';
```

#### For UDFs
```sql
-- Restore from backup
-- (Keep versioned copies in stage)
CREATE OR REPLACE FUNCTION <name>
AS '<previous_version>';
```

### 8. Deployment Validation Report

Track what was deployed where:

```
Artifact: sales_dashboard
Type: Streamlit
Version: v1.2.0 (commit: abc123)

Environments:
✅ DEV     - dev_connection - DEV_DB.PUBLIC.SALES_DASHBOARD
✅ STAGING - staging_connection - STAGING_DB.PUBLIC.SALES_DASHBOARD
✅ PROD    - prod_connection - PROD_DB.PUBLIC.SALES_DASHBOARD

Test Results: PASS
Rollback Plan: Restore from @stage/sales_dashboard_v1.1.0
```

## Output Format

```
🚀 MULTI-ENVIRONMENT DEPLOYMENT

ARTIFACT: sales_dashboard
TYPE: Streamlit App
VERSION: v1.2.0

📋 ENVIRONMENTS:
- DEV: dev_connection → DEV_DB.PUBLIC
- STAGING: staging_connection → STAGING_DB.PUBLIC  
- PROD: prod_connection → PROD_DB.PUBLIC

✅ PRE-DEPLOYMENT CHECKS:
[✓] Connections validated
[✓] No secrets in code
[✓] Dependencies available
[✓] Privileges verified

🔄 DEPLOYMENT SEQUENCE:

1. DEV Environment
   Status: ✅ SUCCESS
   Location: DEV_DB.PUBLIC.SALES_DASHBOARD
   Tests: ✅ PASSED
   URL: https://abc123.snowflakecomputing.com/streamlit/dev/sales_dashboard
   
2. STAGING Environment
   Status: ✅ SUCCESS
   Location: STAGING_DB.PUBLIC.SALES_DASHBOARD
   Tests: ✅ PASSED
   URL: https://abc123.snowflakecomputing.com/streamlit/staging/sales_dashboard

3. PROD Environment  
   Status: ✅ SUCCESS
   Location: PROD_DB.PUBLIC.SALES_DASHBOARD
   Tests: ✅ PASSED
   URL: https://abc123.snowflakecomputing.com/streamlit/prod/sales_dashboard

📝 DEPLOYMENT DETAILS:
- Command: snow streamlit deploy --connection <conn> --replace
- Configuration: Environment-specific YAML configs
- Dependencies: pandas 2.0.0, snowflake-snowpark-python 1.11.0

🔗 ACCESS URLS:
- DEV: https://abc123.snowflakecomputing.com/streamlit/dev/sales_dashboard
- STAGING: https://abc123.snowflakecomputing.com/streamlit/staging/sales_dashboard
- PROD: https://abc123.snowflakecomputing.com/streamlit/prod/sales_dashboard

⚠️  ROLLBACK PLAN:
If issues detected:
1. Run: CREATE OR REPLACE STREAMLIT sales_dashboard FROM '@stage/sales_dashboard_v1.1.0'
2. Verify with smoke tests
3. Notify stakeholders of rollback

VERDICT: ✅ DEPLOYED
```

## Value Proposition

### Before
- Manual deployments to each environment
- Inconsistent deployment procedures
- Missing validation steps
- Difficult rollbacks
- No audit trail

### After
- Automated multi-environment deployments
- Consistent, repeatable process
- Built-in validation and testing
- Easy rollback procedures
- Complete deployment history

### Benefits
- **Time Saved**: ~20-40 minutes per deployment
- **Risk Reduction**: Pre-deployment checks catch issues early
- **Reliability**: Consistent process reduces errors
- **Auditability**: Complete record of what was deployed where
- **Token Reduction**: ~2500 tokens (structured workflow vs. manual steps)

## Best Practices

1. **Deploy to dev first**: Always validate in dev before promoting
2. **Use consistent naming**: Suffixes like `_DEV`, `_PROD` across environments
3. **Externalize configs**: No hardcoded environment values in code
4. **Version everything**: Use git tags, stage versioning
5. **Test in each environment**: Don't assume staging = prod
6. **Automate testing**: Write smoke tests for each deployment
7. **Document rollback**: Know how to undo before deploying
8. **Use separate connections**: Never deploy to prod from dev connection
9. **Monitor post-deployment**: Watch for errors in first hour
10. **Communicate deployments**: Notify stakeholders of prod changes

## Safety Gates

### MUST CHECK before PROD deployment:
- [ ] Successfully deployed to DEV
- [ ] Successfully deployed to STAGING  
- [ ] All tests passing in DEV and STAGING
- [ ] No secrets/credentials exposed
- [ ] Rollback plan documented
- [ ] Stakeholders notified (if required)
- [ ] Off-peak hours (for high-impact changes)

### AUTO-BLOCK PROD deployment if:
- DEV or STAGING deployment failed
- Tests failing in lower environments
- Security scan found issues
- Missing required approvals (if applicable)

## Environment-Specific Considerations

### Streamlit
- Different warehouse sizes per environment
- Feature flags for environment-specific behavior
- Sample data in dev, full data in prod

### SPCS
- Different compute pools per environment
- Different image tags (`:dev`, `:staging`, `:prod`)
- Different min/max instances

### UDFs
- Same code, different data access patterns
- Performance testing in staging before prod
- Consider warehouse size for expensive UDFs

## Common Scenarios

### Scenario 1: Streamlit App Deployment

**User Request**: "Deploy this Streamlit app to all environments"

**Skill Actions**:
1. Identifies Streamlit files (`streamlit_app.py`, `requirements.txt`)
2. Lists available connections (dev, staging, prod)
3. Validates each environment (databases exist, privileges granted)
4. Deploys to DEV → tests → deploys to STAGING → tests → deploys to PROD
5. Provides access URLs for each environment

### Scenario 2: SPCS Service Promotion

**User Request**: "Promote my container service from staging to prod"

**Skill Actions**:
1. Verifies service exists and is healthy in STAGING
2. Checks PROD environment for dependencies
3. Tags container image with `:prod`
4. Pushes image to prod registry
5. Creates service in PROD with prod-specific compute pool
6. Validates service is RUNNING
7. Tests endpoints

### Scenario 3: UDF Rollout with Rollback

**User Request**: "Deploy this new UDF to prod, but I need to be able to roll back easily"

**Skill Actions**:
1. Creates versioned copy of current prod UDF in stage
2. Deploys new UDF to DEV → tests
3. Deploys to STAGING → performance tests
4. Documents rollback SQL command
5. Deploys to PROD
6. Monitors for errors
7. If issues detected, executes rollback procedure

## Troubleshooting

### Connection Issues

Verify all environment connections are configured:

```bash
# List connections
cat ~/.snowflake/config.toml

# Test connection
snow connection test --connection <env_connection>
```

### Permission Errors

Ensure role has necessary privileges in each environment:

```sql
SHOW GRANTS TO ROLE <role>;
-- Should see CREATE privileges on target databases/schemas
```

### Stage Access Issues

Verify stages exist and are accessible:

```sql
SHOW STAGES;
LIST @<stage_name>;
```

## Related Skills

- **snowflake-diagnostics**: For troubleshooting deployment issues
- **code-quality-check**: For pre-deployment code validation

## Support & Feedback

For issues or suggestions, contact your Snowflake Solutions Engineer or file an issue in the repository.
