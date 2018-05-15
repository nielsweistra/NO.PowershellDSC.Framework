using module "..\internal\NO.PowershellDSC.Framework.ConfigurationManager.psm1"
[CmdletBinding()]
param(
)
function New-Configs {
[CmdletBinding()]
param($ConfigurationName, $ConfigurationData, $ConfigPath) 

    $Configuration = [ConfigurationManager]::new($ConfigurationName, $ConfigurationData)
    $Configuration.Create()

}