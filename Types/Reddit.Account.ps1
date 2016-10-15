@{
    Name = 'Reddit.Account'
    Properties = @(
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'SuspensionExpirationUtcDate'
            Value = {
                $This.suspension_expiration_utc | ConvertFrom-RedditDate
            }
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'GoldExpirationDate'
            Value = {
                $This.gold_expiration | ConvertFrom-RedditDate
            }
        }
    )
}