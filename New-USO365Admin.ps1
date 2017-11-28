<#
.SYNOPSIS
   Create new admin user in Office 365
.DESCRIPTION
   This script creates a new Azure AD user account in Office 365 tenant and assign pre-defined admin roles to it.
.NOTES
   Author: Tom Chen
   Creation Date: 11/28/2017
#>

Import-Module 

param( 
	    [Parameter(Mandatory=$true)] 
	    [String]$UserName, 
	    [Parameter(Mandatory=$true)] 
	    [String]$displayName,
        [Parameter(Mandatory=$true)] 
	    [String]$password
	  ) 

$theUPN = $Username+"-adm@tenantname.onmicrosoft.com"

$displayName += " - Admin"

#Connect to O365 tenant, by default import credential from local credential file
$o365Cred = Import-Clixml -Path "C:\scripts\cred.xml"

#uncomment the command below to input O365 credential interactively
#$o365Cred = Get-Credential

Connect-MsolService -Credential $o365Cred

#Create a new O365 admin
New-MsolUser -UserPrincipalName $theUPN -DisplayName $displayName

#Set a password
Set-MsolUserPassword -UserPrincipalName $theUPN -NewPassword $password -ForceChangePassword $true

#Assign typical US admin roles to the user
Add-MsolRoleMember -RoleMemberEmailAddress $theUPN -RoleName "Helpdesk Administrator"

Add-MsolRoleMember -RoleMemberEmailAddress $theUPN -RoleName "Service Support Administrator"

Add-MsolRoleMember -RoleMemberEmailAddress $theUPN -RoleName "Exchange Service Administrator"

Add-MsolRoleMember -RoleMemberEmailAddress $theUPN -RoleName "Lync Service Administrator"

Add-MsolRoleMember -RoleMemberEmailAddress $theUPN -RoleName "User Account Administrator"

Add-MsolRoleMember -RoleMemberEmailAddress $theUPN -RoleName "SharePoint Service Administrator"

Add-MsolRoleMember -RoleMemberEmailAddress $theUPN -RoleName "Power BI Service Administrator"