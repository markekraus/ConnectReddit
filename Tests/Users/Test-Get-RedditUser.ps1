$TestsRequired = @('Test-New-RedditOAuthAccessToken.ps1')
foreach ($TestRequired in $TestsRequired) {
    if ($TestRequired -notin $Global:TestsCompleted) {
        $RequiredTestScript = Get-ChildItem -Recurse -Path ..\ -Filter $TestRequired
        Write-Host "Running tests from '$($RequiredTestScript.FullName)'"
        . $RequiredTestScript.FullName
    }
}


InModuleScope 'ConnectReddit' {
    Describe 'Get-RedditUser' {
        $TargetUser = 'markekraus'
        Mock Get-RedditApiResponse -MockWith {
            $JSONResponse = @"
{"kind": "t2", "data": {"name": "$TargetUser", "is_friend": false, "created": 1243564237.0, "hide_from_robots": false, "created_utc": 1243535437.0, "link_karma": 111, "comment_karma": 10418, "is_gold": true, "is_mod": true, "has_verified_email": true, "id": "3httw"}}
"@
            return $($JSONResponse | ConvertFrom-Json)
        }
        It 'Has No errors' {
            {
                $Params = @{
                    Username = $TargetUser
                    AccessToken = $Global:RedditTokenWeb
                    ErrorAction = 'Stop'
                }
                $Global:RedditUserAbout = Get-RedditUser @Params
            } | Should Not Throw
        }
        It "Requests data from the /user/$TargetUser/about API Endpoint" {
            Assert-MockCalled -CommandName Get-RedditApiResponse -ParameterFilter { $ApiEndPoint -eq "/user/$TargetUser/about" }
        }
        It 'Returns a valid user object' {
            $Global:RedditUserAbout.psobject.typenames -contains 'Reddit.User' | Should Be $True
            $Global:RedditUserAbout.psobject.typenames -contains 'Reddit.Object' | Should Be $True
            $Global:RedditUserAbout.CreatedDate | Should Be (Get-Date '01/01/1970').AddSeconds(1243564237.0)
            $Global:RedditUserAbout.CreatedUtcDate | Should Be (Get-Date '01/01/1970').AddSeconds(1243535437.0)
            $Global:RedditUserAbout.UserURL | Should Be "https://www.reddit.com/u/$TargetUser"
            $Global:RedditUserAbout.RedditName | Should Be "/u/$TargetUser"
            $Global:RedditUserAbout.RedditApiTypeName | Should Be 'Account'
            $Global:RedditUserAbout.RedditApiTypePrefix | Should Be 't2'
            $Global:RedditUserAbout.RedditApiFullName | Should Be 't2_3httw'
            $Global:RedditUserAbout.name | Should Be $TargetUser
        }
    }
}

$Global:TestsCompleted += Split-Path -Path $MyInvocation.MyCommand.Definition -Leaf