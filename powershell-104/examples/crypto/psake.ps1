# PSake makes variables declared here available in other scriptblocks
# Init some things
Properties {
  # Find the build folder based on build system
  $ProjectRoot = $env:BHProjectPath
  $ModuleName = $env:BHProjectName
  $ModuleVersion = (Get-Module -ListAvailable $env:BHPSModuleManifest).Version
  $TestsFolder = "$ProjectRoot\Tests"
  $SpecsFolder = "$ProjectRoot\Specs"
  $BuildFolder = "$ProjectRoot\_bin\$ModuleName"
  
  $ZipFolder = "$ProjectRoot\_zip"
  $VersionFolder = "$BuildFolder\$ModuleVersion"
  $ReleaseNotesFile = "$ProjectRoot\source\ReleaseNotes.md"
  $Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
  $PSVersion = $PSVersionTable.PSVersion.Major
  $TestsOutputFolder = "$ProjectRoot\_testresults\"
  $TestsOutput = "$TestsOutputFolder\Test_Help`_$TimeStamp.xml"
  $SpecOutput = "Results_Specs_PS$PSVersion`_$TimeStamp.xml"
  $ApiKey = $env:APIKEY
  $CommitID = $env:COMMITID
}

Task default -Depends Build

Task Build {
  Write-Host "Building Module Structure"  -ForegroundColor Blue
  $FunctionsPublic = Get-ChildItem -Path $ProjectRoot\Source\Functions\public -Recurse -Exclude *.Tests.* -File `
    | ForEach-Object -Process {Get-Content -Path $_.FullName; "`r`n"}
  $FunctionsPrivate = Get-ChildItem -Path $ProjectRoot\Source\Functions\private -Recurse -Exclude *.Tests.* -File `
    | ForEach-Object -Process {Get-Content -Path $_.FullName; "`r`n"}

  If (-not (Test-Path $BuildFolder)) {
    Write-Host "Creating Build Folder"  -ForegroundColor Blue
    $Null = New-Item -Path $BuildFolder -Type Directory -Force
  }
  Else {
    Write-Host "Clearing Existing Build Folder  $BuildFolder"  -ForegroundColor Blue
    Remove-Item -Path $BuildFolder/* -Recurse -Force
  }
  Write-Host "Creating Version Folder"  -ForegroundColor Blue
  $Null = New-Item -Path $VersionFolder -Type Directory -Force

  If (-not (Test-Path $ZipFolder)) {
    Write-Host "Creating Zip Folder"  -ForegroundColor Blue
    $Null = New-Item -Path $ZipFolder -Type Directory -Force
  }
  Else {
    Write-Host "Clearing Existing Zip Folder  $ZipFolder"  -ForegroundColor Blue
    Remove-Item -Path $ZipFolder/* -Recurse -Force
  }


  Write-Host "Copying Module Manifest"  -ForegroundColor Blue
  $Null = Copy-Item   -Path "$ProjectRoot\Source\$ModuleName.psd1" -Destination "$VersionFolder\$ModuleName.psd1" -Force
  Write-Host "Creating and compiling Module file"  -ForegroundColor Blue
  $Null = New-Item    -Path "$VersionFolder\$ModuleName.psm1" -Type File -Force
  $Null = Add-Content -Path "$VersionFolder\$ModuleName.psm1" -Value $FunctionsPublic, "`r`n"
  $Null = Add-Content -Path "$VersionFolder\$ModuleName.psm1" -Value "#------------------===Private Functions===-------------------`r`n"
  $Null = Add-Content -Path "$VersionFolder\$ModuleName.psm1" -Value $FunctionsPrivate, "`r`n"
  $Null = Get-Content -Path "$ProjectRoot\Source\$ModuleName.psm1" `
    | Select-Object -Last 1 `
    | Add-Content -Path $VersionFolder\$ModuleName.psm1

  Write-Host "Module built, verifying module output" -ForegroundColor Blue 
  Get-Module -ListAvailable "$VersionFolder\$ModuleName.psd1" `
    | ForEach-Object -Process {
    $ExportedFunctions = $_ `
      | Select-Object -Property @{ Name = "ExportedFunctions" ; Expression = { [string[]]$_.ExportedFunctions.Keys } } `
      | Select-Object -ExpandProperty ExportedFunctions
    $ExportedAliases = $_ `
      | Select-Object -Property @{ Name = "ExportedAliases"   ; Expression = { [string[]]$_.ExportedAliases.Keys   } } `
      | Select-Object -ExpandProperty ExportedAliases
    $ExportedVariables = $_ `
      | Select-Object -Property @{ Name = "ExportedVariables" ; Expression = { [string[]]$_.ExportedVariables.Keys } } `
      | Select-Object -ExpandProperty ExportedVariables
    Write-Output "Name              : $($_.Name)"
    Write-Output "Description       : $($_.Description)"
    Write-Output "Guid              : $($_.Guid)"
    Write-Output "Version           : $($_.Version)"
    Write-Output "ModuleType        : $($_.ModuleType)"
    Write-Output "ExportedFunctions : $ExportedFunctions"
    Write-Output "ExportedAliases   : $ExportedAliases"
    Write-Output "ExportedVariables : $ExportedVariables"
  }

}

Task Analyze -Depends Build {
  $saResults = Invoke-ScriptAnalyzer -Path $VersionFolder\$ModuleName.psm1 -Severity @('Error') -Recurse -Verbose:$false
  if ($saResults) {
    $saResults | Format-Table
    Write-Error -Message 'One or more Script Analyzer errors where found.'
  }
}

Task Test -Depends Analyze {
  If (-not (Test-Path $TestsOutputFolder)) {
    Write-Host "Creating Tests Output Folder"  -ForegroundColor Blue
    $Null = New-Item -Path $TestsOutputFolder -Type Directory -Force
  }

  Write-Host "Removing Test Output > 5 runs ago"
  Get-ChildItem $TestsOutputFolder -Recurse | Where-Object {-not $_.PSIsContainer} | Sort CreationTime -Descending | Select-Object -Skip 5 | Remove-Item -Force

  Write-Host "Testing Module"  -ForegroundColor Blue
  $HelpResults = Invoke-Pester $TestsFolder -OutputFormat NUnitXml -OutputFile $TestsOutput -PassThru
  If ($HelpResults.FailedCount -gt 0) {
    Exit $HelpResults.FailedCount
  }
}

Task WinZip -depends Test {
  $FileName = "$ZipFolder\$ModuleName.$ModuleVersion.zip"
  Compress-Archive -Path $BuildFolder -DestinationPath $FileName -Force
}

