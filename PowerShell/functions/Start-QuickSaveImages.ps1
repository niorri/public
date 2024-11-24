# v1
# Save images from clipboard, makes it easy to Right Click + Copy and save image automatically to a directory
function Start-QuickSaveImages {
    param(
        [string]$Path,
        [ValidateSet(".png", ".jpg", ".bmp", ".gif", ".tiff")]
        [string]$Extension,
        [switch]$Loop
    )
    
    if($PSVersionTable.PSVersion.Major -eq 5)
    {
        # Image prep
        Add-Type -AssemblyName System.Windows.Forms

        # Path
        if($Path.Length -eq 0)
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

        # Core
        $escape = $false
        $compareObj = ""
        $count = 0

        do{
            # Compare to last copy before saving
            $clipboardData = (Get-Clipboard -Format Image)
            if($clipboardData -is [System.Drawing.Image])
            {
                # Create a memory stream to not save the image
                $memoryStream = New-Object System.IO.MemoryStream
                $clipboardData.Save($memoryStream, [System.Drawing.Imaging.ImageFormat]::Png)

                # Get the byte array and calculate a hash
                $byteArray = $memoryStream.ToArray()
                $hash = [BitConverter]::ToString([System.Security.Cryptography.SHA256]::Create().ComputeHash($byteArray))

                if ($hash -ne $compareObj) {
                    # Make image from clipboard
                    [System.Windows.Forms.Clipboard]::SetDataObject($clipboardData, $true)
                    $img = [System.Windows.Forms.Clipboard]::GetImage()

                    # Save
                    $name = ($count.ToString("0000") + "_" + ((New-Guid).Guid).Substring(0, 8))

                    if($Extension -like ".tiff")
                    {
                        $img.Save(($Path + $name + $Extension), [System.Drawing.Imaging.ImageFormat]::Tiff)
                    }
                    elseif($Extension -like ".gif")
                    {
                        $img.Save(($Path + $name + $Extension), [System.Drawing.Imaging.ImageFormat]::Gif)
                    }
                    elseif($Extension -like ".bmp")
                    {
                        $img.Save(($Path + $name + $Extension), [System.Drawing.Imaging.ImageFormat]::Bmp)
                    }
                    elseif($Extension -like ".jpg")
                    {
                        $img.Save(($Path + $name + $Extension), [System.Drawing.Imaging.ImageFormat]::Jpeg)
                    }
                    else
                    {
                        $img.Save(($Path + $name + $Extension), [System.Drawing.Imaging.ImageFormat]::Png)
                    }

                    # Chance for escape
                    if($Loop)
                    {
                        cls
                        $count++
                        Write-Host ("`nSaved " + $count.ToString() + " images.`n") -ForegroundColor Yellow
                    }
                    else
                    {
                        $escape = $true
                    }
                }
            }

            # Set the new hash for comparison
            $compareObj = $hash

        }while($escape -eq $false)
    }
    else
    {
        Write-Host 'Unfortunately, this function will only work on PoSh 5.X;' -ForegroundColor Red
        Write-Host '"Get-Clipboard -Format Image" is not available on later builds.' -ForegroundColor Red
    }
}