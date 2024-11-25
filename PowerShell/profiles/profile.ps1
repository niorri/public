$CustomProfile = "$env:APPDATA\miorri\PowerShell\profiles\"
if((gci $CustomProfile -File | Where-Object -Property BaseName -Like $host.UI.RawUI.WindowTitle).Count -gt 0)
{
	$CustomProfile = $CustomProfile + $host.UI.RawUI.WindowTitle + ".ps1"
	. $CustomProfile
}
else
{
	cls
	Write-Host "PowerShell" -ForegroundColor Blue -NoNewline
	Write-Host (" v" + $PSVersionTable.PSVersion.ToString())
	Write-Host (Get-Date).ToString("F") -ForegroundColor Cyan
	Write-Host ""
}
