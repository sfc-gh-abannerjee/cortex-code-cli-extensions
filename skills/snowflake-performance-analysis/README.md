# Snowflake Performance Analysis Skill

Analyze and optimize Snowflake query performance, warehouse sizing, memory spilling, partition pruning, cache hit rates, and cost optimization through detailed profiling and recommendations.

## Features

- **Query Profile Analysis**: Deep dive into query execution metrics
- **Memory Spilling Detection**: Identify undersized warehouses
- **Partition Pruning Analysis**: Optimize clustering keys
- **Cache Hit Rate Monitoring**: Improve data reuse patterns
- **Warehouse Sizing Recommendations**: Right-size compute resources
- **Cost Optimization**: Reduce unnecessary spend
- **Performance Issue Detection**: Automated bottleneck identification

## Installation

### Personal Installation (All Projects)

```bash
# Copy to personal skills directory
cp -r skills/snowflake-performance-analysis ~/.snowflake/cortex/skills/
```

### Project-Level Installation (Team-Shared)

```bash
# Copy to project skills directory
cp -r skills/snowflake-performance-analysis .cortex/skills/
git add .cortex/skills/snowflake-performance-analysis
git commit -m "Add snowflake-performance-analysis skill"
```

### Symlink Method (Developers)

```bash
# Link from personal directory to project
ln -s ~/.snowflake/cortex/skills/snowflake-performance-analysis .cortex/skills/
```

## When to Use

The skill automatically activates when you need:

- Query performance optimization
- Warehouse sizing recommendations
- Performance troubleshooting
- Cost optimization analysis
- Memory spilling investigation
- Cache hit rate improvement

### Example Prompts

```
"Why is this query slow?"
"Optimize my warehouse sizing"
"Analyze query performance"
"Check for memory spilling"
"How can I reduce costs?"
"Improve cache hit rates"
```

## Workflow Steps

### 1. Identify Problem Scope

- **Slow specific query**: Analyze query ID or SQL text
- **General slowness**: Check recent query history patterns
- **Warehouse issues**: Identify which warehouse(s) involved
- **Cost concerns**: Focus on compute spend patterns

### 2. Query Profile Analysis

Deep analysis of query execution:

```sql
SELECT 
    query_id,
    query_text,
    database_name,
    schema_name,
    warehouse_name,
    warehouse_size,
    execution_status,
    total_elapsed_time/1000 as total_elapsed_sec,
    bytes_scanned,
    bytes_spilled_to_local_storage,
    bytes_spilled_to_remote_storage,
    bytes_written,
    partitions_scanned,
    partitions_total,
    percentage_scanned_from_cache,
    rows_produced,
    compilation_time/1000 as compilation_sec,
    execution_time/1000 as execution_sec,
    queued_provisioning_time/1000 as queued_provisioning_sec,
    queued_repair_time/1000 as queued_repair_sec,
    queued_overload_time/1000 as queued_overload_sec
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE query_id = '<query_id>'
ORDER BY start_time DESC
LIMIT 1;
```

**Key Metrics Analyzed**:
- **Spilling**: `bytes_spilled_to_*_storage > 0` = warehouse too small
- **Cache hit rate**: `percentage_scanned_from_cache` (higher is better)
- **Partition pruning**: `partitions_scanned / partitions_total` (lower ratio is better)
- **Queueing**: Any `queued_*_time > 0` = contention issues
- **Data scanned**: `bytes_scanned` = table scan efficiency

### 3. Warehouse Utilization Analysis

Check usage patterns over last 7 days:

```sql
SELECT 
    warehouse_name,
    DATE_TRUNC('hour', start_time) as hour,
    COUNT(*) as query_count,
    AVG(total_elapsed_time)/1000 as avg_elapsed_sec,
    SUM(total_elapsed_time)/1000 as total_elapsed_sec,
    AVG(bytes_scanned) as avg_bytes_scanned,
    SUM(CASE WHEN bytes_spilled_to_local_storage > 0 
             OR bytes_spilled_to_remote_storage > 0 
        THEN 1 ELSE 0 END) as queries_with_spilling,
    AVG(percentage_scanned_from_cache) as avg_cache_hit_rate
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE warehouse_name IS NOT NULL
  AND start_time >= dateadd('days', -7, current_timestamp())
GROUP BY warehouse_name, hour
ORDER BY warehouse_name, hour DESC;
```

