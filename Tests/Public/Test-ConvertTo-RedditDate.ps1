$TestsRequired = @()
foreach ($TestRequired in $TestsRequired) {
    if ($TestRequired -notin $Global:TestsCompleted) {
        $RequiredTestScript = Get-ChildItem -Recurse -Path ..\ -Filter $TestRequired
        Write-Host "Running tests from '$($RequiredTestScript.FullName)'"
        . $RequiredTestScript.FullName
    }
}

InModuleScope 'Connect-Reddit' {
    Describe 'ConvertTo-RedditDate' {
        It 'Converts a DateTime to UNIX Epoch' {
            Get-Date '09/11/2001 15:45:00' | ConvertTo-RedditDate | Should Be 1000223100
            Get-Date '06/29/2007 18:00:00' | ConvertTo-RedditDate | Should Be 1183140000
        }
    }
}

$Global:TestsCompleted += Split-Path -Path $MyInvocation.MyCommand.Definition -Leaf