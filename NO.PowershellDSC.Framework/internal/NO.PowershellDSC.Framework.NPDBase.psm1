class NPDBase {

    hidden [string] $_Initiator = $null

    NPDBase() {
    
    }

    [string] GetInitiator () {

        Return $this._Initiator
        
    }

    hidden AddPublicMember() {
        $Members = $this | Get-Member -Force -MemberType Property -Name '_*'
        ForEach ($Member in $Members) {
            $PublicPropertyName = $Member.Name -replace '_', ''
            # Define getter part
            $Getter = "return `$this.{0}" -f $Member.Name
            $Getter = [ScriptBlock]::Create($Getter)
            # Define setter part
            $Setter = "Write-Warning 'This is a readonly property.'"
            $Setter = [ScriptBlock]::Create($Setter)
    
            $AddMemberParams = @{
                Name = $PublicPropertyName
                MemberType = 'ScriptProperty'
                Value = $Getter
                SecondValue = $Setter
            }
            $this | Add-Member @AddMemberParams
        }
    }
    
}