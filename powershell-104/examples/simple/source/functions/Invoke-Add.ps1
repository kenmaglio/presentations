function Invoke-Add {
    <#
    .SYNOPSIS
        This will add two numbers
    .DESCRIPTION
        This will add parameter A and parameter B and return an INT
    .PARAMETER A
        Number to be Added
    .PARAMETER B
        Number to be Added
    .EXAMPLE
         Get-Add -A 5 -B 10
    .INPUTS
        Int
    .OUTPUTS
        Int
    .NOTES
        Author:  Ken Maglio
        Website: http://github.com/kenmaglio
        Twitter: @kenmaglio
    #>     
    [CmdletBindinds()]
    [OutputType('Int')]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [int]$A,
        [ValidateNotNullOrEmpty()]
        [int]$B
    ) 
    
    $C = $A + $B
    return $C
             
}