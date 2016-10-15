$TestsRequired = @('Test-New-RedditOAuthAccessToken.ps1')
foreach ($TestRequired in $TestsRequired) {
    if ($TestRequired -notin $Global:TestsCompleted) {
        $RequiredTestScript = Get-ChildItem -Recurse -Path ..\ -Filter $TestRequired
        Write-Host "Running tests from '$($RequiredTestScript.FullName)'"
        . $RequiredTestScript.FullName
    }
}

Describe 'Get-RedditApiResponse' {
    Mock -CommandName Update-RedditOAuthAccessToken -ModuleName ConnectReddit -MockWith { }
    Mock -CommandName Wait-RedditOAuthAccessTokenRatelimitExpiration -ModuleName ConnectReddit -MockWith { }
    Mock -CommandName Invoke-WebRequest -ModuleName ConnectReddit -MockWith {
        return [pscustomobject] @{
            StatusCode = 200
            SatusDescription = 'OK'
            Content = '{"kind": "t2", "data": {"name": "markekraus", "is_friend": false, "created": 1243564237.0, "hide_from_robots": false, "created_utc": 1243535437.0, "link_karma": 111, "comment_karma": 10169, "is_gold": true, "is_mod": true, "has_verified_email": true, "id": "3httw"}}'
            Headers = @{
                'x-ratelimit-remaining' = 547.0
                'x-ratelimit-used' = 53
                'x-ratelimit-reset' = 60
            }
        }
    }
    $RedditToken = $Global:RedditTokenWeb.Psobject.Copy()
    $PreviousLastRequest = $RedditToken.LastRequest.psobject.copy()
    $Params = @{
        Get = $true
        AccessToken = $RedditToken
        ApiEndPoint = '/user/markekraus/about'
    }
    It 'Sould not have errors' {
        { $Global:APIResponse = Get-RedditApiResponse @Params } | Should Not Throw
    }
    $APIResponse = $Global:APIResponse
    It 'Returns a valid response object' {
        $APIResponse.Kind | Should be 't2'
        $APIResponse.Data.Name | Should be 'markekraus'
    }
    It 'Updates the Ratelimit data' {
        $RedditToken.RatelimitUsed | Should be 53
        $RedditToken.RatelimitRemaining | Should be 547.0
    }
    It 'Updates LastRequest' {
        $RedditToken.LastRequest | Should BeGreaterThan $PreviousLastRequest
    }
}

$Global:TestsCompleted += Split-Path -Path $MyInvocation.MyCommand.Definition -Leaf