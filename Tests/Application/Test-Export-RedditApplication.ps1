$TestsRequired = @('Test-New-RedditApplication.ps1')
foreach ($TestRequired in $TestsRequired) {
    if ($TestRequired -notin $Global:TestsCompleted) {
        $RequiredTestScript = Get-ChildItem -Recurse -Path ..\ -Filter $TestRequired
        . $RequiredTestScript.FullName
    }
}

Write-Host "Running tests from '$($MyInvocation.MyCommand.Definition)'"
Describe 'Export-RedditApplication' {
    if ($Global:TestExportsDirectory) {
        $TestExportsDirectory = $Global:TestExportsDirectory
    }
    else {
        $TestExportsDirectory = $ENV:TEMP
    }
    $Global:ExportApplicationGuid = [System.guid]::New('cf436368-449b-44ef-8335-4d0f35c9c55a')
    $Filename = '{0}.xml' -f $Global:ExportApplicationGuid.ToString()
    $FilePath = Join-Path -Path $TestExportsDirectory -ChildPath $Filename
    $RedditApplication = $GLOBAL:RedditAppWeb.psobject.copy()
    $RedditApplication.GUID = $Global:ExportApplicationGuid
    It 'Has no errors' {
        { $RedditApplication | Export-RedditApplication -Path $FilePath -ErrorAction Stop } |
            Should Not Throw
    }
    It 'Exports the application object to an xml file' {
        Test-Path $FilePath | Should be $true
    }    
}

$Global:TestsCompleted += Split-Path -Path $MyInvocation.MyCommand.Definition -Leaf