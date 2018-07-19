function Get-AESCryptoManager {
  [CmdletBinding()]
  [OutputType([System.Security.Cryptography.AesManaged])]
   param(
       [Parameter(Position=0,Mandatory=$true,ParameterSetName="aes")]
       [Hashtable]$aesHash,
       [Parameter(Position=0,Mandatory=$true,ParameterSetName="params")]
       [string]$passphrase,
       [Parameter(Position=1,Mandatory=$true,ParameterSetName="params")]
       [string]$salthash,
       [Parameter(Position=2,Mandatory=$true,ParameterSetName="params")]
       [string]$ivhash,
       [Parameter(Mandatory=$false)]
       [int]$iterationCount = 5
   )
  
   switch ($PsCmdlet.ParameterSetName) {
    "aes" {
      $passphrase = $aesHash.passphrase
      $salthash = $aesHash.salthash
      $ivhash = $aesHash.ivhash
    }
  }
  # Create a COM Object for Cryptography
  $crypto = New-Object System.Security.Cryptography.AesManaged

  # Convert to UTF8 Bytes
  [byte[]]$bpassphrase = [Text.Encoding]::UTF8.GetBytes($passphrase)
  [byte[]]$bsalthash = [Text.Encoding]::UTF8.GetBytes($salthash)
  [byte[]]$bivhash = [Text.Encoding]::UTF8.GetBytes($ivhash)

  # Create the Encryption Key using the passphrase, salt using Rfc2898DeriveBytes  (Sha256)
  # public PasswordDeriveBytes(byte[] password,byte[] salt,int iterations)

  $pdb = New-Object System.Security.Cryptography.Rfc2898DeriveBytes $bpassphrase, $bsalthash, $iterationCount
  $crypto.Key = $pdb.GetBytes(32) #256/8

 # Create Intersecting Vector Crypto Hash
  $sha = New-Object System.Security.Cryptography.SHA256Managed
  $crypto.IV = $sha.ComputeHash($bivhash)[0..15]

  return $crypto
}
