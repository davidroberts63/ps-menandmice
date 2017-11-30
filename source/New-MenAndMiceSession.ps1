function New-MenAndMiceSession {
    [CmdletBinding()]
    param (
        $root,
        $dnsServer,
        $credentials
    )

    $result = Invoke-MenAndMiceRpcRequest -root $root `
        -method 'Login' `
        -parameters @{ `
            loginName = $credentials.Username; `
            password = $credentials.GetNetworkCredential().Password; `
            server = $dnsServer `
        }

    $Script:MenAndMiceSession = New-Object -TypeName PsCustomObject -Property @{
        RootUrl = $root;
        Session = $result.result.session
    }

    $result | Write-Output
}
