[CmdletBinding()]
param(
    
) 
Get-ChildItem -Path $PSScriptRoot -Recurse -File | Unblock-File


try {
    Get-ChildItem -Path $PSScriptRoot -Recurse -File -Filter '*.ps1' | ForEach-Object {
        
        if ($_.DirectoryName -imatch '.+\\NO.PowershellDSC.Framework\\(functions|includes)$') {
            . $_.FullName
            Write-Verbose "$($_.FullName) has been included"
        }
    }
}
catch {
    Write-Host $_.Exception.Message
}