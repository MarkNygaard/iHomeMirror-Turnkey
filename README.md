
# Instructions to create image

The following are the step-by-step instructions for how I create the turnkey image. If you don't want to download the image I created above (I don't blame you), then follow these to make one exactly the same.

These instructions assume you are using Ubuntu. You can use Windows/OS X for most of these steps, except step #4 which requires resizing.

## 1. Flash Raspbian Buster Lite

Starting from version [Raspbian Buster Lite](https://www.raspberrypi.org/downloads/raspbian/).

```
$ diskutil list
```

Identify you SD Card. The name wil be something like /dev/disk2

```
$ diskutil unmountDisk /dev/disk2
$ sudo dd bs=1m if=path_of_your_image.img of=/dev/rdiskN conv=sync
$ sudo diskutil eject /dev/rdisk2
```

After flashing, for the first time use, just plug in ethernet and you can SSH into the Pi. To activate SSH on boot just do

```
$ touch /media/YOURUSER/boot/ssh
```

Or create an empty file called ssh in the root of your SD Card

## 2. Install libraries onto the Raspberry Pi

SSH into your Pi using Ethernet, as you will have to disable the WiFi connection when you install `hostapd`.

### Basic libraries

```
$ sudo apt-get update && sudo apt-get dist-upgrade -y && sudo apt-get install -y dnsmasq hostapd vim python3-flask python3-requests git && sudo apt-get install --no-install-recommends xserver-xorg x11-xserver-utils xinit openbox && sudo apt-get install --no-install-recommends chromium-browser && sudo apt-get install lxde-core && sudo apt-get install lightdm && sudo apt-get install unclutter && sudo apt-get install git && sudo apt-get install libxss1 && sudo apt-get install libnss3
```

```
$ sudo raspi-config
```

Go to "Boot Options" and change boot to "Desktop" or "Desktop Autologin"


### Install MagicMirror
```
$ curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
$ sudo apt install -y nodejs
$ git clone https://github.com/MichMich/MagicMirror
```

```
$ cd MagicMirror/
$ npm install
$ npm install electron@6.0.12
```

### Install node (optional)

```
$ wget https://nodejs.org/dist/v8.9.4/node-v8.9.4-linux-armv6l.tar.xz
$ sudo mkdir /usr/lib/nodejs
$ sudo tar -xJvf node-v8.9.4-linux-armv6l.tar.xz -C /usr/lib/nodejs
$ rm -rf node-v8.9.4-linux-armv6l.tar.xz
$ sudo mv /usr/lib/nodejs/node-v8.9.4-linux-armv6l /usr/lib/nodejs/node-v8.9.4
$ echo 'export NODEJS_HOME=/usr/lib/nodejs/node-v8.9.4' >> ~/.profile
$ echo 'export PATH=$NODEJS_HOME/bin:$PATH' >> ~/.profile
$ source ~/.profile
```

### Install Go (optional)

```
$ wget https://dl.google.com/go/go1.10.linux-armv6l.tar.gz
$ sudo tar -C /usr/local -xzf go*gz
$ rm go*gz
$ echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >>  ~/.profile
$ echo 'export GOPATH=$HOME/go' >>  ~/.profile
$ source ~/.profile
```

### Install turnkey

```
$ git clone https://github.com/MarkNygaard/iHomeMirror-Turnkey.git
```

### Add `pi` to sudoers

Add `pi` to the sudoers, so that you can run sudo commands without having to be root (so that all the paths to your programs are unchanged).

```
$ sudo visudo
```

Then add this line:

```
pi      ALL=(ALL:ALL) ALL
```
### Change orientation and remove rainbow colored cube
```
$ sudo nano /boot/config.txt
$ add the line display_rotate=1
$ disable_splash=1
```

### Style chromium browser
```
$ sudo nano /boot/config.txt /
$ disable_overscan=1
```

### Change name of MagicMirror configuration
```
$ cd MagicMirror/config/
$ mv config.js.sample config.js
```

### Install pm2 using NPM
```
$ cd
$ sudo npm install -g pm2
$ pm2 startup
$ pm2 start ~/iHomeMirror-Turnkey/startup.sh --watch ~/MagicMirror/config/config.js
$ pm2 save
```

### Disable text terminals from blanking

change two settings in /etc/kbd/config
```
$ sudo nano /etc/kbd/config
$ BLANK_TIME=0
$ POWERDOWN_TIME=0
```
### Disable the screensaver
```
$ sudo nano /etc/xdg/lxsession/LXDE/autostart
```

Add the following lines

```
$ @xset s noblank
$ @xset s off
$ @xset -dpms
$ @unclutter -display :0 -idle 3 -root -noevents
```

Go to lightdm.conf:

```
$ sudo nano /etc/lightdm/lightdm.conf
```

add the following line below [Seat:]:
```
$ xserver-command=X -s 0 -dpms
```
Close the file and run

```
$ sudo apt-get remove xscreensaver
```

### Remove raspberry logo and text in Boot
```
$ sudo nano /boot/cmdline.txt
```
Replace the line with the following
```
$ console=serial0,115200 console=tty3 root=PARTUUID=738a4d67-02 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait splash quiet plymouth.ignore-serial-consoles logo.nologo vt.global_cursor_default=0 consoleblank=0 loglevel=1
```
Save with ctrl+x, type yes and enter
```
$ sudo systemctl disable getty@tty1
$ sudo apt install fbi
$ sudo nano /etc/systemd/system/splashscreen.service
```
Insert the following and save the file
```
[Unit]
Description=Splash screen
DefaultDependencies=no
After=local-fs.target

[Service]
ExecStart=/usr/bin/fbi -d /dev/fb0 --noverbose -a /home/pi/splash.png
StandardInput=tty
StandardOutput=tty

[Install]
WantedBy=sysinit.target
```

```
$ sudo systemctl enable splashscreen
```
If you haven't placed a splash image in your root folder you can do that by open you standard terminal (not the one you use for ssh) and copy a file over shh from your computer using the following command.
```
$ scp /location/splash.png pi@ip of your pi:~/my_splash.png
```
Overwrite MagicMirror splash screen with custom
```
$ cp /home/pi/splash.png /home/pi/MagicMirror/splashscreen/splash.png
$ cp /home/pi/splash.png /home/pi/MagicMirror/splashscreen/splash_halt.png
```
### Make a backup of the SD card now before adding startup to rc.local
```
$ sudo shutdown now
```

Remove the SD Card from the mirror to your computer. In your computer terminal type:

```
$ diskutil list
```

Identify you SD Card. The name wil be something like /dev/disk2

```
$ sudo dd if=/dev/rdisk2 of=/Users/Yourname/Desktop/pi.img bs=1m
$ sudo diskutil eject /dev/rdisk2
```

### Change Debian graphics
Change Desktop background on Debian and hide icons. Set wallpaper= to point at the file.
```
$ sudo nano ~/.config/pcmanfm/LXDE/desktop-items-0.conf
```
Change debian boot screen here:
```
$ cd /usr/share/desktop-base/active-theme/plymouth
```

### Startup server on boot

Open up the `rc.local`

```
$ sudo nano /etc/rc.local
```

And add the following line before `exit 0`:

```
$ su pi -c '/usr/bin/sudo /usr/bin/python3 /home/pi/iHomeMirror-Turnkey/startup.py &'
```

### Install Hostapd

```
$ sudo systemctl stop dnsmasq && sudo systemctl stop hostapd

$ echo 'interface wlan0
static ip_address=192.168.4.1/24' | sudo tee --append /etc/dhcpcd.conf

$ sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig  
$ sudo systemctl daemon-reload
$ sudo systemctl restart dhcpcd

$ echo 'interface=wlan0
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h' | sudo tee --append /etc/dnsmasq.conf

$ echo 'interface=wlan0
driver=nl80211
ssid=iHomeMirror
channel=7
hw_mode=g
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0' | sudo tee --append /etc/hostapd/hostapd.conf

$ echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' | sudo tee --append /etc/default/hostapd
$ sudo systemctl unmask hostapd && sudo systemctl unmask dnsmasq
$ sudo systemctl enable hostapd && sudo systemctl enable dnsmasq
$ sudo rfkill unblock wifi
$ sudo systemctl start hostapd && sudo systemctl start dnsmasq
```


### Shutdown the pi

Shutdown the Raspberry Pi and do not start it up until after you write the image. Otherwise the unique ID that is generated will be the same for all the images.

```
$ sudo shutdown now
```

## 3. Save your final image

Make a final image of the finished product.

```
$ sudo dd if=/dev/rdisk2 of=/Users/Yourname/Desktop/pi.img bs=1m
```

The new image will be in `/some/place/iHomeMirror-Turnkey.img` which you can use to flash other SD cards. To test it out, get a new SD card and do:

```
$ sudo dd bs=1m if=path_of_your_image.img of=/dev/rdisk2 conv=sync
```

# License

MIT
