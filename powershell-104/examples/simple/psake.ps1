# PSake makes variables declared here available in other scriptblocks
# Init some things
Properties {
    # Find the build folder based on build system
    $ProjectRoot = $env:BHProjectPath
    $ModuleName = $env:BHProjectName
    $ModuleVersion = (Get-Module -ListAvailable $env:BHPSModuleManifest).Version

    $BuildFolder = "$ProjectRoot\_bin\$ModuleName"    
    $VersionFolder = "$BuildFolder\$ModuleVersion"
}

Task default -Depends Build

Task Build {
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

        
    Write-Host "Copying Module Manifest"  -ForegroundColor Blue
    $Null = Copy-Item   -Path "$ProjectRoot\Source\$ModuleName.psd1" -Destination "$VersionFolder\$ModuleName.psd1" -Force

    Write-Host "Creating and compiling Module file"  -ForegroundColor Blue    
    $Null = New-Item -Path "$VersionFolder\$ModuleName.psm1" -Type File -Force
    
    $Functions = Get-ChildItem -Path $ProjectRoot\Source\Functions -Recurse -Exclude *.Tests.* -File `
        | ForEach-Object -Process {Get-Content -Path $_.FullName; "`r`n"}
        
    $Null = Add-Content -Path "$VersionFolder\$ModuleName.psm1" -Value $Functions, "`r`n"
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
  
  