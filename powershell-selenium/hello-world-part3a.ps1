Set-Location $PSScriptRoot

Remove-Module hello-world-class -Force 

Import-Module .\hello-world-class.ps1 -Force



if ($null -eq $global:LABCRED) {
    $global:LABCRED = Get-Credential -Message "User / Pass for Lab - Meetup Login"
}


$bot = New-Object MAGDEV_MAIN
$bot.SetConfig()
$bot.Selenium.GetChrome()

#now turn on verbose
$bot.VerboseLogging($true)

$bot.Selenium.Navigate('https://www.meetup.com/login')

$username = ($global:LABCRED).GetNetworkCredential().UserName
$password = ($global:LABCRED).GetNetworkCredential().Password

$bot.Selenium.FindAndTypeByName('email',$username)
$bot.Selenium.FindAndTypeByName('password',$password)

$username = $null
$password = $null

$bot.Selenium.FindAndClickByName('rememberme')

$bot.Selenium.FindAndClickBySelector("input[value='Log in']")

$bot.Selenium.Navigate('https://www.meetup.com/STLPSUG')

$bot.Shutdown()
$bot = $null