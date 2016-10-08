$TestName = Split-Path -Path $PSCommandPath -Leaf
$TestsRequired = @('Test-New-RedditApplication.ps1')
foreach ($TestRequired in $TestsRequired) {
    if ($TestRequired -notin $Global:TestsCompleted) {
        $RequiredTestScript = Get-ChildItem -Recurse -Path ..\ -Filter $TestRequired
        Write-Host "Running tests from '$($RequiredTestScript.FullName)'"
        . $RequiredTestScript.FullName
    }
}

$TokenJSON = @'
{
    "access_token":  "NgKrqo8WZaTmn429Iv5T-7fabcde",
    "token_type":  "bearer",
    "device_id":  "None",
    "expires_in":  3600,
    "scope":  "account creddits edit flair history identity livemanage modconfig modcontributors modflair modlog modmail modothers modposts modself modtraffic modwiki mysubreddits privatemessages read report save submit subscribe vote wikiedit wikiread"
}
'@
$TokenOBJECT = $TokenJSON | ConvertFrom-Json
$RefreshToken = 'NgKrqo8WZaTmn429Iv5T-7fabcde'
$Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
$Session.Headers.Add('Authorization', 'bearer NgKrqo8WZaTmn429Iv5T-7fabcde')
$Session.Headers.Add('User-Agent', $AppUserAgent)
$Session.UserAgent = $AppUserAgent

$TokenGUIDWeb = [System.guid]::new('ac59804a-277e-49c6-91cc-138f003ef064')
$tokenGUIDScript = [System.Guid]::new('224c7492-0011-47be-9411-7e242b12eb20')
$RequestDate = (get-date)
$ResponseHeaders = @{
    'x-ratelimit-remaining' = 598.0
    'x-ratelimit-used' = 2
    'x-ratelimit-reset' = 41
}

