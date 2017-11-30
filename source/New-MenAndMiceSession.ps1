function New-MenAndMiceSession {
    [CmdletBinding()]
    param (
        $root,
        $dnsServer,
        $credentials
    )

    $result = Invoke-MenAndMiceRpcRequest $root 'Login' @{ loginName = $credentials.Username; password = $credentials.GetNetworkCredential().Password; server = $dnsServer }

    $Script:MenAndMiceSession = New-Object -TypeName PsCustomObject -Property @{
        RootUrl = $rootUrl;
        Session = $result.result.session
    }
}
