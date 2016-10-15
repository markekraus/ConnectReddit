$TestsRequired = @('Test-New-RedditOAuthAccessToken.ps1')
foreach ($TestRequired in $TestsRequired) {
    if ($TestRequired -notin $Global:TestsCompleted) {
        $RequiredTestScript = Get-ChildItem -Recurse -Path ..\ -Filter $TestRequired
        Write-Host "Running tests from '$($RequiredTestScript.FullName)'"
        . $RequiredTestScript.FullName
    }
}

Describe 'Get-RedditAccount'{
    Mock -CommandName Get-RedditApiResponse -ModuleName Connect-Reddit -MockWith {
        $OutObject = [pscustomobject]@{
            "name" = "connect-reddit"
            "created" = 1473998069.0
            "is_suspended" = $false
            "created_utc" =  1473969269.0
            "id" = "11fmvc"
            "gold_expiration" =  0
            "suspension_expiration_utc" = 0
        }
        Return $OutObject
    }
    $Params = @{
        AccessToken = $Global:RedditTokenWeb
        OutVariable = 'OutVariable'
    }
    $RedditAccount = Get-RedditAccount @Params
    It 'Returns a Reddit.Account Object'{        
        { Get-RedditAccount @Params } | Should not throw
    }
    It 'Has Reddit.Account Pstypename'{
        $RedditAccount.Psobject.TypeNames -contains 'Reddit.Account' | Should be $true
    }
    It 'Has Reddit.User Pstypename'{
        $RedditAccount.Psobject.TypeNames -contains 'Reddit.User' | Should be $true
    }
    It 'Has Reddit.Object Pstypename'{
        $RedditAccount.Psobject.TypeNames -contains 'Reddit.Object' | Should be $true
    }
    It 'Has valid CreatedDate'{
        $RedditAccount.CreatedDate | Should be $(ConvertFrom-RedditDate -RedditDate 1473998069.0)
    }
    It 'Has valid CreatedUtcDate'{
        $RedditAccount.CreatedUtcDate | Should be $(ConvertFrom-RedditDate -RedditDate 1473969269.0)
    }
    It 'has valid UserURL'{
        $RedditAccount.UserURL | Should be 'https://www.reddit.com/u/connect-reddit'
    }
    it 'Has valid RedditName'{
        $RedditAccount.RedditName | Should be '/u/connect-reddit'
    }
    It 'Has valid SuspensionExpirationUtcDate' {
        $RedditAccount.SuspensionExpirationUtcDate | Should be $(Get-Date '1970/1/1').addseconds(0)
    }
    It 'Has valid RedditApiTypeName' {
        $RedditAccount.RedditApiTypeName | Should be 'Account'
    }
    It 'Has valid RedditApiTypePrefix' {
        $RedditAccount.RedditApiTypePrefix | Should be 't2'
    }
    It 'Has valid Id' {
        $RedditAccount.Id | Should be '11fmvc'
    }
    It 'Has valid RedditApiFullName' {
        $RedditAccount.RedditApiFullname | Should be 't2_11fmvc'
    }
    It 'Has Valid GoldExpirationDate' {
        $RedditAccount.GoldExpirationDate | Should be $(Get-Date '1970/1/1').addseconds(0)
    }
}


$Global:TestsCompleted += Split-Path -Path $MyInvocation.MyCommand.Definition -Leaf