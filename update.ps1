<#
.SYNOPSIS
Script to update packages on a remote host.

.DESCRIPTION
This script will update packages on a remote host with a PowerShell session.

.PARAMETER client
One or more clients to update packages on.

.PARAMETER package
One or more packages to update on the remote host(s).

.PARAMETER username
The username to use when connecting to the remote host(s).

.PARAMETER password
The password as a SecureString to use when connecting to the remote host(s). If the password is not specified, the user will be prompted to enter the password.

.EXAMPLE
PS> .\update.ps1 -clients 192.168.116.132 -packages git.install -username vmadmin

.EXAMPLE
PS> .\update.ps1 -clients host1, host2 -packages git.install, adobereader -username vmadmin -password ****

.EXAMPLE
PS> .\update.ps1 -clients host1, host2 -all -username vmadmin -password **** 
#>

param (
    [Parameter(Mandatory = $true, ParameterSetName = 'update')]
    [Parameter(Mandatory = $true, ParameterSetName = 'updateAll')]
    [string[]]
    $clients,

    [Parameter(Mandatory = $true, ParameterSetName = 'update')]
    [string[]]
    $packages,

    [Parameter(Mandatory = $true, ParameterSetName = 'updateAll')]
    [switch]
    $all,

    [Parameter(Mandatory = $true, ParameterSetName = 'update')]
    [Parameter(Mandatory = $true, ParameterSetName = 'updateAll')]
    [string]
    $username,

    [Parameter(Mandatory = $true, ParameterSetName = 'update')]
    [Parameter(Mandatory = $true, ParameterSetName = 'updateAll')]
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
        
        Write-Host "updating chocolatey on host $i"
        if ($packages) {
            choco upgrade $packages
        } else {
            choco upgrade all
        }
    }

    Invoke-Command -Command $scriptBlock -computerName $i -credential $cred -ArgumentList $i, $packages
}