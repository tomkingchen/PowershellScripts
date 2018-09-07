<#
.SYNOPSIS
Create a Window for CR document creation and review request.

.DESCRIPTION
The script loads a Window using WPF xaml file. User can use the Window to create folder and copy document template. It also allow user to send out CR review request.

.NOTES
Author: Tom Chen
Version 0.0.1

#>

# Do the necessary to load the XAML file
Add-Type -AssemblyName presentationframework, presentationcore
$wpf = @{ }
$inputXML = Get-Content -Path ".\MainWindow.xaml"
$inputXMLClean = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace 'x:Class=".*?"','' -replace 'd:DesignHeight="\d*?"','' -replace 'd:DesignWidth="\d*?"',''
[xml]$xaml = $inputXMLClean
$reader = New-Object System.Xml.XmlNodeReader $xaml
$tempform = [Windows.Markup.XamlReader]::Load($reader)
$namedNodes = $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")
$namedNodes | ForEach-Object {$wpf.Add($_.Name, $tempform.FindName($_.Name))}

# Action Script

# Get current year
$year = (get-date).year

#This code runs when the "Create CR Folder" button is clicked
$wpf.crfolderBT.add_Click({
    
    $result =""

    # Get CR number from user input
    $crnumber = $wpf.crnumberTBox.text
    
    
    # Validate the CR number 
    if ($crnumber.Length -eq 5 -and $crnumber -match '^\d+$'){

        $initials = $wpf.initialsTB.text

        $location = $wpf.crlocationCBox.text
        
        # Create folder based on different location
        $loc = switch ($location){
            "AU" {"1. AU - Australia"}
            "CN" {"2. SH - China"}
            "NZ" {"3. NZ - New Zealand"}
            "UK" {"4. UK - United Kingdom"}
        }

        # Define the path
        if ($initials -eq ""){
            $crpath = "\\Fileserver\Document\Change Management\"+$loc+"\2018\CR"+$crnumber
        }else{
            if ($initials -like "* *"){
                $crpath = "\\Fileserver\Document\Change Management\"+$loc+"\2018\CR"+$crnumber
            }else{
                $crpath = "\\Fileserver\Document\Change Management\"+$loc+"\2018\CR"+$crnumber+"-"+$initials
            }
        }
        $crdocpath = $crpath+"\"+"cr"+$crnumber+".docx"

        Try {
            if (test-path -path $crpath){
                $result = "Folder already existed"
            }else{
                new-item -path $crpath -ItemType directory
                copy-item -path "\\Fileserver\Document\Change Management\Resources\Change req Template.docx" -Destination $crdocpath
                #Show successful result
                $result = "Successfully created folder: `n $crpath"
            }
             
        }
        Catch{
            $result = $Error[0]
        }
    }else{
        $result = "Invalid Input!"
    }   

    $wpf.outputTBlock.text = $result
})

#This code runs when "Ask for Peer Review" button is clicked
$wpf.reviewBT.add_Click({

    $result =""

    # Get CR number from user input
    $crnumber = $wpf.crnumberTBox.text
    
    
    # Validate the CR number 
    if ($crnumber.Length -eq 5 -and $crnumber -match '^\d+$'){

        $initials = $wpf.initialsTB.text

        $location = $wpf.crlocationCBox.text
        
        # Create folder based on different location
        $loc = switch ($location){
            "AU" {"1. AU - Australia"}
            "CN" {"2. SH - China"}
            "NZ" {"3. NZ - New Zealand"}
            "UK" {"4. UK - United Kingdom"}
        }

        # Define the path
        if ($initials -eq ""){
            $crpath = "\\fileserver\Document\Change Management\"+$loc+"\$year\CR"+$crnumber
        }else{
            if ($initials -like "* *"){
                $crpath = "\\fileserver\Document\Change Management\"+$loc+"\$year\CR"+$crnumber
            }else{
                $crpath = "\\fileserver\Document\Change Management\"+$loc+"\$year\CR"+$crnumber+"-"+$initials
            }
        }
        $crdocpath = $crpath+"\"+"cr"+$crnumber+".docx"

        Try {
            #Open Outlook new message
            $outlookObj = New-Object -comObject Outlook.Application    
            $mail = $outlookObj.CreateItem(0)
            $mail.Subject = "Please Review CR$crnumber"
            $mail.htmlbody = "Please review <b> CR$crnumber</b>. <br/> CR Checklist Document Location: <br/><a href='"+$crpath+"'>$crpath</a>"
            $inspector = $mail.GetInspector
            $inspector.Activate()
             
        }
        Catch{
            $result=$Error[0]
        }
    }else{
        $result = "Invalid Input!"
    }
    $wpf.outputTBlock.text = $result

})


$wpf.changeManagerWindow.ShowDialog() | Out-Null