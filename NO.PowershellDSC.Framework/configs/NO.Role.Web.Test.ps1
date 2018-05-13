Configuration NO.Role.Web.Test
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xWebAdministration

    Node $AllNodes.Where({$_.Roles -contains 'WebServer_Default'}).NodeName
    {
        # Configure for web server role
        WindowsFeature DotNet45Core
        {
            Ensure                          = 'Present'
            Name                            = 'NET-Framework-45-Core'
        }
        WindowsFeature IIS
        {
            Ensure                          = 'Present'
            Name                            = 'Web-Server'
        }     
        WindowsFeature AspNet45
        {
            Ensure                          = "Present"
            Name                            = "Web-Asp-Net45"
        }        
    }
}