# PowerShell 104

This section of the presentations repo, is for the PowerShell 104 presentation

[PowerShell 104: Building Modules with PSake](https://docs.google.com/presentation/d/1ryWbs1WH1kQY5_ahNp_Tn8VhLwPKCVCBf7B7wOhCMrk/edit?usp=sharing)

## Pre-Reqs

- Source: git
- Build: psake


We will use [chocolatey](chocolatey.org) to install git 

```powershell
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
```

Then install the following  (note: poshgit is optional)

```powershell
choco install git.install
choco install poshgit
```

Install psake

```powershell
Install-Module -Name psake
```

## Organization of source directory for PSake

There are a couple of decisions for how to organize your code:

Folder and File structure for very basic setup:

```shell
source
| functions
| | get-something.ps1
| module.psd1
| module.psm1
build.ps1
```

Advanced Setup (Testing, Docs, Full Gallery Style, Working-Temp scripts)

```shell
_output
| .... (actual built module)
_testResults
| ......xml
docs
| ReadMoreStuffs.md
source
| functions
| | public
| | | Get-SomeStuff.ps1
| | private
| | | Get-SecretStuff.ps1
| | working
| | | justTestingStuff.ps1
| module.psd1
| module.psm1
tests
| module.Tests.ps1
.gitignore
build.ps1
CHANGELOG.md
CONTRIBUTION.md
LICENSE.md
README.md
```