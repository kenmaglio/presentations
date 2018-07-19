Write-Host "Importing Modules:" -ForegroundColor Yellow
if ($PSVersionTable.PSEdition -eq 'Core') {
  $Modules = @("Psake","BuildHelpers")
} else {
  $Modules = @("Psake","BuildHelpers")
}

ForEach ($Module in $Modules) {
    Write-Host "...$Module" -ForegroundColor Yellow -NoNewline
    If (!(Get-Module -Name $Module -ListAvailable)) {
        try {
            $null = Find-Module $Module -ErrorAction Stop
            $null = Install-Module -Name $Module -Scope CurrentUser -Force
            Write-Host "...Importing" -ForegroundColor Green -NoNewline
            Import-Module $Module
            Write-Host "...Complete" -ForegroundColor Green
        } catch {
            Write-Host "...Not Found!" -ForegroundColor Red
            Write-Error -Message $_ -ErrorAction Stop
        }
    } Else {
        Write-Host "...Already Loaded" -ForegroundColor Gray
    }
}
Write-Host "Completed`r`n" -ForegroundColor Green

Push-Location $PSScriptRoot
Write-Output "Retrieving Build Variables"
Get-ChildItem -Path env:\bh* | Remove-Item
Set-BuildEnvironment

Write-Output "Executing PSake Build"
Invoke-Psake -buildFile .\psake.ps1 -properties $PSBoundParameters -noLogo -taskList build
