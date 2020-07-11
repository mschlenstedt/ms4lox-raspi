#!/bin/bash
ms_url_version="http://music-server.net/download/version_beta"
squp_url="http://github.com/ralph-irving/squeezelite/"
squp_url_version="https://raw.githubusercontent.com/ralph-irving/squeezelite/master/squeezelite.h"
lmsup_url="http://www.mysqueezebox.com/update/?version=7.9.2&revision=1&geturl=1&os=deb"
lmsup_url_version="http://downloads.slimdevices.com/nightly/?ver=7.9"
lmsup_temp="/tmp/lms.update"
tmpdir="/tmp/musicserver"

ip=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/') 
sudo wget -t 5 -q -O /tmp/msinstall.version $ms_url_version
ms_versonline=`cat /tmp/msinstall.version`

#Chekc Distro
ubu16=$(cat /etc/issue | grep "Ubuntu 16" | wc -l)
ubu18=$(cat /etc/issue | grep "Ubuntu 18" | wc -l)
debian=$(cat /etc/issue | grep "Debian" | wc -l)
debian10=$(cat /etc/issue | grep "10" | wc -l)
raspbian=$(cat /etc/issue | grep "Raspbian" | wc -l)
raspbian10=$(cat /etc/issue | grep "10" | wc -l)

if [ $ubu16 == 1 ];then
	distro=16
	distro2="Ubuntu_16"
elif [ $debian == 1 ] && [ $debian10 == 1 ];then
	distro="deb10"
	distro2="Debian_10"
elif [ $raspbian == 1 ] && [ $raspbian10 == 1 ];then
	distro="rasp10"
	distro2="Raspbian_10"
else
	echo -e "\033[7mKeine unterstützte Distribution gefunden. Breche ab.\033[0m"
	exit
fi

if [ $distro == "deb10" ]; then
	paket=( sudo apache2 libapache2-mod-php7.3 php7.3-curl php7.3-json php7.3-xml php7.3-dev php7.3-soap bc nmap ethtool git squeezelite git make libasound2-dev libflac-dev libmad0-dev libvorbis-dev libfaad-dev libmpg123-dev liblircclient-dev libncurses5-dev patch  alsa-utils alsa-tools powertop htop build-essential caps libasound2-dev libasound2-plugins bs2b-ladspa swh-plugins libasound2-plugin-equal gcc libffi-dev python3-dev openssl libssl-dev libcrypt-openssl-rsa-perl libio-socket-inet6-perl libwww-perl avahi-utils libio-socket-ssl-perl samba zip unzip cifs-utils socat netcat python3-pip curl net-tools libnet-sip-perl fping nodejs node-websocket )
elif [ $distro == 16 ]; then
	paket=( sudo apache2 libapache2-mod-php7.0 php7.0-curl php7.0-json php7.0-xml php7.0-dev php7.0-soap bc nmap ethtool git squeezelite git make libasound2-dev libflac-dev libmad0-dev libvorbis-dev libfaad-dev libmpg123-dev liblircclient-dev libncurses5-dev patch alsa-base alsa-utils alsa-tools powertop htop build-essential caps libasound2-dev libasound2-plugins bs2b-ladspa swh-plugins libasound2-plugin-equal gcc libffi-dev python3-dev openssl libssl-dev libcrypt-openssl-rsa-perl libio-socket-inet6-perl libwww-perl avahi-utils libio-socket-ssl-perl samba zip unzip cifs-utils socat netcat python3-pip netmask curl fping nodejs node-websocket )
