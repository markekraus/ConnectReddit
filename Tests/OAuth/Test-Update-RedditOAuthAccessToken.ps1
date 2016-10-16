$TestsRequired = @('Test-New-RedditOAuthAccessToken.ps1')
foreach ($TestRequired in $TestsRequired) {
    if ($TestRequired -notin $Global:TestsCompleted) {
        $RequiredTestScript = Get-ChildItem -Recurse -Path ..\ -Filter $TestRequired
        . $RequiredTestScript.FullName
    }
}

Write-Host "Running tests from '$($MyInvocation.MyCommand.Definition)'"
Describe 'Update-RedditOAuthAccessToken'{
    $Global:UpdateRedditToken = $Global:RedditTokenWeb.Psobject.Copy()
    $PreviousRequested = $Global:UpdateRedditToken.Requested.psobject.copy()
    Mock -CommandName Invoke-WebRequest -ModuleName ConnectReddit -MockWith {
        $OutObject = [pscustomobject] @{
            StatusCode = 200
            SatusDescription = 'OK'
            Content = @'
{
    "access_token":  "NgKrqo8WZaTmn429Iv5T-7abcd1",
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
        Return $OutObject
    }
    Mock -CommandName 'Confirm-RedditOAuthAccessTokenResponse' -ModuleName ConnectReddit -MockWith { return $True }
    It 'Should not have errors' {
        { $Global:UpdateRedditToken| Update-RedditOAuthAccessToken -Force -ErrorAction Stop } | Should Not Throw
    }
    It 'Updates The AccessToken' {
        $Global:UpdateRedditToken.AccessToken | Should be 'NgKrqo8WZaTmn429Iv5T-7abcd1'
    }
    It 'Updates Requested' {
        $Global:UpdateRedditToken.Requested | Should begreaterthan $PreviousRequested
    }
    It 'Updates Session.Headers.Authorization' {
        $Global:UpdateRedditToken.Session.Headers.Authorization | Should be 'bearer NgKrqo8WZaTmn429Iv5T-7abcd1'
    }
}

$Global:TestsCompleted += Split-Path -Path $MyInvocation.MyCommand.Definition -Leaf