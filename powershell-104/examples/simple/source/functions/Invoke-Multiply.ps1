function Invoke-Multiply {
    <#
    .SYNOPSIS
        This will multiply two numbers
    .DESCRIPTION
        This will multiply parameter A and parameter B and return an INT
    .PARAMETER A
        Number to be multiplied
    .PARAMETER B
        Number to be multiplied
    .EXAMPLE
         Get-Multiply -A 5 -B 10
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
    
    $C = $A * $B
    return $C
             
}