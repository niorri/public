#v1
function Clear-PSCommandHistory {
    param (
        [int]$ClearLastXCommands = 0,
        [int]$ClearFirstXCommands = 0
    )

    if($ClearLastXCommands -eq 0 -and $ClearFirstXCommands -eq 0)
    {
        New-Item -Path "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" -ItemType File -Force
    }
    else
    {
        $historyPath = "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
        $commandList = Get-Content $historyPath

        $commandListSize = $commandList.Count

        # Adjust ClearLastXCommands and ClearFirstXCommands if they exceed the list size
        $ClearLastXCommands = [math]::Min($ClearLastXCommands, $commandListSize)
        $ClearFirstXCommands = [math]::Min($ClearFirstXCommands, $commandListSize)

        # If the sum of ClearFirstXCommands and ClearLastXCommands is greater than or equal to the commandListSize, clear all
        if($ClearFirstXCommands + $ClearLastXCommands -ge $commandListSize)
        {
            New-Item -Path $historyPath -ItemType File -Force
        }
        else
        {
            # Clear specified commands and keep the rest
            $commandsToKeep = $commandList[$ClearFirstXCommands..($commandListSize - $ClearLastXCommands - 1)]
            $commandsToKeep | Set-Content $historyPath
        }
    }
}
