Get-ChildItem -Path $PSScriptRoot -Recurse -File | Unblock-File

try {
    Get-ChildItem -Path $PSScriptRoot -Recurse -File -Filter '*.ps1' | ForEach-Object {
        $match = ".(functions)|(includes)$"
        if ($_.DirectoryName -imatch $match) {
            . $_.FullName
            Write-Verbose "$($_.FullName) has been included"
        }
    }
}
catch {
    Write-Host "Error while loading supporting PowerShell Scripts" 
}
Show-NPDConsole