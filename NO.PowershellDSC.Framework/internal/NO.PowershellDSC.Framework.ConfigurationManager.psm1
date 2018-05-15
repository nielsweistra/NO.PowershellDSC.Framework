Using module ".\NO.PowershellDSC.Framework.NPDBase.psm1"
[CmdletBinding()]
param(
)
class ConfigurationManager : NPDBase {
    [Guid] hidden $ID = (New-Guid).Guid
    [string] $Configuration
    [string] $Content
    [string] $ConfigurationData
    [string] $DefaultConfigDir = "D:\repos\PowershellDSCExample\NO.PowershellDSC.Framework\configs"
    [string] $Command
    
    ConfigurationManager () {
    }

    ConfigurationManager ([String]$Configuration, [String]$ConfigurationData) {

        $this._Initiator = $Script:MyInvocation.MyCommand
        $this.AddPublicMember()

        $this.Configuration = $Configuration
        $this.ConfigurationData = $ConfigurationData
        $this.Command = "$($this.Configuration) -ConfigurationData $($this.ConfigurationData) -Verbose"
        Write-Verbose "Instance created by $($this.Initiator)"

        $this.Get()
    }

    [void] Get() {

        try {
            Write-Verbose "$($this.Initiator) : Get Configuration"
            $this.Content = Get-Content -Path "$($this.DefaultConfigDir)\$($this.Configuration).ps1" -Raw -ErrorAction Stop
        }
        catch {
            Write-Error "$($_.Exception.Message)" 
        }
    }

    [void] Create() {

        Write-Verbose "$($this.Initiator) : Create Configuration"
        [string] $Config = $this.Content
        $Config += " `n"
        $Config += $this.Command
        $Config | Out-File -FilePath .\test.ps1
        Invoke-Expression $Config
        
    }

    [void] Load() {

        [string] $Config = $this.Content
        Invoke-Expression $Config
    }
}