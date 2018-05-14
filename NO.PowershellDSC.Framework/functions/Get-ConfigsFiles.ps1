function Get-ConfigFiles {
    [CmdletBinding()]
    param
    (
        $Path = "D:\repos\PowershellDSCExample\NO.PowershellDSC.Framework\configs"
    )

    $FileList = [System.Collections.Generic.List[PSCustomObject]]::New()
    
    try {
        Get-ChildItem -Path $Path -Recurse -File -Filter '*.ps1' | ForEach-Object {
            $FileList += [PSCustomObject]@{

                Name     = $_.Name
                FullName = $_.FullName    
            }    
            Write-Verbose "$($pscmdlet.MyInvocation.MyCommand.ToString()) : Configuration $($_.FullName) found!"
        }
    }
    catch {
        Write-Host "Error while loading supporting PowerShell Scripts" 
    }
    return $FileList
}