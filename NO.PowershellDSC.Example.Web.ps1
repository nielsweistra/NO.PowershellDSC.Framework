# region Include required files
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
    $caption = "BEWARE!"
    $message = "Are your ready to Deploy(Push) or Publish(Pull) the configs? Otherwise press Abort"
    $create = new-Object System.Management.Automation.Host.ChoiceDescription "&Create","help"
    $deploy = new-Object System.Management.Automation.Host.ChoiceDescription "&Deploy","help"
    $publish = new-Object System.Management.Automation.Host.ChoiceDescription "&Publish","help"
    $publishmods = new-Object System.Management.Automation.Host.ChoiceDescription "Publish &Modules","help"
    $abort = new-Object System.Management.Automation.Host.ChoiceDescription "&Abort","help"
    $choices = [System.Management.Automation.Host.ChoiceDescription[]]($deploy, $publish, $publishmods, $create, $abort)
    $answer = $host.ui.PromptForChoice($caption,$message,$choices,4)
    
    switch ($answer){
        0 {
            # Retrieve Webserver hosts from Configdata
            $Configdata = Import-PowerShellDataFile -Path .\ConfigData.psd1
            $webservers = $Configdata.Allnodes.Where({$_.Roles -contains 'Web'}).NodeName
            Start-DSCDeploy($webservers)
        }
        1 {
            Publish-Configs -ConfigPath ".\NO.PowershellDSC.Example.Web"
        }
        2 {
            Publish-Modules
        }
        3 {
            Create-Configs
        }
        4 {
            "Exiting..."; break
        }
    }  
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
            Start-DscConfiguration -Path ./NO.PowershellDSC.Example.Web -Wait -Verbose -CimSession $session -Force 
        }
        1 {
            "Exiting..."; break
        }
    }
}
function Publish-Configs($ConfigPath, $ConfigPullPath) {
    if (([string]::IsNullOrEmpty($ConfigPullPath)))
    {
        $PullConfigPath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"
    }
    else {
        $PullConfigPath = $ConfigPullPath
    }
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
function Create-Configs {
    # Create MOFs
    NO.PowershellDSC.Example.Web -ConfigurationData .\ConfigData.psd1 -Verbose
}
#endregion Functions
#region Configurations
Configuration NO.PowershellDSC.Example.Web
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xWebAdministration

    # Web Role
    Node $AllNodes.Where({$_.Roles -contains 'Web'}).NodeName
    {
        # Configure for web server role
        #WindowsFeature DotNet45Core
        #{
        #    Ensure                          = 'Present'
        #    Name                            = 'NET-Framework-45-Core'
        #}
        WindowsFeature IIS
        {
            Ensure = 'Present'
            Name = 'Web-Server'
        }
         #WindowsFeature AspNet45
        #{
        #    Ensure                          = "Present"
         #   Name                            = "Web-Asp-Net45"
        #}

        # Configure Example.Web
        File Example.Web
        {
            Ensure                          = "Present"
            Type                            = "Directory"
            DestinationPath                 = "C:\inetpub\Example.Web"
        }
        xWebAppPool Example.Web
        {
            Ensure                          = "Present"
            Name                            = "Example.Web"
            State                           = "Stopped"
            autoStart                       = $false
            DependsOn                       = "[WindowsFeature]IIS"
        }
        xWebsite Example.Web
        {
            Ensure = "Present"
            Name = "Example.Web"
            State = "Stopped"
            PhysicalPath = "C:\inetpub\Example.Web"
            BindingInfo = MSFT_xWebBindingInformation
            {
                Protocol = 'http'
                Port = '80'
                HostName = $Node.NodeName
                IPAddress = '*'
            }
            ApplicationPool = "Example.Web"
            DependsOn = "[xWebAppPool]Example.Web"
        }

        # Configure for development mode only
        WindowsFeature IISTools
        {
            Ensure = "Present"
            Name = "Web-Mgmt-Tools"
        }

        # Clean up the uneeded website and application pools
        xWebsite Default
        {
            Ensure = "Absent"
            Name = "Default Web Site"
        }
        xWebAppPool NETv45
        {
            Ensure = "Absent"
            Name = ".NET v4.5"
        }
        xWebAppPool NETv45Classic
        {
            Ensure = "Absent"
            Name = ".NET v4.5 Classic"
        }
        xWebAppPool Default
        {
            Ensure = "Absent"
            Name = "DefaultAppPool"
        }
        File wwwroot
        {
            Ensure = "Absent"
            Type = "Directory"
            DestinationPath = "C:\inetpub\wwwroot"
            Force = $True
        }
    }
}
#endregion Configurations


# Start Main
Main