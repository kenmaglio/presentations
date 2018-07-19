function ConvertTo-EncryptedString {
  [CmdletBinding()]
  param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$string,
    [Parameter(Position = 1, Mandatory = $true, ParameterSetName = "aes")]
    [Hashtable]$aesHash,
    [Parameter(Position = 1, Mandatory = $true, ParameterSetName = "params")]
    [string]$passphrase,
    [Parameter(Position = 2, Mandatory = $true, ParameterSetName = "params")]
    [string]$salthash,
    [Parameter(Position = 3, Mandatory = $true, ParameterSetName = "params")]
    [string]$ivhash,
    [Parameter(Mandatory = $false)]
    [int]$iterationCount = 5
  )
  [Reflection.Assembly]::LoadWithPartialName("System.Security") | Out-Null

  switch ($PsCmdlet.ParameterSetName) {
    "aes" {
      $crypto = Get-AESCryptoManager -aesHash $aesHash
    }
    "params" {
      $crypto = Get-AESCryptoManager -passphrase $passphrase -salthash $salthash -ivhash $ivhash
    }
  }

  $crypto = Get-AESCryptoManager -passphrase $passphrase -salthash $salthash -ivhash $ivhash

  $enc = $crypto.CreateEncryptor()
  # Creates a MemoryStream to do the encryption in
  $ms = new-Object IO.MemoryStream
  # Creates the new Cryptology Stream --> Outputs to $MS or Memory Stream
  $cs = new-Object Security.Cryptography.CryptoStream $ms, $enc, "Write"
  # Starts the new Cryptology Stream
  $sw = new-Object IO.StreamWriter $cs
  # Writes the string in the Cryptology Stream
  $sw.Write($string)
  # Stops the stream writer
  $sw.Close()
  # Stops the Cryptology Stream
  $cs.Close()
  # Stops writing to Memory
  $ms.Close()
  # get hash output
  [byte[]]$resultBytes = $ms.ToArray()
  $hash = [Convert]::ToBase64String($resultBytes)
  #clean up in memory objects
  $sw.Dispose()
  $cs.Dispose()
  $ms.Dispose()
  $enc.Dispose()
  $crypto.Dispose()

  return $hash
}
