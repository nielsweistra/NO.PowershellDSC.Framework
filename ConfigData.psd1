@{
    AllNodes = 
    @(
        @{
            NodeName = 'SRVWINTST02'
            Roles = @('Web')
            PSDscAllowDomainUser = $true
            PSDscAllowPlainTextPassword = $true
        },
        @{
            NodeName = 'SRVWINTST01'
            Roles = @('web')
            PSDscAllowDomainUser = $true
            PSDscAllowPlainTextPassword = $true
        }	
    )
}