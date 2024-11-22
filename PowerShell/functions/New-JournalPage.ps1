function New-JournalPage {
    param(
        [string]$Path
    )

    if($Path.Length -eq 0)
    {
        $Path = ".\"
    }

    $date = Get-Date

    $dir = ($Path + $date.ToString("yyyy, MM - MMMM"))
    $dir = (
        $Path +
        $date.ToString("yyyy") +
        "\" +
        $date.ToString("MM, MMMM") +
        "\"
    )

    New-Item -ItemType Directory -Path $dir -Force

    ('***' + $date.ToString("dd\/MM\/yy - dddd, MMMM dd yyyy") + '***
') | Out-File -FilePath ($dir + "\" + $date.ToString("yy-MM-dd") + ".md") -Encoding utf8 -Force
}