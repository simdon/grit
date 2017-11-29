#!/bin/bash

re_tweet='s:\([:num:]*\)\t.*:\1:p'
re_url='s:.*\- \(.*\):\1:p'
re_alert='s:^.*actiontitle">\(.*\)\(</span.*\):\1:p'
re_date='s:^.*Board Created\:</strong> \(.*\)<br.*:\1:p'

tweetid=$(twidge lsarchive -lU warksgritting | head -n1 | sed -n "$re_tweet")
tweeturl=$(twidge status $tweetid | sed -n "$re_url")
boardtext=$(curl -Ls $tweeturl > boardtext.html)

datetext=$(cat boardtext.html | sed -n "$re_date")
alerttext=$(cat boardtext.html | tr '\n' ' ' | sed -n "$re_alert")

prev_alert=$(cat /home/pi/grit/latest_alert.txt)

echo $alerttext
echo $prev_alert


if [ "$alerttext" != "$prev_alert" ]
then
   echo $datetext - $alerttext >> /home/pi/grit/logs/grit.log
   echo $alerttext > /home/pi/grit/latest_alert.txt
   /usr/local/bin/pushover  "WarksGritting $datetext: $alerttext"
fi
