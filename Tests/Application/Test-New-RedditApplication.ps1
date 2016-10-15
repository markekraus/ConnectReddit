$TestsRequired = @()
foreach ($TestRequired in $TestsRequired) {
    if ($TestRequired -notin $Global:TestsCompleted) {
        $RequiredTestScript = Get-ChildItem -Recurse -Path ..\ -Filter $TestRequired
        Write-Host "Running tests from '$($RequiredTestScript.FullName)'"
        . $RequiredTestScript.FullName
    }
}


$ClientID = '12345'
$ClientSecret = '54321'
$SecureClientSecret = $ClientSecret | ConvertTo-SecureString -AsPlainText -Force
$ClientCredential = New-Object -TypeName System.Management.Automation.PSCredential ($ClientID, $SecureClientSecret)
$UserName = 'connect-reddit'
$Password = '54321'
$SecurePassword = $Password | ConvertTo-SecureString -AsPlainText -Force
$UserCredential = New-Object -TypeName System.Management.Automation.PSCredential ($UserName, $SecurePassword)
$EmptyCredential = [System.Management.Automation.PSCredential]::Empty
$AppName = 'Pseter-Connect-Reddit'
$AppDescription = 'Pester Connect-Reddit'
$AppUserAgent = 'windows:pester-connect-reddit:1.0.0.1 (by /u/markekraus)'
$AppRedirectUri = 'http://127.0.0.1:65010/authorize_callback'
$AppScope = @('account', 'creddits', 'edit', 'flair', 'history', 'identity', 'livemanage', 'modconfig', 'modcontributors', 'modflair', 'modlog', 'modmail', 'modothers', 'modposts', 'modself', 'modtraffic', 'modwiki', 'mysubreddits', 'privatemessages', 'read', 'report', 'save', 'submit', 'subscribe', 'vote', 'wikiedit', 'wikiread')
$AppGuidWeb = [guid]::new('2906081a-c858-4c27-a965-e08245d39085')
$AppGuidScript = [guid]::new('73d3d744-be87-40ee-adfc-021c13bada18')
$AppGuidInstalled = [guid]::new('2a7e04f3-06ea-4913-ad75-f8433c237832')

Describe "New-RedditApplication" {
    Context "WebApp"{
        It 'Creates New WebApp Reddit.Application Object' {
            $Params = @{
                WebApp = $true
                Name = $AppName
                ClientCredential = $ClientCredential
                RedirectUri = $AppRedirectUri
                Scope = $AppScope
                UserAgent = $AppUserAgent
                Description = $AppDescription
                GUID = $AppGuidWeb
            }
            { New-RedditApplication @Params } | Should Not Throw
            $GLOBAL:RedditAppWeb = New-RedditApplication @Params
        }
        It 'Has valid name' {
            $GLOBAL:RedditAppWeb.Name | Should be $AppName
        }
        It 'Has valid Description' {
            $GLOBAL:RedditAppWeb.Description | Should be $AppDescription
        }
        It 'Has valid ClientID' {
            $GLOBAL:RedditAppWeb.ClientId | Should be $ClientID
        }
        It 'Has valid Type' {
            $GLOBAL:RedditAppWeb.Type | Should be 'WebApp'
        }
        It 'Has valid Scope Count' {
            $GLOBAL:RedditAppWeb.Scope.count | Should be $AppScope.Count
        }
        It 'Has valid RedirectUri' {
            $GLOBAL:RedditAppWeb.RedirectUri | Should be $AppRedirectUri
        }
        It 'Has valid ClientCredential' {
            (
                $GLOBAL:RedditAppWeb.ClientCredential.Username -eq $ClientID -and
                $GLOBAL:RedditAppWeb.ClientCredential.GetNetworkCredential().Password -eq $ClientSecret
            ) | Should be $true
        }
        It 'Has valid GUID' {
            $GLOBAL:RedditAppWeb.GUID.ToString() | Should be $AppGuidWeb.ToString()
        }
        It 'Has Valid PSTypeName' {
            $GLOBAL:RedditAppWeb.Psobject.TypeNames -contains 'Reddit.Application' | Should be $true
        }
    }
    Context "Script" {
        It 'Creates New Script Reddit.Application Object' {
            $Params = @{
                Script = $true
                Name = $AppName
                ClientCredential = $ClientCredential
                UserCredential = $UserCredential
                RedirectUri = $AppRedirectUri
                Scope = $AppScope
                UserAgent = $AppUserAgent
                Description = $AppDescription
                GUID = $AppGuidScript
            }
            { New-RedditApplication @Params } | Should Not Throw
            $GLOBAL:RedditAppScript = New-RedditApplication @Params
        }
        It 'Has valid name' {
            $GLOBAL:RedditAppScript.Name | Should be $AppName
        }
        It 'Has valid Description' {
            $GLOBAL:RedditAppScript.Description | Should be $AppDescription
        }
        It 'Has valid ClientID' {
            $GLOBAL:RedditAppScript.ClientId | Should be $ClientID
        }
        It 'Has valid Type' {
            $GLOBAL:RedditAppScript.Type | Should be 'Script'
        }
        It 'Has valid Scope Count' {
            $GLOBAL:RedditAppScript.Scope.count | Should be $AppScope.Count
        }
        It 'Has valid RedirectUri' {
            $GLOBAL:RedditAppScript.RedirectUri | Should be $AppRedirectUri
        }
        It 'Has valid ClientCredential' {
            $GLOBAL:RedditAppScript.ClientCredential.Username | Should be $ClientID
        }
        It 'Has valid User Credential' {
            (
                $GLOBAL:RedditAppScript.UserCredential.Username -eq $UserName -and
                $GLOBAL:RedditAppScript.UserCredential.GetNetworkCredential().Password -eq $Password
            ) | Should be $true
        }
        It 'Has valid GUID' {
            $GLOBAL:RedditAppScript.GUID.ToString() | Should be $AppGuidScript.ToString()
        }
        It 'Has Valid PSTypeName' {
            $GLOBAL:RedditAppScript.Psobject.TypeNames -contains 'Reddit.Application' | Should be $true
        }
    }
}

$Global:TestsCompleted += Split-Path -Path $MyInvocation.MyCommand.Definition -Leaf