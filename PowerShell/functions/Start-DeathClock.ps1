function Start-DeathClock {
    param(
        [Parameter(Mandatory=$true)]
        [DateTime]$Birthday,
        [Parameter(Mandatory=$true)]
        [ValidateSet("Male", "Female")]
        [String]$Sex,
        [Float]$LifeExpectancy,
        [Int]$DelayTimeInSeconds = 1,
        [Switch]$Loop
    )

    if($LifeExpectancy -eq 0)
    {
        $expectancies = @(
                [PSCustomObject]@{
                        Open = 1950
                        Close = 1952
                        Male = 67.2
                        Female = 71.3
                },
                [PSCustomObject]@{
                        Open = 1953
                        Close = 1954
                        Male = 67.6
                        Female = 72.15
                },
                [PSCustomObject]@{
                        Open = 1955
                        Close = 1957
                        Male = 68
                        Female = 73
                },
                [PSCustomObject]@{
                        Open = 1958
                        Close = 1959
                        Male = 68.2
                        Female = 73.4
                },
                [PSCustomObject]@{
                        Open = 1960
                        Close = 1962
                        Male = 68.4
                        Female = 73.8
                },
                [PSCustomObject]@{
                        Open = 1963
                        Close = 1964
                        Male = 68.3
                        Female = 74.05
                },
                [PSCustomObject]@{
                        Open = 1965
                        Close = 1967
                        Male = 68.2
                        Female = 74.3
                },
                [PSCustomObject]@{
                        Open = 1968
                        Close = 1969
                        Male = 68.35
                        Female = 74.45
                },
                [PSCustomObject]@{
                        Open = 1970
                        Close = 1972
                        Male = 68.5
                        Female = 74.6
                },
                [PSCustomObject]@{
                        Open = 1973
                        Close = 1974
                        Male = 68.75
                        Female = 75.05
                },
                [PSCustomObject]@{
                        Open = 1975
                        Close = 1977
                        Male = 69
                        Female = 75.5
                },
                [PSCustomObject]@{
                        Open = 1978
                        Close = 1979
                        Male = 69.7
                        Female = 75.95
                },
                [PSCustomObject]@{
                        Open = 1980
                        Close = 1982
                        Male = 70.4
                        Female = 76.4
                },
                [PSCustomObject]@{
                        Open = 1983
                        Close = 1984
                        Male = 70.75
                        Female = 76.75
                },
                [PSCustomObject]@{
                        Open = 1985
                        Close = 1987
                        Male = 71.1
                        Female = 77.1
                },
                [PSCustomObject]@{
                        Open = 1988
                        Close = 1989
                        Male = 72
                        Female = 77.9
                },
                [PSCustomObject]@{
                        Open = 1990
                        Close = 1992
                        Male = 72.9
                        Female = 78.7
                },
                [PSCustomObject]@{
                        Open = 1993
                        Close = 1994
                        Male = 73.65
                        Female = 79.2
                },
                [PSCustomObject]@{
                        Open = 1995
                        Close = 1997
                        Male = 74.4
                        Female = 79.7
                },
                [PSCustomObject]@{
                        Open = 1998
                        Close = 1999
                        Male = 75.35
                        Female = 80.4
                },
                [PSCustomObject]@{
                        Open = 2000
                        Close = 2002
                        Male = 76.3
                        Female = 81.1
                },
                [PSCustomObject]@{
                        Open = 2003
                        Close = 2004
                        Male = 77.15
                        Female = 81.65
                },
                [PSCustomObject]@{
                        Open = 2005
                        Close = 2007
                        Male = 78
                        Female = 82.2
                },
                [PSCustomObject]@{
                        Open = 2008
                        Close = 2011
                        Male = 78.75
                        Female = 82.7
                },
                [PSCustomObject]@{
                        Open = 2012
                        Close = 2014
                        Male = 79.5
                        Female = 83.2
                },
                [PSCustomObject]@{
                        Open = 2015
                        Close = 2016
                        Male = 79.75
                        Female = 83.35
                },
                [PSCustomObject]@{
                        Open = 2017
                        Close = 2019
                        Male = 80
                        Female = 83.5
                }
        )
        if($Birthday.Year -lt 1950)
        {
            if($Sex -eq "Male")
            {
                $LifeExpectancy = $expectancies[0].Male
            }
            else
            {
                $LifeExpectancy = $expectancies[0].Female
            }
        }
        elseif($Birthday.Year -gt 2019)
        {
            if($Sex -eq "Male")
            {
                $LifeExpectancy = $expectancies[-1].Male
            }
            else
            {
                $LifeExpectancy = $expectancies[-1].Female
            }
        }
        else
        {
            if($Sex -eq "Male")
            {
                $LifeExpectancy = ($expectancies | Where-Object -Property Open -LE $Birthday.Year | Where-Object -Property Close -GE $Birthday.Year)[0].Male
            }
            else
            {
                $LifeExpectancy = ($expectancies | Where-Object -Property Open -LE $Birthday.Year | Where-Object -Property Close -GE $Birthday.Year)[0].Female
            }
        }
    }

    $LifeExpectancyYears = [math]::Floor($LifeExpectancy)
    $remainingFraction = $LifeExpectancy - $LifeExpectancyYears
    $additionalDays = [math]::Round($remainingFraction * 365.25)

    $expiryDate = $Birthday.AddYears($LifeExpectancyYears).AddDays($additionalDays)

    $lifeSpan = $expiryDate - $Birthday

    if($loop)
    {
        do{
            cls
            $now = Get-Date
            $timeRemaining = ($expiryDate - $now)
            $timeUsed = ($lifespan - $timeRemaining)

            Write-Host ("User born: " + $Birthday.ToString("dd/MM/yyyy, HH:mm tt"))
            Write-Host ("Life expectancy: " + $lifeExpectancy + " years")
            
            Write-Host ("`nBest before date: " + $expiryDate.ToString("dd/MMM/yyyy"))

            $age = $now - $Birthday

            $years = $age.Days / 365
            $months = ($age.Days % 365) / 30
            $days = ($age.Days % 365) % 30
            $hours = $now.Hour - $Birthday.Hour
            $minutes = $now.Minute - $Birthday.Minute
            $seconds = $now.Second - $Birthday.Second

            # Adjusting for negative values
            if ($seconds -lt 0) {
                $seconds += 60
                $minutes -= 1
            }

            if ($minutes -lt 0) {
                $minutes += 60
                $hours -= 1
            }

            if ($hours -lt 0) {
                $hours += 24
                $days -= 1
            }

            Write-Host "`nCurrent Age" -ForegroundColor Gray
            Write-Host ($years.ToString("0") + " years")
            Write-Host ($months.ToString("0") + " months")
            Write-Host ($days.ToString("0") + " days")
            Write-Host ($hours.ToString("0") + " hours")
            Write-Host ($minutes.ToString("0") + " minutes")
            Write-Host ($seconds.ToString("0") + " seconds")

            Write-Host "`nRemaining time as total values" -ForegroundColor Gray
            Write-Host ("Seconds: " + $timeRemaining.TotalSeconds.ToString("0"))
            Write-Host ("Minutes: " + $timeRemaining.TotalMinutes.ToString("0"))
            Write-Host ("Hours: " + $timeRemaining.TotalHours.ToString("0"))
            Write-Host ("Days: " + $timeRemaining.TotalDays.ToString("0"))
            Write-Host ("Weeks: " + ($timeRemaining.TotalDays * (52.1775 / 365.25)).ToString("0"))
            Write-Host ("Months: " + ($timeRemaining.TotalDays / 30.4375).ToString("0"))
            Write-Host ("Years: " + ($timeRemaining.TotalDays / 365.25).ToString("0"))

            $percentage = ($timeRemaining.TotalSeconds / $lifeSpan.TotalSeconds) * 100
            if($percentage -lt 0.00){$percentage = 0.00}

            if($percentage -ge 83.33)
            {
                $batteryColor = "DarkGreen"
            }
            elseif($percentage -ge 66.66)
            {
                $batteryColor = "Green"
            }
            elseif($percentage -ge 50)
            {
                $batteryColor = "White"
            }
            elseif($percentage -ge 33.33)
            {
                $batteryColor = "Yellow"
            }
            elseif($percentage -ge 16.66)
            {
                $batteryColor = "DarkYellow"
            }
            else
            {
                $batteryColor = "Red"
            }

            Write-Host ("`nBody battery: " + $percentage.ToString("0.00") + "%") -ForegroundColor $batteryColor

            Start-Sleep -Seconds $DelayTimeInSeconds

        }while($true)
    }
    else
    {
        $usedTime = ($expiryDate - $now)
        $timeRemaining = $lifeSpan - $timeUsed

        [PSCustomObject]@{
            Birthday = $Birthday
            Sex = $Sex
            LifeExpectancy = $LifeExpectancy
            BestBeforeDate = $expiryDate
            LifeSpan = $lifeSpan
            UsedTime = $timeUsed
            RemainingTime = $timeRemaining
        }
    }
}

<#
$birthString = "31/12/2009 05:29:30"
$birth = [datetime]::ParseExact($birthString, "dd/MM/yyyy HH:mm:ss", $null)
Start-DeathClock -Birthday $birth -Sex Female -Loop
#>