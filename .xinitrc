#!/bin/sh

xset -dpms
xset s off
xset s noblank
unclutter -idle 0
exec /usr/bin/chromium-browser --app=file:///home/pi/iHomeMirror-Turnkey/templates/setup.html -–window-size=1080,1920 --window-position=0,0 --start-fullscreen --kiosk --incognito --noerrdialogs --fast --fast-start --disable-infobars --no-sandbox --disable-session-crashed-bubble --ignore-certificate-errors-spki-list --ignore-ssl-errors --ignore-certificate-errors --check-for-update-interval=604800
