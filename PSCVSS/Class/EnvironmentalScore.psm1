class EnvironmentalScore {
    [Single] $ConfidentialityRequirement = 1
    [Single] $IntegrityRequirement = 1
    [Single] $AvailabilityRequirement = 1
    [Single] $ModifiedAttackVector = 1
    [Single] $ModifiedAttackComplexity = 1
    [Single] $ModifiedPrivilegesRequired = 1
    [Single] $ModifiedUserInteraction = 1
    [Single] $ModifiedScope = 1
    [String] $ModifiedScopeStatus = 'Unchanged'
    [Single] $ModifiedConfidentiality = 1
    [Single] $ModifiedIntegrity = 1
    [Single] $ModifiedAvailability = 1

    [Double] $ModifiedExploitabilitySubScore
    [Double] $ModifiedImpactMULScore
    [Double] $ModifiedImpactSubScore
    [Double] $ModifiedBaseSubScore
    [Double] $CVSSScore


    EnvironmentalScore() {
    }

    [String] getFormattedValue($value){
        $intNumber = ($value).ToString().Split('.')[0]
        $decNumber = ($value).ToString().Split('.')[1][0]
        return "$intNumber.$decNumber"
    }

    [Void] CalculateModifiedExploitabilitySubScore(){
        $this.ModifiedExploitabilitySubScore = 8.22 * $this.ModifiedAttackVector * $this.ModifiedAttackComplexity * $this.ModifiedPrivilegesRequired * $this.ModifiedUserInteraction
    }

    [Double] GetModifiedExploitabilitySubScore(){
        return $this.ModifiedExploitabilitySubScore
    }

    [Void] CalculateModifiedImpactMULScore (){
        $this.ModifiedImpactMULScore = [Math]::Min((1 - (1 - $this.ModifiedConfidentiality * $this.ConfidentialityRequirement) * (1 - $this.ModifiedIntegrity * $this.IntegrityRequirement) * (1 - $this.ModifiedAvailability * $this.AvailabilityRequirement)), 0.915)
    }

    [Double] GetModifiedImpactMULScore (){
        return $this.ModifiedImpactMULScore
    }

    [Void] CalculateModifiedImpactSubScore(){
        if (($this.ModifiedScope -eq 6.42) -or ($this.ModifiedScopeStatus -eq 'Unchanged')){
            $this.ModifiedImpactSubScore = $this.ModifiedScope * $this.ModifiedImpactMULScore
        }
        else{
            $this.ModifiedImpactSubScore = $this.ModifiedScope * ($this.ModifiedImpactMULScore - 0.029) - 3.25 * [Math]::Pow(($this.ModifiedImpactMULScore - 0.02), 15)
        }
    }

    [Double] GetModifiedImpactSubScore(){
        return $this.ModifiedImpactSubScore
    }

   [Void] CalculateModifiedBaseSubScore([Single]$exploitCodeMaturityScore, [Single]$remediationLevel, [Single]$reportConfidence){
        if ($this.ModifiedImpactSubScore -le 0){
            $this.ModifiedBaseSubScore = 0
        }
        else{
            if (($this.ModifiedScope -eq 6.42) -or ($this.ModifiedScopeStatus -eq 'Unchanged')){
                $this.ModifiedBaseSubScore = [Math]::Round([Math]::Min( ($this.ModifiedExploitabilitySubScore + $this.ModifiedImpactSubScore), 10), 1) * $exploitCodeMaturityScore * $remediationLevel * $reportConfidence
            }
            else{
                $this.ModifiedBaseSubScore = [Math]::Round([Math]::Min((($this.ModifiedExploitabilitySubScore + $this.ModifiedImpactSubScore) * 1.08), 10), 1) * $exploitCodeMaturityScore * $remediationLevel * $reportConfidence
            }
        }
    }

    [Double] GetModifiedBaseSubScore(){
        return $this.getFormattedValue($this.ModifiedBaseSubScore)
    }

    [Void] CalculateCVSSScore(){
        $this.CVSSScore = $this.ModifiedBaseSubScore * 10 / 10
    }

    [Double] GetCVSSScore(){
        return $this.getFormattedValue($this.CVSSScore)
    }

    [Void] CalculateScore([Single]$exploitCodeMaturityScore, [Single]$remediationLevel, [Single]$reportConfidence){
        $this.CalculateModifiedExploitabilitySubScore()
        Write-Debug -Message "Base Exploitability Sub Score is $($this.ModifiedExploitabilitySubScore)"

        $this.CalculateModifiedImpactMULScore()
        Write-Debug -Message "Base Impact Sub Score Base Score is $($this.ModifiedImpactMULScore)"
        
        $this.CalculateModifiedImpactSubScore()
        Write-Debug -Message "Base Impact Sub Score is $($this.ModifiedImpactSubScore)"

        $this.CalculateModifiedBaseSubScore($exploitCodeMaturityScore, $remediationLevel, $reportConfidence)
        Write-Debug -Message "Base Score is $($this.ModifiedBaseSubScore)"

        $this.CalculateCVSSScore()
        Write-Debug -Message "CVSS Score is $($this.CVSSScore)"
    }
}