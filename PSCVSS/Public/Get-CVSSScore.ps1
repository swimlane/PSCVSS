<#
.SYNOPSIS
    Returns a CVSS Score from a returned vector string
.DESCRIPTION
    Returns the Base, Temporal, Environmental and CVSS Score based on a provided Vector String.  
    PSCVSS is based on CVSS 3.0 standard
.PARAMETER VectorString
    A provided CVSS Vector String
.EXAMPLE Simple Example
    When you provide a Vector String it will determine if the values are correct and expected

    Get-CVSSScore -VectorString 'CVSS:3.0/AV:P/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H/RL:W/MPR:N'
.EXAMPLE Bad Input Example
    If you provide values in your Vector string that are not known or valid, this function will ignore them

    Get-CVSSScore -VectorString 'CVSS:3.0/AV:P/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H/RL:W/MPR:N/X:Y/ZZZZ:blah'
.INPUTS
    System.String. You can pipe a VectorString into this function.
.OUTPUTS
    PSCVSS.Vector.Score. A Custom PS Object containing Base, Temporal, Environmental, and CVSS Scores
#>
function Get-CVSSScore {
    [CmdletBinding(DefaultParameterSetName='Vector',
                   PositionalBinding=$false,
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='Medium')]
    Param (
        # A Vector string formatted based on the CVSS standard
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='Vector')]
        [Alias("vector", "string")] 
        $VectorString
    )
    
    begin{

        try{
            $cvssData = Get-CVSSData
        }
        catch{
            Write-Error -ErrorRecord $Error[0] -RecommendedAction 'Unable to load localized CVSS Data!'
            exit
        }

        try{
            $baseScore = [BaseScore]::new()
            $temporalScore = [TemporalScore]::new()
            $environmentalScore = [EnvironmentalScore]::new()
        }
        catch{
            Write-Error -ErrorRecord $Error[0] -RecommendedAction 'Unable to create BaseScore object!'
            exit
        }
    }
    process {

        foreach ($vector in $VectorString.split('/')){
            if ($vector -notmatch 'CVSS'){
                if ($cvssData.Contains($vector.split(':')[0])){
                    if ($cvssData.$($vector.split(':')[0]).Contains($vector.split(':')[1])){
                        Write-Debug "Vector $($vector.split(':')[0]) has a score of $($cvssData.$($vector.split(':')[0]).$($vector.split(':')[1]))"
                        switch ($vector.split(':')[0]) {
                            'AV'  { $baseScore.AttackVector = $cvssData.$($vector.split(':')[0]).$($vector.split(':')[1])                        }
                            'AC'  { $baseScore.AttackComplexity = $cvssData.$($vector.split(':')[0]).$($vector.split(':')[1])                    }
                            'PR'  { $baseScore.PrivilegeRequired = $cvssData.$($vector.split(':')[0]).$($vector.split(':')[1])                   }
                            'UI'  { $baseScore.UserInteraction = $cvssData.$($vector.split(':')[0]).$($vector.split(':')[1])                     }
                            'S'   { $baseScore.Scope =$cvssData.$($vector.split(':')[0]).$($vector.split(':')[1])                                }
                            'C'   { $baseScore.Confidentiality = $cvssData.$($vector.split(':')[0]).$($vector.split(':')[1])                     }
                            'I'   { $baseScore.Integrity = $cvssData.$($vector.split(':')[0]).$($vector.split(':')[1])                           }
                            'A'   { $baseScore.Availability = $cvssData.$($vector.split(':')[0]).$($vector.split(':')[1])                        }
                            'E'   { $temporalScore.ExploitCodeMaturity = $cvssData.$($vector.split(':')[0]).$($vector.split(':')[1])             }
                            'RL'  { $temporalScore.RemediationLevel = $cvssData.$($vector.split(':')[0]).$($vector.split(':')[1])                }
                            'RC'  { $temporalScore.ReportConfidence = $cvssData.$($vector.split(':')[0]).$($vector.split(':')[1])                }
                            'CR'  { $environmentalScore.ConfidentialityRequirement = $cvssData.$($vector.split(':')[0]).$($vector.split(':')[1]) }
                            'IR'  { $environmentalScore.IntegrityRequirement = $cvssData.$($vector.split(':')[0]).$($vector.split(':')[1])       }
                            'AR'  { $environmentalScore.AvailabilityRequirement = $cvssData.$($vector.split(':')[0]).$($vector.split(':')[1])    }
                            'MAV' { $environmentalScore.ModifiedAttackVector = $cvssData.$($vector.split(':')[0]).$($vector.split(':')[1])       }
                            'MAC' { $environmentalScore.ModifiedAttackComplexity = $cvssData.$($vector.split(':')[0]).$($vector.split(':')[1])   }
                            'MPR' { $environmentalScore.ModifiedPrivilegesRequired = $cvssData.$($vector.split(':')[0]).$($vector.split(':')[1]) }
                            'MUI' { $environmentalScore.ModifiedUserInteraction = $cvssData.$($vector.split(':')[0]).$($vector.split(':')[1])    }
                            'MS'  { $environmentalScore.ModifiedScope = $cvssData.$($vector.split(':')[0]).$($vector.split(':')[1])              }
                            'MC'  { $environmentalScore.ModifiedConfidentiality = $cvssData.$($vector.split(':')[0]).$($vector.split(':')[1])    }
                            'MI'  { $environmentalScore.ModifiedIntegrity = $cvssData.$($vector.split(':')[0]).$($vector.split(':')[1])          }
                            'MA'  { $environmentalScore.ModifiedAvailability = $cvssData.$($vector.split(':')[0]).$($vector.split(':')[1])       }
                        }
                    }
                }
                else{
                    Write-Verbose -Message "Unable to find $($vector.split(':')[0]) in Vector list"
                }      
            }
        }
    }
    end {
        $baseScore.CalculateScore()
        $temporalScore.CalculateTemporalScore($baseScore.GetBaseScore())
        $environmentalScore.CalculateScore($temporalScore.ExploitCodeMaturity, $temporalScore.RemediationLevel, $temporalScore.ReportConfidence)

        $cvssScoreObject = [PSCustomObject]@{
            'Base Score' = $baseScore.GetBaseScore()
            'Temporal Score' = $temporalScore.GetTemporalScore()
            'Environmental Score' = $environmentalScore.GetModifiedBaseSubScore()
            'CVSS Score' = $environmentalScore.GetCVSSScore()
        }

        Add-ObjectDetail -InputObject $cvssScoreObject -TypeName 'PSCVSS.Vector.Score'
    }
}