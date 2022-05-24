<#
.SYNOPSIS
Script to uninstall packages on a remote host.

.DESCRIPTION
This script will uninstall packages on a remote host with a PowerShell session.

.PARAMETER client
One or more clients to uninstall packages on.

.PARAMETER package
One or more packages to uninstall on the remote host(s).

.PARAMETER username
The username to use when connecting to the remote host(s).

.PARAMETER password
The password as a SecureString to use when connecting to the remote host(s). If the password is not specified, the user will be prompted to enter the password.

.EXAMPLE
PS> .\uninstall.ps1 -clients 192.168.116.132 -packages git.install -username vmadmin

.EXAMPLE
PS> .\uninstall.ps1 -clients host1, host2 -packages git.install, adobereader -username vmadmin -password ****

.EXAMPLE
PS> .\uninstall.ps1 -clients host1, host2 -all -username vmadmin -password **** 
#>

param (
    [Parameter(Mandatory = $true, ParameterSetName = 'uninstall')]
    [Parameter(Mandatory = $true, ParameterSetName = 'uninstallAll')]
    [string[]]
    $clients,

    [Parameter(Mandatory = $true, ParameterSetName = 'uninstall')]
    [string[]]
    $packages,

    [Parameter(Mandatory = $true, ParameterSetName = 'uninstallAll')]
    [switch]
    $all,

    [Parameter(Mandatory = $true, ParameterSetName = 'uninstall')]
    [Parameter(Mandatory = $true, ParameterSetName = 'uninstallAll')]
    [string]
    $username,

    [Parameter(Mandatory = $true, ParameterSetName = 'uninstall')]
    [Parameter(Mandatory = $true, ParameterSetName = 'uninstallAll')]
    [SecureString]
    $password
)

foreach ($i in $clients) {
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password

    $scriptBlock = {
        param($i, $packages)
        Write-Host "verifying chocolatey is installed on host $i"
        if (!(Test-Path "$($env:ProgramData)\chocolatey\choco.exe")) {
            Write-Host "chocolatey is not installed on host $i"
        }
        
        Write-Host "uninstalling chocolatey package(s) on host $i"
        if ($packages) {
            choco uninstall $packages
        } elseif ($all) {
            choco uninstall all
        } else {
            Write-Host "no package(s) specified"
        }
    }

    Invoke-Command -Command $scriptBlock -computerName $i -credential $cred -ArgumentList $i, $packages
}