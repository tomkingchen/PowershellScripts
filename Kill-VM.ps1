#requires -module Hyper-V
#requires -runasadministrator

<#
.SYNOPSIS
Kill a VM Process.

.DESCRIPTION
Use this tool when a VM is stuck at Stopping state. It will kill the VM Process on the HyperV host.

.PARAMETER VMName
Name of the virtual machine.

.EXAMPLE
C:\PS>.\kill-vm.ps1 -VMName "contoso-av1"

#>

[CmdletBinding(SupportsShouldProcess=$True)]
Param(
    [Parameter(Mandatory=$true,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage="The VM Name"
        )]
    [String]$VMName
)

Try{
    #Get a VM object from local HyperV host
    $VM = Get-VM -Name $VMName -ErrorAction Stop
    $VMGUID = $VM.Id
    $VMWMProc = (Get-WmiObject Win32_Process | Where-Object {$_.Name -match 'VMWP' -and $_.CommandLine -match $VMGUID})
    
    # Kill the VM process
    Stop-Process ($VMWMProc.ProcessId) –Force
    Write-Output "$VMName is stopped successfully"
}Catch{
    $ErrorMsg = $Error[0] #Get the latest Error
    Write-Output $ErrorMsg
}

