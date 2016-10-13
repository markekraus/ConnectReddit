$TestName = Split-Path -Path $PSCommandPath -Leaf
$TestsRequired = @('Test-New-RedditOAuthAccessToken.ps1')
foreach ($TestRequired in $TestsRequired) {
    if ($TestRequired -notin $Global:TestsCompleted) {
        $RequiredTestScript = Get-ChildItem -Recurse -Path ..\ -Filter $TestRequired
        Write-Host "Running tests from '$($RequiredTestScript.FullName)'"
        . $RequiredTestScript.FullName
    }
}

InModuleScope 'Connect-Reddit' {
    Describe 'Get-RedditOAuthAccessTokenURL' {
        It 'Returns a Code URL' {
            $Url = Get-RedditOAuthAccessTokenURL -Application $Global:RedditAppWeb -Code '12345abcde'
            $Url | Should Match 'code=12345abcde'
            $Url | Should Match 'grant_type=authorization_code'
        }
        It 'Returns a Refresh URL' {
            $Url = Get-RedditOAuthAccessTokenURL -AccessToken $Global:RedditTokenWeb
            $Url | Should Match 'grant_type=refresh_token'
            $Url | Should Match 'refresh_token='
        }
        It 'Returns a Script URL' {
            $Url = Get-RedditOAuthAccessTokenURL -AccessToken $Global:RedditTokenScript
            $Url | Should Match 'grant_type=password'
            $Url | Should Match 'username=connect-reddit'
        }
    }
}

$Global:TestsCompleted += $TestName