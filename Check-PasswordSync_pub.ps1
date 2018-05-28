<#
 Run this script to check Office 365 Password Sync status and try resync if its not in sync.
 
 Created by Tom Chen, 2 March 2018
#>

Function GetPassSyncTime()
{
    # Get the last Password Sync date and time
    $passSyncTime = Get-MsolCompanyInformation |select LastPasswordSyncTime

    # Convert the string to date and time only
    $passSyncTime = $passSyncTime -replace ".*=" -replace ""
    $passSyncTime = $passSyncTime -replace "}" -replace ""
    
    return $passSyncTime        
}

# Get O365 credential - you will need to create your own cred xml file with your own O365 admin cred
$cred = Import-Clixml -path 'C:\Scripts\tomcredsecured.xml'
# Connect to O365 Online service
Connect-MsolService -Credential $cred

$passSyncTime = GetPassSyncTime

# Get current date and time
$now = get-date

# Check the time span between the last password sync and the current time
$timeSpan = New-TimeSpan -Start $passSyncTime -End $now.ToUniversalTime()

# If the time span is more than 6 hours, send alert to Wintel AU
If ($timeSpan.TotalHours -gt 6)
{
    # Restart ADSync Service to try remediate the issue
    Restart-Service ADSync -Force
    
    Sleep 300

    # Check Last Password Sync Time after the service restart
    $passSyncTime = GetPassSyncTime

    # Get the new time span between the last password sync and the current time
    $timeSpan = New-TimeSpan -Start $passSyncTime -End $now.ToUniversalTime()

    # Check if the password sync is up to date now, if not send out alert Email
    If ($timeSpan.TotalHours -gt 6){

        $subject = "Alert - Office 365 Password Sync stopped for more than 6 hours!"
        $body = "Dear Helpdesk, </br>If this is the first time you saw this alert in last 12 hours, please raise a new sev3 call with Wintel AU during AU business hours</br>
        <font color=red>If receive the alert outside AU business hours,NO CALLOUT needed!</font> </br></br>Wintel Troubleshooting Steps: </br>1. Restart Microsoft Azue AD Sync service on HSNDON-ADS01.</br>2. Carry out a Full Sync by run <font color=red>Start-ADSyncSyncCycle -PolicyType initial</font></br>3. Check Office 365 Admin Centre"
    
        # Generate Email to WintelAU
        Send-MailMessage -SmtpServer "SMTPserver" -from "no-reply@contoso.com" -to "support@contoso.com" -Cc "tom@contoso.com"  -Subject $subject -Body $body -BodyAsHtml -Priority High
    }
}
