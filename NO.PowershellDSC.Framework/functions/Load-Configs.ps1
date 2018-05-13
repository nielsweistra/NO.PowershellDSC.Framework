function Load-Configs {
    [CmdletBinding()]
    param
    (
        $Path
    )

    
    try {
        $result = Get-ConfigFiles | ForEach-Object {
            . $_.FullName
            Write-Verbose "Configuration $($_.FullName) has been included"
        }
    }
    catch {
        Write-Host "Error while loading supporting PowerShell Scripts" 
    }
    return $result
}