function Verb-Noun {
<#
.SYNOPSIS
    Brief synopsis about the function.
.DESCRIPTION
    Detailed explanation of the purpose of this function.
.PARAMETER Param1
    The purpose of param1.
.PARAMETER Param2
    The purpose of param2.
.EXAMPLE
     Verb-Noun -Param1 'Value1', 'Value2'
.EXAMPLE
     'Value1', 'Value2' | Verb-Noun
.EXAMPLE
     Verb-Noun -Param1 'Value1', 'Value2' -Param2 'Value'
.INPUTS
    String
.OUTPUTS
    PSCustomObject
.NOTES
    Author:  Ken Maglio
    Website: http://github.com/kenmaglio
    Twitter: @kenmaglio
#> 
    [CmdletBinding()]
    [OutputType('PSCustomObject')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [string[]]$Param1,
        [ValidateNotNullOrEmpty()]
        [string]$Param2
    ) 
    BEGIN {
        #Used for prep. This code runs one time prior to processing items specified via pipeline input.
        #Good for removing log files, initalizing csv output files, etc.
    }
 
    PROCESS {
        #This code runs one time for each item specified via pipeline input.
 
        foreach ($Param in $Param1) {
            #Use foreach scripting construct to make parameter input work the same as pipeline input 
            #(iterate through the specified items one at a time).
        }
    }
 
    END {
        #Used for cleanup. This code runs one time after all of the items specified via pipeline input are processed.
        #EMail log files, send them to Splunk/Elk, etc. etc.
    } 
}
