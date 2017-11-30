function Invoke-MenAndMiceRpcRequest {
    [CmdletBinding()]
    param (
        $method,
        $parameters = @{},
        $root
    )

    if(-not $root -and $Script:MenAndMiceSession) {
        Write-Debug "Using root url from session: $($Script:MenAndMiceSession.RootUrl)"
        $root = $Script:MenAndMiceSession.RootUrl
    }

    $url = "$root/_mmwebext/mmwebext.dll?Soap"

    $payload = @{
        'jsonrpc' = '2.0';
        'method' = $method;
        'params' = $parameters
    }

    if($Script:MenAndMiceSession) {
        Write-Debug "Using session id"
        $session = $Script:MenAndMiceSession.Session
    }

    if($session) {
        Write-Verbose 'Adding session to payload'
        $payload.params.session = $session
    }

    Invoke-RestMethod $url -Method POST -Body (ConvertTo-Json $payload -Depth 5) -ContentType 'application/json'
}