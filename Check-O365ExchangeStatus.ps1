#requires -version 3
<#
.SYNOPSIS
   Query for O365 Health
.DESCRIPTION
   Query for most recent status of a particular service & feature.
.NOTES
   Author: Tom Chen
   Creation Date: 02/19/2018
.LINK
   http://www.solarwinds.com/
#>


#-----------------------------[ Configuration ]-------------------------------#

$version = '0.2'

#-------------------------------[ Data ]--------------------------------------#

$svcStatus = @{
    0 = "ServiceInterruption";
    1 = "ServiceDegradation";
    2 = "RestoringService";
    3 = "ExtendedRecovery";
    4 = "Investigating";
    5 = "ServiceRestored";
    6 = "FalsePositive";
    7 = "PIRPublished";
    8 = "InformationUnavailable";
    99 = "ServiceOperational";
    100 = "NoDataAssumingUp";
}

#--------------------------[ Modules/Functions ]------------------------------#

Function Get-RegistrationCookie() {
    $regUri = "https://api.admin.microsoftonline.com/shdtenantcommunications.svc/Register"

    # authentication payload for registration
    $jsonPayload = (@{userName=$username;password=$password;} | ConvertTo-Json).ToString()

    # get cookie for the conversation containing registration through RESTAPI
    $cookie = (Invoke-RestMethod -ContentType "application/json" -Method Post -Uri $regUri -Body $jsonPayload).RegistrationCookie

    return $cookie
}

Function Get-SvcEvents($cookie) {
    $eventsUri = "https://api.admin.microsoftonline.com/shdtenantcommunications.svc/GetEvents"
    $jsonPayload = (@{lastCookie=$cookie;locale="en-US";preferredEventTypes=@(0,1)} | ConvertTo-JSON).ToString()
    $events = (Invoke-RestMethod -ContentType "application/json" -Method Post -Uri $eventsUri -Body $jsonPayload)

    $sortedEvents = ($events.Events | Sort-Object -Property StartTime -Descending)

    return $sortedEvents
}

Function SecureStringToString($value) {
    [System.IntPtr] $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($value);
    try {
        [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr);
    } finally {
        [System.Runtime.InteropServices.Marshal]::FreeBSTR($bstr);
    }
}

#--------------------------------[ Execution ]--------------------------------#

$service = "Exchange Online"

#Use this to get credential if runs from server
#$myCredential = Import-Clixml -Path "C:\Scripts\access1.xml"
#$c = $myCredential

#Use this to get credential if runs from Solarwinds
$c = Get-Credential -Credential ${CREDENTIAL}

[string]$username = $c.Username
[string]$password = SecureStringToString $c.Password

$cookie = Get-RegistrationCookie
$events = Get-SvcEvents $cookie

# iterate over the events, looking for a mention of our service/feature
$currentStatus = 100
:outer foreach ($e in $events.AffectedServiceHealthStatus) {
    if ($e.ServiceName -eq $service) {
        $currentStatus = $e.Status   
    }
}

Write-Output "Statistic: $currentStatus"
Write-Output "Message: $($svcStatus[$currentStatus])"
Exit 0


