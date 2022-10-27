# launch our autostart apps (if we are on the correct tty)
if [ "`tty`" = "/dev/tty1" ]; then
    bash "/usr/bin/retrostone2-autostart.sh"
fi