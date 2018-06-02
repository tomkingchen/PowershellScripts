<#
    Script to check Webpage contents and send out alert if content changed.
#>
param( 
	    [Parameter(Mandatory=$true)] 
	    [String]$webURL,
        [Parameter(Mandatory=$true)] 
	    [String]$EmailServer,
        [Parameter(Mandatory=$true)] 
	    [String]$Sender,
        [Parameter(Mandatory=$true)] 
	    [String]$Recpient

	  ) 


$webURL = "https://booking.doc.govt.nz/menu.aspx?sg=MIL" # Web URL for msg only, dont put in uri parameter for invoke-webrequest

Do
{
    $NotOpen = "Bookings for the 2018/2019 season will open in June – date to be announced by 5 June."
    $content = Invoke-WebRequest -uri "https://booking.doc.govt.nz/menu.aspx?sg=MIL" # Get contents from the webpage
    $notice = $content.ParsedHtml.getElementById("ctl00_bCPH_serviceGroupNoticesListDiv").textContent # Get the div section of the page
    $noticeBody = $notice.Split("`n")[1] # Get line 2 text
    $msgbody = "<h5><font color =green>Notice Status on Milford Sound Track Page:</font></h5> <font color = green>"+$notice+"</font></br></br>"+"<a href = https://booking.doc.govt.nz/menu.aspx?sg=MIL>"+$webURL+"</a>"

    # Send out a friendly Notification
    Send-MailMessage -SmtpServer Email-Server -From "blah@contoso.com" -To "tomking.chen@gmail.com" -Subject "Milford Sound Track Booking is still CLOSED" -Body $msgbody -BodyAsHtml
    Start-Sleep -Seconds (60 * 60 * 3) # Wait for 3 hours
}While ($noticeBody -eq $NotOpen)

$msgbody = "<h5><font color =red>Notice Status on Milford Sound Track Page:</font></h5> <font color = red>"+$notice+"</font></br></br>"+"<a href = https://booking.doc.govt.nz/menu.aspx?sg=MIL>"+$webURL+"</a>"
Send-MailMessage -SmtpServer Email-Server -From "blah@contoso.com" -To "tomking.chen@gmail.com" -Subject "Milford Sound Track Page has just been Updated!" -Body $msgbody -BodyAsHtml
