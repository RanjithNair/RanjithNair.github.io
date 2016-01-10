Start-Process 'C:\windows\system32\notepad.exe'

param($minutes = 60)

$myshell = New-Object -com "Wscript.Shell"

for ($i = 0; $i -lt $minutes; $i++) {
  Start-Sleep -Seconds 60
  $myshell.sendkeys(".")
}