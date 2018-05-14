[CmdletBinding()]
param(
)

try {
    . D:\repos\PowershellDSCExample\NO.PowershellDSC.Framework\functions\Get-ConfigsFiles.ps1
}
catch {
    Write-Host "Error while loading supporting PowerShell Scripts" 
}

class ConfigurationManager {
    [Guid] hidden $ID = (New-Guid).Guid
    [string] $Configuration
    [string] $Content
    [string] $ConfigurationData
    [string] $DefaultConfigDir = "D:\repos\PowershellDSCExample\NO.PowershellDSC.Framework\configs"
    [string] $Command
    
    ConfigurationManager () {
    }

    ConfigurationManager ([String]$Configuration, [String]$ConfigurationData) {

        $this.Configuration = $Configuration
        $this.ConfigurationData = $ConfigurationData
        $this.Command = "$($this.Configuration) -ConfigurationData $($this.ConfigurationData) -Verbose"

        $this.Get()
    }

    [void] Get() {
        try {
            $this.Content = Get-Content -Path "$($this.DefaultConfigDir)\$($this.Configuration).ps1" -Raw
            Write-Verbose "$($MyInvocation.MyCommand) : Get Configuration"
        }
        catch {
            Write-Host "Error while loading supporting PowerShell Scripts" 
        }
    }

    [void] Create() {
        [string] $Config = $this.Content
        $Config += " `n"
        $Config += $this.Command
        $Config | Out-File -FilePath .\test.ps1
        Invoke-Expression $Config
        
    }

    [void] Load() {

        try {
            Get-ConfigFiles -Path $this.DefaultConfigDir | ForEach-Object {
                . $_.FullName
                Write-Verbose "$($MyInvocation.MyCommand.ToString()) : Configuration $($_.FullName) has been included"
            }
        }
        catch {
            Write-Host "Error while loading supporting PowerShell Scripts" 
        }

    }

    [void] LoadConfig() {

        try {
            Get-ConfigFiles -Path $this.DefaultConfigDir | ForEach-Object {
                . $_.FullName
                Write-Verbose "$($MyInvocation.MyCommand.ToString()) : Configuration $($_.FullName) has been included"
            }
        }
        catch {
            Write-Host "Error while loading supporting PowerShell Scripts" 
        }

    }
}

$dscconfig = [ConfigurationManager]::new('NO.PowershellDSC.default', 'D:\repos\PowershellDSCExample\NO.PowershellDSC.Framework\data\NO.PowershellDSC.ConfigManagement.default.psd1')
$dscconfig.Create()