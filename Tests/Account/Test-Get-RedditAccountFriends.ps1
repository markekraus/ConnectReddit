$TestsRequired = @('Test-Get-RedditOAuthAccessToken.ps1')
foreach ($TestRequired in $TestsRequired) {
    if ($TestRequired -notin $Global:TestsCompleted) {
        $RequiredTestScript = Get-ChildItem -Recurse -Path ..\ -Filter $TestRequired
        . $RequiredTestScript.FullName
    }
}

Write-Host "Running tests from '$($MyInvocation.MyCommand.Definition)'"
# The function being tested goes here
$Global:CurApiFunction = 'Get-RedditAccountFriends'
# The ApiEnd point the functoion wraps goes here
$Global:CurAPIEndpoint = '/api/v1/me/friends'
# An example of the JSON response this endpoint returns
$Global:JSONResponse = @'
{"kind": "UserList", "data": {"children": [{"date": 1269466583.0, "note": "", "name": "markekraus", "id": "t2_3httw"}, {"date": 1271407196.0, "note": "", "name": "Connect-Reddit", "id": "t2_3w9we"}]}}
'@
# The Pstypenames that the fucntion assignes tot he retrun objects
$Global:PsTypeNames = @(
    'Reddit.Friend'
)
# Attributes that should be present on the return object
$Global:RequiredAttributes = @(
    'date'
    'note'
    'name'
    'id'
    'dateadded'
    'RedditApiTypeName'
    'RedditApiTypePrefix'
    'RedditApiFullName'
    'UserURL'
)
# Attributes and their values to test for
$Global:AttributeValues = @(
    @{
        Index = 0
        Attribute = 'name'
        Value = 'markekraus'
    }
    @{
        Index = 0
        Attribute = 'RedditApiFullName'
        Value = "t2_3httw"
    }
    @{
        Index = 0
        Attribute = 'UserURL'
        Value = 'https://www.reddit.com/u/markekraus'
    }
    @{
        Index = 1
        Attribute = 'date'
        Value = '1271407196.0'
    }
    @{
        Index = 1
        Attribute = 'dateadded'
        Value = 1271407196.0 | ConvertFrom-RedditDate
    }
)


InModuleScope 'ConnectReddit' {
    Describe "$Global:CurApiFunction" {
        $PsTypeNames = $Global:PsTypeNames
        $RequiredAttributes = $Global:RequiredAttributes
        $AttributeValues = $Global:AttributeValues
        Mock Get-RedditApiResponse -MockWith {
            $OutObj = $Global:JSONResponse | ConvertFrom-Json
            return $OutObj
        }
        It 'Has No Errors' {
            {
                $Params = @{
                    AccessToken = $Global:RedditTokenWeb
                    ErrorAction = 'Stop'
                }
                $Global:ApiResultObj = Invoke-Expression "$Global:CurApiFunction  @Params"
            } | Should Not Throw
        }
        $ApiResponseObj = $Global:ApiResultObj
        It "Requests data from the $Global:CurAPIEndpoint API Endpoint" {
            Assert-MockCalled -CommandName Get-RedditApiResponse -ParameterFilter { $ApiEndPoint -eq $Global:CurAPIEndpoint }
        }
        it 'Returns a valid object' {
            foreach ($PsTypeName in $PsTypeNames) {
                $ApiResponseObj[0].psobject.typenames | Where-Object { $_ -like $PsTypeName } | Should Be $PsTypeName
            }
            foreach ($RequiredAttribute in $RequiredAttributes) {
                ($ApiResponseObj[0] | Get-Member -Name $RequiredAttribute).Name | Should Be $RequiredAttribute
            }
            foreach ($AttributeValue in $AttributeValues) {
                $ApiResponseObj[$AttributeValue.Index].$($AttributeValue.Attribute) | Should Be $AttributeValue.Value
            }
        }
    }
}

$Global:TestsCompleted += Split-Path -Path $MyInvocation.MyCommand.Definition -Leaf