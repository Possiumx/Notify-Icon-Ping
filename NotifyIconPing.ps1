#Read Me Message
Write-Host
"'NotifyIconPing' Tool
Double Click Icon To Exit

[.1] to [.9] ≈ 10 to 90 ms
[1.] to [9.] ≈ 100 to 900 ms
[ ! ] = failed ping or > 1000 ms
"

#Save User Input To JSON
$temp = @($null,$null)
$temp[0] = Read-Host -Prompt "IPv4 Address"
$temp[1] = Read-Host -Prompt "Pings Per Minute"
$temp | ConvertTo-Json | Out-File ".\ico\temp.json"


#Hide PowerShell Window
PowerShell.exe -WindowStyle hidden -Command {

#Get Variables and Delete JSON
$temp = Get-Content ".\ico\temp.json" | ConvertFrom-Json
$IPv4Address = $temp[0]
$PingsPerMinute = $temp[1]
Remove-Item ".\ico\temp.json"

#ObjectEvent Exit Flag
$global:exit = $False

#Initialize NotifyIcon
Add-Type -AssemblyName System.Windows.Forms
$icon = New-Object System.Windows.Forms.NotifyIcon
$icon.Text = $IPv4Address
$icon.Icon = ".\ico\!.ico"
$icon.Visible = $True

#Trigger Exit on NotifyIcon Double Click
Register-ObjectEvent -InputObject $icon -EventName DoubleClick -Action {$global:exit = $True}

#Main Loop Until Trigger Exit
while($global:exit -eq $False){
    
    Start-Sleep -Milliseconds (60000/$PingsPerMinute)

    #Ping Test
    $ping = Test-Connection -ComputerName $global:IPv4Address -Count 1

    #Failed Ping
    if($ping -eq $null){$icon.Icon = ".\ico\!.ico"}

    #Successful Ping
    else
    {
        #Print Ping For Debugging
        #$ping.ResponseTime

        #Round Up Ping Less Than 100 MS
        if($ping.ResponseTime -lt 100)
        {$ms= [math]::Ceiling($ping.ResponseTime/10)*10}
        
        #Round Avg Ping If 100 To 1000 MS
        elseif($ping.ResponseTime -lt 1000)
        {$ms = [math]::Round($ping.ResponseTime/100)*100}

        #Max Ping Error
        else{$ms = 1000}

        #Update NotifyIcon On Rounded Ping
        switch($ms){
        10{$icon.Icon = ".\ico\.1.ico"}
        20{$icon.Icon = ".\ico\.2.ico"}
        30{$icon.Icon = ".\ico\.3.ico"}
        40{$icon.Icon = ".\ico\.4.ico"}
        50{$icon.Icon = ".\ico\.5.ico"}
        60{$icon.Icon = ".\ico\.6.ico"}
        70{$icon.Icon = ".\ico\.7.ico"}
        80{$icon.Icon = ".\ico\.8.ico"}
        90{$icon.Icon = ".\ico\.9.ico"}
        100{$icon.Icon = ".\ico\1.ico"}
        200{$icon.Icon = ".\ico\2.ico"}
        300{$icon.Icon = ".\ico\3.ico"}
        400{$icon.Icon = ".\ico\4.ico"}
        500{$icon.Icon = ".\ico\5.ico"}
        600{$icon.Icon = ".\ico\6.ico"}
        700{$icon.Icon = ".\ico\7.ico"}
        800{$icon.Icon = ".\ico\8.ico"}
        900{$icon.Icon = ".\ico\9.ico"}
        1000{$icon.Icon = ".\ico\!.ico"}
        }
    }
}
#Remove NotifyIcon On Exit
$icon.Dispose()

} 
