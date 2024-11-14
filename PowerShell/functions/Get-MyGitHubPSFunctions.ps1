#v1
function Get-MyGitHubPSFunctions{
    param(
        [string]$Path,
        [string]$Token #Token isn't required except to avoid rate-limits
    )

    $owner = "miorri"
    $repo = "public"
    $subDirectories = @(
        "PowerShell",
        "functions"
    ) #this will work for public/PowerShell/functions #Warning, this is case sensitive

    $uri = "https://api.github.com/repos/$owner/$repo/contents"

    foreach($sub in $subDirectories)
    {
        $uri = $uri + "/" + $sub
    }

    $response = Invoke-RestMethod -Uri $uri -Method Get

    $total = ($response | Where-Object -Property type -Like "file").Count
    $percent = 0
    $count = 1

    # Parse responses and take action on files
    foreach ($item in $response)
    {
        $percent = ($count / $total) * 100
        Write-Progress -Activity "Downloading items..." -Status (
            $count.ToString() + 
            "/" + 
            $total.ToString() +
            " (" +
            $percent.ToString("0") +
            "%)"
        ) -PercentComplete $percent
        
        if($item.type -eq "dir")
        {
            Write-Host $item.name -ForegroundColor Gray
        }
        elseif($item.type -eq "file")
        {
            Write-Host $item.name -ForegroundColor Yellow

            # Set the GitHub API endpoint for raw file content
            $functionUri = ($uri + "/" + $item.name)
            #write-host $functionUri -ForegroundColor Yellow

            # Make GET request to the GitHub API to get the raw content URL
            if($token.Length -gt 0)
            {
                $functionResponse = Invoke-RestMethod -Uri $functionUri -Method Get -Headers @{Authorization = "token $token"}
            }
            else
            {
                $functionResponse = Invoke-RestMethod -Uri $functionUri -Method Get
            }

            # Download the file using the raw content URL
            if($Path.Length -gt 0)
            {
                if(-not(Test-Path $Path))
                {
                    $Path = ".\"
                }
                else
                {
                    if($Path.Substring(0, $Path.Length -1) -ne "\")
                    {
                        $Path = $Path + "\"
                    }
                }
            }
            else
            {
                $Path = ".\"
            }

            if($token.Length -gt 0)
            {
                Invoke-WebRequest -Uri $functionResponse.download_url -OutFile ($Path + $item.name) -Headers @{Authorization = "token $token"}
            }
            else
            {
                Invoke-WebRequest -Uri $functionResponse.download_url -OutFile ($Path + $item.name)
            }
        }

        $count++
    }
}

# Usage
# Get-MyGitHubPSFunctions -Path "C:\Users\username\Downloads\"
