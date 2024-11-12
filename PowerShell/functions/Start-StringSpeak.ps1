function Start-StringSpeak {
    param (
        [string]$String,
        [string]$VoiceName,
        [switch]$GetInstalledVoices
    )

    Add-Type -AssemblyName System.speech
    $speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
    $voices = $speak.GetInstalledVoices().VoiceInfo.Name

    if($GetInstalledVoices)
    {
        $voices
    }
    else
    {
        if($VoiceName.Length -eq 0)
        {
            $VoiceName = $voices[0]
        }
        
        if($Voices -contains $VoiceName)
        {
            $speak.SelectVoice($VoiceName)

            if($String.Length -gt 0)
            {
                $speak.Speak($String)
            }
            else
            {
                $speak.Speak("Hi, my name is $VoiceName")
            }
        }
    }
}