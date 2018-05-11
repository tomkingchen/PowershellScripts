# Script to find out recipients without HansenCX.com namespace
# Update HSNTECH Parent Domain
foreach ($recipient in (Get-Recipient -resultsize unlimited -filter {EmailAddressPolicyEnabled -eq $false -and RecipientTypeDetails -eq "RemoteUserMailbox"})) {
    if ($recipient.EmailAddresses | ? {$_ -like "*hansencx.com"}) {
        #do nothing
    } else {
        $EmailAddr = $recipient.primarysmtpaddress
        $newEmailAddr = $EmailAddr -replace "@hsntech.com","@hansencx.com"
        Try {
                # Force the exception to stop the command and catch the error
                $ErrorActionPreference = "Stop"
                Set-RemoteMailbox -Identity $EmailAddr -EmailAddresses @{Add=$newEmailAddr}
                Write-Host "$EmailAddr is updated" -ForegroundColor Green
            }
        Catch{
                $ErrorMsg = $_.Exception.Message
                Write-Host "Update $EmailAddr failed!" -ForegroundColor Red
                Write-Host "Error Details: $ErrorMsg" -ForegroundColor Red
        }

    }
}

# Update US Child Domain
foreach ($recipient in (Get-Recipient -resultsize unlimited -filter {EmailAddressPolicyEnabled -eq $false -and RecipientTypeDetails -eq "RemoteUserMailbox"} -DomainController hsnCBD-dc01.us.hsntech.int)) {
    if ($recipient.EmailAddresses | ? {$_ -like "*hansencx.com"}) {
        #do nothing
    } else {
        $EmailAddr = $recipient.primarysmtpaddress
        $newEmailAddr = $EmailAddr -replace "@hsntech.com","@hansencx.com"
        Try {
                # Force the exception to stop the command and catch the error
                $ErrorActionPreference = "Stop"
                Set-RemoteMailbox -Identity $EmailAddr -EmailAddresses @{Add=$newEmailAddr} -DomainController hsncbd-dc01.us.hsntech.int
                Write-Host "$EmailAddr is updated" -ForegroundColor Green
            }
        Catch{
                $ErrorMsg = $_.Exception.Message
                Write-Host "Update $EmailAddr failed!" -ForegroundColor Red
                Write-Host "Error Details: $ErrorMsg" -ForegroundColor Red
        }

    }
}

# Update NZ Child Domain
foreach ($recipient in (Get-Recipient -resultsize unlimited -filter {EmailAddressPolicyEnabled -eq $false -and RecipientTypeDetails -eq "RemoteUserMailbox"} -DomainController hsnDON-NZdc03.NZ.hsntech.int)) {
    if ($recipient.EmailAddresses | ? {$_ -like "*hansencx.com"}) {
        #do nothing
    } else {
        $EmailAddr = $recipient.primarysmtpaddress
        $newEmailAddr = $EmailAddr -replace "@hsntech.com","@hansencx.com"
        Try {
                # Force the exception to stop the command and catch the error
                $ErrorActionPreference = "Stop"
                Set-RemoteMailbox -Identity $EmailAddr -EmailAddresses @{Add=$newEmailAddr} -DomainController hsnDON-NZdc03.NZ.hsntech.int
                Write-Host "$EmailAddr is updated" -ForegroundColor Green
            }
        Catch{
                $ErrorMsg = $_.Exception.Message
                Write-Host "Update $EmailAddr failed!" -ForegroundColor Red
                Write-Host "Error Details: $ErrorMsg" -ForegroundColor Red
        }

    }
}

# Update CN Child Domain
foreach ($recipient in (Get-Recipient -resultsize unlimited -filter {EmailAddressPolicyEnabled -eq $false -and RecipientTypeDetails -eq "RemoteUserMailbox"} -DomainController hsnsha-dc01.cn.hsntech.int)) {
    if ($recipient.EmailAddresses | ? {$_ -like "*hansencx.com"}) {
        #do nothing
    } else {
        $EmailAddr = $recipient.primarysmtpaddress
        $newEmailAddr = $EmailAddr -replace "@hsntech.com","@hansencx.com"
        Try {
                # Force the exception to stop the command and catch the error
                $ErrorActionPreference = "Stop"
                Set-RemoteMailbox -Identity $EmailAddr -EmailAddresses @{Add=$newEmailAddr} -DomainController hsnsha-dc01.cn.hsntech.int
                Write-Host "$EmailAddr is updated" -ForegroundColor Green
            }
        Catch{
                $ErrorMsg = $_.Exception.Message
                Write-Host "Update $EmailAddr failed!" -ForegroundColor Red
                Write-Host "Error Details: $ErrorMsg" -ForegroundColor Red
        }

    }
}