[CmdletBinding()]
param (
    [string[]]
    $clients,

    [string[]]
    $packages,

    [Parameter(Mandatory = $true)]
    [string]
    $username,

    [Parameter(Mandatory = $true)]
    [SecureString]
    $password
)

foreach ($i in $clients) {
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password

    $scriptBlock = {
        Write-Host "verifying chocolatey is installed on host $i"
        if (!(Test-Path "$($env:ProgramData)\chocolatey\choco.exe")) {
            Write-FPLog -Category Info -Message "installing chocolatey..."
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

    Invoke-Command -Command $scriptBlock -computerName $i -credential $cred 
}