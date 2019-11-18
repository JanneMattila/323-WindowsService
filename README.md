# 323-WindowsService

Sample files shared at the architect day(s) 19th-20th of November

## KQL

Here are some sample KQL queries used in demos:

**Note**: `Perf` will be moved to `InsightsMetrics` 
[soon](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/vminsights-ga-release-faq#how-will-this-change-affect-my-alert-rules).

```sql
Perf
| where ObjectName == "Process" and
        CounterName == "% Processor Time" and
        Computer == "vmname" and
        InstanceName == "CalcService"
```

```sql
Perf
| where TimeGenerated >= ago(3h) and
        ObjectName == "Process" and
        CounterName == "% Processor Time" and
        Computer == "vmname" and
        InstanceName == "CalcService"
| summarize max(CounterValue) by bin(TimeGenerated, 1m), Computer
| render barchart kind=unstacked
```


```sql
AzureMetrics 
| where ResourceGroup =~ "db-prod-rg" and
        Resource =~ "db" and 
        MetricName =~ "dtu_consumption_percent"
```
