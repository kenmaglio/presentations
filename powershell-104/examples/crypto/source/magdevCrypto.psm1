#region Import Class definitions
if (Test-Path "$PSScriptRoot\Classes") {
  $ClassList = Get-ChildItem -Path "$PSScriptRoot\Classes";

  foreach ($File in $ClassList) {
      . $File.FullName;
      Write-Verbose -Message ('Importing class file: {0}' -f $File.FullName);
  }
}
#endregion

#region Import Private Functions
if (Test-Path "$PSScriptRoot\Functions\Private") {
  $FunctionList = Get-ChildItem -Path "$PSScriptRoot\Functions\Private";

  foreach ($File in $FunctionList) {
      . $File.FullName;
      Write-Verbose -Message ('Importing private function file: {0}' -f $File.FullName);
  }
}
#endregion

#region Import Public Functions
if (Test-Path "$PSScriptRoot\Functions\Public") {
  $FunctionList = Get-ChildItem -Path "$PSScriptRoot\Functions\Public";

  foreach ($File in $FunctionList) {
      . $File.FullName;
      Write-Verbose -Message ('Importing public function file: {0}' -f $File.FullName);
  }
}
#endregion


### Export all functions
Export-ModuleMember -Function *;