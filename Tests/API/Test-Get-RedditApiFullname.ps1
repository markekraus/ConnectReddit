$TestsRequired = @()
foreach ($TestRequired in $TestsRequired) {
    if ($TestRequired -notin $Global:TestsCompleted) {
        $RequiredTestScript = Get-ChildItem -Recurse -Path ..\ -Filter $TestRequired
        . $RequiredTestScript.FullName
    }
}

Write-Host "Running tests from '$($MyInvocation.MyCommand.Definition)'"
Describe 'Get-RedditApiFullname' {
    $ID = "11fmvc"
    It 'Returns an account fullname' {
        Get-RedditApiFullname -Type Account -RedditId $ID | Should be "t2_$id"
    }
    It 'Returns a comment fullname' {
        Get-RedditApiFullname -Type Comment -RedditId $ID | Should be "t1_$id"
    }
    It 'Returns a link fullname' {
        Get-RedditApiFullname -Type Link -RedditId $ID | Should be "t3_$id"
    }
    It 'Returns a Message fullname' {
        Get-RedditApiFullname -Type Message -RedditId $ID | Should be "t4_$id"
    }
    It 'Returns a Subreddit fullname' {
        Get-RedditApiFullname -Type Subreddit -RedditId $ID | Should be "t5_$id"
    }
    It 'Returns a Award fullname' {
        Get-RedditApiFullname -Type Award -RedditId $ID | Should be "t6_$id"
    }
    It 'Returns a PromoCampaign  fullname' {
        Get-RedditApiFullname -Type PromoCampaign -RedditId $ID | Should be "t8_$id"
    }
}

$Global:TestsCompleted += Split-Path -Path $MyInvocation.MyCommand.Definition -Leaf