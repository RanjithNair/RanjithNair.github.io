---
layout: post
title: How to chill out and "work" from home
---

There are often days when we are tempted to work from home owing to umpteen reasons ranging from weather, no meetings and being more productive. But during some days, there isn't really much work and you just want to chill out at home along with giving an impression that you are present right in front of your laptop and is online in your commmunicator. 

![alt text](http://d2ws0xxnnorfdo.cloudfront.net/meme/260667 "Working/Chilling from Home"){: .center-image }

Now the company policy to lock your computer after certain idle time is your enemy which you need to tackle and some folks just make sure they keep moving the mouse to resolve that issue. Here comes your savior - a simple VB Script which prints a character "." to the notepad after every specified interval. 

Lets get to the code :-

{% highlight vb %}
'Set the time here - for how long you need this scipt to run
param($minutes = 60)

'Opening up the notepad to output the dot character
Start-Process 'C:\windows\system32\notepad.exe'

$myshell = New-Object -com "Wscript.Shell"

for ($i = 0; $i -lt $minutes; $i++) {
  'Sleep for 60 seconds - After every 60 seconds output the dot character
  Start-Sleep -Seconds 60
  $myshell.sendkeys(".")
}
{% endhighlight %}

Now save this with a ".ps1" format. You can download this script from [here]({{ site.url}}/download/prevent-lock.ps1).
<div style="overflow: auto;">
<img src="https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcQYpVPzDckwDCjWGmBxPuviLf8tw03cScIzzv6ks438fW-FNR818Q" class="left-align"/>
Along with this, to be safer i hook up my bluetooth speaker to the laptop so that in case anyone pings on IM or i get a new mail, i don't miss that :)
</div>








