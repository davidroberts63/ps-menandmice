function Find-DnsRecord {
    [CmdletBinding()]
    param (
        $root,
        $session,
        $hostName,
        [switch]
        $allowDeepSearch
    )

    process {
        Get-DnsRecord -root $root -session $session -hostName $hostname -allowDeepSearch:$allowDeepSearch
    }
}

function Get-DnsRecord {
    [CmdletBinding()]
    param (
        $root,
        $session,
        $hostName,
        [switch]
        $allowDeepSearch
    )

    process {
        $offset = 0
        $pageSize = 100

        $foundZone = $null
        $totalZones = 1
        $allZones = @()
        do {
            Write-Verbose "Getting DNS zones: $offset"
            $zones = Invoke-MenAndMiceRpcRequest $root 'GetDNSZones' @{ offset = $offset; limit = $pageSize; filter = 'type:Master'} $session
            if($zones.error) {
                Write-Error $zones.error
            }
            
            $totalZones = $zones.result.totalResults
            if($allowDeepSearch) {
                $allZones += $zones.result.dnsZones
            }

            Write-Verbose "  Total zones: $totalZones"
            $foundZone = $zones.result.dnsZones | Where-Object { $_.name } | Where-Object {
                $zoneName = $_.name.Substring(0,$_.name.length - 1) # Take out the last period.
                $hostName.EndsWith($zoneName)
            } | Sort-Object { $_.name.Length } -Descending | Select-Object -First 1

            $offset += $pageSize
        } while((-not $foundZone) -and ($offset -lt $totalZones))

        if(-not $foundZone -and (-not $allowDeepSearch)) {
            Write-Error "Unable to find a DNS zone for $hostname"
            return
        }

        $zonesToSearch = $foundZone
        if($allowDeepSearch) {
            Write-Host "Doing a deep search"
            $zonesToSearch = $allZones
        }

        $foundRecord = $null
        $zonesToSearch | %{
            Write-Host "Looking for $hostname in $($_.name)"
            $foundRecord = $_ | Get-DnsRecordInZone -root $root -session $session -hostName $hostname
        }
        
        if(-not $foundRecord) {
            Write-Error "Unable to find a DNS record for $hostname"
        }

        Write-Verbose 'Getting IP address range of record'
        $range = Invoke-MenAndMiceRpcRequest $root 'GetRangeByIPAddress' @{ addrRef = $foundRecord.data } $session
        if($range) {
            $foundRecord | Add-Member -NotePropertyName range -NotePropertyValue $range.result.range
        }
        $foundRecord | Add-Member -NotePropertyName dnsZone -NotePropertyValue $foundZone
        $foundRecord | Write-Output
    }
}