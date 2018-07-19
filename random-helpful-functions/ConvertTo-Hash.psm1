function ConvertTo-Hash{
  [CmdletBinding()]
  param(
      [Parameter(
          Position = 0,
          ValueFromPipeline, 
          ValueFromPipelineByPropertyName
      )]
      $CustomObject
  )

  $hash = @{}
  #Crazy Custom Object BS
  foreach ($item in ($CustomObject| Get-Member * -MemberType NoteProperty).Name) {
      $hash.Add("$item", $($CustomObject.$item))
  }

  return $hash
}

function Test-ConvertToHash{
  #normally we'd get this from $result.Content
  $json = @"
  {"Ken":"Is Awesome","Jeff":"Is A Noob"}
  "@

  $obj = ConvertFrom-Json $json

  Write-Host("`$obj: " + $obj.GetType().Name)

  $hash = ConvertTo-Hash $obj

  Write-Host("`$hash: " + $hash.GetType().Name)

  foreach($key in $hash.keys) {
      $key + " " + $hash[$key]
  }
}
