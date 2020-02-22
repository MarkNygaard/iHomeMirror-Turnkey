#!/bin/sh

xset -dpms
xset s off
xset s noblank

exec /usr/bin/chromium-browser --window-size=480,320 --kiosk --incognito --noerrdialogs --fast --fast-start --disable-infobars --no-sandbox http://0.0.0.0:80
