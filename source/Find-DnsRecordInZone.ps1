function Find-DnsRecordInZone {
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
        Write-Debug "Trimming $hostName of $($zone.Name) to get subdomain"
        $subdomain = $hostName.Replace($zone.name.TrimEnd("."), "").TrimEnd(".")
        do {
            Write-Verbose "Getting DNS records in $($zone.name): $offset"
            $records = Invoke-MenAndMiceRpcRequest -method 'GetDNSRecords' -parameters @{ dnsZoneRef = $zone.ref; offset = $offset; limit = $pageSize; sortBy = 'name' }
            if($records.error) {
                Write-Error $records.error
            }
            $totalRecords = $records.result.totalResults
            Write-Verbose "Looking through $totalRecords dns records for $subdomain"
            $foundRecord = $records.result.dnsRecords | Where-Object { $_.name -ne '' } | Where-Object {
                Write-Debug "Checking $($_.name)"
                $subdomain.Equals($_.name, [System.StringComparison]::CurrentCultureIgnoreCase)
            }
            $foundRecord = $foundRecord | Sort-Object { $_.name.Length } -Descending | Select-Object -First 1

            $offset += $pageSize
        } while((-not $foundRecord) -and ($offset -lt $totalRecords))

        $foundRecord | Write-Output
    }
}