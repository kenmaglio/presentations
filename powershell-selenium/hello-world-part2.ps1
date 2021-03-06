Push-Location

$basePath = "C:\_lab"
if (-not(Test-Path -Path $basepath)) {
    New-Item $basePath -ItemType Directory -Force
}

$packageDir = "packages"
$packagePath = Join-Path $basePath $packageDir
if (-not(Test-Path $packagePath)) {
    New-Item $packagePath -ItemType Directory -Force
}


function Get-SEChrome {
    param(
        $packagePath
    )    
    Push-Location

    Set-Location $packagePath

    $path = Join-Path $packagePath ".\Selenium.WebDriver.*\lib\net40"
    $pathToWebDriver = Resolve-Path $path

    Write-Host "Load Web Driver"
    Add-Type -Path (Join-Path $pathToWebDriver WebDriver.dll)

    $path = Join-Path $packagePath "Selenium.WebDriver.ChromeDriver.*\driver\win32"
    $pathToChromeDriver = Resolve-Path $path

    # test if we can build a ChromeDriver if we are in the packages dir
    $webdriver = $null
    try {
        $webdriver = New-Object OpenQA.Selenium.Chrome.ChromeDriver($pathToChromeDriver)
    } catch {
        $installIt = Read-Host -Prompt "Could not build Chrome Driver, continue to install?  [Y/N] (Default N)"
        if ($installIt.ToLower() -eq 'y') {
            $cleanIt = Read-Host -Prompt "Clean packages? [Y/N] (Default N)"
            if ($cleanIt.ToLower() -eq 'y') {
                Write-Host "Cleaning existing packages"
                Remove-Item -Path $packagePath -Recurse -Force
                New-Item $packagePath -ItemType Directory -Force
            }

            Install-Package Selenium.WebDriver -Destination $packagePath
            Install-Package Selenium.WebDriver.ChromeDriver -Destination $packagePath

            Write-Host "Load Chrome Driver"
            $webdriver = New-Object OpenQA.Selenium.Chrome.ChromeDriver($pathToChromeDriver)
        }
    }
    
    Pop-Location

    return $webdriver
    
}


## Code Goes Here
#[OpenQA.Selenium.Chrome.ChromeDriver]$chrome = Get-SEChrome -packagePath $packagePath
$chrome = Get-SEChrome -packagePath $packagePath

$By_CSS = [OpenQA.Selenium.By]::CssSelector()

[OpenQA.Selenium.By]::Name($Name)

#chrome.Navigate().GoToUrl('https://www.meetup.com/STLPSUG')

#pause

#$chrome.Close()

Pop-Location