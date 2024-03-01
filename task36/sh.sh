# Input bindings are passed in via param block.
param($Timer)

$subscriptionid = $env:SubscriptionIDcred

$date = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId([DateTime]::Now,"Belarus Standard Time")

Set-AzContext -SubscriptionId $Subscriptionid | Out-Null
$CurrentSub = (Get-AzContext).Subscription.Id

$vms = Get-AzVM -Status | Where-Object {($_.tags.AutoShutdown -ne $null)}
$now = $date

foreach ($vm in $vms) {

    if ( ($vm.PowerState -eq 'VM running') -and ( $now -gt $(get-date $($vm.tags.AutoShutdown)) )) {
        Stop-AzVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Confirm:$false -Force
        Write-Warning "Stop VM - $($vm.Name)"
    }

}
