function Find-MenAndMiceZoneForDNSName {
    [CmdletBinding()]
    param (
        $dnsName
    )

    process {
        $offset = 0
        $pageSize = 100

        $foundZone = $null
        $totalZones = 1
        do {
            Write-Verbose "Getting DNS zones: $offset"
            $zones = Invoke-MenAndMiceRpcRequest -method 'GetDNSZones' -parameters @{ offset = $offset; limit = $pageSize; filter = 'type:Master'}
            if($zones.error) {
                Write-Error $zones.error
            }
            
            $totalZones = $zones.result.totalResults

            Write-Verbose "  Total zones: $totalZones"
            $foundZone = $zones.result.dnsZones | Where-Object { $_.name } | Where-Object {
                $zoneName = $_.name.Substring(0,$_.name.length - 1) # Take out the last period.
                $dnsName.EndsWith($zoneName)
            } | Sort-Object { $_.name.Length } -Descending | Select-Object -First 1

            $offset += $pageSize
        } while((-not $foundZone) -and ($offset -lt $totalZones))

        $foundZone | Write-Output
    }
}