**Warehouse Health Indicators**:
- **Spilling frequency**: >5% queries spilling = warehouse too small
- **Queue times**: Consistent queueing = need more warehouses/clusters
- **Cache hit rate**: <50% average = poor cache reuse patterns
- **Utilization gaps**: Long idle periods = review auto-suspend settings

### 4. Table/Schema Performance Analysis

Analyze clustering and pruning efficiency:

```sql
SELECT 
    table_name,
    AVG(partitions_scanned * 100.0 / NULLIF(partitions_total, 0)) as avg_partition_scan_pct,
    COUNT(*) as query_count,
    AVG(total_elapsed_time)/1000 as avg_elapsed_sec
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE partitions_total > 0
  AND database_name = '<database>'
  AND schema_name = '<schema>'
  AND start_time >= dateadd('days', -7, current_timestamp())
GROUP BY table_name
HAVING avg_partition_scan_pct > 10  -- Scanning >10% of partitions
ORDER BY avg_partition_scan_pct DESC;
```

**Look for**:
- Tables with high partition scan percentages = poor clustering
- Large tables without clustering keys
- Frequent full table scans

### 5. Common Performance Issues Detection

#### Issue 1: Memory Spilling
- **Symptom**: `bytes_spilled_to_*_storage > 0`
- **Cause**: Warehouse too small for workload
- **Fix**: Increase warehouse size OR optimize query (reduce joins, aggregations)

#### Issue 2: Poor Partition Pruning
- **Symptom**: High `partitions_scanned / partitions_total` ratio
- **Cause**: Missing or ineffective clustering keys, no WHERE clause on cluster key
- **Fix**: Add clustering key on frequently filtered columns, ensure WHERE clause uses cluster key

#### Issue 3: Low Cache Hit Rate
- **Symptom**: `percentage_scanned_from_cache < 50%`
- **Cause**: Insufficient query pattern repetition, warehouse suspended too quickly
- **Fix**: Increase auto-suspend time, consolidate similar queries, use result caching

#### Issue 4: Queue Delays
- **Symptom**: `queued_overload_time > 0` or `queued_provisioning_time > 0`
- **Cause**: Warehouse under-provisioned for concurrency
- **Fix**: Enable multi-cluster warehouse, increase max_cluster_count

#### Issue 5: Long Compilation Time
- **Symptom**: `compilation_time > execution_time`
- **Cause**: Complex query with many joins/subqueries
- **Fix**: Simplify query, use CTEs, materialize intermediate results

### 6. Warehouse Sizing Recommendations

**When to size UP (larger warehouse)**:
- Consistent memory spilling
- Individual queries taking too long
- Complex analytical queries

**When to scale OUT (multi-cluster)**:
- Queue delays during peak times
- High concurrency workloads
- Many users/applications competing

**When to size DOWN**:
- No spilling, fast query times
- Low utilization (<50% avg)
- Cost optimization opportunity

### 7. Cost Optimization Check

Analyze warehouse credit consumption:

```sql
SELECT 
    warehouse_name,
    SUM(credits_used) as total_credits,
    AVG(credits_used_compute) as avg_compute_credits,
    AVG(credits_used_cloud_services) as avg_cloud_services_credits
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE start_time >= dateadd('days', -30, current_timestamp())
GROUP BY warehouse_name
ORDER BY total_credits DESC;
```

## Output Format

```
🚀 SNOWFLAKE PERFORMANCE ANALYSIS

SCOPE: Query abc123def456
TIMEFRAME: Last 7 days

📊 KEY FINDINGS:

Query Performance:
- Total time: 45.2 sec
- Compilation: 2.1 sec | Execution: 43.1 sec
- Data scanned: 1.2 TB
- Cache hit rate: 23%
- Partition pruning: 450/500 partitions (90%)

⚠️  ISSUES DETECTED:

1. Memory Spilling
   Severity: 🔴 HIGH
   Evidence: 850 MB spilled to remote storage
   Impact: 3x slower query execution, increased costs
   Fix: Increase warehouse from MEDIUM to LARGE

2. Poor Partition Pruning
   Severity: 🟡 MEDIUM
   Evidence: Scanning 90% of partitions (450/500)
   Impact: Unnecessary data scanning, slower queries
   Fix: Add clustering key on DATE_COLUMN, ensure WHERE clause filters on it

3. Low Cache Hit Rate
   Severity: 🟡 MEDIUM
   Evidence: Only 23% cache hit rate
   Impact: Re-scanning same data repeatedly
   Fix: Increase auto-suspend to 300s, consolidate similar queries

💡 RECOMMENDATIONS:

Immediate actions:
1. Increase warehouse size to LARGE - Expected improvement: 65% faster
2. Add clustering key on ORDER_DATE - Expected improvement: 80% fewer partitions scanned

Long-term optimizations:
1. Enable result caching with longer auto-suspend
2. Create materialized view for frequently aggregated data

📈 WAREHOUSE SIZING:
Current: MEDIUM (4 credits/hour)
Recommended: LARGE (8 credits/hour)
Rationale: Consistent memory spilling indicates undersized warehouse for workload complexity

💰 COST IMPACT:
Current spend: $1,200/month
Estimated savings: $300/month (25%)
- Reduced query times = less compute time
- Better caching = fewer repeated scans
```

