function Get-NonZeroBytes {
  <#
    Helper Function For Testing Crypto
  #>
  [CmdLetBinding()]
  [OutputType([byte[]])]
  param(
    [byte[]] $data
  )

  $enc = [system.Text.Encoding]::UTF8
  $enc.GetBytes($data)

  [int] $indexOfFirst0Byte = $data.Length
  for ($i=0; $i -lt $data.Length; $i++) { 
    if ($data[$i] -eq 0) {
      $indexOfFirst0Byte = $i
      break
    }
  }

  for ($i=$indexOfFirst0Byte; $i -lt $data.Length; $i++) {
    if ($data[$i] -ne 0) {
      $data[$indexOfFirst0Byte++] = $data[$i]
    }
  }

  while ($indexOfFirst0Byte -lt $data.Length) {
    # this should be more than enough to fill the rest in one iteration
    [byte[]] $tmp = new [byte[2 * ($data.Length - $indexOfFirst0Byte)]]
    $enc.GetBytes($tmp)

    for ($i=0; $i -lt $tmp.Length; $i++) {
      if ($tmp[$i] -ne 0) { 
        $data[$indexOfFirst0Byte++] = $tmp[$i]
        if ($indexOfFirst0Byte -ge $data.Length) {
          break
        }
      }
    }
  }

  return $data
}