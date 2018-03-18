# New Staff Onboard Powershell Script

<# 
.SYNOPSIS
Creat necessary accesses for a new staff

.DESCRIPTION
 Complete new staff onboarding tasks by the order defined in the company New Employee checklist
 - Create AD account and configure necessary attributes
 - Create user home drive
 - Create user Office 365 mailbox
 - Assign user Office 365 licenses
 
.NOTES
 Author: Tom Chen
 Creation Date: 21/2/2018

.EXAMPLES
.\New-Staff_pub.ps1 -username "sanderb" -password "Passw0rd" -fName "Brandon" -lname "Sanderson" -location "AU" -phoneNum "+61 0391234567" -jobTitle "Developer" -copyUser "jsmith" -Manager "tom"

.CHANGELOGS
 15-Mar-18 Improve Exception error message display

#>

# Get necessary parmaeters
param( 
	    [Parameter(Mandatory=$true)] 
	    [String]$userName,
        [Parameter(Mandatory=$true)] 
	    [String]$password,
	    [Parameter(Mandatory=$true)] 
	    [String]$fName,
        [Parameter(Mandatory=$true)]
	    [String]$lname,
        [Parameter(Mandatory=$true)]
        [ValidateSet('AU','US','GB','CN','NZ','VN','DK')]
	    [String]$location,
        [String]$phoneNum = '+61 0391234567',
        [Parameter(Mandatory=$true)] 
	    [String]$jobTitle,
        [Parameter(Mandatory=$true)] 
	    [String]$copyUser,
        [Parameter(Mandatory=$true)] 
	    [String]$manager
	  ) 

#region Create New AD account

$userobj = $Null
$groupName = ""
$fullname = $fname+" "+$lname
$upn = $username + "@contoso.com"

Try {
        # Select the source user the new user will copy from, to run the command you will need to have ActiveDirectory module installed, which comes with Remote Server Manager tool
        $oldUser = Get-ADUser -identity $copyUser -Properties title,office,streetaddress,city,state,postalcode,country,department,description,scriptPath,HomeDrive,Memberof

        # Get the OU path of the existing user
        $OUPath = $oldUser.DistinguishedName -replace '^cn=.+?(?<!\\),'

        # Set a secure password, change the intial password regularly
        $secPassword = ConvertTo-SecureString $password –asplaintext –force

        # Create the new AD account based on the existing user profile
        New-AdUser -samAccountName $username -UserPrincipalName $username"@contoso.com" -Name $fullname -DisplayName $fullname -GivenName $fname -Surname $lname -instance $oldUser -AccountPassword $secPassword -path $OUpath -Enabled $true -ChangePasswordAtLogon $false

        # Copy group membership from the old user to the new user
        $oldUser.memberof |ForEach-Object{$groupName = % { (Get-ADGroup $_).samAccountName; } ;Add-ADGroupMember -identity $groupName –Members $username;} 

        # Update new user phone number, description and job title
        Set-ADUser -Identity $username -OfficePhone $phoneNum -Description $jobTitle -Title $jobTitle -Company "Contoso Technologies"

        # Enable user Dial-in
        Set-ADUser -Identity $username -replace @{msNPAllowDialin=$true}

        # Assign the line manager for the new user
        Get-ADUser -Identity $username | Set-ADUser -Manager $manager

        # Check User Porperties
        $userObj = Get-ADUser -Identity $username
}
Catch{
        $ErrorMsg = $_.Exception.Message
        Write-Host "Create AD Account Failed!" -ForegroundColor Red
        Write-Host "Error Details: $ErrorMsg" -ForegroundColor Red
        Exit
}

#endregion




#region createhomedrive

