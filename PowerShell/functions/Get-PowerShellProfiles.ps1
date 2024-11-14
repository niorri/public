function Get-PowerShellProfiles {
    $profile | Select-Object * -ExcludeProperty Length | Format-List -Force
}