function Get-DnsRecordInZone {
    [CmdletBinding()]
    param (
        $hostName,
        [Parameter(ValueFromPipeline)]
        $zone
    )

    process {
        $offset = 0
        $foundRecord = $null
        $totalRecords = 1
        do {
            Write-Verbose "Getting DNS records in $($zone.name): $offset"
            $records = Invoke-MenAndMiceRpcRequest -method 'GetDNSRecords' -parameters @{ dnsZoneRef = $zone.ref; offset = $offset; limit = $pageSize; sortBy = 'name' }
            if($records.error) {
                Write-Error $records.error
            }
            $totalRecords = $records.result.totalResults
            Write-Verbose "Looking through $totalRecords dns records"
            $foundRecord = $records.result.dnsRecords | Where-Object { $_.name -ne '' } | Where-Object {
                $hostName.StartsWith($_.name, [System.StringComparison]::CurrentCultureIgnoreCase)
            }
            $foundRecord = $foundRecord | Sort-Object { $_.name.Length } -Descending | Select-Object -First 1

            $offset += $pageSize
        } while((-not $foundRecord) -and ($offset -lt $totalRecords))

        $foundRecord | Write-Output
    }
}