elif [ $distro == "rasp10" ]; then
	paket=( sudo apache2 libapache2-mod-php7.3 php7.3-curl php7.3-json php7.3-xml php7.3-dev php7.3-soap bc nmap ethtool git squeezelite git make libasound2-dev libflac-dev libmad0-dev libvorbis-dev libfaad-dev libmpg123-dev liblircclient-dev libncurses5-dev patch  alsa-utils alsa-tools powertop htop build-essential caps libasound2-dev libasound2-plugins bs2b-ladspa swh-plugins libasound2-plugin-equal gcc libffi-dev python3-dev openssl libssl-dev libcrypt-openssl-rsa-perl libio-socket-inet6-perl libwww-perl avahi-utils libio-socket-ssl-perl samba zip unzip cifs-utils socat netcat python3-pip curl net-tools libnet-sip-perl fping nodejs node-websocket )
fi

cd /
clear
echo
echo -e "\033[7mMusik-Server | INSTALL                                                     "$ms_versonline"\033[0m"
echo "================================================================================"

# System update
echo
echo -e "\033[7mMusik-Server | SYSTEM UPDATE                                                    \033[0m"
echo "--------------------------------------------------------------------------------"
echo "Softwareliste wird eingelesen..."
apt update
echo "--------------------------------------------------------------------------------"
echo "Softwareliste wird eingelesen..."
apt -yy -qq upgrade
echo "--------------------------------------------------------------------------------"

# Installierte Paket abfragen
echo
echo -e "\033[7mMusik-Server | INSTALL PAKET                                                    \033[0m"
echo "--------------------------------------------------------------------------------"
for i in "${paket[@]}"; do
if dpkg-query -s $i 2>/dev/null | grep -q installed ; then
echo -e "$i - \033[30m\033[42mist installiert \033[0m"
else
echo -e "$i - \033[30m\033[41mnicht installiert  \033[0m"
echo "$i wird installiert"
export DEBIAN_FRONTEND=noninteractive
apt-get -yq install $i
fi
echo "--------------------------------------------------------------------------------"
done

