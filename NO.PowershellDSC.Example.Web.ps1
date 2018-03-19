function Start-DSCDeploy($target) {

    $cso = New-CimSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -UseSsl
    $session = New-CimSession -Credential administrator -Port 5986 -SessionOption $cso -ComputerName $target 
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

# Create MOFs
NO.PowershellDSC.Example.Web -ConfigurationData .\ConfigData.psd1 -Verbose

# Retrieve Webserver hosts from Configdata
$Configdata = Import-PowerShellDataFile -Path .\ConfigData.psd1
$webservers = $Configdata.Allnodes.Where({$_.Roles -contains 'Web'}).NodeName

# Start deploy
Start-DSCDeploy($webservers)