#v1
function Get-PSCommandHistory {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateSet('First', 'Last', 'All')]
        [string]$Mode,
        [Parameter(Position = 1)]
        [int]$Count = 1
    )

    $historyFilePath = "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"

    if (-Not (Test-Path $historyFilePath)) {
        Write-Error "History file not found at: $historyFilePath"
        return
    }

    $historyLines = Get-Content -Path $historyFilePath

    switch ($Mode) {
        'First' {
            # Get the first X commands
            return $historyLines | Select-Object -First $Count
        }

        'Last' {
            # Get the last X commands
            return $historyLines | Select-Object -Last $Count
        }

        'All' {
            # Get all commands
            return $historyLines
        }
    }
}