# Create sub folder on \\fileserver\sharefolder and enable share, replace this with your own file server name and path
If ($userObj -ne $Null)
{
    Try {
            Invoke-Command -ComputerName "fileserver" -argumentlist $username -ScriptBlock {

                $username = $args[0]
        
                # Define User home folder path
                $homefolder = "D:\ShareFolder\"+$username
        
                # Create folder
                New-Item -Path $homefolder -type Directory -Force

                # Get current ACL permission on the folder
                $Acl = (Get-Item $homefolder).GetAccessControl('Access')
        
                # Define ACL permission to add
                $ACLnew = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Modify','ContainerInherit,ObjectInherit','None','Allow')

                # Assign ACL permissions
                $ACL.SetAccessRule($ACLnew)
                Set-Acl -Path $homefolder -AclObject $Acl
        
                # Create share and configure permission
                New-SmbShare -Name $username"$" -Path $homefolder -ChangeAccess "contoso\$username"

            }
    }Catch{
        $ErrorMsg = $_.Exception.Message
        Write-Host "Home drive create failed!" -ForegroundColor Red
        Write-Host "Error Details: $ErrorMsg" -ForegroundColor Red
        Exit
    }
}
Else{
    Write-Host "AD Account not found!" -ForegroundColor Red
    Exit
}


# You can check if the script worked or not by command: dir \\fileserver\d$\sharefolder\username 
# If the folder is created successfully, the command should return no error
# Please note share access to \\fileserver\username$ is blocked accept for the user

# Setup User Profile settings
$homeshare = "\\fileserver\"+$username+"$"
Try {
        Set-ADUser -Identity $username -HomeDirectory $homeshare -HomeDrive "U:"
     }
Catch{
        $ErrorMsg = $_.Exception.Message
        Write-Host "Configure user home drive U: failed!" -ForegroundColor Red
        Write-Host "Error Details: $ErrorMsg" -ForegroundColor Red
        Exit
      }

#endregion




#region Create Mailbox
Try {
        # Get on premise Ecxchange credential, use exadmin login
        $OnPremCred = Get-Credential contoso\exchangeAdmin
    
        # Connect to On Prem Exchange Server, you will be prompted for login, use exadmin credential
        $OnPremSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://exchServer.contoso.com/PowerShell/ -Authentication Kerberos -Credential $OnPremCred
        Import-PSSession $onPremSession

        #Enable O365 mailbox for on prem user
        Enable-RemoteMailbox $fullname -RemoteRoutingAddress $username"@contoso.mail.onmicrosoft.com"

        # End the session, it's important to terminate the session
        Remove-PSSession $OnPremSession
}
Catch{
        $ErrorMsg = $_.Exception.Message
        Write-Host "Create user mailbox failed!" -ForegroundColor Red
        Write-Host "Error Details: $ErrorMsg" -ForegroundColor Red
        Exit
}
#endregion



#region Sync with Azure AD 
Try {
        # Kick off a manual ADSync with Office 365
        Invoke-Command -ComputerName "ADConnectServerName" -ScriptBlock {Start-ADSyncSyncCycle -PolicyType Delta }
        Echo "The script is waiting for AD Sync to complete, this will take 5 mins"
        # Supspend the script for 5 mins
        Start-Sleep -Seconds 300
}
Catch{
        $ErrorMsg = $_.Exception.Message
        Write-Host "AD Sync with O365 failed, try Run Start-ADSyncSyncCyle command again manually!" -ForegroundColor Red
        Write-Host "Error Details: $ErrorMsg" -ForegroundColor Red
        Exit

}

#endregion




#region Assign Office 365 Licenses

Try{
        # Type in your O365 Admin credential
        $o365cred = Get-Credential

        # Connect to Office 365, you will need to install MSonline module by run command "install-module MSOnline"
        Connect-MsolService -Credential $o365cred

        # Update: Specify user country: AU,US,DK,UK,CN,NZ
        Set-MsolUser -UserPrincipalName $upn -UsageLocation $location

        # Assign Enterprise E3 licesning plan to the user
        Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses "contoso:ENTERPRISEPACK"
}
Catch{
    $ErrorMsg = $_.Exception.Message
    Write-Host "Assign Office 365 Licenses failed, you will need to manually do that!" -ForegroundColor Red
    Write-Host "Error Details: $ErrorMsg" -ForegroundColor Red
    Exit
}

Write-Host "The user account has been successfully created!" -ForegroundColor Green

#endregion