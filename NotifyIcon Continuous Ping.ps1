
#ReadMe Message
Write-Host
"Notifyicon Continuous Ping
Double Click Icon To End

Icon Legend
[.0] to [.9] = 0ms to 99ms
[1.] to [9.] = 100ms to 999ms
[!] = Bad Connection > 1000ms
[!!!] = Failed/No Connection
"
#Get User Input
$temp = @($null,$null)
$temp[0] = Read-Host -Prompt "IP/Web Address"
$temp[1] = Read-Host -Prompt "Pings Per Minute"

#Save User Input & ICO64 To JSON
$temp | ConvertTo-Json | Out-File ".\ico\temp.json"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Hide PowerShell Window
PowerShell.exe -WindowStyle hidden -Command {

#Get Variables and Delete JSON
$temp = Get-Content ".\ico\temp.json" | ConvertFrom-Json
$IPv4Address = $temp[0]
$PingsPerMinute = $temp[1]
Remove-Item ".\ico\temp.json"

#ObjectEvent Exit Flag for Double Click
$global:exit = $False

#Initialize NotifyIcon on Taskbar
Add-Type -AssemblyName System.Windows.Forms
$icon = New-Object System.Windows.Forms.NotifyIcon
$icon.Icon = $ICO_x
$icon.Visible = $True

#Trigger Exit on NotifyIcon Double Click
Register-ObjectEvent -InputObject $icon -EventName DoubleClick -Action {$global:exit = $True}

#Main Loop Until Trigger Exit
while($global:exit -eq $False){

    #Status Blink Rate & Wait Time Till Next Ping
    $blink = 200
    Start-Sleep -Milliseconds (60000/$PingsPerMinute-$blink)  

    #Ping Test
    $ping = Test-Connection -ComputerName $IPv4Address -Count 1

    #Debugging
    #$ping = Test-Connection -ComputerName 127.0.0.1 -Count 1
    #$ping.ResponseTime = 0
    #$ping = $null
    
    #Failed Ping Condition
    if($ping -eq $null)
    {$ms=$null}
    
    #Round Avg Ping Less Than 100 MS
    elseif($ping.ResponseTime -lt 100)
    {$ms= [math]::Round($ping.ResponseTime/10)*10}
    
    #Round Avg Ping If 100 To 1000 MS
    elseif($ping.ResponseTime -lt 1000)
    {$ms = [math]::Round($ping.ResponseTime/100)*100}

    #Ping Over 1000ms Error
    else{$ms = 9999}
    
    #Intermittent Status Blink
    function Blink 
    {
        param($i)
        switch($i)
        {
        '<'{$icon.Icon = ".\ico\ix.ico"}
        '>'{$icon.Icon = ".\ico\xi.ico"}
        Default{$icon.Icon = ".\ico\x.ico"}
        }
        switch($i)
        {
        '!!!'{$icon.Text = "Click to End | " + $IPv4Address + " | 🚫"+ $ms}
        Default{$icon.Text = "Click to End | " + $IPv4Address + " | " + $ping.ResponseTime + "ms"}
        }
        Start-Sleep -Milliseconds $blink
    } 

    #Update NotifyIcon via Rounded Ping
    switch($ms){
    $null{Blink('!!!'); $icon.Icon = ".\ico\iii.ico"}
    0{Blink('<'); $icon.Icon = ".\ico\i0.ico"}
    10{Blink('<'); $icon.Icon = ".\ico\i1.ico"}
    20{Blink('<'); $icon.Icon = ".\ico\i2.ico"}
    30{Blink('<'); $icon.Icon = ".\ico\i3.ico"}
    40{Blink('<'); $icon.Icon = ".\ico\i4.ico"}
    50{Blink('<'); $icon.Icon = ".\ico\i5.ico"}
    60{Blink('<'); $icon.Icon = ".\ico\i6.ico"}
    70{Blink('<'); $icon.Icon = ".\ico\i7.ico"}
    80{Blink('<'); $icon.Icon = ".\ico\i8.ico"}
    90{Blink('<'); $icon.Icon = ".\ico\i9.ico"}
    100{Blink('>'); $icon.Icon = ".\ico\1i.ico"}
    200{Blink('>'); $icon.Icon = ".\ico\2i.ico"}
    300{Blink('>'); $icon.Icon = ".\ico\3i.ico"}
    400{Blink('>'); $icon.Icon = ".\ico\4i.ico"}
    500{Blink('>'); $icon.Icon = ".\ico\5i.ico"}
    600{Blink('>'); $icon.Icon = ".\ico\6i.ico"}
    700{Blink('>'); $icon.Icon = ".\ico\7i.ico"}
    800{Blink('>'); $icon.Icon = ".\ico\8i.ico"}
    900{Blink('>'); $icon.Icon = ".\ico\9i.ico"}
    1000{Blink('>'); $icon.Icon = ".\ico\9i.ico"}
    9999{Blink('!'); $icon.Icon = ".\ico\i.ico"}
    }

    #Debugging
    #$icon.Text = "Click to End | " + $IPv4Address + " | " + $ping.ResponseTime + "ms ping | " + $ms + "ms calc"
}

#Remove NotifyIcon On Exit
$icon.Dispose()
}
