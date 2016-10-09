$TestName = Split-Path -Path $PSCommandPath -Leaf
$TestsRequired = @()
foreach ($TestRequired in $TestsRequired) {
    if ($TestRequired -notin $Global:TestsCompleted) {
        $RequiredTestScript = Get-ChildItem -Recurse -Path ..\ -Filter $TestRequired
        Write-Host "Running tests from '$($RequiredTestScript.FullName)'"
        . $RequiredTestScript.FullName
    }
}

Describe 'Get-RedditApiTypeName' {
    it 'Returns Account for Reddit.User' {
        $Object = [pscustomobject]@{ }
        $Object.psobject.typenames.insert(0, 'Reddit.User')
        $Object | Get-RedditApiTypeName | Should Be 'Account'
    }
    it 'Returns Account for Reddit.Account' {
        $Object = [pscustomobject]@{ }
        $Object.psobject.typenames.insert(0, 'Reddit.Account')
        $Object | Get-RedditApiTypeName | Should Be 'Account'
    }
}

$Global:TestsCompleted += $TestName