function get-aztoken {
    <#
    .SYNOPSIS
        Retrieve token of the current Azure Context session
    .DESCRIPTION
        Retrieve token of the current Azure Context session
        This is using the Get-AzContext cmdlets from the module Az.Account and assume a session is already opened.
    .EXAMPLE
        $token=Get-AzToken
        $uri = "https://management.azure.com/tenants?api-version=2019-11-01"
        invoke-restmethod -method get -uri $uri -Headers @{Authorization="Bearer $token";'Content-Type'='application/json'}
        This leverate the token of the current session to query the Azure Management
        API and retrieves all the tenants information
    .LINK
        https://github.com/lazywinadmin/PowerShell
    #>
    [CmdletBinding()]
    Param()
    try{
        $currentAzureContext = Get-AzContext
        $azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile;
        $profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azureRmProfile)
        $profileClient.AcquireAccessToken($currentAzureContext.Subscription.TenantId).AccessToken
    }catch{
        throw $_
    }
}

$token=Get-AzToken
$uri = "https://management.azure.com/providers/Microsoft.ResourceGraph/resourceChanges?api-version=2018-09-01-preview"
$ResourceID = "/subscriptions/<subid>/resourceGroups/test-appservice3manual/providers/Microsoft.Web/sites/test-webapp6"
$RequestBody = @"
{
    "resourceId": "$ResourceID",
    "interval": {
        "start": "2020-10-25T00:00:00.000Z",
        "end": "2020-10-27T00:00:00.000Z"
    },
    "fetchPropertyChanges": true
}
"@

invoke-restmethod -method post -uri $uri -Headers @{Authorization="Bearer $token";'Content-Type'='application/json'} -Body $RequestBody

