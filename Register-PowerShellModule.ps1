<#
.SYNOPSIS
    Registers a PowerShell Module on to the PowerShell Gallery
.DESCRIPTION
    This function registers a powershell module on the Powershell Gallery
.PARAMETER Key
    A PowerShell Gallery API Key
.EXAMPLE Simple Example

    Register-PowerShellModule -Key 'YOUR_API_KEY'
.INPUTS
    System.String. You can pipe a PSGallery API Key into this function.
#>
function Register-PowerShellModule {
    [CmdletBinding(DefaultParameterSetName='default',
                   PositionalBinding=$false,
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='Medium')]
    Param (
        # A Vector string formatted based on the CVSS standard
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='default')]
        [Alias("ApiKey", "string")] 
        [string] $Key,

        # A Vector string formatted based on the CVSS standard
        [Parameter(Mandatory=$false,
                   Position=1,
                   ValueFromPipelineByPropertyName=$true,
            ParameterSetName='default')]
        [int] $Major,

        # A Vector string formatted based on the CVSS standard
        [Parameter(Mandatory=$false,
                   Position=2,
                   ValueFromPipelineByPropertyName=$true,
            ParameterSetName='default')]
        [int] $Minor,

        # A Vector string formatted based on the CVSS standard
        [Parameter(Mandatory=$false,
                   Position=3,
                   ValueFromPipelineByPropertyName=$true,
            ParameterSetName='default')]
        [int] $Patch
    )

    begin{
        $manifestPath = (Get-ChildItem -Path '*' -Filter '*.psd1' -Recurse).FullName
        if (-not $manifestPath){
            Write-Error -Message 'Unable to find a valid PowerShell Module (psd1) file in this repository'
        }
        $moduleName = $manifestPath.split('/')[-1].split('.psd1')[0]
    }
    process{
        Write-Debug -Message 'Testing ModuleManifest and getting current version'
        try{
            $moduleManifest = (Test-ModuleManifest -Path $manifestPath)
            [System.Version] $version = $moduleManifest.Version
        }
        catch{
            Write-Error -ErrorRecord $Error[0] -ErrorAction Stop
        }

        Write-Debug -Message "Current Version is $version"
        
        if (-not $Major){
            $Major = $version.Major
        }
        if (-not $Minor){
            $Minor = $version.Minor
        }
        if (-not $Patch){
            $Patch = $version.Build
        }
        [String] $newVersion = New-Object -TypeName System.Version -ArgumentList ($Major, $Minor, $Build)
        Write-Debug -Message "New Version is $newVersion"

        Write-Debug -Message 'Updating Module Manifest'
        try{
            $splat = @{
                'Path'              = $manifestPath
                'ModuleVersion'     = $newVersion
                'Copyright'         = "(c) 2019-$( (Get-Date).Year ). All rights reserved."
            }
            Update-ModuleManifest @splat
            (Get-Content -Path $manifestPath) -replace "PSGet_$($moduleName)", '$($moduleName)' | Set-Content -Path $manifestPath
            (Get-Content -Path $manifestPath) -replace 'NewManifest', '$($moduleName)' | Set-Content -Path $manifestPath
        }
        catch{
            Write-Host $moduleName
            Write-Error -ErrorRecord $Error[0] -ErrorAction Stop

        }

        Write-Debug -Message 'Beginning to publish new module to PowerShell Gallery'
        try{
            $PM = @{
                Path        = "./$($moduleName)"
                NuGetApiKey = $Key
                ErrorAction = 'Stop'
                Tags         = $moduleManifest.Tags
                LicenseUri   = $moduleManifest.LicenseUri
                ProjectUri   = $moduleManifest.ProjectUri
                ReleaseNotes = "Publishing $newVersion of $moduleName"
            }
            Write-Host @PM
    
            Publish-Module @PM
        }
        catch{
            Write-Error -ErrorRecord $Error[0] -ErrorAction Stop
        }
    }
    end{

    }
}
    