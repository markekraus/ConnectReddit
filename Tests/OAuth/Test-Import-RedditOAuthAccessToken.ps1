$TestName = Split-Path -Path $PSCommandPath -Leaf
$TestsRequired = @('Test-Export-RedditOAuthAccessToken.ps1')
foreach ($TestRequired in $TestsRequired) {
    if ($TestRequired -notin $Global:TestsCompleted) {
        $RequiredTestScript = Get-ChildItem -Recurse -Path ..\ -Filter $TestRequired
        Write-Host "Running tests from '$($RequiredTestScript.FullName)'"
        . $RequiredTestScript.FullName
    }
}

InModuleScope 'Connect-Reddit' {
    Describe 'Import-RedditOAuthAccessToken' {
        if ($Global:TestExportsDirectory) {
            $TestExportsDirectory = $Global:TestExportsDirectory
        }
        else {
            $TestExportsDirectory = $ENV:TEMP
        }
        #$Global:ExportTokenGuid = [System.guid]::New('4b9dcb62-59d4-4294-ba68-03f09e860068')
        $Filename = '{0}.xml' -f $Global:ExportTokenGuid.ToString()
        $FilePath = Join-Path -Path $TestExportsDirectory -ChildPath $Filename
        It 'Has no errors' {
            { $Global:RedditTokenImport = Import-RedditOAuthAccessToken -Path $FilePath -ErrorAction Stop } |
            Should Not Throw
        }
        It 'Imports a valid Token object' {
            $Global:RedditTokenImport.GUID.tostring() | Should be '4b9dcb62-59d4-4294-ba68-03f09e860068'
            $Global:RedditTokenImport.AccessToken | Should be $GLOBAL:RedditTokenWeb.AccessToken
            $Global:RedditTokenImport.RefreshToken | Should be $GLOBAL:RedditTokenWeb.RefreshToken
            $Global:RedditTokenImport.TokenType | Should be $GLOBAL:RedditTokenWeb.TokenType
            $Global:RedditTokenImport.Requested | Should be $GLOBAL:RedditTokenWeb.Requested
            $Global:RedditTokenImport.Expires | Should be $GLOBAL:RedditTokenWeb.Expires
            $Global:RedditTokenImport.IsExpired | Should be $GLOBAL:RedditTokenWeb.IsExpired
            $Global:RedditTokenImport.ValidScope.count | Should be $GLOBAL:RedditTokenWeb.ValidScope.count
            $Global:RedditTokenImport.TokenJSON | Should be $GLOBAL:RedditTokenWeb.TokenJSON
            $Global:RedditTokenImport.RatelimitUsed | Should be $GLOBAL:RedditTokenWeb.RatelimitUsed
            $Global:RedditTokenImport.RatelimitRemaining | Should be $GLOBAL:RedditTokenWeb.RatelimitRemaining
            $Global:RedditTokenImport.LastRequest | Should be $GLOBAL:RedditTokenWeb.LastRequest
            $Global:RedditTokenImport.RatelimitReset | Should be $GLOBAL:RedditTokenWeb.RatelimitReset
            $Global:RedditTokenImport.IsRatelimited | Should be $GLOBAL:RedditTokenWeb.IsRatelimited
            $Global:RedditTokenImport.Application.Guid.ToString() | Should be $GLOBAL:RedditTokenWeb.Application.Guid.ToString()
        }
    }
}

$Global:TestsCompleted += $TestName