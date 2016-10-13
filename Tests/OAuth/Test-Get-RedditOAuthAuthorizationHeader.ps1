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
    Describe 'Get-RedditOAuthAuthorizationHeader' {
        It 'Returns an Auhtorzation header for a plain text user/password' {
            $Param = @{
                UserName = 'User'
                Password = 'Password'
            }
            Get-RedditOAuthAuthorizationHeader @Param | Should Be 'Basic VXNlcjpQYXNzd29yZA=='
        }
        It 'Returns an Authorization header for an application'{
            $Param = @{
                Application = $Global:RedditAppWeb
            }
            Get-RedditOAuthAuthorizationHeader @Param | Should Be 'Basic MTIzNDU6NTQzMjE='
        }
        It 'Returns an Authorization header for an Access Token' {
            $Param = @{
                AccessToken = $Global:RedditTokenWeb
            }
            Get-RedditOAuthAuthorizationHeader @Param | Should Be 'Basic MTIzNDU6NTQzMjE='
        }
    }
}

$Global:TestsCompleted += $TestName