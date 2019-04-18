class TemporalScore {
    [Single] $ExploitCodeMaturity = 1
    [Single] $RemediationLevel = 1
    [Single] $ReportConfidence = 1
    
    [Double] $TemporalScore

    TemporalScore() {
    }

    [Void] CalculateTemporalScore ([Double] $baseScore){
        $this.TemporalScore = [Math]::Round(($baseScore * $this.ExploitCodeMaturity * $this.RemediationLevel * $this.ReportConfidence), 1)
    }

    [Double] GetTemporalScore (){
        return $this.TemporalScore
    }
}