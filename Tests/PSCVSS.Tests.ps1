$here = "$(Split-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -Parent)\PSCVSS"
#$here = '../PSCVSS'

$module = 'PSCVSS'

Describe "$module PowerShell Module Tests" {
    
    Context 'Module Setup' {

        It "has the root module $module.psm1" {
            "$here/$module.psm1" | Should -Exist
        }

        It "has the manifest file $module.psd1" {
            "$here/$module.psd1" | should -Exist
        }

        It "$module has functions" {
            "$here\Public\*.ps1" | Should -Exist
        }
    }


    $pubFunctions = ( 'Get-CVSSScore')

    $privFunctions = ( 'Add-ObjectDetail' )

    foreach ($function in $pubFunctions)
    {
        Context 'Function Tests' {
            
            It "$function.ps1 should exist" {
                "$here\Public\$function.ps1" | Should -Exist
            }

            It "$function.ps1 should have help block" {
                "$here\Public\$function.ps1" | Should -FileContentMatch '<#'
                "$here\Public\$function.ps1" | Should -FileContentMatch '#>'
            }
            
            It "$function.ps1 should have a SYNOPSIS section in the help block" {
                "$here\Public\$function.ps1" | Should -FileContentMatch '.SYNOPSIS'
            }

            It "$function.ps1 should have a DESCRIPTION section in the help block" {
                "$here\Public\$function.ps1" | Should -FileContentMatch '.DESCRIPTION'
            }

            It "$function.ps1 should have a EXAMPLE section in the help block" {
                "$here\Public\$function.ps1" | Should -FileContentMatch '.EXAMPLE'
            }

            It "$function.ps1 should be an advanced function" {
                "$here\Public\$function.ps1" | Should -FileContentMatch 'function'
                "$here\Public\$function.ps1" | Should -FileContentMatch 'CmdLetBinding'
                "$here\Public\$function.ps1" | Should -FileContentMatch 'param'
            }

            It "$function.ps1 should contain Write-Verbose blocks" {
                "$here\Public\$function.ps1" | Should -FileContentMatch 'Write-Verbose'
            }

            It "$function.ps1 is valid PowerShell code" {
                $psFile = Get-Content -Path "$here\Public\$function.ps1" -ErrorAction Stop
                $errors = $null

                $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
                $errors.count | Should be 0
            }
        }#Context Function Tests
    }

    foreach ($function in $privFunctions) {
        Context 'Private Functions' {

            It "$function.ps1 should exist" {
                "$here\Private\$function.ps1" | Should -Exist
            }

            It "$function.ps1 should have help block" {
                "$here\Private\$function.ps1" | Should -FileContentMatch '<#'
                "$here\Private\$function.ps1" | Should -FileContentMatch '#>'
            }
            
            It "$function.ps1 should have a SYNOPSIS section in the help block" {
                "$here\Private\$function.ps1" | Should -FileContentMatch '.SYNOPSIS'
            }

            It "$function.ps1 should have a DESCRIPTION section in the help block" {
                "$here\Private\$function.ps1" | Should -FileContentMatch '.DESCRIPTION'
            }

            It "$function.ps1 should have a EXAMPLE section in the help block" {
                "$here\Private\$function.ps1" | Should -FileContentMatch '.EXAMPLE'
            }

            It "$function.ps1 should be an advanced function" {
                "$here\Private\$function.ps1" | Should -FileContentMatch 'function'
                "$here\Private\$function.ps1" | Should -FileContentMatch 'CmdLetBinding'
                "$here\Private\$function.ps1" | Should -FileContentMatch 'param'
            }

            It "$function.ps1 should contain Write-Verbose blocks" {
                "$here\Private\$function.ps1" | Should -FileContentMatch 'Write-Verbose'
            }

            It "$function.ps1 is valid PowerShell code" {
                $psFile = Get-Content -Path "$here\Private\$function.ps1" -ErrorAction Stop
                $errors = $null

                $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
                $errors.count | Should be 0
            }
        } # Context Private Function Tests
    } # end of foreach
}