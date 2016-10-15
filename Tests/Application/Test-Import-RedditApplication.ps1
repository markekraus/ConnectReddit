$TestsRequired = @('Test-Export-RedditApplication.ps1')
foreach ($TestRequired in $TestsRequired) {
    if ($TestRequired -notin $Global:TestsCompleted) {
        $RequiredTestScript = Get-ChildItem -Recurse -Path ..\ -Filter $TestRequired
        Write-Host "Running tests from '$($RequiredTestScript.FullName)'"
        . $RequiredTestScript.FullName
    }
}


Describe 'Import-RedditApplication' {
    if ($Global:TestExportsDirectory) {
        $TestExportsDirectory = $Global:TestExportsDirectory
    }
    else {
        $TestExportsDirectory = $ENV:TEMP
    }
    #$Global:ExportApplicationGuid = [System.guid]::New('cf436368-449b-44ef-8335-4d0f35c9c55a')
    $Filename = '{0}.xml' -f $Global:ExportApplicationGuid.ToString()
    $FilePath = Join-Path -Path $TestExportsDirectory -ChildPath $Filename
    It 'Has no errors' {
        { $Global:RedditAppImport = Import-RedditApplication -Path $FilePath -ErrorAction Stop } |
            Should Not Throw
    }
    It 'Imports an application object with valid members' {
        $Global:RedditAppImport.GUID.ToString() | Should Be $Global:ExportApplicationGuid.ToString()
        $Global:RedditAppImport.Name | Should Be $GLOBAL:RedditAppWeb.Name
        $Global:RedditAppImport.Description | Should Be $GLOBAL:RedditAppWeb.Description
        $Global:RedditAppImport.UserAgent | Should Be $GLOBAL:RedditAppWeb.UserAgent
        $Global:RedditAppImport.ClientID | Should Be $GLOBAL:RedditAppWeb.ClientID
        $Global:RedditAppImport.ClientCredential.GetNetworkCredential().password |
            Should Be $GLOBAL:RedditAppWeb.ClientCredential.GetNetworkCredential().password
        $Global:RedditAppImport.Scope.Count | Should Be $GLOBAL:RedditAppWeb.Scope.Count
        $Global:RedditAppImport.RedirectUri | Should Be $GLOBAL:RedditAppWeb.RedirectUri
    }
}

$Global:TestsCompleted += Split-Path -Path $MyInvocation.MyCommand.Definition -Leaf