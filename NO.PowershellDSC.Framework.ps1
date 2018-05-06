#region Include required files
#
$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
try {
    . ("$ScriptDirectory\includes\fun.ps1")
}
catch {
    Write-Host "Error while loading supporting PowerShell Scripts" 
}
#endregion

#region Functions
function Main {
    Console
}
function Console {
    #region variables
    $caption = "BEWARE!"
    $message = "Are your ready to Deploy(Push) or Publish(Pull) the configs? Otherwise press Abort"
    $create = new-Object System.Management.Automation.Host.ChoiceDescription "&Create","help"
    $deploy = new-Object System.Management.Automation.Host.ChoiceDescription "&Deploy","help"
    $publish = new-Object System.Management.Automation.Host.ChoiceDescription "&Publish","help"
    $publishmods = new-Object System.Management.Automation.Host.ChoiceDescription "Publish &Modules","help"
    $abort = new-Object System.Management.Automation.Host.ChoiceDescription "&Abort","help"
    $choices = [System.Management.Automation.Host.ChoiceDescription[]]($deploy, $publish, $publishmods, $create, $abort)
    #endregion
    #region menu
    $answer = $host.ui.PromptForChoice($caption,$message,$choices,4)
    switch ($answer){
        0 {
            # Retrieve Webserver hosts from Configdata
            $Configdata = Import-PowerShellDataFile -Path .\ConfigData.psd1
            $webservers = $Configdata.Allnodes.Where({$_.Roles -contains 'Web'}).NodeName
            Start-DSCDeploy($webservers)
        }
        1 {
            Publish-Configs -ConfigPath ".\NO.PowershellDSC.ConfigManagement"
        }
        2 {
            Publish-Modules
        }
        3 {
            try {
                . ("$ScriptDirectory\configs\*")
            }
            catch {
                Write-Host "Error while loading Configurations" 
            }
            
            $DefaultConfig = "NO.PowershellDSC.ConfigManagement.default"
            $DefaultConfigData = ".\data\NO.PowershellDSC.ConfigManagement.default"

            $Config = Read-Host "What is the name of the configuration or enter for using the default [$($DefaultConfig)]" 
            if([string]::IsNullOrEmpty($Config))
            {
                $Config = $DefaultConfig
            }

            $ConfigData = Read-Host "What is the name of the configuration data file or enter for using the default [$($DefaultConfigData)]" 
            if([string]::IsNullOrEmpty($ConfigData))
            {
                $ConfigData = $DefaultConfigData
            }

            Create-Configs -Configuration $Config -ConfigurationData $ConfigData
            Console
        }
        4 {
            "Exiting..."; break
        }
    }
    #endregion
}
function Start-DSCDeploy($Target) {

    $cso = New-CimSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -UseSsl
    $session = New-CimSession -Credential administrator -Port 5986 -SessionOption $cso -ComputerName $Target 
    $caption = "Confirm"
    $message = "Are you sure?"
    $yes = new-Object System.Management.Automation.Host.ChoiceDescription "&Yes","help"
    $no = new-Object System.Management.Automation.Host.ChoiceDescription "&No","help"
    $choices = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no)
    $answer = $host.ui.PromptForChoice($caption,$message,$choices,0)

    switch ($answer){
        0 {
            Start-DscConfiguration -Path ./NO.PowershellDSC.ConfigManagement -Wait -Verbose -CimSession $session -Force 
        }
        1 {
            "Exiting..."; break
        }
    }
}
function Start-DSCDeployRoles($Target) {
    write-host "Not implemented yet"
}

function Start-DSCDeployNodes($Target) {
    write-host "Not implemented yet"
}
function Publish-Configs($ConfigPath, $ConfigPullPath) {
    if (([string]::IsNullOrEmpty($ConfigPullPath)))
    {
        $PullConfigPath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"
    }
    else {
        $PullConfigPath = $ConfigPullPath
    }
    New-DscChecksum -Path $PullConfigPath
    
    $WebConfigPath = "$($ConfigPath)\*"
    Copy-Item -Path $WebConfigPath -Destination $PullConfigPath -Recurse
    
}
function Publish-Modules {
    Write-Host "Not implemented yet"; break
    
    # This code will not be executed
    # I wish to have a function that strips the name of de modules used in de configuration section
    # Import-DscResource -ModuleName PSDesiredStateConfiguration
    #                                ^^^^^^^^^^^^^^^^^^^^^^^^^^^ I need a regex for this
    # Import-DscResource -Name or other combinations
    # This function need to loop through all modules, download, package and published to the dsc pull service
    # For now.... just do it manually by running the code below

    $ModuleName = 'xWebAdministration'
    $Version = (Get-Module $ModuleName -ListAvailable).Version
    $ModulePath = (Get-Module $ModuleName -ListAvailable).modulebase+'\*'
    $DestinationPath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules\$($ModuleName)_$($Version).zip"
    Compress-Archive -Path $ModulePath -DestinationPath $DestinationPath
    New-DscChecksum -Path $DestinationPath
}
function Create-Configs ($Configuration, $ConfigurationData) {
    $CreateMofs = "$($Configuration) -ConfigurationData $($ConfigurationData) -Verbose"
    $result = Invoke-Expression $CreateMofs
    return $result
}
function List-ConfigFiles {

}
function List-ConfigDataFiles($Target) {
    write-host "Not implemented yet"
}
#endregion Functions

# Start Main
Main