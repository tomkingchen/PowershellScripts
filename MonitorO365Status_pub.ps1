
<#
    Script to check latest tweet update from Office 365 Status Twitter Account.
    The script uses MyTwitter module created by Adam Bertram
#>
[string]$body = ""

# Function to convert the twitter time format to standard date time format
function Convert-DateString ([String]$Date, [String[]]$Format)
{
   $result = New-Object DateTime
 
   $convertible = [DateTime]::TryParseExact(
      $Date,
      $Format,
      [System.Globalization.CultureInfo]::InvariantCulture,
      [System.Globalization.DateTimeStyles]::None,
      [ref]$result)
 
   if ($convertible) { $result }
}

# Create a authenticated twitter session with auth token
New-MyTwitterConfiguration -APIKey TKuADFNwJAf4kFAKEAPIKEY -APISecret 5F6ORB4b6eVADSFAgoM6AgDmi5YmZU1q58FAKESECRET -AccessToken 2015912SDAFtpL1LcxVB82KkEIqCNWpFAKE -AccessTokenSecret 4xJYwameZA2m8324234SDFbnwoN32kwi55mAKFAKE

# Get the latest tweet
$tweet = Get-TweetTimeline -Username 'office365status' -MaximumTweets 1

# Convert twitter create time to normal time format
$createTime = Convert-DateString -Date $tweet.created_at -Format 'ddd MMM dd HH:mm:ss zzzz yyyy'

# Do not actio if it's a reply tweet
if ($tweet.in_reply_to_user_id_str -like ""){
    # If the tweet is created within last hour, send out alert
    if ($createTime -gt (get-date).Addhours(-1)){
        
        $body = $tweet.text
        $Emailsubject = "Microsoft Office365Status Twitter Account just post a new update"
        Send-MailMessage -from "tom.chen@hansencx.com" -To "wintelau@hansencx.com" -SmtpServer mxb-00249101.gslb.pphosted.com -Subject $Emailsubject -Body $body
    }else{
        return
    }
}