Describe 'New-RedditOAuthToken' {
    Context "WebbApp JSON Token"{
        it "Creates a new Reddit.OAuthAccessToken Object"{
            $Params = @{
                TokenJSON = $TokenJSON
                RefreshToken = $RefreshToken
                Application = $RedditAppWeb
                Session = $Session
                GUID = $TokenGUIDWeb
                Requested = $RequestDate
                ResponseHeaders = $ResponseHeaders
                LastRequest = $RequestDate
            }
            { New-RedditOAuthAccessToken @Params } | Should not throw
            $Global:RedditTokenWeb = New-RedditOAuthAccessToken @Params
        }
        It "Has valid AccessToken"{
            $RedditTokenWeb.AccessToken | Should be $TokenOBJECT.Access_Token
        }
        It "Has valid RefreshToken"{
            $RedditTokenWeb.RefreshToken | Should be $RefreshToken
        }
        It "Has valid TokenType"{
            $RedditTokenWeb.TokenType | Should be 'bearer'
        }
        It "Has valid Requested"{
            $RedditTokenWeb.Requested | Should be $RequestDate
        }
        It "Should not be expired"{
            $RedditTokenWeb.IsExpired | Should be $false
        }
        It "Has a valid Scope Count"{
            $RedditTokenWeb.ValidScope.Count | Should be $AppScope.Count
        }
        It "Has Valid Application" {
            $RedditTokenWeb.Application.GUID.ToString() | Should be $AppGUIDWeb.ToString()
        }
        It "Has valid TokenObject"{
            Compare-Object $RedditTokenWeb.TokenObject $TokenOBJECT | Should be $null
        }
        It "Has Valid TokenJSON"{
            $RedditTokenWeb.TokenJSON | Should be $TokenJSON
        }
        It "Has valid Session"{
            $RedditTokenWeb.Session.UserAgent | Should be $AppUserAgent
        }
        It "Has Valid ResponseHeaders"{
            $RedditTokenWeb.ResponseHeaders.'x-ratelimit-remaining' | Should be $ResponseHeaders.'x-ratelimit-remaining'
        }
        It "Has Valid RatelimitUsed" {
            $RedditTokenWeb.RatelimitUsed | Should be $ResponseHeaders.'x-ratelimit-used'
        }
        It "Has Valid RateLimitRemaining" {
            $RedditTokenWeb.RateLimitRemaining | Should be $ResponseHeaders.'x-ratelimit-remaining'
        }
        It "Has Valid LastRequest" {
            $RedditTokenWeb.LastRequest | Should be $RequestDate
        }
        It "Should not be Rate limited" {
            $RedditTokenWeb.IsRateLimited | Should be $false
        }
        It "Has valid GUID" {
            $RedditTokenWeb.GUID.ToString() | Should be $TokenGUIDWeb.ToString()
        }
        It "Has valid PSTypeName" {
            $RedditTokenWeb.psobject.typenames -contains 'Reddit.OAuthAccessToken' | Should be $true
        }
    }
    Context "Script JSON Token"{
        it "Creates a new Reddit.OAuthAccessToken Object"{
            $Params = @{
                TokenJSON = $TokenJSON
                RefreshToken = $RefreshToken
                Application = $RedditAppScript
                Session = $Session
                GUID = $TokenGUIDScript
                Requested = $RequestDate
                ResponseHeaders = $ResponseHeaders
                LastRequest = $RequestDate
            }
            { New-RedditOAuthAccessToken @Params } | Should not throw
            $Global:RedditTokenScript = New-RedditOAuthAccessToken @Params
        }
        It "Has valid AccessToken"{
            $RedditTokenScript.AccessToken | Should be $TokenOBJECT.Access_Token
        }
        It "Has valid RefreshToken"{
            $RedditTokenScript.RefreshToken | Should be $RefreshToken
        }
        It "Has valid TokenType"{
            $RedditTokenScript.TokenType | Should be 'bearer'
        }
        It "Has valid Requested"{
            $RedditTokenScript.Requested | Should be $RequestDate
        }
        It "Should not be expired"{
            $RedditTokenScript.IsExpired | Should be $false
        }
        It "Has a valid Scope Count"{
            $RedditTokenScript.ValidScope.Count | Should be $AppScope.Count
        }
        It "Has Valid Application" {
            $RedditTokenScript.Application.GUID.ToString() | Should be $AppGUIDScript.ToString()
        }
        It "Has valid TokenObject"{
            Compare-Object $RedditTokenScript.TokenObject $TokenOBJECT | Should be $null
        }
        It "Has Valid TokenJSON"{
            $RedditTokenScript.TokenJSON | Should be $TokenJSON
        }
        It "Has valid Session"{
            $RedditTokenScript.Session.UserAgent | Should be $AppUserAgent
        }
        It "Has Valid ResponseHeaders"{
            $RedditTokenScript.ResponseHeaders.'x-ratelimit-remaining' | Should be $ResponseHeaders.'x-ratelimit-remaining'
        }
        It "Has Valid RatelimitUsed" {
            $RedditTokenScript.RatelimitUsed | Should be $ResponseHeaders.'x-ratelimit-used'
        }
        It "Has Valid RateLimitRemaining" {
            $RedditTokenScript.RateLimitRemaining | Should be $ResponseHeaders.'x-ratelimit-remaining'
        }
        It "Has Valid LastRequest" {
            $RedditTokenScript.LastRequest | Should be $RequestDate
        }
        It "Should not be Rate limited" {
            $RedditTokenScript.IsRateLimited | Should be $false
        }
        It "Has valid GUID" {
            $RedditTokenScript.GUID.ToString() | Should be $TokenGUIDScript.ToString()
        }
        It "Has valid PSTypeName" {
            $RedditTokenScript.psobject.typenames -contains 'Reddit.OAuthAccessToken' | Should be $true
        }
    }
}

$Global:TestsCompleted += $TestName