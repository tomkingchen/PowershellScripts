<#
.SYNOPSIS
Carry out initial configuration based on new server build checklist tasks
.DESCRIPTION
The script carries out some basic inital configurations on a newly provisioned Windows server.
.EXAMPLE
Config-New-VM -ServerName "vm01" -IPAddress "10.1.1.10" -DefaultGW "10.1.1.1" -DNSServers "10.1.1.3,10.1.1.4"
#>
param( 
	    [Parameter(Mandatory=$false)] 
	    [String]$serverName, 
	    [Parameter(Mandatory=$true)] 
	    [String]$IPAddress,
        [Parameter(Mandatory=$true)] 
	    [String]$defaultGW,
        [Parameter(Mandatory=$true)] 
	    [String]$DNSServers
	  ) 


# Configure network interface
$nic = Get-NetAdapter -Name "Ethernet"
# Disable DHCP
$nic |Set-NetIPInterface -Dhcp Disabled
# Set static IP
$nic |New-NetIPAddress -IPAddress $IPAddress -PrefixLength 24 -DefaultGateway $defaultGW
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses $DNSServers

# Disable Guest account
Get-localuser Guest |Disable-LocalUser

# Rename admin account
Rename-LocalUser Administrator -NewName srv_admin

# Change CD ROM Driver letter to Z:
$drv = Get-WmiObject win32_volume -Filter 'DriveLetter ="D:"'
$drv.DriveLetter = "Z:"
$DRV.Put()|out-null

# Set Security Eventlog retention to 60 days and size to 100MB
Limit-EventLog -LogName Security -RetentionDays 60 -MaximumSize 100MB -OverflowAction OverwriteOlder

# Rename computer name
Try
{
    Rename-Computer -NewName $serverName 
}
Catch
{
    Echo "Server name will not be changed"
}

# Join to the domain
$ADCred = Get-Credential
Add-Computer -DomainName "Contoso.com" -OUPath "OU=Servers,DC=Contoso,DC=com" -Credential $ADCred
