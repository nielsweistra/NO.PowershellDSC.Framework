@{
    AllNodes = 
    @(
        @{
            NodeName = 'SRVWINTST02'
            Roles = @('WebServer_Custom')
            Description = 'Customized IIS Webserver'
            PSDscAllowDomainUser = $true
            PSDscAllowPlainTextPassword = $true
        },
        @{
            NodeName = 'SRVWINTST03'
            Roles = @('WebServer_Default')
            Description = 'Basic IIS Webserver'
            PSDscAllowDomainUser = $true
            PSDscAllowPlainTextPassword = $true
        }
    )
}