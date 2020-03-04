#!/bin/bash

sleep 3

# enable the AP
sudo echo 'interface=wlan0
driver=nl80211
ssid=iHomeMirror
channel=7
hw_mode=g
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
' > /etc/hostapd/hostapd.conf

sudo cp config/hostapd /etc/default/hostapd
sudo cp config/dhcpcd.conf /etc/dhcpcd.conf
sudo cp config/dnsmasq.conf /etc/dnsmasq.conf

# load wan configuration
sudo cp wpa.conf /etc/wpa_supplicant/wpa_supplicant.conf

sudo reboot now
