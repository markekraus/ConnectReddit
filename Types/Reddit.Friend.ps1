@{
    Name = 'Reddit.Friend'
    Properties = @(
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'DateAdded'
            Value = {
                $This.Date | ConvertFrom-RedditDate
            }
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'RedditApiTypeName'
            Value = {
                $This | Get-RedditApiTypeName
            }
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'RedditApiTypePrefix'
            Value = {
                $This | Get-RedditApiTypePrefix
            }
        }
        @{
            MemberType = 'AliasProperty'
            MemberName = 'RedditApiFullName'
            Value = 'Id'
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'UserURL'
            Value = {
                "{0}{1}" -f $global:ConnectRedditSettings.UserBaseUrl, $This.Name
            }
        }
    )
}