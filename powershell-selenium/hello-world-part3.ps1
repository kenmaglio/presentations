Remove-Module hello-world-class -Force 

Import-Module .\hello-world-class.ps1 -Force



if ($null -eq $global:LABCRED) {
    $global:LABCRED = Get-Credential -Message "User / Pass for Lab"
}


$bot = New-Object MAGDEV_MAIN
$bot.SetConfig()
$bot.Selenium.GetChrome()

$bot

#code goes here

$bot.Shutdown()
$bot = $null