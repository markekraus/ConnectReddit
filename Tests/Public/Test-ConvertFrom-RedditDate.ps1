$TestName = Split-Path -Path $PSCommandPath -Leaf
$TestsRequired = @()
foreach ($TestRequired in $TestsRequired) {
    if ($TestRequired -notin $Global:TestsCompleted) {
        $RequiredTestScript = Get-ChildItem -Recurse -Path ..\ -Filter $TestRequired
        Write-Host "Running tests from '$($RequiredTestScript.FullName)'"
        . $RequiredTestScript.FullName
    }
}

InModuleScope 'Connect-Reddit' {
    Describe 'ConvertFrom-RedditDate' {
        It 'Converts a UNIX Epoch to DateTime' {
            1476531339.0 | ConvertFrom-RedditDate | Should Be (Get-Date '10/15/2016 11:35:39')
            393608340.0 | ConvertFrom-RedditDate | Should Be (Get-Date '06/22/1982 15:39:00')
        }
    }
}

$Global:TestsCompleted += $TestName