#region Import Private Functions
if (Test-Path "$PSScriptRoot\Functions") {
  $FunctionList = Get-ChildItem -Path "$PSScriptRoot\Functions";

  foreach ($File in $FunctionList) {
      . $File.FullName;
      Write-Verbose -Message ('Importing Function: {0}' -f $File.Name);
  }
}
#endregion

### Export all functions - This last line of the file - will be copied by the PSake Build Task
Export-ModuleMember -Function *;