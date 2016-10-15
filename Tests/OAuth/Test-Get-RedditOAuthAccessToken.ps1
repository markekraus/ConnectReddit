$TestsRequired = @('Test-New-RedditApplication.ps1')
foreach ($TestRequired in $TestsRequired) {
    if ($TestRequired -notin $Global:TestsCompleted) {
        $RequiredTestScript = Get-ChildItem -Recurse -Path ..\ -Filter $TestRequired
        Write-Host "Running tests from '$($RequiredTestScript.FullName)'"
        . $RequiredTestScript.FullName
    }
}


Describe 'Get-RedditOAuthAccessToken' {
    Mock -CommandName Invoke-WebRequest -ModuleName ConnectReddit -MockWith {
        $OutObject = [pscustomobject] @{
            StatusCode = 200
            SatusDescription = 'OK'
            Content = @'
{
    "access_token":  "NgKrqo8WZaTmn429Iv5T-poiuyt",
    "token_type":  "bearer",
    "device_id":  "None",
    "expires_in":  3600,
    "scope":  "account creddits edit flair history identity livemanage modconfig modcontributors modflair modlog modmail modothers modposts modself modtraffic modwiki
 mysubreddits privatemessages read report save submit subscribe vote wikiedit wikiread"
}
'@
            Headers = @{
                'x-ratelimit-remaining' = 598.0
                'x-ratelimit-used' = 2
                'x-ratelimit-reset' = 41
            }
        }
        $OutObject.psobject.typenames.insert(0, 'Microsoft.PowerShell.Commands.WebResponseObject')
        $OutObject.psobject.typenames.insert(0, 'Microsoft.PowerShell.Commands.HtmlWebResponseObject')
        $SessionObj = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
        $SessionObj.Headers.Add('Authorization', 'lalala')
        New-Variable -Scope Script -Name 'Session' -Value $SessionObj
        Return $OutObject
    }
    Mock -CommandName Confirm-RedditOAuthAccessTokenResponse -ModuleName ConnectReddit
    Mock -CommandName Get-RedditOAuthAccessTokenURL -ModuleName ConnectReddit {Return 'http://127.0.0.1/'}
    Mock -CommandName Get-RedditOAuthAuthorizationHeader -ModuleName ConnectReddit
    It 'Does not have errors' {
        {
            $Params = @{
                Application = $Global:RedditAppWeb
                Code = '12345'
                ErrorAction = 'Stop'
            }
            $Global:RedditTokenGet =Get-RedditOAuthAccessToken @Params
        } | Should Not Throw
    }
    $RedditToken = $Global:RedditTokenGet
    It 'Returns a valid Redd.OAuthAccessToken object' {
        $RedditToken.AccessToken | Should Be 'NgKrqo8WZaTmn429Iv5T-poiuyt'
        $RedditToken.Expires | Should BeGreaterThan (Get-date)
        $RedditToken.IsExpired | Should Be $false
        $RedditToken.Application.GUID.ToString() | Should Be  $Global:RedditAppWeb.GUID.ToString()
    }
}

$Global:TestsCompleted += Split-Path -Path $MyInvocation.MyCommand.Definition -Leaf