$basePath = "C:\_lab"
$packages = "packages"

if (-not(Test-Path -Path $basepath)) {
    New-Item $basePath -ItemType Directory -Force
}

$packagePath = Join-Path $basePath $packages

if (-not(Test-Path $packagePath)) {
    New-Item $packagePath -ItemType Directory -Force
} 

Install-Package Selenium.WebDriver -Destination $packagePath
Install-Package Selenium.WebDriver.ChromeDriver -Destination $packagePath


