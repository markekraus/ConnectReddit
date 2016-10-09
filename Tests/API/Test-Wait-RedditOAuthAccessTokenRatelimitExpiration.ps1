$TestName = Split-Path -Path $PSCommandPath -Leaf
$TestsRequired = @('Test-New-RedditOAuthAccessToken.ps1')
foreach ($TestRequired in $TestsRequired) {
    if ($TestRequired -notin $Global:TestsCompleted) {
        $RequiredTestScript = Get-ChildItem -Recurse -Path ..\ -Filter $TestRequired
        Write-Host "Running tests from '$($RequiredTestScript.FullName)'"
        . $RequiredTestScript.FullName
    }
}

Describe 'Wait-RedditOAuthAccessTokenRatelimitExpiration' {
    # Simulate reaching Ratelimit
    $RedditToken = $Global:RedditTokenWeb.Psobject.Copy()
    $RedditToken.ResponseHeaders.'x-ratelimit-remaining' = 0
    $RedditToken.ResponseHeaders.'x-ratelimit-reset' = 5
    $RedditToken.LastRequest = Get-date
    $Result = Measure-Command {
        $RedditToken | Wait-RedditOAuthAccessTokenRatelimitExpiration -WarningAction SilentlyContinue
    }
    It 'Sleeps properly when ratelmit exceeded' {
        $Result.Seconds | Should BeGreaterThan 3
        $Result.Seconds | Should BeLessThan 7
    }
    # Simulate reaching Ratelimit
    $RedditToken = $Global:RedditTokenWeb.Psobject.Copy()
    $RedditToken.ResponseHeaders.'x-ratelimit-remaining' = 0
    $RedditToken.ResponseHeaders.'x-ratelimit-reset' = 5
    $RedditToken.LastRequest = Get-date
    $Result = Measure-Command {
        $RedditToken | Wait-RedditOAuthAccessTokenRatelimitExpiration -MaxSleepSeconds 2 -WarningAction SilentlyContinue
    }
    It 'Sleeps less when told to' {
        $Result.Seconds | Should BeLessThan 5
    }
}


$Global:TestsCompleted += $TestName