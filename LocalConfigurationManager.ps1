[DscLocalConfigurationManager()]
Configuration LocalConfigurationManager
{

    Node $AllNodes.NodeName
    {
        Settings
        {
            RefreshMode = 'Push'
            AllowModuleOverwrite = $True
            # A configuration Id needs to be specified, known bug
            ConfigurationID = '3a15d863-bd25-432c-9e45-9199afecde91'
            ConfigurationMode = 'ApplyAndAutoCorrect'
            RebootNodeIfNeeded = $True   
        }

        ResourceRepositoryShare FileShare
        {
            SourcePath = '\\prm-core-dc\DscResources\'
        }
    }
}
LocalConfigurationManager -ConfigurationData $configurationData -OutputPath C:\Dsc\Mof -Verbose

Set-DscLocalConfigurationManager -Path C:\Dsc\Mof -Verbose
Start-DSCConfiguration -Path C:\Dsc\Mof -Wait -Verbose -Force