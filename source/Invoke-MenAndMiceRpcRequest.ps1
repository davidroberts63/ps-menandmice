function Invoke-MenAndMiceRpcRequest {
    [CmdletBinding()]
    param (
        $root,
        $method,
        $parameters = @{},
        $session
    )

    $url = "$root/_mmwebext/mmwebext.dll?Soap"

    $payload = @{
        'jsonrpc' = '2.0';
        'method' = $method;
        'params' = $parameters
    }

    if($session) {
        Write-Verbose 'Adding session to payload'
        $payload.params.session = $session
    }

    Invoke-RestMethod $url -Method POST -Body (ConvertTo-Json $payload -Depth 5) -ContentType 'application/json'
}