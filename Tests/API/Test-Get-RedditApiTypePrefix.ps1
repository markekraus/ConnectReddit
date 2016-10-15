$TestsRequired = @()
foreach ($TestRequired in $TestsRequired) {
    if ($TestRequired -notin $Global:TestsCompleted) {
        $RequiredTestScript = Get-ChildItem -Recurse -Path ..\ -Filter $TestRequired
        Write-Host "Running tests from '$($RequiredTestScript.FullName)'"
        . $RequiredTestScript.FullName
    }
}

Describe 'Get-RedditApiTypePrefix' {
    it 'Returns t2 for Reddit.User' {
        $Object = [pscustomobject]@{ }
        $Object.psobject.typenames.insert(0, 'Reddit.User')
        $Object | Get-RedditApiTypePrefix | Should Be 't2'
    }
    it 'Returns t2 for Reddit.Account' {
        $Object = [pscustomobject]@{ }
        $Object.psobject.typenames.insert(0, 'Reddit.Account')
        $Object | Get-RedditApiTypePrefix | Should Be 't2'
    }
}

$Global:TestsCompleted += Split-Path -Path $MyInvocation.MyCommand.Definition -Leaf