$Script:MenAndMiceSession = $null

Get-ChildItem -Path $PSScriptRoot\*.ps1 | %{
    . $_.Fullname
}
