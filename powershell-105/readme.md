# PowerShell 105 - PSDeploy

## Table of Contents
1. [Getting Started](#gettingstarted)
    1. [Install](#install)
    2. [Documentation and Helpful Blog Posts(#docs)
3. [Another paragraph](#paragraph2)
    1. [Sub paragraph](#subparagraph1)

## Getting Started! <a name="gettingstarted"></a>
So first and foremost, if you have no idea who RamblingCookieMonster is, you will after this!

### Installing PSDeploy <a name="install"></a>

First and foremost you'll need to make sure you start powershell as an administrator ( elevated prompt ).

To install PSDeploy, you can follow these [simple steps](docs/install.md) or you can look at the [Quick Start](https://psdeploy.readthedocs.io/en/latest/Quick-Start.-Installation-and-Example/) guide for PSDeploy

Note: If you get something like this ...

```
PS C:\WINDOWS\system32> Install-Module PSDeploy

Untrusted repository
You are installing the modules from an untrusted repository. If you trust this repository, change its
InstallationPolicy value by running the Set-PSRepository cmdlet. Are you sure you want to install the modules from
'PSGallery'?
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "N"): A
WARNING: Version '0.2.5' of module 'PSDeploy' is already installed at
'C:\Users\[yourusername]\Documents\WindowsPowerShell\Modules\PSDeploy\0.2.5'. To install version '1.0', run Install-Module and
add the -Force parameter, this command will install version '1.0' in side-by-side with version '0.2.5'.
PS C:\WINDOWS\system32> Update-Module PSDeploy
```

Then you'll want to simply update your install

```
PS C:\WINDOWS\system32> Update-Module PSDeploy

Untrusted repository
You are installing the modules from an untrusted repository. If you trust this repository, change its
InstallationPolicy value by running the Set-PSRepository cmdlet. Are you sure you want to install the modules from
'PSGallery'?
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "N"): y
PS C:\WINDOWS\system32>
```

Once you've done the above, please make sure the following works! 

```
PS C:\WINDOWS\system32>  Get-Command -Module PSDeploy

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        By                                                 1.0        PSDeploy
Function        DependingOn                                        1.0        PSDeploy
Function        Deploy                                             1.0        PSDeploy
Function        FromSource                                         1.0        PSDeploy
Function        Get-PSDeployment                                   1.0        PSDeploy
Function        Get-PSDeploymentScript                             1.0        PSDeploy
Function        Get-PSDeploymentType                               1.0        PSDeploy
Function        Initialize-PSDeployment                            1.0        PSDeploy
Function        Invoke-PSDeploy                                    1.0        PSDeploy
Function        Invoke-PSDeployment                                1.0        PSDeploy
Function        Tagged                                             1.0        PSDeploy
Function        To                                                 1.0        PSDeploy
Function        WithOptions                                        1.0        PSDeploy
Function        WithPostScript                                     1.0        PSDeploy
Function        WithPreScript                                      1.0        PSDeploy
```

### Documentation and helpful Blog Posts <a name="docs"></a>
- [PSDeploy Docs](https://psdeploy.readthedocs.io/en/latest)
- [PSDeploy](http://ramblingcookiemonster.github.io/PSDeploy)
- [PSDeploy Take Two](http://ramblingcookiemonster.github.io/PSDeploy-Take-Two)


## Another paragraph <a name="paragraph2"></a>
The second paragraph text

### Sub paragraph <a name="subparagraph1"></a>
This is a sub paragraph, formatted in heading 3 style
