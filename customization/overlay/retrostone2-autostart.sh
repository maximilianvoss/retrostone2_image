#!/bin/bash
#

stty -echo

#SERVICE='fbi'
#if ps ax | grep $SERVICE > /dev/null; then
#      sudo killall -q $SERVICE
#fi

#while pgrep mpv &>/dev/null;
#do
#  sleep 1;
#done

#sudo rmmod brcmfmac;

#pulseaudio --start;
#python /home/pi/RetrOrangePi/Background_Music/bgmusic.py &

/opt/retropie/supplementary/emulationstation/emulationstation.sh;

stty echo;

#sudo pkill -f bgmusic.py