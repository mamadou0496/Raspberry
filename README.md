# Raspberry
My own All In One Raspberry Pi project.
## Headless configuration
Place a file named 'ssh', without any extension, onto the boot partition of the SD card for a one time SSH server start
## Update
    sudo apt-get update
    sudo apt-get upgrade
## Rotate LCD Screen
    sudo nano /boot/config.txt
    lcd_rotate=2
## Brightness LCD Screen (0-255)
    sudo su
    echo 128 > /sys/class/backlight/rpi_backlight/brightness

## Start VNC server
    sudo systemctl start vncserver-x11-serviced.service
## Raspberry Pi Configuration
    sudo raspi-config
    Localisation Options
      nl_BE.UTF-8 UTF-8 (Locale: nl (Dutch), BE (Belgium))
      Timezone: Europe, Brussels
      WiFi Country Code: BE Belgium
    Hostname
    Interfacing Options
      Enable Camera
      Enable SSH
      I2C Enable
## Security
    passwd
    ssh-copy-id -i ~/.ssh/id_rsa.pub pi@raspberrypi.local
    sudo nano /etc/ssh/sshd_config
      PasswordAuthentication no
    # Rsync backup
    sudo rsync -aAXv --delete --exclude="/dev/" --exclude="/proc/" --exclude="/sys/" --exclude="/tmp/" --exclude="/run/" --exclude="/mnt/" --exclude="/media/" --exclude="/lost+found/" / backup.local::backup/raspberrypi

## Autostart fullscreen browser
    sudo apt-get install xautomation firefox-esr
    nano .config/lxsession/LXDE-pi/autostart
      @sh /home/pi/.config/lxsession/LXDE-pi/autostart.sh
## Webserver
    sudo apt-get install apache2
    sudo a2enmod ssl
    sudo a2ensite default-ssl
    sudo systemctl restart apache2.service
    
    sudo mkdir /etc/apache2/ssl
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt
    sudo chmod 600 /etc/apache2/ssl/*
    sudo nano /etc/apache2/sites-enabled/default-ssl.conf
      ServerAdmin webmaster@localhost
      ServerName rpipindanet.local:443
      
      SSLCertificateFile      /etc/apache2/ssl/apache.crt         
      SSLCertificateKeyFile /etc/apache2/ssl/apache.key
    sudo systemctl restart apache2.service
    openssl s_client -connect 127.0.0.1:443
    
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt
    sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
    # sudo nano /etc/apache2/conf-available/ssl-params.conf
      # from https://cipherli.st/
      # and https://raymii.org/s/tutorials/Strong_SSL_Security_On_Apache2.html

      SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH
      SSLProtocol All -SSLv2 -SSLv3
      SSLHonorCipherOrder On
      # Disable preloading HSTS for now.  You can use the commented out header line that includes
      # the "preload" directive if you understand the implications.
      #Header always set Strict-Transport-Security "max-age=63072000; includeSubdomains; preload"
      Header always set Strict-Transport-Security "max-age=63072000; includeSubdomains"
      Header always set X-Frame-Options DENY
      Header always set X-Content-Type-Options nosniff
      # Requires Apache >= 2.4
      SSLCompression off 
      SSLSessionTickets Off
      SSLUseStapling on 
      SSLStaplingCache "shmcb:logs/stapling-cache(150000)"

      SSLOpenSSLConfCmd DHParameters "/etc/ssl/certs/dhparam.pem"
    # sudo cp /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf.bak
      ServerName rpipindanet.local
      SSLCertificateFile      /etc/ssl/certs/apache-selfsigned.crt
      SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
    # sudo a2enmod ssl
    # sudo a2enmod headers
    # sudo a2enconf ssl-params
    
### Folder with background pictures
    sudo mkdir /media/data/var/www/html/background
    sudo mkdir -p /media/data/etc/systemd/system/
    sudo cp /media/data/etc/systemd/system/PindaNetWallpaper.timer /etc/systemd/system/PindaNetWallpaper.timer
    sudo cp /media/data/etc/systemd/system/PindaNetWallpaper.service /etc/systemd/system/PindaNetWallpaper.service
    sudo ln -s /media/data/home/pi/wallpaper.sh wallpaper.sh
    sudo chmod a+x /media/data/home/pi/wallpaper.sh
    sudo systemctl daemon-reload
    sudo systemctl enable PindaNetWallpaper.timer
    sudo systemctl start PindaNetWallpaper.timer
    systemctl list-timers
## Activate python3 and Bash CGI
    sudo a2enmod cgid
    sudo nano /etc/apache2/conf-enabled/pinda.conf
    <Directory /var/www/html>
        Options +ExecCGI
        AddHandler cgi-script .py .sh
    </Directory>
    
    sudo visudo
    www-data ALL = NOPASSWD: /sbin/shutdown -r now, /sbin/shutdown -h now, /usr/bin/apt-get update, /usr/bin/apt-get upgrade -y

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
    sudo adduser www-data i2c
## YouTube Live Video Stream
    # Account pictogram > Creator Studio > Live Streaming
    sudo apt-get install libmp3lame-dev libx264-dev
    mkdir software
    cd software
    wget http://ffmpeg.org/releases/ffmpeg-3.1.4.tar.bz2
    cd ..
    mkdir src
    cd src/
    tar xvjf ../software/ffmpeg-3.1.4.tar.bz2
    cd ffmpeg-3.1.4/
    ./configure --enable-gpl --enable-nonfree --enable-libx264 --enable-libmp3lame
    make
    sudo make install
    sudo /sbin/ldconfig
    raspivid -o - -t 0 -fps 30 -b 6000000 | ffmpeg -re -ar 44100 -ac 2 -acodec pcm_s16le -f s16le -ac 2 -i /dev/zero -f h264 -i - -vcodec copy -acodec aac -ab 128k -g 50 -strict experimental -f flv rtmp://a.rtmp.youtube.com/live2/<SESSIE>