## Value Proposition

### Before
- Trial-and-error optimization
- Unclear performance bottlenecks
- Over-provisioned or under-provisioned warehouses
- High costs without understanding why

### After
- Data-driven optimization decisions
- Clear identification of bottlenecks
- Right-sized warehouses for workload
- Cost optimization with maintained performance

### Benefits
- **Time Saved**: ~30-60 minutes per optimization session
- **Cost Savings**: Typically 15-30% reduction in compute costs
- **Performance Gains**: 2-5x faster query execution
- **Token Reduction**: ~3000 tokens (structured analysis vs. ad-hoc exploration)

## Best Practices

1. **Baseline First**: Get metrics before suggesting changes
2. **Prioritize Impact**: Focus on slow queries > cost > minor optimizations
3. **Specific SQL**: Provide exact queries for monitoring improvements
4. **Cost vs. Performance**: Consider tradeoffs in recommendations
5. **Feature Awareness**: Check for Query Acceleration, Search Optimization
6. **Use EXPLAIN**: For query-specific analysis
7. **Monitor Changes**: Validate improvements with before/after metrics

## Snowflake Performance Features

### Query Acceleration Service
**Use for**: Highly variable query execution times

### Search Optimization Service
**Use for**: Point lookups and selective filters

### Materialized Views
**Use for**: Repeated expensive aggregations

### Clustering Keys
**Use for**: Large tables with common filter patterns

### Result Caching
**Already automatic**, but verify utilization

### Warehouse Size
**Match to workload complexity**

### Multi-Cluster
**For concurrency needs**

## Common Scenarios

### Scenario 1: Slow Query Investigation

**User Request**: "This query is taking 5 minutes, why?"

**Skill Actions**:
1. Retrieves query profile from QUERY_HISTORY
2. Identifies 2GB memory spilled to remote storage
3. Finds warehouse is SMALL for 500GB data scan
4. Recommends increasing to MEDIUM warehouse
5. Estimates 70% performance improvement

### Scenario 2: Cost Optimization

**User Request**: "Our Snowflake bill is too high"

**Skill Actions**:
1. Analyzes warehouse credit consumption
2. Finds 3 warehouses barely utilized (<30%)
3. Identifies auto-suspend set to 10 minutes (too long for usage pattern)
4. Recommends consolidating warehouses and reducing auto-suspend to 60s
5. Estimates $2,000/month savings

### Scenario 3: Cache Hit Rate Improvement

**User Request**: "Why are my queries slow even though I run them frequently?"

**Skill Actions**:
1. Checks cache hit rates (finds 15% average)
2. Identifies warehouse auto-suspends after 60s
3. Finds query patterns repeat every 5 minutes
4. Recommends increasing auto-suspend to 300s
5. Expects cache hit rate to improve to 80%+

## Troubleshooting

### Insufficient Permissions

Some queries require `IMPORTED PRIVILEGES` on SNOWFLAKE database:

```sql
USE ROLE ACCOUNTADMIN;
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE TO ROLE <your_role>;
```

### Query History Lag

ACCOUNT_USAGE views have latency (45 min - 3 hours). For real-time analysis:

```sql
-- Use INFORMATION_SCHEMA instead
SELECT * FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE query_id = '<query_id>';
```

### Large Result Sets

For accounts with high query volume, add filters:

```sql
-- Filter by time range
WHERE start_time >= dateadd('hours', -1, current_timestamp())

-- Filter by warehouse
AND warehouse_name = '<specific_warehouse>'
```

## Related Skills

- **snowflake-diagnostics**: For connection and permission troubleshooting
- **code-quality-check**: For SQL query syntax validation

## Support & Feedback

For issues or suggestions, contact your Snowflake Solutions Engineer or file an issue in the repository.
