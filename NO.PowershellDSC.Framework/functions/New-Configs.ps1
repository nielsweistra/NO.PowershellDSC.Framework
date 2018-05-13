function New-Configs ($Configuration, $ConfigurationData, $ConfigPath) {
    try {
        Get-ConfigFiles -Path $DefaultConfigDir| ForEach-Object {
            . $_.FullName
            Write-Verbose "Configuration $($_.FullName) has been included"
        }
    }
    catch {
        Write-Host "Error while loading supporting PowerShell Scripts" 
    }

    $CreateMofs = "$($Configuration) -ConfigurationData $($ConfigurationData) -Verbose"
    Invoke-Expression $CreateMofs
}