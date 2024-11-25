#region Pre-Load
$global:PowerShellTheme = @{
    default = "White"
    root = "Green"
    child = "Yellow"
    divider = "Cyan"
    accent = "Magenta"
} #Global variable to store custom PS Theme colors

# Default Functions
function prompt {

    $date = Get-Date
    $path = ($executionContext.SessionState.Path.CurrentLocation).Path
    write-host "[" -NoNewline -ForegroundColor $global:PowerShellTheme.divider
    write-host $date.ToString("HH") -NoNewline -ForegroundColor $global:PowerShellTheme.child
    write-host ":" -NoNewline -ForegroundColor $global:PowerShellTheme.accent
    write-host $date.ToString("mm") -NoNewline -ForegroundColor $global:PowerShellTheme.child
    write-host ":" -NoNewline -ForegroundColor $global:PowerShellTheme.accent
    write-host $date.ToString("ss") -NoNewline -ForegroundColor $global:PowerShellTheme.child
    write-host "] " -NoNewline -ForegroundColor $global:PowerShellTheme.divider
    write-host $path.Split(":")[0] -NoNewline -ForegroundColor $global:PowerShellTheme.root
    write-host ":" -NoNewline -ForegroundColor $global:PowerShellTheme.accent
    $path.Split("\") | ForEach-Object {
        if($_ -notlike "*:*")
        {
            write-host "\" -NoNewline -ForegroundColor $global:PowerShellTheme.divider
            write-host $_ -NoNewline -ForegroundColor $global:PowerShellTheme.child
        }
    }
    write-host ">" -NoNewline -ForegroundColor $global:PowerShellTheme.accent
    return " "
}
function Install-MyGitHubPSFunctions{
    param(
        [string]$Path,
        [string]$Token #Token isn't required except to avoid rate-limits
    )

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
        $Path = "$env:APPDATA\miorri\PowerShell\functions\"
    }
    
    # Main
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
} #Get-MyGitHubPSFunctions v1 (modded)
function Get-IPInfo {
    param (
        [string]$IPAddress
    )

    if($IPAddress.Length -eq 0)
    {
        $ipAddress = (Invoke-WebRequest -Uri "https://ipinfo.io/ip" -ErrorAction SilentlyContinue).Content.Trim()
    }

    Invoke-RestMethod -Uri "https://ipinfo.io/$ipAddress/json"
}
#endregion

#region Presentation
#region Default display
cls
Write-Host "PowerShell" -ForegroundColor Blue -NoNewline
Write-Host (" v" + $PSVersionTable.PSVersion.ToString())
Write-Host (Get-Date).ToString("F") -ForegroundColor $global:PowerShellTheme.divider
Write-Host ""
#endregion
#region Custom functions count
$FunctionsCount = (Get-Command -Type Function).Count
$CustomFunctionsPath = "$env:APPDATA\miorri\PowerShell\functions\"
gci $CustomFunctionsPath -File |
    ForEach-Object {
        . $_.FullName
    }
Write-Host ("Activated " + ((Get-Command -Type Function).Count - $FunctionsCount).ToString() + " custom functions.`n") -ForegroundColor Green
Remove-Variable FunctionsCount
#endregion
#region Network dependant features
if(Test-Connection 8.8.8.8 -Count 1 -Quiet)
{
    if((Get-Command | Where-Object -Property Name -Like "Get-IPInfo").Count -gt 0)
    {
        $ipInfo = Get-IPInfo
        Write-Host $ipInfo.City -ForegroundColor $global:PowerShellTheme.child -NoNewline
        Write-Host ", " -ForegroundColor $global:PowerShellTheme.accent -NoNewline
        Write-Host $ipInfo.Country -ForegroundColor $global:PowerShellTheme.child
        Write-Host $ipInfo.Org -ForegroundColor $global:PowerShellTheme.divider
        Write-Host ""
    }
}
#endregion
#endregion