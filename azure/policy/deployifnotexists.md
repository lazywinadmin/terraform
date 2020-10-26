
# Azure Policy

Used to control the "WHAT", what you deploy
the who should be control via AAD or RBAC

alias is a property

# Notes
if existence rule is wrong, it will keep deploying ?


# High level flow
1. Create Policy Definition, this contains:
   1. the compliance conditions
   2. the effect to take
      1. Role(s) required to apply the effect
   3. remediation ARM Template to apply if the conditions are met
2. Apply the Definition on a specific scope (Sub or RG) and create a Managed Identity in the process (MSI)
   1. Remember that the role(s) you specified in the defition need to be accessible where the assignement is done.
3. Create a Policy Remediation Automation

# Authoring Flow
1. Determine resource properties (vscode)
2. find alias (vscode)
3. determine effect
4. compose policy


# Uses cases to explore
-Lock RG
    https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/lock-resources#who-can-create-or-delete-locks
    To create or delete management locks, you must have access to Microsoft.Authorization/* or Microsoft.Authorization/locks/* actions. Of the built-in roles, only Owner and User Access Administrator are granted those actions.
-Subscription Diagnostic settings to apply with mapping to a LAW
-Add Tags to Resources created (use the MODIFY effect for this)
    Created timedate (sub dont have this information as of today)
    Creator not sure we can pull this from the logs
-Storage Account encryption to apply
-Delete resources

# To investigate
-make sure keyvault expire
-nsg that are open
-policies without auto-remediation


https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyMenuBlade/Definitions


# Gotchas

* DeployIfNotExists runs about 15 minutes after a Resource Provider has handled a create or update resource request and has returned a success status code.
* Can only be applied at Sub or RG level
* Role id specified in roleDefinitionIds need to be accessible to the subscription or rg when the policy is applied
* When using Start-AzPolicyRemediation, it will fix existing devices and correct any resources create/updated as well


# Building the Policy Profile
# Find Role definition id

```powershell
# Az Cli
az account set --subscriptionid <id>
az role definition list --name 'Contributor'

# PowerShell
Set-AzContext -Subscription <subid>
Get-AzRoleDefinition -Name Contributor -Debug # ResourceId only show in debug
```


# Create managed identity with PowerShell

https://docs.microsoft.com/en-us/azure/governance/policy/how-to/remediate-resources#create-managed-identity-with-powershell

```powershell
# Retrieve the policy definition to apply
# Get the built-in "Deploy SQL DB transparent data encryption" policy definition
$policyDef = Get-AzPolicyDefinition -Id /subscriptions/<sub_id>/providers/Microsoft.Authorization/policyDefinitions/ee3e2c9d-78b4-4f1c-be06-38b90a68b9ab

# Define where the Policy will be applied
# Get the reference to the resource group
$resourceGroup = Get-AzResourceGroup -Name 'MyResourceGroup'

# Create the assignment using the -Location and -AssignIdentity properties
$assignment = New-AzPolicyAssignment -Name 'sqlDbTDE' -DisplayName 'Deploy SQL DB transparent data encryption' -Scope $resourceGroup.ResourceId -PolicyDefinition $policyDef -Location 'westus' -AssignIdentity
```

# Grant rights to the Managed Identity

```powershell
# Use the $policyDef to get to the roleDefinitionIds array
$roleDefinitionIds = $policyDef.Properties.policyRule.then.details.roleDefinitionIds

if ($roleDefinitionIds.Count -gt 0)
{
    $roleDefinitionIds | ForEach-Object {
        $roleDefId = $_.Split("/") | Select-Object -Last 1
        New-AzRoleAssignment -Scope $resourceGroup.ResourceId -ObjectId $assignment.Identity.PrincipalId -RoleDefinitionId $roleDefId
    }
}
```

# Using Terraform to do all this
* https://www.terraform.io/docs/providers/azurerm/r/policy_definition.html
* https://www.terraform.io/docs/providers/azurerm/r/policy_assignment.html
* https://www.terraform.io/docs/providers/azurerm/r/policy_remediation.html



# Remediate existing resources

Once the policy definition, assignement and remediation in place it covers any new or update resources. But what about resources that exist already and don't get updated ?


# Resources

* https://github.com/Azure/azure-policy/
* https://github.com/Azure/Community-Policy
* https://www.youtube.com/watch?v=rcVN9p4XNVg
* https://docs.microsoft.com/en-us/azure/governance/policy/how-to/remediate-resources
* https://docs.microsoft.com/en-us/azure/lighthouse/how-to/deploy-policy-remediation
* [Microsoft Docs - Azure Policy DeployIfNotExists](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/effects#deployifnotexists)
* [Microsoft Docs - Remediate non-compliant resources with Azure Policy](https://docs.microsoft.com/en-us/azure/governance/policy/how-to/remediate-resources#configure-policy-definition)
* [Microsoft Docs - Start-AzPolicyRemediation](https://docs.microsoft.com/en-us/powershell/module/az.policyinsights/start-azpolicyremediation?view=azps-4.6.1#examples)


```powershell
$PolicyName = 'test-deployifnotexist-locks_rg'

$Policydef=New-AzPolicyDefinition -Name $PolicyName -Policy .\policy.json
#$Policydef=Set-AzPolicyDefinition -Name $PolicyName -Policy .\policy.json

# Define where the Policy will be applied
# Get the reference to the resource group
#$resourceGroup = Get-AzResourceGroup -Name 'MyResourceGroup'
$Scope = '/subscriptions/<sub_id>'

# Create the assignment using the -Location and -AssignIdentity properties
$assignment = New-AzPolicyAssignment -Name $PolicyName -DisplayName $PolicyName  -Scope $Scope -PolicyDefinition $policyDef -Location 'westus' -AssignIdentity
<#
Identity           : @{type=SystemAssigned; principalId=b2ce6f00-ac96-4e91-8beb-9e28cc335bb8; tenantId=8d4fe8c3-bb00-4d1e-b62f-3a103ae8d9c4}
Location           : westus
Name               : test-deployifnotexist-locks_rg
ResourceId         : /subscriptions/<sub_id>/providers/Microsoft.Authorization/policyAssignments/test-deployifnotexist-locks_rg
ResourceName       : test-deployifnotexist-locks_rg
ResourceGroupName  :
ResourceType       : Microsoft.Authorization/policyAssignments
SubscriptionId     : <sub_id>
Sku                : @{name=A0; tier=Free}
PolicyAssignmentId : /subscriptions/<sub_id>/providers/Microsoft.Authorization/policyAssignments/test-deployifnotexist-locks_rg
Properties         : Microsoft.Azure.Commands.ResourceManager.Cmdlets.Implementation.Policy.PsPolicyAssignmentProperties
#>


# This MSI is used to deployed the template and need appropriate rights on each
# Grant the MSI to grant access to the
# Use the $policyDef to get to the roleDefinitionIds array
$roleDefinitionIds = $policyDef.Properties.policyRule.then.details.roleDefinitionIds

if ($roleDefinitionIds.Count -gt 0)
{
    $roleDefinitionIds | ForEach-Object {
        $roleDefId = $_.Split("/") | Select-Object -Last 1
        New-AzRoleAssignment -Scope $scope -ObjectId $assignment.Identity.PrincipalId -RoleDefinitionId $roleDefId
    }
}
<#
RoleAssignmentId   : /subscriptions/<sub_id>/providers/Microsoft.Authorization/roleAssignments/0e91642b-7d19-49c5-acc0-e2578218609a
Scope              : /subscriptions/<sub_id>
DisplayName        : test-deployifnotexist-locks_rg
SignInName         :
RoleDefinitionName : Owner
RoleDefinitionId   : 8e3af657-a8ff-443c-a75c-2fe8c4bcb635
ObjectId           : b2ce6f00-ac96-4e91-8beb-9e28cc335bb8
ObjectType         : ServicePrincipal
CanDelegate        : False
#>




# Create Remediation Tasks
$rem=start-AzPolicyRemediation -Name "$($PolicyName)-remediation" -PolicyAssignmentId $assignment.PolicyAssignmentId -PolicyDefinitionReferenceId $assignment.Properties.PolicyDefinitionId

# This remediate all the non-compliant resources currently deployed
<#
Id                          : /subscriptions/<sub_id>/providers/microsoft.policyinsights/remediations/test-deployifnotexist-locks_rg-re
                              mediation
Type                        : Microsoft.PolicyInsights/remediations
Name                        : test-deployifnotexist-locks_rg-remediation
PolicyAssignmentId          : /subscriptions/<sub_id>/providers/microsoft.authorization/policyassignments/test-deployifnotexist-locks_r
                              g
PolicyDefinitionReferenceId : /subscriptions/<sub_id>/providers/microsoft.authorization/policydefinitions/test-deployifnotexist-locks_r
                              g
CreatedOn                   : 9/13/2020 10:22:45 PM
LastUpdatedOn               : 9/13/2020 10:22:45 PM
ProvisioningState           : Succeeded
Filters                     :
DeploymentSummary           : Microsoft.Azure.Commands.PolicyInsights.Models.Remediation.PSRemediationDeploymentSummary
Deployments                 :
ResourceDiscoveryMode       : ExistingNonCompliant

#>

# you can force a re-evaluation of the non-compliance detected using something like:
# This took 20 minutes according to my tests
Start-AzPolicyRemediation `
-PolicyAssignmentId $policyAssignmentId `
-Name "remediation_$(get-date -format 'yyyyMMdd_HHmmss')" `
-AsJob -ResourceDiscoveryMode ReEvaluateCompliance -scope $scope

#you can start remediation on a resource that you just deployed (not detected as non-compliant yet)
# This took ~10 min according to my tests
Start-AzPolicyRemediation `
-PolicyAssignmentId $policyAssignmentId `
-Name "remediation_$(get-date -format 'yyyyMMdd_HHmmss')" `
-AsJob -ResourceDiscoveryMode ReEvaluateCompliance -scope /subscriptions/b70ae6c2-7420-4191-8671-bc8caaf7cd48/resourceGroups/test-appservice3manual/providers/Microsoft.Web/sites/test-webapp6
```




