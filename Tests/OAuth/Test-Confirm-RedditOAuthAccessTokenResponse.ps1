$TestName = Split-Path -Path $PSCommandPath -Leaf
$TestsRequired = @()
foreach ($TestRequired in $TestsRequired) {
    if ($TestRequired -notin $Global:TestsCompleted) {
        $RequiredTestScript = Get-ChildItem -Recurse -Path ..\ -Filter $TestRequired
        Write-Host "Running tests from '$($RequiredTestScript.FullName)'"
        . $RequiredTestScript.FullName
    }
}

Describe 'Confirm-RedditOAuthAccessTokenResponse'{
    It 'Throws if there is a 401 Response code'{
        {
            $Obj = [pscustomobject]@{ ResponseCode = 401 }
            $Obj.psobject.typenames.insert(0, 'Microsoft.PowerShell.Commands.HtmlWebResponseObject')
            $Obj | Confirm-RedditOAuthAccessTokenResponse
        } | Should Throw
    }
    It 'Throws if there is a JSON Error element' {
        {
            $Obj = [pscustomobject]@{
                ResponseCode = 200
                Content = [pscustomobject]@{Error = 'unsupported_grant_type'} | ConvertTo-Json
            }
            $Obj.psobject.typenames.insert(0, 'Microsoft.PowerShell.Commands.HtmlWebResponseObject')
            $Obj | Confirm-RedditOAuthAccessTokenResponse
        } | Should Throw
    }
    It 'Throws if there is no access_token' {
        {
            $Obj = [pscustomobject]@{
                ResponseCode = 200
                Content = [pscustomobject]@{ } 
            }
            $Obj.psobject.typenames.insert(0, 'Microsoft.PowerShell.Commands.HtmlWebResponseObject')
            $Obj | Confirm-RedditOAuthAccessTokenResponse
        } | Should Throw
    }
    It 'Does not throw for a valid response' {
        {
            $Obj = [pscustomobject]@{
                ResponseCode = 200
                Content = [pscustomobject]@{ access_token = '12345'} | ConvertTo-Json
            }
            $Obj.psobject.typenames.insert(0, 'Microsoft.PowerShell.Commands.HtmlWebResponseObject')
            $Obj | Confirm-RedditOAuthAccessTokenResponse
        } | Should Not Throw
    }
}

$Global:TestsCompleted += $TestName