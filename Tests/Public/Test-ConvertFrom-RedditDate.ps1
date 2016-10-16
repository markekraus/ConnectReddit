$TestsRequired = @()
foreach ($TestRequired in $TestsRequired) {
    if ($TestRequired -notin $Global:TestsCompleted) {
        $RequiredTestScript = Get-ChildItem -Recurse -Path ..\ -Filter $TestRequired
        . $RequiredTestScript.FullName
    }
}

Write-Host "Running tests from '$($MyInvocation.MyCommand.Definition)'"
InModuleScope 'ConnectReddit' {
    Describe 'ConvertFrom-RedditDate' {
        It 'Converts a UNIX Epoch to DateTime' {
            1476531339.0 | ConvertFrom-RedditDate | Should Be (Get-Date '10/15/2016 11:35:39')
            393608340.0 | ConvertFrom-RedditDate | Should Be (Get-Date '06/22/1982 15:39:00')
        }
    }
}

$Global:TestsCompleted += Split-Path -Path $MyInvocation.MyCommand.Definition -Leaf