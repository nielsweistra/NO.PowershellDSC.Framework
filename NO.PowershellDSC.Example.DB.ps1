Configuration NO.PowershellDSC.Example.DB
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        $SqlInstallCredential,

        [Parameter()]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        $SqlAdministratorCredential = $SqlInstallCredential,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        $SqlServiceCredential,

        [Parameter()]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        $SqlAgentServiceCredential = $SqlServiceCredential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xWebAdministration
    Import-DscResource -ModuleName xSQLServer
    Import-DscResource -ModuleName SqlServerDsc

    # Database Role
    Node $AllNodes.Where({$_.Roles -contains 'Database'}).NodeName
    {
        #region Install prerequisites for SQL Server
        WindowsFeature 'NetFramework35'
        {
            Name   = 'NET-Framework-Core'
            Source = '\\fileserver.company.local\images$\Win2k12R2\Sources\Sxs' # Assumes built-in Everyone has read permission to the share and path.
            Ensure = 'Present'
        }

        WindowsFeature 'NetFramework45'
        {
            Name   = 'NET-Framework-45-Core'
            Ensure = 'Present'
        }
        #endregion Install prerequisites for SQL Server

        #region Install SQL Server
        SqlSetup 'InstallDefaultInstance'
        {
            InstanceName         = 'MSSQLSERVER'
            Features             = 'SQLENGINE,AS'
            SQLCollation         = 'SQL_Latin1_General_CP1_CI_AS'
            SQLSvcAccount        = $SqlServiceCredential
            AgtSvcAccount        = $SqlAgentServiceCredential
            ASSvcAccount         = $SqlServiceCredential
            SQLSysAdminAccounts  = 'COMPANY\SQL Administrators', $SqlAdministratorCredential.UserName
            ASSysAdminAccounts   = 'COMPANY\SQL Administrators', $SqlAdministratorCredential.UserName
            InstallSharedDir     = 'C:\Program Files\Microsoft SQL Server'
            InstallSharedWOWDir  = 'C:\Program Files (x86)\Microsoft SQL Server'
            InstanceDir          = 'C:\Program Files\Microsoft SQL Server'
            InstallSQLDataDir    = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data'
            SQLUserDBDir         = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data'
            SQLUserDBLogDir      = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data'
            SQLTempDBDir         = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data'
            SQLTempDBLogDir      = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data'
            SQLBackupDir         = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup'
            ASServerMode         = 'TABULAR'
            ASConfigDir          = 'C:\MSOLAP\Config'
            ASDataDir            = 'C:\MSOLAP\Data'
            ASLogDir             = 'C:\MSOLAP\Log'
            ASBackupDir          = 'C:\MSOLAP\Backup'
            ASTempDir            = 'C:\MSOLAP\Temp'
            SourcePath           = 'C:\InstallMedia\SQL2016RTM'
            UpdateEnabled        = 'False'
            ForceReboot          = $false

            PsDscRunAsCredential = $SqlInstallCredential

            DependsOn            = '[WindowsFeature]NetFramework35', '[WindowsFeature]NetFramework45'
        }
        #endregion Install SQL Server
    }
}

NO.PowershellDSC.Example -ConfigurationData .\ConfigData.psd1 -Verbose

$cso = New-CimSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -UseSsl
$session = New-CimSession -Credential administrator -Port 5986 -SessionOption $cso -ComputerName "srvwintst02"

$caption = "Confirm"
$message = "Are you sure?"
$yes = new-Object System.Management.Automation.Host.ChoiceDescription "&Yes","help"
$no = new-Object System.Management.Automation.Host.ChoiceDescription "&No","help"
$choices = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no)
$answer = $host.ui.PromptForChoice($caption,$message,$choices,0)

switch ($answer){
    0 {
        Start-DscConfiguration -Path ./NO.PowershellDSC.Example.DB -Wait -Verbose -CimSession $session -Force
    }
    1 {
        "Exiting..."; break
    }
}

