<#
.SYNOPSIS
Check old snapshots on a HyperV host and notify help desk if there are VM snapshots older than a week

.NOTES
 Author: Tom Chen
 Creation Date: 21/1/2018

.CHANGELOGS
#>
#Initialize Email Payload
[string]$notificationPayload = ""
[string]$serverName = ""
[string]$fixsteps = "Dear Helpdesk,  `n"+"Please raise a sev3 call for this alert. `n `n Old Snapshots:`n"

$serverName = $env:COMPUTERNAME
$Emailsubject = "Alert - HYPER-V Cluster VMSnapshots Older Than 7 days on Host: "+$serverName

#Remove left over backup snapshots older than a week, we want them to be removed automatically without verification from Wintel
Get-VMSnapshot -VMName * -SnapshotType Recovery |Where-Object {$_.CreationTime -lt (Get-Date).AddDays(-7)} |Remove-VMSnapshot

#Record snapshots older than a week and add the list to Email payload
Get-VMSnapshot -VMName * |ForEach-Object {if($_.CreationTime -lt (Get-Date).AddDays(-7)) {$notificationPayload += $_.Name; $notificationPayload +="`n"}}

#Send notification Email to Helpdesk
If ($notificationPayload -ne "") {
    $notificationPayload +="`n"
    $notificationPayload = $fixsteps + $notificationPayload
    Send-MailMessage -from "no-reply@contoso.com" -to "helpdesk@contoso.com" -cc "wintel@contoso.com" -SmtpServer SMTPServerName -Subject $Emailsubject -Body $notificationPayload
}