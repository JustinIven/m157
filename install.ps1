<#
.SYNOPSIS
Script to install choco and packages on a remote host.

.DESCRIPTION
This script will install either choco or choco and packages on a remote host with a PowerShell session.

.PARAMETER client
One or more clients to install choco and packages on.

.PARAMETER package
One or more packages to install on the remote host(s).

.PARAMETER username
The username to use when connecting to the remote host(s).

.PARAMETER password
The password as a SecureString to use when connecting to the remote host(s). If the password is not specified, the user will be prompted to enter the password.

.EXAMPLE
PS> .\install.ps1 -clients 192.168.116.132 -packages git.install -username vmadmin

.EXAMPLE
PS> .\install.ps1 -clients host1, host2 -packages git.install, adobereader -username vmadmin -password ****
#>

param (
    [Parameter(Mandatory = $true, ParameterSetName = 'installChoco')]
    [Parameter(Mandatory = $true, ParameterSetName = 'installAll')]
    [string[]]
    $clients,

    [Parameter(Mandatory = $true, ParameterSetName = 'installAll')]
    [string[]]
    $packages,

    [Parameter(Mandatory = $true, ParameterSetName = 'installChoco')]
    [Parameter(Mandatory = $true, ParameterSetName = 'installAll')]
    [string]
    $username,

    [Parameter(Mandatory = $false, ParameterSetName = 'installChoco')]
    [Parameter(Mandatory = $false, ParameterSetName = 'installAll')]
    [SecureString]
    $password
)

foreach ($i in $clients) {
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password

    $scriptBlock = {
        param($i, $packages)
        Write-Host "verifying chocolatey is installed on host $i"
        if (!(Test-Path "$($env:ProgramData)\chocolatey\choco.exe")) {
            Write-Host "installing chocolatey..."
            try {
                Set-ExecutionPolicy Bypass -Scope Process -Force
                [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
                Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

            }
            catch {
                Write-Error "failed to install chocolatey"
                continue
            }
        }

        foreach ($j in $packages) {
            Write-Host "installing package $j on host $i"
            try {
                choco install $j -y
            }
            catch {
                Write-Error "failed to install package $j"
                continue
            }
        }
    }

    Invoke-Command -Command $scriptBlock -computerName $i -credential $cred -ArgumentList $i, $packages
}
