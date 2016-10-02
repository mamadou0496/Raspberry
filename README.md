# Raspberry
My own All In One Raspberry Pi project.
## Update
    sudo apt-get update
    sudo apt-get upgrade
## Rotate LCD Screen
    sudo nano /boot/config.txt
    lcd_rotate=2
## Brightness LCD Screen (0-255)
    sudo su
    echo 128 > /sys/class/backlight/rpi_backlight/brightness

## Install VNC server
    sudo apt-get install tightvncserver
    Start with: vncserver -geometry 800x480 :1
## Raspberry Pi Configuration
    sudo raspi-config
      nl_BE.UTF-8 UTF-8 (Locale: nl (Dutch), BE (Belgium))
      Timezone: Europe, Brussels

    WiFi Country Code: BE Belgium
  
    Enable Camera
    
    Advanced Options
      I2C Enable
## Security
    passwd
    ssh-copy-id -i ~/.ssh/id_rsa.pub pi@raspberrypi.local
    sudo nano /etc/ssh/sshd_config
      PasswordAuthentication no

## User Access on non system partition
    sudo nano /etc/fstab
      /dev/mmcblk0p3  /media/data     ext4    defaults          0       0
    sudo mkdir /media/data
    sudo mount -a
    sudo mkdir -p /media/data/home/pi
    chown pi:pi /media/data/home/pi/
## Autostart fullscreen browser
    sudo apt-get install xautomation firefox-esr
    mkdir -p /media/data/home/pi/.config/lxsession/LXDE-pi/
    nano .config/lxsession/LXDE-pi/autostart
      @sh /media/data/home/pi/.config/lxsession/LXDE-pi/autostart.sh
## Webserver
    sudo apt-get install apache2
    sudo mkdir -p /media/data/var/www/html
    sudo rm -r /var/www/html/
    sudo ln -s /media/data/var/www/html/ /var/www/html
### Folder with background pictures
    sudo ln -s /usr/share/pixel-wallpaper/ /media/data/var/www/html/background
## Activate python3 CGI
    sudo a2enmod cgid
    sudo nano /etc/apache2/conf-enabled/pinda.conf
    <Directory /var/www/html>
        Options +ExecCGI
        AddHandler cgi-script .py
    </Directory>

    sudo nano /media/data/var/www/html/test.py
    #!/usr/bin/python3
    # -*- coding: UTF-8 -*-# enable debugging
    import cgitb
    cgitb.enable()
    print("Content-Type: text/html;charset=utf-8")
    print()
    print("Hello World!")

    sudo chmod +x /media/data/var/www/html/test.py
    
    sudo chmod +x /media/data/var/www/html/background.py
## BME280 I2C Temperature and Pressure Sensor
    Vin > 3v3 (1) (Red)
    GND > Ground (6) (Black)
    SCK > BCM 3 (SCL) (5) (White)
    SDI > BCM 2 (SDA) (3) (Brown)
    
    sudo apt-get install i2c-tools python-smbus
    wget https://bitbucket.org/MattHawkinsUK/rpispy-misc/raw/master/python/bme280.py
    i2cdetect -y 1
    nano bme280.py
      DEVICE = 0x77 # Default device I2C address
    python bme280.py
    
    sudo mv bme280.py /media/data/var/www/html/
    sudo chmod o+rw /dev/i2c-1
