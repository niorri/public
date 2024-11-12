function Test-IfPrime {
    param (
        [Parameter(Mandatory=$true)]
        [int]$Number,
        [switch]$WriteOutput
    )

    if($Number -le 1)
    {
        $isPrime = $false

        if($WriteOutput)
        {
            Write-Host ($Number.ToString() + " is not prime.") -ForegroundColor Gray
        }
        else
        {
            $isPrime
        }
    }
    else
    {
        $isPrime = $true
        
        for ($i = 2; $i -le [math]::Sqrt($Number); $i++) {
            if($Number % $i -eq 0)
            {
                $isPrime = $false
                break
            }
        }
        
        if($isPrime)
        {
            if($WriteOutput)
            {
                Write-Host ($Number.ToString() + " is prime.") -ForegroundColor Cyan
            }
            else
            {
                $isPrime
            }
        }
        else
        {
            if($WriteOutput)
            {
                Write-Host ($Number.ToString() + " is not prime.") -ForegroundColor Gray
            }
            else
            {
                $isPrime
            }
        }
    }
}

# Example usage
#Test-IfPrime -Number 29
#Test-IfPrime -Number 30
#1..100 | % { Test-IfPrime $_ -WriteOutput}