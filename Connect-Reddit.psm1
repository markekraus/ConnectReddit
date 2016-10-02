Write-Verbose 'Createig the ConnectRedditSettings Global settings object.'
Set-Variable -Scope Global -Name ConnectRedditSettings -Value $(
    [pscustomobject]@{
        # Base URL for user accounts
        UserBaseUrl = 'https://www.reddit.com/u/'
        ApiTypeNameMapping = [pscustomobject]@{
            'Reddit.User' = 'Account'
            'Reddit.Account' = 'Account'
        }
        ApiTypePrefixMapping = [pscustomobject]@{
            'Reddit.User' = 't2'
            'Reddit.Account' = 't2'
        }
    }
)

# Reddit.User TypeData
Write-Verbose 'Adding type data for Reddit.User objects'
Write-Verbose '-Adding CreatedDate property'
Update-TypeData -TypeName 'Reddit.User' -MemberType ScriptProperty -MemberName CreatedDate -Value {
    $This.Created | ConvertFrom-RedditDate
}
Write-Verbose '-Adding CreatedUtcDate property'
Update-TypeData -TypeName 'Reddit.User' -MemberType ScriptProperty -MemberName CreatedUtcDate -Value {
    $This.Created_utc | ConvertFrom-RedditDate
}
Write-Verbose '-Adding UserUrl property'
Update-TypeData -TypeName 'Reddit.User' -MemberType ScriptProperty -MemberName UserURL -Value {
    $MyConnectRedditSettings = Get-Variable -Scope Global -Name ConnectRedditSettings -ValueOnly
    "{0}{1}" -f $MyConnectRedditSettings.UserBaseUrl, $This.Name
}
Write-Verbose '-Adding RedditName property'
Update-TypeData -TypeName 'Reddit.User' -MemberType ScriptProperty -MemberName RedditName -Value {
    '/u/{0}' -f $This.name
}

# Reddit.Account TypeData
Write-Verbose 'Adding type data for Reddit.Account objects'
Write-Verbose '-Adding CreatedDate property'
Update-TypeData -TypeName 'Reddit.Account' -MemberType ScriptProperty -MemberName SuspensionExpirationUtcDate -Value {
    $This.suspension_expiration_utc | ConvertFrom-RedditDate
}

# Reddit.Object TypeData
Write-Verbose 'Adding Type data for Reddit.Object'
Write-Verbose '-Adding RedditApiTypeName property'
Update-TypeData -TypeName 'Reddit.Object' -MemberType ScriptProperty -MemberName RedditApiTypeName -Value {
    $This | Get-RedditApiTypeName
}
Write-Verbose '-Adding RedditApiTypePrefix property'
Update-TypeData -TypeName 'Reddit.Object' -MemberType ScriptProperty -MemberName RedditApiTypePrefix -Value {
    $This | Get-RedditApiTypePrefix
}
Write-Verbose '-Adding RedditApiTypePrefix property'
Update-TypeData -TypeName 'Reddit.Object' -MemberType ScriptProperty -MemberName RedditApiFullName -Value {
    Get-RedditApiFullname -Type $This.RedditApiTypeName -RedditId $This.Id
}