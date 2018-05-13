function Publish-Configs($ConfigPath, $ConfigPullPath) {
    if (([string]::IsNullOrEmpty($ConfigPullPath))) {
        $PullConfigPath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"
    }
    else {
        $PullConfigPath = $ConfigPullPath
    }
    New-DscChecksum -Path $PullConfigPath
    
    $WebConfigPath = "$($ConfigPath)\*"
    Copy-Item -Path $WebConfigPath -Destination $PullConfigPath -Recurse
    
}