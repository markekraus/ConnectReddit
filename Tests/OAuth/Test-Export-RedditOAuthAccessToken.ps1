$TestsRequired = @('Test-New-RedditOAuthAccessToken.ps1')
foreach ($TestRequired in $TestsRequired) {
    if ($TestRequired -notin $Global:TestsCompleted) {
        $RequiredTestScript = Get-ChildItem -Recurse -Path ..\ -Filter $TestRequired
        . $RequiredTestScript.FullName
    }
}

Write-Host "Running tests from '$($MyInvocation.MyCommand.Definition)'"
Describe 'Export-RedditOAuthAccessToken'{
    if ($Global:TestExportsDirectory) {
        $TestExportsDirectory = $Global:TestExportsDirectory
    }
    else {
        $TestExportsDirectory = $ENV:TEMP
    }
    $Global:ExportTokenGuid = [System.guid]::New('4b9dcb62-59d4-4294-ba68-03f09e860068')
    $Filename = '{0}.xml' -f $Global:ExportTokenGuid.ToString()
    $FilePath = Join-Path -Path $TestExportsDirectory -ChildPath $Filename
    $RedditToken = $GLOBAL:RedditTokenWeb.psobject.copy()
    $RedditToken.GUID = $Global:ExportTokenGuid
    It 'Has no errors' {
        { $RedditToken | Export-RedditOAuthAccessToken -Path $FilePath -ErrorAction Stop } |
        Should Not Throw
    }
    It 'Exports the application object to an xml file' {
        Test-Path $FilePath | Should be $true
    }
}

$Global:TestsCompleted += Split-Path -Path $MyInvocation.MyCommand.Definition -Leaf