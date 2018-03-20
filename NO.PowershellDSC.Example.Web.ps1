#region 
    #
    # Mastering my Powershell skills and implementing Desired State Configuration
    #
#endregion

#region Functions

function Main {
    $caption = "BEWARE!"
    $message = "Are your ready to Deploy(Push) or Publish(Pull) the configs? Otherwise press Abort"
    $deploy = new-Object System.Management.Automation.Host.ChoiceDescription "&Deploy","help"
    $publish = new-Object System.Management.Automation.Host.ChoiceDescription "&Publish","help"
    $abort = new-Object System.Management.Automation.Host.ChoiceDescription "&Abort","help"
    $choices = [System.Management.Automation.Host.ChoiceDescription[]]($deploy,$publish,$abort)
    $answer = $host.ui.PromptForChoice($caption,$message,$choices,2)
    
    switch ($answer){
        0 {
            # Retrieve Webserver hosts from Configdata
            $Configdata = Import-PowerShellDataFile -Path .\ConfigData.psd1
            $webservers = $Configdata.Allnodes.Where({$_.Roles -contains 'Web'}).NodeName
            Start-DSCDeploy($webservers)
        }
        1 {
            #Write-Host "Not implemented yet"; break
            Publish-Configs -ConfigPath ".\NO.PowershellDSC.Example.Web"
        }
        2 {
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
        WindowsFeature DotNet45Core
        {
            Ensure                          = 'Present'
            Name                            = 'NET-Framework-45-Core'
        }
        WindowsFeature IIS
        {
            Ensure = 'Present'
            Name = 'Web-Server'
        }
         WindowsFeature AspNet45
        {
            Ensure                          = "Present"
            Name                            = "Web-Asp-Net45"
        }

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
            State                           = "Started"
            autoStart                       = $true
            CLRConfigFile                   = ''
            enable32BitAppOnWin64           = $false
            enableConfigurationOverride     = $true
            managedPipelineMode             = 'Integrated'
            managedRuntimeLoader            = 'webengine4.dll'
            managedRuntimeVersion           = 'v4.0'
            passAnonymousToken              = $true
            startMode                       = 'OnDemand'
            queueLength                     = 1000
            cpuAction                       = 'NoAction'
            cpuLimit                        = 90000
            cpuResetInterval                = (New-TimeSpan -Minutes 5).ToString()
            cpuSmpAffinitized               = $false
            cpuSmpProcessorAffinityMask     = 4294967295
            cpuSmpProcessorAffinityMask2    = 4294967295
            identityType                    = 'SpecificUser'
            idleTimeout                     = (New-TimeSpan -Minutes 20).ToString()
            idleTimeoutAction               = 'Terminate'
            loadUserProfile                 = $true
            logEventOnProcessModel          = 'IdleTimeout'
            logonType                       = 'LogonBatch'
            manualGroupMembership           = $false
            maxProcesses                    = 1
            pingingEnabled                  = $true
            pingInterval                    = (New-TimeSpan -Seconds 30).ToString()
            pingResponseTime                = (New-TimeSpan -Seconds 90).ToString()
            setProfileEnvironment           = $false
            shutdownTimeLimit               = (New-TimeSpan -Seconds 90).ToString()
            startupTimeLimit                = (New-TimeSpan -Seconds 90).ToString()
            orphanActionExe                 = ''
            orphanActionParams              = ''
            orphanWorkerProcess             = $false
            loadBalancerCapabilities        = 'HttpLevel'
            rapidFailProtection             = $true
            rapidFailProtectionInterval     = (New-TimeSpan -Minutes 5).ToString()
            rapidFailProtectionMaxCrashes   = 5
            autoShutdownExe                 = ''
            autoShutdownParams              = ''
            disallowOverlappingRotation     = $false
            disallowRotationOnConfigChange  = $false
            logEventOnRecycle               = 'Time,Requests,Schedule,Memory,IsapiUnhealthy,OnDemand,ConfigChange,PrivateMemory'
            restartMemoryLimit              = 0
            restartPrivateMemoryLimit       = 0
            restartRequestsLimit            = 0
            restartTimeLimit                = (New-TimeSpan -Minutes 1440).ToString()
            restartSchedule                 = @('00:00:00', '08:00:00', '16:00:00')
            DependsOn                       = "[WindowsFeature]IIS"
        }
        xWebsite Example.Web
        {
            Ensure = "Present"
            Name = "Example.Web"
            State = "Started"
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
# Create MOFs
NO.PowershellDSC.Example.Web -ConfigurationData .\ConfigData.psd1 -Verbose

# Retrieve Webserver hosts from Configdata
$Configdata = Import-PowerShellDataFile -Path .\ConfigData.psd1
$webservers = $Configdata.Allnodes.Where({$_.Roles -contains 'Web'}).NodeName

# Start deploy
Start-DSCDeploy($webservers)