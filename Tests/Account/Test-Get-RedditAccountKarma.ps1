$TestsRequired = @('Test-Get-RedditOAuthAccessToken.ps1')
foreach ($TestRequired in $TestsRequired) {
    if ($TestRequired -notin $Global:TestsCompleted) {
        $RequiredTestScript = Get-ChildItem -Recurse -Path ..\ -Filter $TestRequired
        . $RequiredTestScript.FullName
    }
}

Write-Host "Running tests from '$($MyInvocation.MyCommand.Definition)'"
$Global:CurApiFunction = 'Get-RedditAccountKarma'
$Global:CurAPIEndpoint = '/api/v1/me/karma'
$Global:JSONResponse = @'
{"kind": "KarmaList", "data": [{"sr": "DeepIntoYouTube", "comment_karma": 2932, "link_karma": 2}, {"sr": "talesfromtechsupport", "comment_karma": 841, "link_karma": 1}, {"sr": "anime", "comment_karma": 757, "link_karma": 1}]}
'@
$Global:PsTypeNames = @(
    'Reddit.KarmaList'
)
$Global:RequiredAttributes = @(
    'sr'
    'comment_karma'
    'link_karma'
    'subreddit'
)
$Global:AttributeValues = @(
    @{
        Order = 0
        Attribute = 'sr'
        Value = 'DeepIntoYouTube'
    }
    @{
        Order = 1
        Attribute = 'comment_karma'
        Value = 841
    }
    @{
        Order = 2
        Attribute = 'link_karma'
        Value = 1
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
                $ApiResponseObj[$AttributeValue.Order].$($AttributeValue.Attribute) | Should Be $AttributeValue.Value
            }
        }
    }
}

$Global:TestsCompleted += Split-Path -Path $MyInvocation.MyCommand.Definition -Leaf