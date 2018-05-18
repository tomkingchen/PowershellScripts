<#     
    .SYNOPSIS
    Renew Wireless Certificate for user

    .NOTES 
    =========================================================================== 
     Created on:       14/05/2018
     Created by:       Tom Chen
    =========================================================================== 
    .DESCRIPTION 
        This script is needed to re-issue user Hansen Wireless User certificate after UPN change.
        This Script will remove any existing Hansen Wireless User certificates.
        It will then reissue a new certificate from Corporate CA.

    .EXAMPLE
        .\Renew-WirelessCert.ps1

#> 

# Find Hansen Wireless User certificates and remove them based on template name
Get-ChildItem Cert:\CurrentUser\my | ? {$_.Extensions | ? {$_.oid.friendlyname -match "Template" -and $_.Format(0) -match "Wireless User"}}|Remove-Item

# Request a new Wireless Certificate from CA
Set-Location 'Cert:\CurrentUser\My'
Get-Certificate -Template 'WirelessUser' -Url ldap:
 