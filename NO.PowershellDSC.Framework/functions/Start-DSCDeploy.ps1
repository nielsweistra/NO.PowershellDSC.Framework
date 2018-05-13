function Start-DSCDeploy {
    [CmdletBinding()]
Param(
    $Target        
)

    $caption = "Confirm"
    $message = "Are you sure?"
    $yes = new-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "help"
    $no = new-Object System.Management.Automation.Host.ChoiceDescription "&No", "help"
    $choices = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    $answer = $host.ui.PromptForChoice($caption, $message, $choices, 0)

    switch ($answer) {
        0 {
            $cso = New-CimSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -UseSsl
            $session = New-CimSession -Credential administrator -Port 5986 -SessionOption $cso -ComputerName $Target
            Start-DscConfiguration -Path ./NO.PowershellDSC.ConfigManagement -Wait -Verbose -CimSession $session -Force
            Remove-CimSession -CimSession $session
        }
        1 {
            "Exiting..."; break
        }
    }
}