using module "..\internal\NO.PowershellDSC.Framework.ConfigurationManager.psm1"

function Show-NPDConsole {
[CmdletBinding()]
param(
)
    $DefaultConfigData = "$($PWD)\data\NO.PowershellDSC.ConfigManagement.default.psd1"
    $DefaultConfigDir = "$($PWD)\configs"
    $DefaultConfig = "NO.PowershellDSC.default"

    if (([string]::IsNullOrEmpty($config) -and ([string]::IsNullOrEmpty($ConfigData)))) {
        $Config = Read-Host "What is the name of the configuration or enter for using the default [$($DefaultConfig)]" 
        if ([string]::IsNullOrEmpty($Config)) {
            $Config = $DefaultConfig
        }
        
        $ConfigData = Read-Host "What is the name of the configuration data file or enter for using the default [$($DefaultConfigData)]" 
        if ([string]::IsNullOrEmpty($ConfigData)) {
            $ConfigData = $DefaultConfigData
        }
    }
    $caption = "BEWARE!"
    $message = "Are your ready to Deploy(Push) or Publish(Pull) the configs? Otherwise press Abort"
    $create = new-Object System.Management.Automation.Host.ChoiceDescription "&Create", "help"
    $deploy = new-Object System.Management.Automation.Host.ChoiceDescription "&Deploy", "help"
    $publish = new-Object System.Management.Automation.Host.ChoiceDescription "&Publish", "help"
    $publishmods = new-Object System.Management.Automation.Host.ChoiceDescription "Publish &Modules", "help"
    $abort = new-Object System.Management.Automation.Host.ChoiceDescription "&Abort", "help"
    $choices = [System.Management.Automation.Host.ChoiceDescription[]]($deploy, $publish, $publishmods, $create, $abort)
    $answer = $host.ui.PromptForChoice($caption, $message, $choices, 4)
    
    switch ($answer) {
        0 {
            $caption = "Deploy"
            $message = "Deploy to All"
            $AllChoice = new-Object System.Management.Automation.Host.ChoiceDescription "&All", "help"
            $RoleChoice = new-Object System.Management.Automation.Host.ChoiceDescription "&Role", "help"
            $HostChoice = new-Object System.Management.Automation.Host.ChoiceDescription "&Host", "help"
            $abort = new-Object System.Management.Automation.Host.ChoiceDescription "&Abort", "help"
            $choices = [System.Management.Automation.Host.ChoiceDescription[]]($AllChoice, $RoleChoice, $HostChoice, $abort)
            $answer = $host.ui.PromptForChoice($caption, $message, $choices, 3)
                
            switch ($answer) {
                0 {
                    
                    $Target = Import-PowerShellDataFile -Path $ConfigData 
                    Start-DSCDeploy($Target.Allnodes.NodeName)
                }
                1 {
                    Write-Host "Role"
                    $Configdata = Import-PowerShellDataFile -Path $ConfigData 
                    
                    $DefaultTargetRole = "WebServer_Default"

                    
                    $Target = Read-Host "What is the name of the Role you want to deploy or enter for using the default [$($DefaultTargetRole)]" 
                    if ([string]::IsNullOrEmpty($Target)) {
                        $target = $Configdata.Allnodes.Where( {$_.Roles -eq "WebServer_Default"}).NodeName
                        Start-DSCDeploy($target)
                    }
                }
                2 {
                    Write-host "Host"
                }
                3 {
                    Write-host "Abort"; break
                }
            }          
        }
        1 {
            Publish-Configs -ConfigPath "..\NO.PowershellDSC.ConfigManagement"
        }
        2 {
            Publish-Modules
        }
        3 {         
            #New-Configs -Configuration $Config -ConfigurationData $ConfigData -Path $DefaultConfigDir
            New-Configs -ConfigurationName $Config -ConfigurationData $ConfigData

            Show-NPDConsole
        }
        4 {
            "Exiting..."; break
        }
    }
}