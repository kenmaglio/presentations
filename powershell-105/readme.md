3# PowerShell 105 - PSDeploy

## Table of Contents

<!-- TOC -->

- [Table of Contents](#table-of-contents)
- [Getting Started!](#getting-started)
  - [Installing PSDeploy](#installing-psdeploy)
  - [Documentation and helpful Blog Posts](#documentation-and-helpful-blog-posts)
- [First Steps](#first-steps)
  - [Getting our module](#getting-our-module)
  - [Build a deployment folder](#build-a-deployment-folder)
- [Our First Deployment](#our-first-deployment)
  - [Ingredients](#ingredients)
  - [Deployment Configurations: *.PSDeploy.ps1](#deployment-configurations-psdeployps1)
  - [A basic deployment](#a-basic-deployment)
  - [A more fun deployment](#a-more-fun-deployment)
    - [Questions](#questions)
- [Topics Not Covered](#topics-not-covered)
  - [DeploymentType map: PSDeploy.yaml](#deploymenttype-map-psdeployyaml)

<!-- /TOC -->

## Getting Started!
So first and foremost, if you have no idea who RamblingCookieMonster is, you will after this!

### Installing PSDeploy

First and foremost you'll need to make sure you start powershell as an administrator ( elevated prompt ).

To install PSDeploy, you can follow these [simple steps](docs/INSTALL.md) or you can look at the [Quick Start](https://psdeploy.readthedocs.io/en/latest/Quick-Start.-Installation-and-Example/) guide for PSDeploy

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

### Documentation and helpful Blog Posts
- [PSDeploy Docs](https://psdeploy.readthedocs.io/en/latest)
- [PSDeploy](http://ramblingcookiemonster.github.io/PSDeploy)
- [PSDeploy Take Two](http://ramblingcookiemonster.github.io/PSDeploy-Take-Two)


## First Steps

### Getting our module

We are going to use the **simple** module we built from [PowerShell 104](../powershell-104/examples/simple)

So first let's checkout the repo  ( we're going to assume to check this out into `C:\_git\stlpsug\[repo here]` 

( substitute if you need )

```
c:
mkdir _git/stlpsug
cd _git/stlpsug
git clone https://github.com/kenmaglio/presentations.git
```

Next we need to build our _simple_ module

```
cd 
.\build.ps1
```

This should create a `simple` folder in the current folder under the `_bin` directory. At this point you should have the following path

`C:\_git\stlpsug\presentations\powershell-104\examples\simple\_bin\simple\1.0.0\simple(.psd1 & .psm1)`

If you do you're **winning**

Note: Make sure you're in the directory 

`C:\_git\stlpsug\presentations\powershell-104\examples\simple`

### Build a deployment folder

We want to have all our assets in one location, and we will want to organize our deployment scripts and config, so now we'll create a new folder and copy our module over to this new working directory

```
mkdir C:\_temp\deployfrom
cp _bin\* C:\_temp\deployfrom\modules -Force -Recurse
cd C:\_temp\deployfrom
```

Now our module we want to deploy is sitting in `C:\_git\deployfrom\modules`

Let's also assume we want to deploy some scripts ( just files ) out there too.

(assuming you have vscode installed)

```
mkdir scripts
code scripts\myscript.ps1

-- in code --
write-host "Hello World"
-- save the file ---
```

Now we have a module and a script ready to deploy!!!

## Our First Deployment

### Ingredients

**YAML:** Data format for deployment config files. Even easier to read than JSON.

**Deployment config:** YAML files defining what is being deployed. They should have a source, a destination, a deployment type, and might contain freeform deployment options.

**Deployment type:** These define how to actually deploy something. Each type is associated with a script. We’re including FileSystem and FileSystemRemote to start, but this is extensible.

**Deployment script:** These are scripts associated with a particular deployment type. All should accept a ‘Deployment’ parameter. For example, the FileSystem script uses robocopy and copy-item to deploy folders and files, respectively.

Note: While there is a `Initialize-PSDeployment` command we will not be using it - it kinda really doesn't help.

### Deployment Configurations: *.PSDeploy.ps1

These are PowerShell scripts that tell PSDeploy what to deploy.

They build up the following details on a deployment:

```
DeploymentName:    Name for a particular deployment.  Must be unique.
DeploymentType:    The type of deployment.  Tells PSDeploy how to deploy (FileSystem, ARM, etc.)
DeploymentOptions: One or more options to pass along to the DeploymentType script
Tags:              One or more tags associated with this deployment
Source:            One or more source items to deploy
Targets:           One or more targets to deploy to
Dependencies:      One or more DeploymentNames that this deployment depends on
```

A *.PSDeploy.ps1 file will have one or more deployment blocks like this:

```
Deploy UniqueDeploymentName                         # Deployment name.
    By FileSystem {                                 # Deployment type.
        FromSource RelativeSourceFolder,            # One or more sources to deploy. These are
                                                      specific to your DeploymentType
                                                      Subfolder\RelativeSource.File,
                                                      \\Absolute\Source$\FolderOrFile
        To \\Some\Target$\Folder,                   # One or more destinations to target for
                                                      deployment. These are specific to a DeploymentType
           \\Another\Target$\Folder
        Tagged Prod, Module                         # One or more tags for this deployment. Optional
        WithOptions @{                              # Deployment options hash table to pass as
                                                      parameters to DeploymentType script. Optional.
            Mirror = $True
        }
        DependingOn SomeOtherDeployment             # Run this deployment only after SomeOtherDeployment has run
    }
}
```

These are each PowerShell functions (only useful in a PSDeploy.ps1 file), so you can run Get-Help to find out more information:

```
Get-Help Deploy -Full
Get-Help By -Full
Get-Help FromSource -Full
Get-Help To -Full
Get-Help Tagged -Full
Get-Help WithOptions -Full
Get-Help DependingOn -Full
```

### A basic deployment

At the very least, we need a Deploy, By, FromSource, and To:

```
cd C:\_temp\deployfrom
code my.psdeploy.ps1
```

The contents should be:

```
Deploy SimpleDeployment {
    By FileSystem {
        FromSource modules
        To C:\_temp\deployto
    }
}
```

Let's test that PSDeploy can read our deployment!

```
PS C:\_temp\deployfrom> Get-PSDeployment -path .\my.psdeploy.ps1

Source            : C:\_temp\deployfrom\modules
DeploymentType    : FileSystem
DeploymentOptions :
Targets           : C:\_temp\deployto
Tags              :
```

Looking Good! However....

### A more fun deployment

```
cd C:\_temp\deployfrom
code fancy.psdeploy.ps1
```

The contents should be:


```
Deploy FancyDeployment {
    By FileSystem AllTheThings {
        FromSource modules,
                   scripts
        To C:\_temp\deployto
        DependingOn FancyDeployment-Modules  #DeploymentName-ByName
        Tagged Dev
    }

    By FileSystem Modules {
        FromSource modules
        To \\ServerY\c$\SomePSModulePath,
           \\ServerX\SomeShare$\Modules
        Tagged Prod,
               Module
    }
}
```

Let's look at how PSDeploy sees our fancy deployment!

```
PS C:\_temp\deployfrom> Get-PSDeployment -path .\fancy.psdeploy.ps1

Source            : C:\_temp\deployfrom\modules
DeploymentType    : FileSystem
DeploymentOptions :
Targets           : \\ServerY\c$\SomePSModulePath
                    \\ServerX\SomeShare$\Modules
Tags              : Prod
                    Module

Source            : C:\_temp\deployfrom\modules
DeploymentType    : FileSystem
DeploymentOptions :
Targets           : C:\_temp\deployto
Tags              : Dev

Source            : C:\_temp\deployfrom\scripts
DeploymentType    : FileSystem
DeploymentOptions :
Targets           : C:\_temp\deployto
Tags              : Dev
```

Like many PowerShell objects, we can find more properties using Select-Object:

```
PS C:\_temp\deployfrom> Get-PSDeployment -path .\fancy.psdeploy.ps1 | Select-Object -Property *

DeploymentFile    : C:\_temp\deployfrom\fancy.psdeploy.ps1
DeploymentName    : FancyDeployment-Modules
DeploymentType    : FileSystem
DeploymentOptions :
Source            : C:\_temp\deployfrom\modules
SourceType        : Directory
SourceExists      : True
Targets           : {\\ServerY\c$\SomePSModulePath, \\ServerX\SomeShare$\Modules}
Tags              : {Prod, Module}
Dependencies      :
PreScript         :
PostScript        :
Raw               :

DeploymentFile    : C:\_temp\deployfrom\fancy.psdeploy.ps1
DeploymentName    : FancyDeployment-AllTheThings
DeploymentType    : FileSystem
DeploymentOptions :
Source            : C:\_temp\deployfrom\modules
SourceType        : Directory
SourceExists      : True
Targets           : {C:\_temp\deployto}
Tags              : {Dev}
Dependencies      : @{DeploymentName=System.String[]; ScriptBlock=}
PreScript         :
PostScript        :
Raw               :

DeploymentFile    : C:\_temp\deployfrom\fancy.psdeploy.ps1
DeploymentName    : FancyDeployment-AllTheThings
DeploymentType    : FileSystem
DeploymentOptions :
Source            : C:\_temp\deployfrom\scripts
SourceType        : Directory
SourceExists      : True
Targets           : {C:\_temp\deployto}
Tags              : {Dev}
Dependencies      : @{DeploymentName=System.String[]; ScriptBlock=}
PreScript         :
PostScript        :
Raw               :
```

Now Let's Deploy!

```
PS C:\_temp\deployfrom> Invoke-PSDeploy

Processing deployment
Process the deployment 'FancyDeployment-Modules'?
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): n

Processing deployment
Process the deployment 'FancyDeployment-AllTheThings'?
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): Y

Processing deployment
Process the deployment 'FancyDeployment-AllTheThings'?
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): Y

Processing deployment
Process the deployment 'SimpleDeployment'?
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): n
```

```
PS C:\_temp\deployfrom> dir C:\_temp\deployto\ -Recurse | Select FullName

FullName
--------
C:\_temp\deployto\simple
C:\_temp\deployto\myscript.ps1
C:\_temp\deployto\simple\1.0.0
C:\_temp\deployto\simple\1.0.0\simple.psd1
C:\_temp\deployto\simple\1.0.0\simple.psm1
```


#### Questions

1. But what about my scripts???
2. Why are there two AllTheThings?
3. How would I only deploy Tagged items?
4. What happens if I try to deploy FancyDeployment-Modules, where those servers aren't real?
5. What is with the DependsOn? Why isn't that failing when I run AllTheThings?



## Topics Not Covered

### DeploymentType map: PSDeploy.yaml

[See PSDocs](https://psdeploy.readthedocs.io/en/latest/PSDeploy-Configuration-Files/#deploymenttype-map-psdeployyml)

This is a file that tells PSDeploy what script to use for each DeploymentType. By default, it sits in your PSDeploy module folder.

e.g.

`C:\Users\[username]\Documents\WindowsPowerShell\Modules\PSDeploy\1.0\PSDeploy.yml`

There are two scenarios you would generally work with this:

- You want to extend PSDeploy to add more DeploymentTypes
- You want to move the PSDeploy.yml to a central location that multiple systems could point to

