Write-Host "Using BuildHelpers Variables" -ForegroundColor Yellow
# build vars
$ProjectRoot = $env:BHProjectPath
$ModuleName = $env:BHProjectName
$ModuleVersion = (Get-Module -ListAvailable $env:BHPSModuleManifest).Version
$BuildFolder = "$ProjectRoot\_bin\$ModuleName"
$VersionFolder = "$BuildFolder\$ModuleVersion"
## testing vars
$ModuleManifestName = "$ModuleName.psd1"
$ModulePath = "$VersionFolder\$ModuleManifestName"

Import-Module $ModulePath -Force

Describe 'Module Manifest Test' {
  It 'Passes Test-ModuleManifest' {
    Test-ModuleManifest -Path $ModulePath | Should Be $true
  }
}

Describe 'Module Imported Test' {
  It 'Confirms Module Is Loaded' {
    (Get-Module $ModuleName) -eq $null | Should Be $false
  }
}

Describe 'Functions ConvertFrom Test' {
  It 'Proves ConvertFrom-EncryptedString Exists' {
    (Get-Command 'ConvertFrom-EncryptedString' -CommandType Function) -eq $null | Should Be $false
  }
}

Describe 'Function ConvertTo Test' {
  It 'Proves ConvertTo-EncryptedString Exists' {
    (Get-Command 'ConvertTo-EncryptedString' -CommandType Function) -eq $null | Should Be $false
  }
}


Describe 'Test Crypto - PSCore' {
  It 'Validates Credentials' {

    [string]$mypassphrase = "secret"

    #generate a random salt
    [int]$max_length = 8;
    [byte[]]$rnd = 1..$max_length
    $rnd = magdevCrypto\Get-NonZeroBytes -data $rnd
    [string]$mysalt = [Convert]::ToBase64String($rnd)

    #generate a random ivhash
    [int]$max_length = 8;
    [byte[]]$rnd = 1..$max_length
    $rnd = magdevCrypto\Get-NonZeroBytes -data $rnd
    [string]$myivhash = [Convert]::ToBase64String($rnd)

    $pass = "password"
    $encrypted = magdevCrypto\ConvertTo-EncryptedString -string $pass -passphrase $mypassphrase -salthash $mysalt -ivhash $myivhash

    [SecureString]$result = magdevCrypto\ConvertFrom-EncryptedString -encryptedString $encrypted -passphrase $mypassphrase -salthash $mysalt -ivhash $myivhash

    $user = "blah"
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, $result

    $($cred.GetNetworkCredential().Password) | Should Be $pass

  }
}