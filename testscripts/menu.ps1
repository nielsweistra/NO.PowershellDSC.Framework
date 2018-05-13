


Function New-Console {
    If (-Not(Get-Menu -Name "Main")) {

        Set-MenuOption -Heading "NO.PowershellDSC.Framework" -SubHeading "Nelsonline @ DevopsMania" -MenuFillChar "#" -MenuFillColor DarkYellow
        Set-MenuOption -HeadingColor DarkCyan -MenuNameColor DarkGray -SubHeadingColor Green -FooterTextColor DarkGray -FooterText "** Created by a DevopsGuru - 2018 - NO.PowershellDSC.Framework **"
        Set-MenuOption -MaxWith 100
        
        New-Menu -Name "Main"
        New-Menu -Name "SubMenu" -DisplayName "*** SubMenu1 ***"
    
        # Add a menuitem to the main menu
        New-MenuItem -Name "Exit" -DisplayName "Exit.." -Action {$script; break} -MenuName "Main" -DisableConfirm
        New-MenuItem -Name "Create" -DisplayName "Create Configuration" -Action {Write-Host Create; Show-Menu} -MenuName "Main" -DisableConfirm
        New-MenuItem -Name "Deploy" -DisplayName "Deploy Configuration" -Action {Write-Host Deploy} -MenuName "Main" -DisableConfirm
        New-MenuItem -Name "Publish" -DisplayName "Publish Configuration to DSC Service" -Action {Write-Host Publish} -MenuName "Main" -DisableConfirm
        New-MenuItem -Name "InstallSubMenu" -DisplayName "Install -->" -MenuName "Main" -DisableConfirm -Action {
            Clear-Host
            Show-Menu -MenuName SubMenu
        }
        New-MenuItem -Name "InstallDSCPullService" -DisplayName "Install DSC Pull Service" -MenuName "SubMenu" -Action {
            Clear-Host
            Show-Menu
        }
        New-MenuItem -Name "GoToMain" -DisplayName "Go to Main Menu" -MenuName "SubMenu" -Action {
            Clear-Host
            Show-Menu
        }
    }
    else {
        Remove-Variable -Name "Menu*" -scope "Script" 
    }
    clear-host
    Show-Menu
}

Function Main {
    New-Console
}

Main