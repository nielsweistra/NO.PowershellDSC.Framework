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
    $ModulePath = (Get-Module $ModuleName -ListAvailable).modulebase + '\*'
    $DestinationPath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules\$($ModuleName)_$($Version).zip"
    Compress-Archive -Path $ModulePath -DestinationPath $DestinationPath
    New-DscChecksum -Path $DestinationPath
}