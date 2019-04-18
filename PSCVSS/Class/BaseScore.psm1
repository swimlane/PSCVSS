class BaseScore {
    [Single] $AttackVector = 1
    [Single] $AttackComplexity = 1
    [Single] $PrivilegeRequired = 1
    [Single] $UserInteraction = 0.85
    [Single] $Scope = 1
    [Single] $Confidentiality = 1
    [Single] $Integrity = 1
    [Single] $Availability = 1
    [Double] $ExploitabilitySubScore
    [Double] $ImpactSubScoreBaseScore
    [Double] $ImpactSubScore
    [Double] $BaseScore


    BaseScore() {
    }

    [Void] CalculateExploitabilitySubScore (){
        $this.ExploitabilitySubScore = [Single] 8.22 * $this.AttackVector * $this.AttackComplexity * $this.PrivilegeRequired * $this.UserInteraction
    }

    [Double] GetExploitabilitySubScore(){
        return $this.ExploitabilitySubScore
    }

    [Void] CalculateImpactSubScoreBaseScore (){
        $this.ImpactSubScoreBaseScore = (1 - ((1 - $this.Confidentiality) * (1 - $this.Integrity) * (1 - $this.Availability)))
    }

    [Double] GetImpactSubScoreBaseScore (){
        return $this.ImpactSubScoreBaseScore
    }

    [Void] CalculateImpactSubScore (){
        if ($this.Scope -eq 6.42){
            $this.ImpactSubScore = $this.Scope * $this.ImpactSubScoreBaseScore
        }
        else{
            $this.ImpactSubScore = $this.Scope * ($this.ImpactSubScoreBaseScore - 0.029) - 3.25 * [Math]::Pow(($this.ImpactSubScoreBaseScore - 0.02), 15)
        }
    }

    [Double] GetImpactSubScore (){
        return $this.ImpactSubScore
    }

    [Void] CalculateBaseScore (){
        if ($this.ImpactSubScore -le 0){
            $this.BaseScore = 0
        }
        else{
            if ($this.Scope -eq 6.42){
                $this.BaseScore = [Math]::Min($this.ExploitabilitySubScore + $this.ImpactSubScore, 10)
            }
            else{
                $this.BaseScore = [Math]::Min(($this.ExploitabilitySubScore + $this.ImpactSubScore) * 1.08, 10)
            }
        }        
    }

    [Double] GetBaseScore (){
        return [Math]::Ceiling($this.BaseScore * [Math]::Pow(10, 1)) / [Math]::Pow(10,1)
    }

    [Void] CalculateScore(){
        $this.CalculateExploitabilitySubScore()
        Write-Debug -Message "Base Exploitability Sub Score is $($this.ExploitabilitySubScore)"

        $this.CalculateImpactSubScoreBaseScore()
        Write-Debug -Message "Base Impact Sub Score Base Score is $($this.ImpactSubScoreBaseScore)"
        
        $this.CalculateImpactSubScore()
        Write-Debug -Message "Base Impact Sub Score is $($this.ImpactSubScore)"

        $this.CalculateBaseScore()
        Write-Debug -Message "Base Score is $($this.BaseScore)"
    }
}