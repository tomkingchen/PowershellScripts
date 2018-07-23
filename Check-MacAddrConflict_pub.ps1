<#
    Script to check MAC Address conflicts within Hyper-V Cluster
#>

# Define an array to hold list of NICs
$vmnics = @()
$vmnics_sorted = @()

[string]$notiPayload = ""

# Reference MacAddress
$refmacaddr = ""

# Check MAC Address Conflict
$vmnics = Get-VMNetworkAdapter -vmname * -ComputerName host01
$vmnics += Get-VMNetworkAdapter -vmname * -ComputerName host02
$vmnics += Get-VMNetworkAdapter -vmname * -ComputerName host03
$vmnics += Get-VMNetworkAdapter -vmname * -ComputerName host04

# Sort the array of VM NICs by MacAddresses
$vmnics |Sort-Object -Property MacAddress|foreach{$vmnics_sorted += $_}

$maxloop = $vmnics.count-1

For ($i=0;$i -le $maxloop;$i++){
    $vmnic = $vmnics_sorted[$i]
    $vmname = $vmnic.vmname
    $macaddr = $vmnic.macaddress
    # Check if there are duplicated Mac Addresses
    If ($refmacaddr -ne $vmnic.macaddress){
        
        # Write-Host "$vmname MACAddress is $macaddr" -ForegroundColor green

        # Replace the reference macaddress with the current MAC
        $refmacaddr = $vmnic.macaddress
    }Else{
        $conflictedvmname = $vmnics_sorted[$i-1].vmname
        $notipayload += "$vmname has conflicted MAC Address with $conflictedvmname! `n"
    }
}

If ($notipayload -ne ""){
    Send-MailMessage -From "monitor@contoso.com" -To "itadmins@contoso.com" -SmtpServer emailserver -Subject "ALERT - HYPERV Cluster MACAddress Conflict" -Body $notiPayload
}