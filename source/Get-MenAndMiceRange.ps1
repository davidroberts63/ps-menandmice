function Get-MenAndMiceRange {
    [CmdletBinding()]
    param (
    )

    process {
        Invoke-MenAndMiceRpcRequest -method 'GetRanges' | Select -ExpandProperty result | Write-Output
    }
}