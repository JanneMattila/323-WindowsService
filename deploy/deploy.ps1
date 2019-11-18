<#
.SYNOPSIS
Deploy two alerts:
- Log based query alert for monitoring CalcService
- Metric alert for SQL database high DTU usage

.DESCRIPTION
Example ARM template for deploying log based query alert and
metric based query alert together with action group.

.PARAMETER ResourceGroupName
Deployment target resource group.

.PARAMETER Location
Deployment target resource group location.

.PARAMETER WorkspaceResourceId
Log Analytics Workspace resource id.

.PARAMETER DatabaseResourceId
SQL Database resource id.

.PARAMETER AlertEmailAddress
Alert email address.

.NOTES
Here's example how you can retrieve required workspace resource id:
$workspaceResourceId = (Get-AzOperationalInsightsWorkspace -ResourceGroupName "log-prod-rg" -Name "log").ResourceId

Here's example how you can retrieve required database resource id:
$databaseResourceId = (Get-AzSqlDatabase -ResourceGroupName "db-prod-rg" -ServerName "server" -DatabaseName "db").ResourceId
#>
Param (
    [Parameter(HelpMessage="Deployment target resource group")] 
    [string] $ResourceGroupName = "logvm-local-rg",

    [Parameter(HelpMessage="Deployment target resource group location")] 
    [string] $Location = "North Europe",

    [Parameter(Mandatory=$true, HelpMessage="Log Analytics Workspace resource id")] 
    [string] $WorkspaceResourceId,

    [Parameter(Mandatory=$true, HelpMessage="SQL Database resource id")] 
    [string] $DatabaseResourceId,

    [Parameter(Mandatory=$true, HelpMessage="Alert email address")]
    [string] $AlertEmailAddress,

    [string] $Template = "$PSScriptRoot\azuredeploy.json",
    [string] $TemplateParameters = "$PSScriptRoot\azuredeploy.parameters.json"
)

$ErrorActionPreference = "Stop"

$date = (Get-Date).ToString("yyyy-MM-dd-HH-mm-ss")
$deploymentName = "Local-$date"

if ([string]::IsNullOrEmpty($env:RELEASE_DEFINITIONNAME))
{
    Write-Host (@"
Not executing inside Azure DevOps Release Management.
Make sure you have done "Login-AzAccount" and
"Select-AzSubscription -SubscriptionName name"
so that script continues to work correctly for you.
"@)
}
else
{
    $deploymentName = $env:RELEASE_RELEASENAME
}

if ($null -eq (Get-AzResourceGroup -Name $ResourceGroupName -Location $Location -ErrorAction SilentlyContinue))
{
    throw "Resource group '$ResourceGroupName' does not exist. Deployment is cancelled."
}

# Additional parameters that we pass to the template deployment
$additionalParameters = New-Object -TypeName hashtable
$additionalParameters['workspaceResourceId'] = $WorkspaceResourceId
$additionalParameters['databaseResourceId'] = $DatabaseResourceId
$additionalParameters['alertEmailAddress'] = $AlertEmailAddress

$result = New-AzResourceGroupDeployment `
    -DeploymentName $deploymentName `
    -ResourceGroupName $ResourceGroupName `
    -TemplateFile $Template `
    -TemplateParameterFile $TemplateParameters `
    @additionalParameters `
    -Mode Incremental -Force `
    -Verbose

$result
