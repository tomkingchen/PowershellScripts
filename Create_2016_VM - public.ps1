<#
.SYNOPSIS
Create Windows 2016 VM from template
.DESCRIPTION
Create a Windows 2016 Virtual Machine in SCVMM cluster from pre-defined Hyper-V template.

#>
# You will need to install and import SCVMM module first if run the script remotely
# Uncomment the command line below to install and import the SCVMM module
# Install-Module VirtualMachineManager
# Import-Module VirtualMachineManager

# Get Required Variables
param( 
	    [Parameter(Mandatory=$true)] 
	    [String]$vmName, 
	    [Parameter(Mandatory=$true)] 
	    [String]$HostName,
        [Parameter(Mandatory=$true)] 
	    [String]$volnumber
	  ) 

# Cluster Shared Volume path
$volpath ="C:\ClusterStorage\Volume$volnumber"

#region CreateWindows2016VM


# Create a new Windows 2016 VM from template

# Get VM Template
$VMTemplate = Get-SCVMTemplate -VMMServer scvmm-server | where {$_.Name -eq "Template_Win2016_Std"}

# Assign the VM to host, pick a host with least memory usage
$VMHost = Get-SCVMHost -ComputerName $HostName

# Set the hardware profile, you will need to create a hardware profile in VMM beforehand
$HardwareProfile = Get-SCHardwareProfile | where {$_.Name -eq "Medium Windows Server"}

# Create the VM using the template and hardware profile
New-SCVirtualMachine -VMTemplate $VMTemplate -Name $vmName -VMHost $VMHost -Path $volpath -RunAsynchronously -ComputerName $vmName -FullName "Tom Chen" -OrganizationName "MyCompany" -HardwareProfile $HardwareProfile

#endregion