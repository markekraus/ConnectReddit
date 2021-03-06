﻿$TestsRequired = @()
foreach ($TestRequired in $TestsRequired) {
    if ($TestRequired -notin $Global:TestsCompleted) {
        $RequiredTestScript = Get-ChildItem -Recurse -Path ..\ -Filter $TestRequired
        . $RequiredTestScript.FullName
    }
}

Write-Host "Running tests from '$($MyInvocation.MyCommand.Definition)'"
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

$Global:TestsCompleted += Split-Path -Path $MyInvocation.MyCommand.Definition -Leaf