$subid = "<subid>"
Select-AzSubscription -Subscription $subid

# Policy AssignmentID
$policyAssignmentId= "/subscriptions/$subid/resourceGroups/test-appservice3manual/providers/Microsoft.Authorization/policyAssignments/pol-test-appservice-tls12"

# https://docs.microsoft.com/en-us/powershell/module/az.policyinsights/start-azpolicyremediation?view=azps-4.8.0
# resourceid
$job = Start-AzPolicyRemediation `
-PolicyAssignmentId $policyAssignmentId `
-Name "remediation_$(get-date -format 'yyyyMMdd_HHmmss')" `
-AsJob -ResourceDiscoveryMode ReEvaluateCompliance

$job|wait-job
$result = $job | Receive-Job
$result