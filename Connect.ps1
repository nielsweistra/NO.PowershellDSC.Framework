$hostName = "idl-tst-nw-01" # example: "mywindowsvm.westus.cloudapp.azure.com"
$winrmPort = "5986"

# Get the credentials of the machine
$cred = Get-Credential

# Connect to the machine
$soptions = New-PSSessionOption -SkipCACheck -SkipCNCheck
Enter-PSSession -ComputerName $hostName -Port $winrmPort -Credential $cred -SessionOption $soptions -UseSSL