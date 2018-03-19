configuration Install-xDscPullServer
{
    param
    (
            [string[]]$NodeName = 'localhost',

            [ValidateNotNullOrEmpty()]
            [string] $certificateThumbPrint,

     
            [string] $RegistrationKey
     )

     Import-DSCResource -ModuleName PSDesiredStateConfiguration
     Import-DscResource -ModuleName XPSDesiredStateConfiguration

     Node $NodeName
     {
         WindowsFeature DSCServiceFeature
         {
             Ensure = 'Present'
             Name   = 'DSC-Service'
         }

         xDscWebService PSDSCPullServer
         {
             Ensure                   = 'Present'
             EndpointName             = 'PSDSCPullServer'
             Port                     = 8080
             PhysicalPath             = "$env:SystemDrive\inetpub\PSDSCPullServer"
             CertificateThumbPrint    = $certificateThumbPrint
             ModulePath               = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
             ConfigurationPath        = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"
             State                    = 'Started'
             DependsOn                = '[WindowsFeature]DSCServiceFeature'
             UseSecurityBestPractices = $false
         }

        File RegistrationKeyFile
        {
            Ensure          = 'Present'
            Type            = 'File'
            DestinationPath = "$env:ProgramFiles\WindowsPowerShell\DscService\RegistrationKeys.txt"
            Contents        = $RegistrationKey
        }

        File CertThumPrintFile
        {
            Ensure          = 'Present'
            Type            = 'File'
            DestinationPath = "$env:ProgramFiles\WindowsPowerShell\DscService\CertThumPrintFile.txt"
            Contents        = $RegistrationKey
        }
    }
}