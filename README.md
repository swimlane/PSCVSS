![](https://img.shields.io/badge/PowerShell-2.0.4-brightgreen.svg)
![](https://img.shields.io/badge/PowerShell%20Core-2.0.4-brightgreen.svg)

# PSCVSS

A Windows PowerShell & PowerShell Core Module to calculate a CVSS3 Score based on a Vector string

## Synopsis

`PSCVSS` is a Script Module that can be used to calculate a CVSS (Common Vulnerability Scoring System) 3 Score by providing a `VectorString`.  This module works on Windows PowerShell as well as PowerShell Core.

`PSCVSS` returns the Base, Temporal, Environmental and CVSS Score based on a provided Vector String.

If you're not familiar, CVSS is a standard used by almost all Vulnerability Management and CVE repository to provide a repeatable way to determine the risk of a specific vulnerability.  From my searching this capability was not previously available in a PowerShell Module, so I wrote it to take a Vulnerability/CVE Vector and calculate the overall score/risk of the provided string.

## Example

You can retrieve a Vector string from the NVD (National Vulnerability Database).  For example, this vulnerability was released on April 1st: https://nvd.nist.gov/vuln/detail/CVE-2017-16774

The Vector String for this vulnerability is provided: `AV:N/AC:L/PR:L/UI:R/S:C/C:L/I:L/A:N`

Using `PSCVSS` you can calculate the score locally without communicating with third-party APIs:

### Installation

First you can download PSCVSS from the PowerShellGallery:

```powershell
Install-Module -Name PSCVSS
```

Additionally, you can clone the repository:

```powershell
git clone git@github.com:swimlane/PSCVSS.git
```

### Importing

You first need to import the module into your current PowerShell session:

```powershell
Import-Module -Name PSCVSS -Force
```

### Using

Now that PSCVSS is installed on your machine, you can run the `Get-CVSSScore` Function.  At this time, you can provide a `VectorString` that you have written yourself or retrieved from a third-party service:

```powershell
Get-CVSSScore -VectorString 'CVSS:3.0/AV:N/AC:L/PR:L/UI:R/S:C/C:L/I:L/A:N'
```

You can also pipe your `VectorString` to this function:

```powershell
'CVSS:3.0/AV:N/AC:L/PR:L/UI:R/S:C/C:L/I:L/A:N' | Get-CVSSScore
```

## Current Support

Thanks for taking the time to look at PSCVSS.  In the future I plan on expanding this functionality so that you can provide a set of key value pairs and in return it will give you different options based on opposite values.

You can find `PSCVSS` here:

* GitHub: https://github.com/swimlane/PSCVSS
* PowerShellGallery: 


## Notes
```yaml
   Name: PSCVSS
   Created by: Josh Rickard
   Created Date: 04/17/2019
```
