@{
    Name = 'Reddit.OAuthAccessToken'
    Properties = @(
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'UserContext'
            Value = {
                try {
                    Get-RedditAccount -AccessToken $This -ErrorAction Stop
                }
                catch {
                    $null
                }
            }
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'AccessToken'
            Value = {
                $This.TokenObject.access_token
            }
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'TokenType'
            Value = {
                $this.TokenObject.token_type
            }
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'TokenType'
            Value = {
                $this.TokenObject.token_type
            }
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'Expires'
            Value = {
                if ($This.Requested) {
                    $This.Requested.AddSeconds($this.TokenObject.expires_in)
                }
                else {
                    Get-Date
                }
            }
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'IsExpired'
            Value = {
                $(get-date) -ge $this.Expires
            }
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'ValidScope'
            Value = {
                $This.TokenObject.Scope -split ' '
            }
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'RatelimitUsed'
            Value = {
                $This.ResponseHeaders.'X-Ratelimit-Used'
            }
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'RatelimitRemaining'
            Value = {
                $This.ResponseHeaders.'X-Ratelimit-Remaining'
            }
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'RatelimitReset'
            Value = {
                if ($This.ResponseHeaders.'X-Ratelimit-Reset' -and $This.LastRequest) {
                    $This.LastRequest.AddSeconds($This.ResponseHeaders.'X-Ratelimit-Reset')
                }
                else {
                    Get-Date
                }
            }
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'IsRatelimited'
            Value = {
                if ($This.RatelimitReset -gt (get-date) -and $This.RatelimitRemaining -lt 1) {
                    $True
                }
                else {
                    $False
                }
            }
        }
    )
}


























