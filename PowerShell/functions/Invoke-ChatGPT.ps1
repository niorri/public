#v2.1

# Global variable to store chat history
$global:GPTChatHistory = @()

function Invoke-ChatGPT {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [string]$Color = "Yellow",
        [string]$apiKey, # You can predefine your API Key here ahead of time e.g. [string]$apiKey = "MY API KEY"
        [ValidateSet('gpt-4o', 'gpt-4o-mini', 'o1-preview', 'o1-mini', 'gpt-4-turbo', 'gpt-4')]
        [string]$Model = "gpt-4o-mini",
        [string]$ContextProfile,
        [int]$MaxTokens = 2048,
        [switch]$ResetHistory
    )

    #region Context profiles. Feel free to delete these or add your own!
    $ContextProfiles = @(
        @{
            Name = "PowerShell" #Coding language example
            InitialPrompt = "I am a software engineer using PowerShell, this conversation will be about PowerShell."
            ReminderPrompt = "Remember, I am a software engineer using PowerShell."
            Color = "DarkCyan"
        },
        @{
            Name = "WindowsSupport" #Practical assistance example
            InitialPrompt = "I am a computer engineer working in support. Please keep your responses relevant to Windows 11 support."
            ReminderPrompt = "Remember, I have a background in computer engineering and am currently supporting Windows 11."
            Color = "Blue"
        },
        @{
            Name = "Naruto" #Character example
            InitialPrompt = "For this conversation I want you to reply as if you are Naruto Uzumaki from the series Naruto: Shippuden"
            ReminderPrompt = "Remember, you must reply as if you are Naruto Uzumaki from Naruto: Shippuden."
            Color = "DarkYellow"
        }
    )
    #endregion

    if($ResetHistory)
    {
        $global:GPTChatHistory = @()  # Clear the chat history
    }

    if($apiKey.Length -eq 0)
    {
        Write-Host "Please define an API key first." -ForegroundColor "Red"
        return
    }

    $endpoint = "https://api.openai.com/v1/chat/completions"

    # Create the headers for authentication
    $headers = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $apiKey"
    }

    # If Profile exists, prepend message with Profile flags
    if(($ContextProfiles | Where-Object {$_.Name -like $ContextProfile}).Count -gt 0)
    {
        $context = ($ContextProfiles | Where-Object {$_.Name -like $ContextProfile})

        $color = $context.Color

        if($global:GPTChatHistory.Length -eq 0)
        {
            $Message = ($context.InitialPrompt + " " + $Message)
        }
        else
        {
            $Message = ($context.ReminderPrompt + " " + $Message)
        }
    }

    # Append the new message to the chat history
    $global:GPTChatHistory += @{
        "role" = "user"
        "content" = $Message
    }

    # Define your data payload
    $data = @{
        "model" = $Model
        "messages" = $global:GPTChatHistory
        "temperature" = 1
        "max_tokens" = $MaxTokens
        "top_p" = 1
        "frequency_penalty" = 0
        "presence_penalty" = 0
    } | ConvertTo-Json

    try{
        # Invoke the API and get the response
        $response = Invoke-RestMethod -Uri $endpoint -Method Post -Headers $headers -Body $data

        # Append the assistant's reply to the conversation history
        $assistantMessage = $response.choices[0].message.content
        $global:GPTChatHistory += @{
            "role" = "assistant"
            "content" = $assistantMessage
        }

        # Output message
        Write-Host $assistantMessage -ForegroundColor $Color

    }catch{
        Write-Host "An error occurred: $_" -ForegroundColor "Red"
    }
}

Set-Alias -Name "gpt" -Value "Invoke-ChatGPT"