#posh-restful-api-examples.ps1
#created by Ken Maglio
#Slides: http://slides.com/kenmaglio/posh-rest-api



Function Convert-wlResponse {
<#
.Synopsis
   Sets Global variables from REST Response to a WL login
.INPUTS
   Response
#>
  [CmdletBinding()]
  Param (# The response either read from a file, or fetched from the web service
       [Parameter(Mandatory=$true,ValueFromPipeline=$true)] $Response,
       # A message to put out to verbose to say if what we did
       [String]$Action = "Processed Response for",
       # Dump the info to an XML file
       [switch]$Save,
       # If the info is fresh from the web, set the expiry time, otherwise don't
       [switch]$SetExpiry
  ) 
    if ($Save)      { 
        Write-verbose "Saving to $wlSavePath" 
        Export-Clixml -Path $wlSavePath  -InputObject $Response -Depth 5
    } 
    $Global:wlAccess   = $Response.access_token
    $Global:wlScope    = $Response.scope -split "\s+"   
    $Global:wlRefresh  = $Response.refresh_token
    if ($setExpiry) { #if we're reading from a file: life in seconds is meaningless, don't set expiry or get the username either
        $Global:wlExpiry = (Get-Date).AddSeconds([int]$Response.expires_in -10 )
        if ($Response.access_token) {
           Write-Progress -Activity "Authenticating with Live.com" -Status "Getting Token from Server" -PercentComplete 50
           $Global:wlUser = (Invoke-RestMethod -Method Get -Uri "$wlApiUri/me?access_token=$wlAccess").name 
           Write-Verbose ($action + $Global:wlUser) 
        }
    } 
}





$exampleToRun = 7

switch($exampleToRun) {
    1 {
        #example 1 - PowerShell 2.0
        clear

        $ex1_url = "https://www.destroyallsoftware.com/talks/wat"

        [System.Net.WebClient]$webClient = New-Object System.Net.WebClient
        $webClientResult = $webClient.DownloadString($ex1_url)
        
        $webClientResult

    }
    2 {
        #example 2
        clear

        $ex2_url = "https://www.destroyallsoftware.com/talks/wat"

        # there are a couple of objects that you could use from .Net

        [net.httpWebRequest] $webRequest = [net.webRequest]::create($ex2_url)    
        $webRequest.Method = "GET"

        #we can get and reuse cookies if we need
        $webRequestCookies = New-Object System.Net.CookieContainer
        $webRequest.CookieContainer = $webRequestCookies 

        [net.httpWebResponse] $webRequestResponse = $webRequest.GetResponse()
        $webResponseStream = $webRequestResponse.getResponseStream()
        $webResponseStreamReader = new-object IO.StreamReader($webResponseStream)
        $webResponseResult = $webResponseStreamReader.ReadToEnd()
        $webRequestResponse.Close()

        $webResponseResult
        $webRequestCookies.GetCookies($ex2_url)

    }
    3 {
        clear

        #from example 1 - get the mp4

        $ex3_url = "https://www.destroyallsoftware.com/talks/wat"

        [System.Net.WebClient]$webClient = New-Object System.Net.WebClient
        $webClientResult = $webClient.DownloadString($ex3_url)
        
        $watRegExMatch = "<a href=\`"([\S]*)wat\.mp4([\S]*)\`">Download this talk<\/a>"
        
        $found = $webClientResult -match $watRegExMatch
        if ($found) {
            $mp4Match = $Matches[0]
            $mp4URL = $mp4Match.replace("<a href=`"","").replace("`">Download this talk</a>","")

            Write-Output "Found URL: $mp4URL"
            
        }       
    }
    4 {
        clear
        
        # same as example 1 - just now with Invoke WR
        
        $ex4_url = "https://www.destroyallsoftware.com/talks/wat"

        $ex4_result = Invoke-WebRequest -Uri $ex4_url

        if($ex4_result.StatusCode -eq "200") {
            $ex4_result
            #$ex4_result.Content
            #$ex4_result.RawContent
            #$ex4_result.ParsedHtml
        }  else {
            Write-Output "Error! $($ex4_result.StatusDescription)"
        }

    }
    5 {
        clear

        #now let's start calling REST APIs

        $movieTitle = Read-Host "Enter Title of Movie"
        $movieTitle = [System.Web.HttpUtility]::UrlEncode($movieTitle)

        $ex5_url = "https://netflixroulette.net/api/api.php?title=$movieTitle"

        $ex5_r = ""
        try {
            $ex5_r = Invoke-WebRequest -Uri $ex5_url -Method Get            

            Write-Host "Full Result" -fo Green
            $ex5_r
        
            Write-Host "Content (the JSON we should expect)"  -fo Green
            $ex5_r.Content

            $ex5_r_obj = ConvertFrom-Json -InputObject $ex5_r.Content
        
            Write-Host "Converted from JSON to Object"  -fo Green
            $ex5_r_obj

            Write-Host "Summary"  -fo Green
            $ex5_r_obj.summary

        } catch {
            $_            
        }
    }
    6 {

        clear

        # now let's try Ice and Fire

        $ex6_url = "https://anapioficeandfire.com/api"
        
        $ex6_endpoint = "books"

        $ex6_uri = @($ex6_url,$ex6_endpoint) -join "/"

        $allBooksResult = Invoke-WebRequest -Uri $ex6_uri -Method Get

        $allBooks = $allBooksResult.Content | ConvertFrom-Json

        $allBooks | select name, url

        $book = $allBooks[0]
        
        Write-Host "Getting Characters for $($book.name)" -fo Green
        $allCharacters = $book.characters
        foreach($character in $allCharacters) {
            $charResult = Invoke-WebRequest -Uri $character -Method Get        
            $char = $charResult.Content | ConvertFrom-Json
            Write-Host "... $($char.name)"                                
        }                                    

    }
    7 {
        clear

        
        

    }

    default {
        Write-Output "What are you doing??? There's no Example with that number"
    }
}