# Dateien downloaden
echo
echo -e "\033[7mMusik-Server | COPY FROM MUSIC-SERVER.NET                                       \033[0m"
echo "--------------------------------------------------------------------------------"
cd /tmp
echo "Kopiere Dateien von music-server.net... nach /tmp"
sudo rm -rf $tmpdir
sudo rm -rf /tmp/install_beta.zip
sudo wget -q http://music-server.net/download/install_beta.zip
echo "--------------------------------------------------------------------------------"
echo "entpacke Dateien nach "$tmpdir
sudo unzip -q -d $tmpdir /tmp/install_beta.zip
echo "--------------------------------------------------------------------------------"
sleep 2
# Dateien kopieren / Rechte anpassen
echo
echo -e "\033[7mMusik-Server | COPY & CHMOD                                                     \033[0m"
echo "--------------------------------------------------------------------------------"
echo "Kopiere Dateien..."
echo ".../etc/..."
sudo cp -r $tmpdir/etc/ /
echo ".../opt/..."
sudo cp -r $tmpdir/opt/ /
echo ".../www/..."
sudo cp -r $tmpdir/var/www/ /var/
echo "--------------------------------------------------------------------------------"
echo "Rechte anpassen..."
echo "für SCRIPT.."
sudo chmod 0755 /opt/music_server/*
echo "für CONFIG..."
sudo chmod 0777 /opt/music_server/soundcard_cfg/
sudo chmod 0777 /opt/music_server/sq_cfg/
sudo chmod 0777 /opt/music_server/tools/
sudo chmod 0755 /opt/music_server/tools/*.*
sudo chmod 0777 /opt/music_server/sq_fav
sudo chmod 0666 /opt/music_server/sq_cfg/*.*
sudo chmod 0777 /opt/music_server/sq_cfg/event/
sudo chmod 0666 /opt/music_server/sq_cfg/event/*.*
sudo chmod 0777 /opt/music_server/sq_cfg/eq/
sudo chmod 0777 /opt/music_server/sq_cfg/zones/
sudo chmod 0777 /opt/music_server/sq_cfg/zones_ext/
sudo chmod 0666 /opt/music_server/soundcard_cfg/defaultcard/*.*
sudo chmod 0666 /opt/music_server/soundcard_cfg/multicard/*.*
sudo chmod 0777 /opt/music_server/soundcard_cfg/zones/
sudo chmod 0666 /opt/music_server/soundcard_cfg/*.*
sudo chmod 0777 /opt/music_server/t5_cmd/
sudo chmod 0777 /opt/music_server/msg/
sudo chmod 0755 /opt/music_server/msg/msg.sh
sudo chmod 0755 /opt/music_server/msg/msg1.sh
echo "für WWW..."
sudo chmod 0777 /var/www/event/tts_tmp/
sudo chmod 0777 /var/www/event/ringtones/
sudo chmod 0777 /var/www/system/log/
sudo chmod 0777 /var/www/event/ringtones/tts_signal/
sudo chmod 0666 /var/www/settings/network.conf
sudo chmod 0666 /var/www/settings/soundcards.txt
sudo chmod 0666 /opt/music_server/soundcard_cfg/event.cfg
echo "für ALSA..."
sudo chmod 0666 /etc/asound.conf
echo "für NETWORK SETTING..."
sudo chmod 0666 /etc/network/interfaces
sudo chmod 0755 /etc/rc.local
echo "--------------------------------------------------------------------------------"

# Softlinks anlegen
echo
echo -e "\033[7mMusik-Server | SOFTLINKS                                                        \033[0m"
echo "--------------------------------------------------------------------------------"
echo "Soft-Links anlegen..."
sudo ln -f /opt/music_server/sc /bin/sc
sudo ln -f /opt/music_server/mstools /bin/mstools
echo "--------------------------------------------------------------------------------"

#User music anlegen
echo
echo -e "\033[7mMusik-Server | USER CREATE                                                      \033[0m"
echo "--------------------------------------------------------------------------------"
if getent passwd music >/dev/null; then
echo "Benutzer MUSIC vorhanden"
else
 sudo adduser music
 sudo passwd music 
fi
echo "--------------------------------------------------------------------------------"

#Verzeichnisse anlegen
echo
echo -e "\033[7mMusik-Server | DIR CREATE                                                       \033[0m"
echo "--------------------------------------------------------------------------------"
cd /home/music
if [ -d "/home/music/music_files" ]; then
echo "Verezichnis music_files existiert bereits..."
else
echo "Verzeichnis music_files anlegen..."
sudo mkdir music_files
echo "Rechte an für das Verzeichnis an User:music übergeben..."
sudo chown -c music /home/music/music_files
sudo chmod 0777 /home/music/music_files
  fi

if [ -d "/home/music/music_playlists" ]; then
echo "Verezichnis music_playlists existiert bereits..."
else
echo "Verzeichnis music_playlists anlegen..."
sudo mkdir music_playlists
echo "Rechte an für das Verzeichnis an User:music übergeben..."
sudo chown -c music /home/music/music_playlists
sudo chmod 0777 /home/music/music_playlists
fi

if [ -d "/home/music/backup" ]; then
echo "Verezichnis backup existiert bereits..."
else
echo "Verzeichnis backup anlegen..."
sudo mkdir backup
echo "Rechte an für das Verzeichnis an User:music übergeben..."
sudo chown -c music /home/music/backup
sudo chmod 0777 /home/music/backup
fi
echo "--------------------------------------------------------------------------------"

# LMS installieren
cd /
echo
echo -e "\033[7mMusik-Server | LOGITECHMEDIASERVER                                              \033[0m"
echo "--------------------------------------------------------------------------------"
cd /tmp
if [ -d "/tmp/lms_sources" ]; then
sudo rm -rf /tmp/lms_sources
fi
lmsup_url_version="http://downloads.slimdevices.com/nightly/?ver=7.9"
lmsup_temp="/tmp/lms.update"
sudo wget -q -O $lmsup_temp $lmsup_url_version
lmsup_version=$(grep -A 1 "_all.deb" $lmsup_temp | grep -v grep | cut -c 95- | cut -d"<" -f1 | cut -d"_" -f1 | cut -d"~" -f1 )
lmsup_url="http://www.mysqueezebox.com/update/?version=$lmsup_version&revision=1&geturl=1&os=deb"
if [ $raspbian == 1 ]; then
        lmsup_url=$lmsup_url"arm"
fi
versonline=$(grep -A 1 "_all.deb" $lmsup_temp | grep -v grep | cut -c 95- | cut -d"<" -f1 | cut -d"_" -f1 )
cd /tmp
latest_lms=$(wget -q -O - "$lmsup_url")
sudo mkdir -p /tmp/lms_sources
cd /tmp/lms_sources
wget $latest_lms
lms_deb=${latest_lms##*/}
sudo dpkg -i $lms_deb
sudo update-rc.d -f logitechmediaserver disable
sudo rm -f /etc/init.d/logitechmediaserver
sudo rm -rf /tmp/lms_sources/*.*
sudo rm -rf /tmp/lms_sources
sudo rm -rf /tmp/lms.update
sudo rm -f /etc/init.d/logitechmediaserver
#echo "Kopiere Setup Dateien... für LMS"
#sudo cp -fr $tmpdir/var/lib/ /var/
#sudo chmod 0644 /var/lib/squeezeboxserver/prefs/plugin/extensions.prefs
#sudo chmod 0644 /var/lib/squeezeboxserver/prefs/plugin/state.prefs
echo "--------------------------------------------------------------------------------"

# Squeezelite installieren
echo
echo -e "\033[7mMusik-Server | SQUEEZELITE                                                      \033[0m"
echo "--------------------------------------------------------------------------------"
dir="`mktemp --directory`"
cd "$dir"
sudo wget -t 5 -q -O sqo.version $squp_url_version
version_online=$(grep "#define VERSION" sqo.version | cut -c 19- | cut -d"\"" -f1 )
version_installed=`squeezelite -? | grep "Squeezelite v" | awk '{print $2}' | cut -d "v" -f2 | cut -d "," -f1`
sudo git clone $squp_url
cd squeezelite
CORES=$(grep ^processor /proc/cpuinfo | wc -l)
sudo make -j$CORES
sudo cp -f squeezelite /usr/bin/squeezelite-$version_online
sudo ln -f /usr/bin/squeezelite-$version_online /usr/bin/squeezelite
sudo rm -rf /tmp/*.*
sudo update-rc.d squeezelite disable
echo "--------------------------------------------------------------------------------"

# Vorbereitung für Plugins
cd /
echo
echo -e "\033[7mMusik-Server | PREPARE                                                          \033[0m"
echo "--------------------------------------------------------------------------------"
if [[ $distro -eq 16 ]]; then 
echo "libnet installieren..."
sudo wget http://music-server.net/download/install/libnet-sip-perl_0.812-1_all.deb
sudo dpkg -i libnet-sip-perl_0.812-1_all.deb
sudo rm -rf libnet-sip-perl_0.812-1_all.deb
echo "--------------------------------------------------------------------------------"
fi
echo "PowerTop AutoTune Service..."
if ! [ -e /etc/systemd/system/powertop.service ]; then
cat << EOF | sudo tee /etc/systemd/system/powertop.service
[Unit]
Description=PowerTOP auto tune

[Service]
Type=idle
Environment="TERM=dumb"
ExecStart=/usr/sbin/powertop --auto-tune

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable powertop.service
else
echo "Service existiert bereits"
fi
echo "--------------------------------------------------------------------------------"

#Apache Neustart
echo
echo -e "\033[7mMusik-Server | APACHE PREPARE                                                  \033[0m"
echo "--------------------------------------------------------------------------------"
echo "Apache-Server setup und neustarten"
if [ $distro == "deb10" ]; then
	
	apache_file="/etc/systemd/system/multi-user.target.wants/apache2.service"

	echo "[Unit]" > $apache_file
	echo "Description=The Apache HTTP Server" >> $apache_file
	echo "After=network.target remote-fs.target nss-lookup.target" >> $apache_file
	echo "Documentation=https://httpd.apache.org/docs/2.4/" >> $apache_file
	echo "" >> $apache_file
	echo "[Service]" >> $apache_file
	echo "Type=forking" >> $apache_file
	echo "Environment=APACHE_STARTED_BY_SYSTEMD=true" >> $apache_file
	echo "ExecStart=/usr/sbin/apachectl start" >> $apache_file
	echo "ExecStop=/usr/sbin/apachectl stop" >> $apache_file
	echo "ExecReload=/usr/sbin/apachectl graceful" >> $apache_file
	echo "PrivateTmp=false" >> $apache_file
	echo "Restart=on-abort" >> $apache_file
	echo "" >> $apache_file
	echo "[Install]" >> $apache_file
	echo "WantedBy=multi-user.target" >> $apache_file

	sudo systemctl daemon-reload
	sudo systemctl restart apache2
else
	sudo service apache2 restart
fi

echo "--------------------------------------------------------------------------------"

echo
echo -e "\033[7mMusik-Server | CRON RESTART                                                     \033[0m"
echo "--------------------------------------------------------------------------------"
echo "Cron neustarten"
sudo service cron restart
sudo wget -t 5 -q -O /tmp/msinstall.version $ms_url_version
ms_versonline=`cat /tmp/msinstall.version`
echo VERS="$ms_versonline" > /opt/music_server/sq_cfg/sq_version.cfg
sudo /opt/music_server/mstools send_stat
echo "--------------------------------------------------------------------------------"

IFACE=$(ip -o link show | sed -rn '/^[0-9]+: en/{s/.: ([^:]*):.*/\1/p}')
echo "######################################################" > /etc/network/interfaces
echo "## NETWORK SETTINGS CREATE BY MUSICSERVER4LOX" >> /etc/network/interfaces
echo "auto lo" >> /etc/network/interfaces
echo "iface lo inet loopback" >> /etc/network/interfaces
echo "" >> /etc/network/interfaces
echo "auto $IFACE" >> /etc/network/interfaces
echo "iface $IFACE inet dhcp" >> /etc/network/interfaces

