#!/bin/sh

xset -dpms
xset s off
xset s noblank

exec /usr/bin/chromium-browser -–window-size=1080,1920 --window-position=0,0 --start-fullscreen --kiosk --incognito --noerrdialogs --fast --fast-start --disable-infobars --no-sandbox file:///home/pi/iHomeMirror-Turnkey/templates/setup.html
