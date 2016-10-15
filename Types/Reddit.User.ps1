@{
    Name = 'Reddit.User'
    Properties = @(
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'CreatedDate'
            Value = {
                $This.Created | ConvertFrom-RedditDate
            }
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'CreatedUtcDate'
            Value = {
                $This.Created_utc | ConvertFrom-RedditDate
            }
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'UserURL'
            Value = {
                "{0}{1}" -f $global:ConnectRedditSettings.UserBaseUrl, $This.Name
            }
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'RedditName'
            Value = {
                '/u/{0}' -f $This.name
            }
        }
    )
}