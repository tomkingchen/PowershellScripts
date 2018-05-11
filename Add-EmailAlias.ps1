# Use the script to add a new Email alias address to user mailboxes in Office 365
# Find out recipients without @contosoNew.com namespace in the alias
# Add the alias if found

# Update Parent Domain
foreach ($recipient in (Get-Recipient -resultsize unlimited -filter {EmailAddressPolicyEnabled -eq $false -and RecipientTypeDetails -eq "RemoteUserMailbox"})) {
    if ($recipient.EmailAddresses | Where-Object {$_ -like "*contoso.com"}) {
        #do nothing
    } else {
        $EmailAddr = $recipient.primarysmtpaddress
        $newEmailAddr = $EmailAddr -replace "@contoso.com","@contosoNew.com"
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
foreach ($recipient in (Get-Recipient -resultsize unlimited -filter {EmailAddressPolicyEnabled -eq $false -and RecipientTypeDetails -eq "RemoteUserMailbox"} -DomainController USDC1.us.contoso.com)) {
    if ($recipient.EmailAddresses | Where-Object {$_ -like "*contosoNew.com"}) {
        #do nothing
    } else {
        $EmailAddr = $recipient.primarysmtpaddress
        $newEmailAddr = $EmailAddr -replace "@contoso.com","@contosoNew.com"
        Try {
                # Force the exception to stop the command and catch the error
                $ErrorActionPreference = "Stop"
                Set-RemoteMailbox -Identity $EmailAddr -EmailAddresses @{Add=$newEmailAddr} -DomainController USDC1.us.consoto.com
                Write-Host "$EmailAddr is updated" -ForegroundColor Green
            }
        Catch{
                $ErrorMsg = $_.Exception.Message
                Write-Host "Update $EmailAddr failed!" -ForegroundColor Red
                Write-Host "Error Details: $ErrorMsg" -ForegroundColor Red
        }
    }
}