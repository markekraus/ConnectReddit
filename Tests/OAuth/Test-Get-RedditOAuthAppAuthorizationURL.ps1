$TestsRequired = @('Test-New-RedditApplication.ps1')
foreach ($TestRequired in $TestsRequired) {
    if ($TestRequired -notin $Global:TestsCompleted) {
        $RequiredTestScript = Get-ChildItem -Recurse -Path ..\ -Filter $TestRequired
        Write-Host "Running tests from '$($RequiredTestScript.FullName)'"
        . $RequiredTestScript.FullName
    }
}

InModuleScope 'ConnectReddit' {
    Describe 'Get-RedditOAuthAppAuthorizationURL' {
        It 'Returns a Code authorization URL' {
            $Params = @{
                Application = $Global:RedditAppWeb
                State = [System.Guid]::new('86263983-387d-4d6a-abdb-4965677ad281')
                
            }
            $Url = Get-RedditOAuthAppAuthorizationURL @Params
            $Url | Should Match 'client_id=12345'
            $Url | Should Match 'response_type=code'
            $Url | Should Match 'state=86263983-387d-4d6a-abdb-4965677ad281'
            $Url | Should Match 'scope=account%2c'
            $Url | Should Match 'redirect_uri=http%3a%2f%2f127.0.0.1%3a65010%2fauthorize_callback'
            $Url | Should Match 'duration=permanent'
        }
    }
}

$Global:TestsCompleted += Split-Path -Path $MyInvocation.MyCommand.Definition -Leaf