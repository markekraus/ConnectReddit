﻿$TestsRequired = @()
foreach ($TestRequired in $TestsRequired) {
    if ($TestRequired -notin $Global:TestsCompleted) {
        $RequiredTestScript = Get-ChildItem -Recurse -Path ..\ -Filter $TestRequired
        Write-Host "Running tests from '$($RequiredTestScript.FullName)'"
        . $RequiredTestScript.FullName
    }
}


$Global:ScopeJSON = @'
{"creddits": {"description": "Spend my reddit gold creddits on giving gold to other users.", "id": "creddits", "name": "Spend reddit gold creddits"}, "modcontributors": {"description": "Add/remove users to approved submitter lists and ban/unban or mute/unmute users from subreddits I moderate.", "id": "modcontributors", "name": "Approve submitters and ban users"}, "modmail": {"description": "Access and manage modmail via mod.reddit.com.", "id": "modmail", "name": "New Modmail"}, "modconfig": {"description": "Manage the configuration, sidebar, and CSS of subreddits I moderate.", "id": "modconfig", "name": "Moderate Subreddit Configuration"}, "subscribe": {"description": "Manage my subreddit subscriptions. Manage \"friends\" - users whose content I follow.", "id": "subscribe", "name": "Edit My Subscriptions"}, "wikiread": {"description": "Read wiki pages through my account", "id": "wikiread", "name": "Read Wiki Pages"}, "wikiedit": {"description": "Edit wiki pages on my behalf", "id": "wiki", "name": "Wiki Editing"}, "vote": {"description": "Submit and change my votes on comments and submissions.", "id": "vote", "name": "Vote"}, "mysubreddits": {"description": "Access the list of subreddits I moderate, contribute to, and subscribe to.", "id": "mysubreddits", "name": "My Subreddits"}, "submit": {"description": "Submit links and comments from my account.", "id": "submit", "name": "Submit Content"}, "modlog": {"description": "Access the moderation log in subreddits I moderate.", "id": "modlog", "name": "Moderation Log"}, "modposts": {"description": "Approve, remove, mark nsfw, and distinguish content in subreddits I moderate.", "id": "modposts", "name": "Moderate Posts"}, "modflair": {"description": "Manage and assign flair in subreddits I moderate.", "id": "modflair", "name": "Moderate Flair"}, "save": {"description": "Save and unsave comments and submissions.", "id": "save", "name": "Save Content"}, "modothers": {"description": "Invite or remove other moderators from subreddits I moderate.", "id": "modothers", "name": "Invite or remove other moderators"}, "read": {"description": "Access posts and comments through my account.", "id": "read", "name": "Read Content"}, "privatemessages": {"description": "Access my inbox and send private messages to other users.", "id": "privatemessages", "name": "Private Messages"}, "report": {"description": "Report content for rules violations. Hide &amp; show individual submissions.", "id": "report", "name": "Report content"}, "identity": {"description": "Access my reddit username and signup date.", "id": "identity", "name": "My Identity"}, "livemanage": {"description": "Manage settings and contributors of live threads I contribute to.", "id": "livemanage", "name": "Manage live threads"}, "account": {"description": "Update preferences and related account information. Will not have access to your email or password.", "id": "account", "name": "Update account information"}, "modtraffic": {"description": "Access traffic stats in subreddits I moderate.", "id": "modtraffic", "name": "Subreddit Traffic"}, "edit": {"description": "Edit and delete my comments and submissions.", "id": "edit", "name": "Edit Posts"}, "modwiki": {"description": "Change editors and visibility of wiki pages in subreddits I moderate.", "id": "modwiki", "name": "Moderate Wiki"}, "modself": {"description": "Accept invitations to moderate a subreddit. Remove myself as a moderator or contributor of subreddits I moderate or contribute to.", "id": "modself", "name": "Make changes to your subreddit moderator and contributor status"}, "history": {"description": "Access my voting history and comments or submissions I've saved or hidden.", "id": "history", "name": "History"}, "flair": {"description": "Select my subreddit flair. Change link flair on my submissions.", "id": "flair", "name": "Manage My Flair"}}
'@
InModuleScope 'Connect-Reddit' {
    Describe 'Get-RedditOAuthScope' {
        Mock Invoke-WebRequest {
            return ([pscustomobject]@{
                    Content = $Global:ScopeJSON
                })
        }
        $Scopes = Get-RedditOAuthScope
        It 'Returns a valid Reddit.Scope Object' {
            $Scopes[0].psobject.typenames -contains 'Reddit.Scope' | Should Be $true
            $Scopes | Where-Object { $_.Scope -like 'submit' } | Should Not BeNullOrEmpty
            $Scopes | Where-Object { $_.Scope -like 'modmail' } | Should Not BeNullOrEmpty
            $Scopes[13].id | Should Not BeNullOrEmpty
            $Scopes[11].description | Should Not BeNullOrEmpty
            $Scopes[4].name | Should Not BeNullOrEmpty
        }
    }
}

$Global:TestsCompleted += Split-Path -Path $MyInvocation.MyCommand.Definition -Leaf