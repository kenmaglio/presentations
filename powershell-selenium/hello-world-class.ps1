Class MAGDEV_CORE {
    $config = @{}
    hidden [string]$logFile = ".\automation.log"   

    MAGDEV_CORE(){
        $this.config.verbose = $false

        $this.config.baseURL = 'https://www.meetup.com'

        $this.config.basePath = "C:\_lab"
        $this.config.packageDir = 'packages'

        $this.config.packagePath = Join-Path $($this.config.basePath) $($this.config.packageDir)
      
    }

    #region Methods
    [void] Log ([string] $message) {
        if($this.config['verbose']) {
            Write-Host $("Verbose: {0}" -f $message) -ForegroundColor Cyan
        }
        $date = Get-Date -f 'yyyyMMdd:hhmmss'
        ("{0}-{1}" -f $date,$message) | Out-File $this.logFile -Append
    }

    [string]JoinUri([uri]$uri,[string]$childPath) {
        $combinedPath = [system.io.path]::Combine($uri.AbsoluteUri, $childPath)
        $combinedPath = $combinedPath.Replace('\', '/')
        return New-Object uri $combinedPath
    }

    #endregion
}

Class MAGDEV_MAIN : MAGDEV_CORE {
    #region Public Properties
    #endregion

    #region Sub Classes
    [MAGDEV_SELENIUM] $Selenium = $null
    #endregion

    MAGDEV_MAIN() {
        $this.Selenium = New-Object MAGDEV_SELENIUM
    }

    [void]Shutdown() {
        $this.Log("Shutting Down Main...")
        $this.Selenium.Shutdown()
        $this.Log(".....Ending Run")
    }

    [void]SetConfig() {
        if (-not(Test-Path -Path $($this.config.basePath))) {
            New-Item $($this.config.basePath) -ItemType Directory -Force
        }
        
        if (-not(Test-Path $($this.config.packagePath))) {
            New-Item $($this.config.packagePath) -ItemType Directory -Force
        }

        $this.Selenium.config = $this.config
    }

    [void]VerboseLogging([bool]$value){
        $this.config.verbose = $value
        $this.SetConfig()
    }

    #region Automation
    

    
    #endregion

    
}


Class MAGDEV_SELENIUM : MAGDEV_CORE {
    #region Private Properties
    hidden [OpenQA.Selenium.Chrome.ChromeDriver]$SELENIUM = $null
    #endregion


    MAGDEV_SELENIUM() {
    }

    [void]Shutdown() {
        $this.Log("Shutting Down Selenium...")
        $this.SELENIUM.Close()
    }

    #region Get Selenium Chrome Driver
    [void]GetChrome() {
        Push-Location

        $packagePath = $this.config.packagePath
    
        Set-Location $packagePath

    
        $path = Join-Path $packagePath ".\Selenium.WebDriver.*\lib\net40"
        $pathToWebDriver = Resolve-Path $path

        Add-Type -Path (Join-Path $pathToWebDriver WebDriver.dll)

        $path = Join-Path $packagePath "Selenium.WebDriver.ChromeDriver.*\driver\win32"
        $pathToChromeDriver = Resolve-Path $path

        # test if we can build a ChromeDriver if we are in the packages dir
        $webdriver = $null
        try {
            $webdriver = New-Object OpenQA.Selenium.Chrome.ChromeDriver($pathToChromeDriver)        
        } catch {
            $installIt = Read-Host -Prompt "Could not build Chrome Driver, continue to install?  [Y/N] (Default N)"
            if ($installIt.ToLower() -eq 'y') {
                $cleanIt = Read-Host -Prompt "Clean packages? [Y/N] (Default N)"
                if ($cleanIt.ToLower() -eq 'y') {
                    Write-Host "Cleaning existing packages"
                    Remove-Item -Path $packagePath -Recurse -Force
                    New-Item $packagePath -ItemType Directory -Force
                }

                Install-Package Selenium.WebDriver -Destination $packagePath
                Install-Package Selenium.WebDriver.ChromeDriver -Destination $packagePath

                $webdriver = New-Object OpenQA.Selenium.Chrome.ChromeDriver($pathToChromeDriver)
            }
        }
    
        Pop-Location

        $this.SELENIUM = $webdriver
    
    }

    #endregion

    #region basic methods

    [void]Navigate($url) {
        $this.Log("Navigate to: $url")
        $this.SELENIUM.Navigate().GoToUrl($url)
    }

    [void]FindAndTypeByName($Name, $SendKeys) {
        $this.Log(("Find {0} and Send {1}" -f $Name, $SendKeys))
        $el = $this.SELENIUM.FindElementByName($Name)
        $el.SendKeys($SendKeys)
    }

    [void]FindAndClickBySelector($Selector) {
        $this.Log(("Find by Selector `"{0}`" and Click" -f $Selector))
        $el = $this.SELENIUM.FindElementByCssSelector($Selector)
        $el.Click()
    }

    [void]FindAndClickByText($Text) {
        $this.Log(("Find by Link Text `"{0}`" and Click" -f $Text))
        $el = $this.SELENIUM.FindElementByLinkText($Text)
        $el.Click()
    }

    [void]FindAndClickByName($Name) {
        $this.Log(("Find by Name `"{0}`" and Click" -f $Name))
        $el = $this.SELENIUM.FindElementByName($Name)
        $el.Click()
    }
    #endregion


    [array]GetEvents(){
        $eventURLS = @()

        
        $eventCards = $this.SELENIUM.FindElementsByClassName('eventCard--link')

        # show help by doing this
        #[OpenQA.Selenium.Remote.RemoteWebElement]$card = $null

        ForEach($card in $eventCards) {
            $url = $card.GetAttribute('href')
            if ($url -like '*/STLPSUG/*'){
                $eventURLS += $url
            }
        }

        return $eventURLS
    }

    [array]GetUpcomingEvents(){
        $eventURLS = @()

        # but we need to first look for this:
        $this.Log("Find upcoming event list element")
        $elUpcoming = $this.SELENIUM.FindElementByClassName('groupHome-eventsList-upcomingEvents')
        $this.Log("Find event cards")
        $eventCards = $elUpcoming.FindElementsByClassName('eventCard--link')
        $this.Log(("Event Cards Found: {0}" -f $eventCards.Count))
        
        ForEach($card in $eventCards) {
            $url = $card.GetAttribute('href')
            if ($url -like '*/STLPSUG/*'){
                $this.Log(("Found Event: {0}" -f $url))
                $eventURLS += $url
            }
        }
        $this.Log(("Total Event URLS: {0}" -f $eventURLS.Count))

        return $eventURLS
    }

    [array]GetAttendees($eventURL) {
        $this.Log("Navigate to event attendeeds URL")
        $this.Navigate($eventURL)

        $attendees = @()

        $js = 'window.scrollTo(0, document.body.scrollHeight);'

        $noMoreAttendees = $false
        $attendeeCount = -1
        $this.Log("Attendees is an infinite scroll page, scroll till we have the same count")
        Do {
            $attendeeItems = $this.SELENIUM.FindElementsByClassName('attendee-item')
            $this.Log(("Count: {0}" -f $attendeeItems.Count))
            if ($attendeeCount -ne $attendeeItems.Count) {
                if ($attendeeItems.Count -gt 0) {
                    $this.Log("Scroll the page...")
                    $attendeeCount = $attendeeItems.Count
                    $this.SELENIUM.ExecuteScript($js)
                    Start-Sleep 1
                } else {
                    $this.Log("Waiting for initial attendee list to load...")
                    Start-Sleep 3
                }
            } else {
                $attendeeCount = $attendeeItems.Count
                $noMoreAttendees = $true
            }
        }
        Until ($noMoreAttendees)
        $this.Log(("Final Count: {0}" -f $attendeeItems.Count))

        ForEach($item in $attendeeItems) {
            $attendee = @{}
            
            $selector = "div[class='flex-item']"
            $div = $item.FindElementByCssSelector($selector)

            $a = $div.FindElementByTagName('a')
            $h4 = $div.FindElementByTagName('h4')

            $this.Log(("Found Attendee: {0}" -f $h4.Text))
            $attendee.Name = $h4.Text
            $attendee.Profile = $a.GetAttribute('href')

            $attendees += $attendee
        }
        $this.Log(("Total Attendees Found: {0}" -f $attendees.Count))

        return $attendees

    }
}