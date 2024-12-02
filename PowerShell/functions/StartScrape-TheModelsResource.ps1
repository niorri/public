function StartScrape-TheModelsResource
{
	param (
        [string]$Url = "",
		[array]$Urls = @(),
        [string]$UrlTextFilePath = "",
		[string]$OutputPath = "",
        [int]$DelayTimeInSeconds = 0, #Adds delay time to avoid server detecting as spam
        [float]$NaturalizeAmount = 0, #Adds randomization to delay time to avoid bot detection, 0.5 will remove and add halfl; i.e. 100 becomes 50 to 150
        [switch]$MakeTextFile,
        [switch]$IgnoreTextFile,
        [switch]$Debug
	)
    
    $defaultTitle = $Host.UI.RawUI.WindowTitle

    if($Debug){$Debug = $true}else{$Debug = $false}

    function Debug {
        param(
            [Parameter(Mandatory=$true)]
            [string]$Message,
            [ValidateSet(
                "Black",
                "DarkBlue",
                "DarkGreen",
                "DarkCyan",
                "DarkRed",
                "DarkMagenta",
                "DarkYellow",
                "Gray",
                "DarkGray",
                "Blue",
                "Green",
                "Cyan",
                "Red",
                "Magenta",
                "Yellow",
                "White"
            )]
            [string]$ForegroundColor = "Yellow",
            [ValidateSet(
                "Black",
                "DarkBlue",
                "DarkGreen",
                "DarkCyan",
                "DarkRed",
                "DarkMagenta",
                "DarkYellow",
                "Gray",
                "DarkGray",
                "Blue",
                "Green",
                "Cyan",
                "Red",
                "Magenta",
                "Yellow",
                "White"
            )]
            [string]$BackgroundColor = "Black"
        )

        if($Debug -eq $true)
        {
            $date = (get-date).ToString("HH:mm:ss > ")
            write-host ($date + $Message) -ForegroundColor $ForegroundColor -BackgroundColor $Backgroundcolor
        }
    }
    function DelayAndNaturalize {
        param(
            [int]$DelayTimeInSeconds,
            [float]$NaturalizeAmount
        )

        if($DelayTimeInSeconds -ne 0)
        {
            if($NaturalizeAmount -ne 0)
            {
                $DelayTime = [math]::Floor((Get-Random -Minimum ($DelayTimeInSeconds - ($DelayTimeInSeconds * $NaturalizeAmount)) -Maximum ($DelayTimeInSeconds + ($DelayTimeInSeconds * $NaturalizeAmount))) * 1000)
            }
            else
            {
                $DelayTime = $DelayTimeInSeconds * 1000
            }
        }

        Debug ("Delaying for " + ($DelayTime / 1000) + " seconds") -ForegroundColor Blue
        Start-Sleep -Milliseconds $DelayTime
    }

	if ($OutputPath.Length -eq 0)
	{
		$OutputPath = (Get-Location).Path
        Debug ("No OutputPath variable set, setting to " + $OutputPath)
	}
	if ($OutputPath.SubString($OutputPath.Length -1, 1) -ne "\")
	{
		$OutputPath = $OutputPath + "\"
        Debug ("OutputPath variable missing final backslash, path updated to " + $OutputPath)
	}
    
    Debug ("OutputPath variable finalized as " + $OutputPath)

    $cache = "$OutputPath\cache"
    if (Test-Path $cache -PathType Container)
    {
        Debug "cache already exists, old instance will be deleted"
        Remove-Item $cache -Recurse -Force -Confirm:$false -ea 0
    }
	
    if($Url.Length -gt 0)
    {
        $Urls += $Url
        Debug "Added singular Url to Urls list"
    }

    if($IgnoreTextFile -ne $true)
    {
        Debug "Will not ignore Url Text Files"
        if(Test-Path $UrlTextFilePath -PathType Leaf)
        {
            Debug "$UrlTextFilePath text file path is valid"
            Get-Content $UrlTextFilePath | foreach-Object {
                if($_ -like "*models-resource.com*")
                {
                    $Urls += $_
                }
            }
        }
        else
        {
            if(Test-Path ".\urls.txt" -PathType Leaf)
            {
                Debug "root text file path is valid"
                Get-Content ".\urls.txt" | foreach-Object {
                    if($_ -like "*models-resource.com*")
                    {
                        $Urls += $_
                    }
                }
            }
        }
    }

    if($MakeTextFile -eq $true)
    {
        New-Item -ItemType File -Path (".\urls.txt") -Force
        Debug "Making generic urls.txt file"
    }

    if($Urls.Count -eq 0)
    {
        Write-Host "Please define at least one Url" -ForegroundColor Red
    }
    else
    {
        Debug ("Downloaded 0 of " + $Urls.Count + " collections.") -ForegroundColor Cyan

	    foreach ($child in $Urls)
	    {
            #Build cache
            Debug "Making new child output folder, $cache"
            mkdir $cache -ea 0

            ###
		    $platform = ($child.Split("/") | Where-Object -Property Length -GT 0)[-2]
		    $title = ($child.Split("/") | Where-Object -Property Length -GT 0)[-1]

            Debug ("Platform is " + $platform)
            Debug ("Title is " + $title)
		
		    $Host.UI.RawUI.WindowTitle = "Scraping $title files"

            $outputChild = ($OutputPath + $platform + "\" + $title)
		    if (Test-Path $outputChild -PathType Container)
		    {
                Debug "OutputChild already exists, old instance will be deleted"
			    Remove-Item $outputChild -Recurse -Force -Confirm:$false -ea 0
		    }
            Debug "Making new child output folder, $outputChild"
		    mkdir $outputChild -ea 0

            # Web
            DelayAndNaturalize $DelayTimeInSeconds $NaturalizeAmount
            Debug "Invoking webpage: $child"
            do{
                $escape = $true
                try{
                    $web = Invoke-WebRequest $child
                }
                catch{
                    if($escape -eq $true)
                    {
                        Debug "Failed to invoke web-request. Will try again until success. ($child)" -ForegroundColor Red
                    }
                    $escape = $false
                }
            }while($escape -eq $false)
            
            $targets = $web.Links | Where-Object -Property href -Like (
			    "/" +
                $platform +
			    "/" +
			    $title +
			    "/model/*"
		    ) | Select-Object -ExpandProperty href

            $count = 0
		    foreach ($target in $targets)
		    {
			    $count++
			    $total = $targets.count
			    $percentage = (($count / $total) * 100)
			    Write-Progress -Activity "Downloading to $dir" -Status "$count / $total" -PercentComplete $percentage
			
			    $model = $target.Split("/")[$target.Split("/").Count - 2]
			    $target = "https://www.models-resource.com" + $target
			
                DelayAndNaturalize $DelayTimeInSeconds $NaturalizeAmount
                Debug "Invoking webpage: $target"
                do{
                    $escape = $true
                    try{
                        $target = Invoke-WebRequest $target
                    }
                    catch{
                        if($escape -eq $true)
                        {
                            Debug "Failed to invoke web-request. Will try again until success. ($target)" -ForegroundColor Red
                        }
                        $escape = $false
                    }
                }while($escape -eq $false)
			
			    $target = $target.Links | Where-Object -Property href -Like ("/download/" + "$model/") | Select-Object -ExpandProperty href | Select-Object -First 1
			
			    $target = "https://www.models-resource.com" + $target
			
                $savePath = ($cache + "\$model.zip")

                DelayAndNaturalize $DelayTimeInSeconds $NaturalizeAmount
                Debug "Saving to path: $savePath"
                do{
                    $escape = $true
                    try{
                        Invoke-WebRequest $target -OutFile $savePath
                    }
                    catch{
                        if($escape -eq $true)
                        {
                            Debug "Failed to invoke web-request. Will try again until success. ($target)" -ForegroundColor Red
                        }
                        $escape = $false
                    }
                }while($escape -eq $false)

                # extracting data from downloaded archive files
                $target = Get-Item $savePath

                Debug "Unpacking archive: $target"
                Expand-Archive $target -DestinationPath $target.DirectoryName
                Remove-Item $target -Recurse -Force -Confirm:$false -ea 0

                $savedFiles = gci $cache -File
                $savedDirectories = gci $cache -Directory
                if($savedFiles.Count -gt 0)
                {
                    New-Item -Path ("$outputChild\$model") -ItemType Directory -Force
                    $savedFiles | Move-Item -Destination ("$outputChild\$model")
                    $savedDirectories | Move-Item -Destination ("$outputChild\$model")
                    debug "Move-Item performed on loose files" -ForegroundColor DarkGray
                }
                else
                {
                    $savedDirectories | Move-Item -Destination ("$outputChild")
                    debug "Move-Item performed on directory" -ForegroundColor DarkGray
                }
                
                Debug ("Downloaded " + $count + " of " + $total + " models.") -ForegroundColor Green
		    }

            Debug ("Downloaded " + ($Urls.IndexOf($child) +1) + " of " + $Urls.Count + " collections.") -ForegroundColor Cyan
        }
    }

    if (Test-Path $cache -PathType Container)
    {
        Remove-Item -Path $cache -Force
    }

    $Host.UI.RawUI.WindowTitle = $defaultTitle
}

#Usage Examples
# StartScrape-TheModelsResource -Url "https://www.models-resource.com/nintendo_64/legendofzeldaocarinaoftime/"
# StartScrape-TheModelsResource -OutputPath "C:\My\Output\Folder\Path" -UrlTextFilePath "C:\My\Text\File\Full\Of\Urls.txt" -Debug -DelayTimeInSeconds 1 -NaturalizeAmount 0.5