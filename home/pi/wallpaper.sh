#!/bin/bash

# Keep the 100 latest wallpapers
numfiles=`ls /var/www/html/background | wc -l`
while [ $((numfiles)) -gt 99 ]; do
  oldest=`ls -t /var/www/html/background/* | tail -1`
  rm $oldest
  numfiles=`ls /var/www/html/background | wc -l`
done

# Nieuwe achtergrond instellen
# Set InterfaceLift specifics
SITE=interfacelift.com
PAGE=https://$SITE/wallpaper/downloads/random/android/800x480/index.html
#echo $PAGE

# check if InterfaceLift is reachable
if curl -s --head  --request GET https://$site ; then
  # extract wallpaper of the day url
  WOTD=`wget --user-agent="Mozilla/5.0 (X11; Linux x86_64; rv:49.0) Gecko/20100101 Firefox/49.0" -qO - $PAGE | grep "click here to download" | head -1 | sed -e "s,.*href=\",," -e "s,\",," | cut -d '>' -f 1`
#   echo $WOTD

  wget --user-agent="Mozilla/5.0 (X11; Linux x86_64; rv:49.0) Gecko/20100101 Firefox/49.0"  --directory-prefix=/var/www/html/background/ https://$SITE$WOTD
else
  PICPAGEURL=`wget -qO - http://wallpaperswide.com/latest_wallpapers.html | awk '/mini-hud/{getline; print}' | head -1 | sed -e "s,.*href=\",," -e "s,\",," | cut -d ' ' -f 1`
#   echo http://wallpaperswide.com$PICPAGEURL
  PICURL=`wget -qO - http://wallpaperswide.com$PICPAGEURL | grep 800x600.jpg | sed -e "s,.*href=\",," -e "s,\",," | cut -d ' ' -f 1`
#   echo http://wallpaperswide.com$PICURL
  wget --directory-prefix=/var/www/html/background/ http://wallpaperswide.com$PICURL
  mogrify -crop 800x480+0+60 /var/www/html/background/${PICURL:10}
fi
