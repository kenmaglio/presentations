function ConvertFrom-EncryptedString {
  [CmdletBinding()]
  [OutputType([SecureString])]
  param(
      [Parameter(Position=0,Mandatory=$true)]
      [string]$encryptedString,
      [Parameter(Position=1,Mandatory=$true,ParameterSetName="aes")]
      [Hashtable]$aesHash,
      [Parameter(Position=1,Mandatory=$true,ParameterSetName="params")]
      [string]$passphrase,
      [Parameter(Position=2,Mandatory=$true,ParameterSetName="params")]
      [string]$salthash,
      [Parameter(Position=3,Mandatory=$true,ParameterSetName="params")]
      [string]$ivhash,
      [Parameter(Mandatory=$false)]
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

  $encryptedBytes = [Convert]::FromBase64String($encryptedString)

  $dec = $crypto.CreateDecryptor()
  # Create a New memory stream with the encrypted value.
  $ms = new-Object IO.MemoryStream @(,$encryptedBytes)
  # Read the new memory stream and read it in the cryptology stream
  $cs = new-Object Security.Cryptography.CryptoStream $ms,$dec,'Read'
  # Read the new decrypted stream
  # using this silly loop format to loop one char at a time
  # so we never store the entire password naked in memory
  [securestring]$secureResult = New-Object SecureString
  $ndx = 0
  $buffer = New-Object byte[] 1
  $enc = [system.Text.Encoding]::UTF8  #UTF8 no Unicode - one byte per char
  While(($ndx = $cs.Read($buffer, 0, $buffer.Length)) -gt 0 )
  {
      $secureResult.AppendChar($enc.GetString($buffer).ToCharArray()[0]);
  }  
  # Stops the Cryptology Stream
  $cs.Close()
  # Stops writing to Memory
  $ms.Close()
  #clean up in memory objects
  $cs.Dispose()
  $ms.Dispose()
  $dec.Dispose()
  $crypto.Dispose()

  return $secureResult
}