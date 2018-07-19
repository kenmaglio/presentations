# magdev Crypto
This module uses .Net AES ecryption libraries to encrypt and decrypt credentials. It attempts to never write this information into memory un-encrypted. 

**This is a compiled module and cannot be deployed via a git checkout**

**Important Notes**
- This module does not log any usefull error logs. This is to keep secrets from accidentally making their way into logs.
- Any changes which are made to this module, must be reflexed in any language equivalent. magdev relies on all languages being able to decrypt the credentials *encrypted* with PowerShell.




### Change Log
[Change Log can be viewed here](CHANGELOG.md)

### To Contribute
[Please see the following article](CONTRIBUTION.md)

### License
[License can be seen here](LICENSE.md)