#SET LMS
echo "LMS_AUTOSTART=\"1\"" > /opt/music_server/sq_cfg/sq_lms.cfg
echo "LMS_IP=\"$ip\"" >> /opt/music_server/sq_cfg/sq_lms.cfg
echo "LMS_WEB_PORT=\"9000\"" >> /opt/music_server/sq_cfg/sq_lms.cfg
echo "LMS_TELNET_PORT=\"9090\"" >> /opt/music_server/sq_cfg/sq_lms.cfg

#kill Player Music-Server
pid=$(ps -eo pid,command | grep Music-Server | grep -v grep | awk '{print $1}')
if [[ $pid -gt 0 ]]; then
sudo kill $pid
fi

#Aufräumen
echo
echo -e "\033[7mMusik-Server | CLEANUP                                                          \033[0m"
echo "--------------------------------------------------------------------------------"
echo "Verzeichnisse und Dateien löschen..."
sudo rm -rf /var/www/html/*.*
sudo rm -rf /var/www/html
sudo rm -rf /tmp/install_beta.zip
sudo rm -rf /tmp/musicserver/*.*
sudo rm -rf /tmp/musicserver/
sudo mstools clean_event
echo "--------------------------------------------------------------------------------"

#Fertig
echo
echo -e "\033[7mMusik-Server | READY                                                            \033[0m"
echo "--------------------------------------------------------------------------------"
echo "FERTIG"
echo "System jetzt rebooten!!"
echo "LMS unter "$ip":9000 im Browser jetzt konfigurieren"
echo "--------------------------------------------------------------------------------"
cd /
sudo rm -rf install_beta.sh

exit 0
