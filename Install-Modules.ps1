$Configdata = Import-PowerShellDataFile -Path .\ConfigData.psd1
$webservers = $Configdata.Allnodes.Where({$_.Roles -contains 'Web'}).NodeName

$cred = get-credential

$cso = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck

$session = New-PSSession -ComputerName $webservers -Credential $cred -port "5986" -SessionOption $cso -UseSSL

Invoke-Command -Session $session -ScriptBlock {Install-Package -Name xWebAdministration}