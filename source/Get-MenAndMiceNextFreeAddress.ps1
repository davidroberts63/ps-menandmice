function Get-MenAndMiceNextFreeAddress {
    [CmdletBinding()]
    param (
        $range
    )

    process {
        $parameters = @{
            rangeRef = $range.ref
        }
        
        Invoke-MenAndMiceRpcRequest -method 'GetNextFreeAddress' -parameters $parameters | Select -ExpandProperty result | Write-Output
    }
}