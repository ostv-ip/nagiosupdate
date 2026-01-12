#!/usr/bin/env bash

##########################################################################################################################

# Copyright 2022 Sysnote (sysnotecom@gmail.com)
# Author: Sysnote (sysnotecom@gmail.com)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>
#
# File : allions.sh : A simple shell script to Install Nagios Monitoring Tool.
# Updated: January 2026 - Updated to Nagios Core 4.5.10 and Nagios Plugins 2.4.12

##########################################################################################################################


# Text color variables

txtund=$(tput sgr 0 1)    # Underline
txtbld=$(tput bold)       # Bold
txtred=$(tput setaf 1)    # Red
txtgrn=$(tput setaf 2)    # Green
txtylw=$(tput setaf 3)    # Yellow
txtblu=$(tput setaf 4)    # Blue
txtpur=$(tput setaf 5)    # Purple
txtcyn=$(tput setaf 6)    # Cyan
txtwht=$(tput setaf 7)    # White
txtrst=$(tput sgr0)       # Text reset

clear

#########################################################################################################################
echo ""
echo ""
echo "#############################################################"
echo "#############################################################"
echo "##                                                         ##"
echo "##${txtgrn}         Welcome To All In One Nagios (AllION) Script${txtrst}    ##"
echo "##                  Created By sysnote                     ##"
echo "##          ${txtylw}       sysnotecom@gmail.com   ${txtrst}                 ##"
echo "##                                                         ##"
echo "#############################################################"
echo "#############################################################"
echo ""
echo ""
#########################################################################################################################

sleep 2


############ Variable Definitions  ################
path=`pwd`
log=/tmp/nagios_setup.log

# Current latest versions - UPDATE THESE WHEN NEW VERSIONS ARE RELEASED
NAGIOS_VERSION="4.5.10"
NAGIOS_PLUGINS_VERSION="2.4.12"
NRPE_VERSION="4.1.0"

# Download URLs
NAGIOS_URL="https://assets.nagios.com/downloads/nagioscore/releases/nagios-${NAGIOS_VERSION}.tar.gz"
NAGIOS_PLUGINS_URL="https://github.com/nagios-plugins/nagios-plugins/releases/download/release-${NAGIOS_PLUGINS_VERSION}/nagios-plugins-${NAGIOS_PLUGINS_VERSION}.tar.gz"

nagios_core="nagios-${NAGIOS_VERSION}.tar.gz"
folder_nagios="nagios-${NAGIOS_VERSION}"
nagios_plugin="nagios-plugins-${NAGIOS_PLUGINS_VERSION}.tar.gz"
folder_plugin="nagios-plugins-${NAGIOS_PLUGINS_VERSION}"

############ Functions Definition ################

stop() {
sleep 2
echo ""
echo ""
exit 0
}

thankyou() {
echo ""
echo ""
echo "#############################################################"
echo "#############################################################"
echo "##                                                         ##"
echo "##${txtgrn}  Thank You for using All In One Nagios (AllION) Script${txtrst}  ##"
echo "##                  Created By sysnote                     ##"
echo "##          ${txtylw}       sysnotecom@gmail.com   ${txtrst}                 ##"
echo "##                                                         ##"
echo "#############################################################"
echo "#############################################################"
echo ""
echo ""
cd $path
rm -rf index_latest.html latest* latest_year.txt nagplug.txt php.txt plugin1.txt plugin.txt result.txt reverse.txt index* php.txt year.txt version.txt check_nagios.txt rpm_nagios_cfg.txt rpm_nagios.txt nagios_folder.txt targz.txt wget-log* httpd.txt upgrade-nagios upgrade-plugin 2>/dev/null
sleep 2
}

finish() {
echo "${txtgrn}Congratulations, Nagios installation completed successfully.${txtrst}"
sleep 5
echo "Nagios Installation Completed successfully" >> $log 2>/dev/null
echo ""
echo "${txtpur}Here is detail information:${txtrst}"
sleep 2
echo "Nagios Web Frontend Url             : ${txtcyn}http://localhost/nagios${txtrst}  or  ${txtcyn}http://ip_address_server/nagios${txtrst}"
echo "Nagios Web Frontend Username        : ${txtcyn}nagiosadmin${txtrst}"
echo "Nagios Web Frontend Password        : ${txtcyn}***********${txtrst}"
echo "Nagios Installation Directory       : ${txtcyn}/usr/local/nagios/${txtrst}"
echo "Nagios Main Configuration File      : ${txtcyn}/usr/local/nagios/etc/nagios.cfg${txtrst}"
echo "Nagios Object configuration Files   : ${txtcyn}/usr/local/nagios/etc/objects/${txtrst}"
echo "Nagios Apache Configuration File    : ${txtcyn}/etc/httpd/conf.d/nagios.conf${txtrst} (For RHEL-Based)"
echo "                                    : ${txtcyn}/etc/apache2/sites-enabled/nagios.conf${txtrst} (For Ubuntu/Debian)"
echo "                                    : ${txtcyn}/etc/apache2/vhosts.d/nagios.conf${txtrst} (For OpenSUSE)"
sleep 2

echo
echo "${txtpur}Note${txtrst}"
echo "${txtbld}If you can't display the Nagios application in your browser, ${txtrst}"
echo "${txtbld}it means that the firewall and/or selinux application is still enabled in your server.${txtrst}"
sleep 2

echo
echo "${txtred} ********                   Please change Contacts in                 ******** ${txtrst}"
echo "${txtred} ********          /usr/local/nagios/etc/objects/contacts.cfg         ******** ${txtrst}"
echo "${txtred} ******** Check Nagios installation Log File in /tmp/nagios_setup.log ******** ${txtrst}"
echo ""
sleep 2

echo " ${txtgrn}     ********** Thank You For Using All in One Nagios Script ********** ${txtrst}"
echo "              ${txtgrn}     ******** sysnotecom@gmail.com ******** ${txtrst}"
echo "                     ${txtgrn}     ****** Thank You ****** ${txtrst}"
echo

cd $path
rm -rf index_latest.html latest* nagplug.txt php.txt plugin1.txt plugin.txt result.txt reverse.txt index* php.txt year.txt version.txt check_nagios.txt rpm_nagios.txt rpm_nagios_cfg.txt targz.txt wget-log* upgrade-nagios upgrade-plugin 2>/dev/null
exit 0
}

check() {
if [ $? != 0 ]
then
echo
echo "${txtred}I am sorry, I cannot continue the process because there was a problem. Please fix it first. ${txtrst}"
stop
thankyou
fi
}

check_internet () {
echo "${txtylw}I will check whether the server is connected to the internet or not. ${txtrst}"
echo "${txtylw}Please wait a minute ...${txtrst}"
ping -q -c5 google.com >> /dev/null
if [ $? = 0 ]
then
echo "${txtgrn}Great, Your server is connected to the internet${txtrst}"
echo "Your System is Connected to Internet" >> $log 2>/dev/null
sleep 2
echo
else
echo "${txtred}Your server is not connected to the internet so I cannot continue to install Nagios.${txtrst}"
echo "${txtred}Please connect the internet first ...!${txtrst}"
echo "Please connect to the internet ..." >> $log 2>/dev/null
stop
fi
}

check_user () {
echo "${txtylw}Try to guess your account${txtrst}"
sleep 2
user=`whoami`
if [ $user = "root" ]
then
echo "${txtgrn}Good, your account is root${txtrst}"
echo "Your account is root" >> $log 2>/dev/null
echo
else
echo "${txtred}Please change first to root account${txtrst}"
echo "Please change first to root" >> $log 2>/dev/null
stop
fi
sleep 1
}

####################################################################
#  Install Nagios Plugin Function
####################################################################

install_nagios_plugin() {
echo
echo "${txtylw}I will install Nagios Plugins version ${NAGIOS_PLUGINS_VERSION}.${txtrst}"
sleep 2
echo "${txtylw}Downloading Nagios Plugins...${txtrst}"
cd $path
wget --no-check-certificate "${NAGIOS_PLUGINS_URL}" -O ${nagios_plugin}
sleep 2

count=`ls -1 ${nagios_plugin} 2>/dev/null | wc -l`
if [ $count != 0 ]
then
    echo "${txtgrn}Done${txtrst}"
    echo
    echo "${txtylw}Extract package Nagios plugins${txtrst}"
    sleep 2
    tar -zxvf ${nagios_plugin};check
    echo "${txtgrn}Done${txtrst}"
    sleep 2
    echo
    echo "${txtylw}Compile Nagios plugins version ${NAGIOS_PLUGINS_VERSION}${txtrst}"
    sleep 2
    cd ${folder_plugin}
    ./configure --with-nagios-user=nagios --with-nagios-group=nagios;check
    make;check
    make install;check
    echo "${txtgrn}Done${txtrst}"
    sleep 2
    
    echo
    echo "${txtylw}Adding Nagios to the list of system services${txtrst}"
    systemctl enable apache2 2>/dev/null
    systemctl enable nagios 2>/dev/null
    systemctl enable httpd 2>/dev/null
    chkconfig --add nagios 2>/dev/null
    chkconfig --level 345 nagios on 2>/dev/null
    chkconfig --add httpd 2>/dev/null
    chkconfig --level 345 httpd on 2>/dev/null
    echo "${txtgrn}Done${txtrst}"
    
    echo
    echo "${txtylw}Verify Nagios configuration files${txtrst}"
    sleep 2
    /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg;check
    echo "${txtgrn}Done${txtrst}"
    
    echo
    echo "${txtylw}Restarting Nagios Service${txtrst}"
    sleep 1
    systemctl restart nagios.service 2>/dev/null
    service nagios start 2>/dev/null
    echo "${txtgrn}Done${txtrst}"
    echo
    finish
else
    echo "${txtred}Failed to download Nagios Plugins. Please check your internet connection.${txtrst}"
    stop
fi
}

####################################################################
#  Install Nagios Core Functions - CentOS/RHEL
####################################################################

nagioscore_centos() {
echo "${txtylw}Downloading Nagios Core ${NAGIOS_VERSION}...${txtrst}"
sleep 2
cd $path
wget --no-check-certificate "${NAGIOS_URL}" -O ${nagios_core}
sleep 2

count=`ls -1 ${nagios_core} 2>/dev/null | wc -l`
if [ $count != 0 ]
then
    echo "${txtgrn}Done${txtrst}"
    echo
    echo "${txtylw}Extract package Nagios${txtrst}"
    sleep 2
    tar -zxvf ${nagios_core};check
    echo "${txtgrn}Done${txtrst}"
    sleep 2
    
    echo
    echo "${txtylw}Adding user and group for nagios${txtrst}"
    sleep 2
    useradd -m nagios 2>/dev/null
    groupadd nagcmd 2>/dev/null
    usermod -a -G nagcmd nagios
    usermod -a -G nagcmd apache 2>/dev/null
    echo "${txtgrn}Done${txtrst}"
    sleep 2
    
    echo
    echo "${txtylw}Compiling Nagios${txtrst}"
    sleep 2
    cd ${folder_nagios}
    ./configure --with-command-group=nagcmd;check
    make all;check
    make install;check
    make install-init;check
    make install-commandmode;check
    make install-config;check
    make install-webconf;check
    echo "${txtgrn}Done${txtrst}"
    sleep 2
    
    echo
    echo "${txtylw}Creating a NAGIOSADMIN account for logging into the Nagios web interface.${txtrst}"
    echo "${txtylw}Please enter your password below & remember the password you assign to this account.${txtrst}"
    htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin;check
    echo "${txtgrn}Done${txtrst}"
    sleep 2
    
    echo
    echo "${txtylw}Restarting Apache Service${txtrst}"
    sleep 1
    cp /lib/systemd/system/nagios.service /etc/systemd/system 2>/dev/null
    systemctl daemon-reload 2>/dev/null
    systemctl restart httpd 2>/dev/null
    service httpd restart 2>/dev/null
    echo "${txtgrn}Done${txtrst}"
    sleep 2
    
    echo
    echo "${txtgrn}Nagios Core ${NAGIOS_VERSION} has been installed!${txtrst}"
    sleep 2
    install_nagios_plugin
else
    echo "${txtred}Failed to download Nagios Core. Please check your internet connection.${txtrst}"
    stop
fi
}

####################################################################
#  Install Nagios Core Functions - Ubuntu/Debian
####################################################################

nagioscore_ubuntu() {
echo "${txtylw}Downloading Nagios Core ${NAGIOS_VERSION}...${txtrst}"
sleep 2
cd $path
wget --no-check-certificate "${NAGIOS_URL}" -O ${nagios_core}
sleep 2

count=`ls -1 ${nagios_core} 2>/dev/null | wc -l`
if [ $count != 0 ]
then
    echo "${txtgrn}Done${txtrst}"
    echo
    echo "${txtylw}Extract package Nagios${txtrst}"
    sleep 2
    tar -zxvf ${nagios_core};check
    echo "${txtgrn}Done${txtrst}"
    sleep 2
    
    echo
    echo "${txtylw}Adding user and group for nagios${txtrst}"
    sleep 2
    useradd -m nagios 2>/dev/null
    groupadd nagcmd 2>/dev/null
    usermod -a -G nagcmd nagios
    usermod -a -G nagcmd www-data
    echo "${txtgrn}Done${txtrst}"
    sleep 2
    
    echo
    echo "${txtylw}Compiling Nagios${txtrst}"
    sleep 2
    cd ${folder_nagios}
    ./configure --with-command-group=nagcmd --with-httpd-conf=/etc/apache2/sites-enabled;check
    make all;check
    make install;check
    make install-init;check
    make install-daemoninit;check
    make install-config;check
    make install-commandmode;check
    make install-webconf;check
    a2enmod rewrite;check
    a2enmod cgi;check
    echo "${txtgrn}Done${txtrst}"
    sleep 2
    
    echo
    echo "${txtylw}Creating a NAGIOSADMIN account for logging into the Nagios web interface.${txtrst}"
    echo "${txtylw}Please enter your password below & remember the password you assign to this account.${txtrst}"
    htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin;check
    echo "${txtgrn}Done${txtrst}"
    sleep 2
    
    echo
    echo "${txtylw}Restarting Apache Service${txtrst}"
    sleep 1
    systemctl restart apache2 2>/dev/null
    echo "${txtgrn}Done${txtrst}"
    sleep 2
    
    echo
    echo "${txtgrn}Nagios Core ${NAGIOS_VERSION} has been installed!${txtrst}"
    sleep 2
    install_nagios_plugin
else
    echo "${txtred}Failed to download Nagios Core. Please check your internet connection.${txtrst}"
    stop
fi
}

####################################################################
#  Install Nagios Core Functions - openSUSE
####################################################################

nagioscore_suse() {
echo "${txtylw}Downloading Nagios Core ${NAGIOS_VERSION}...${txtrst}"
sleep 2
cd $path
wget --no-check-certificate "${NAGIOS_URL}" -O ${nagios_core}
sleep 2

count=`ls -1 ${nagios_core} 2>/dev/null | wc -l`
if [ $count != 0 ]
then
    echo "${txtgrn}Done${txtrst}"
    echo
    echo "${txtylw}Extract package Nagios${txtrst}"
    sleep 2
    tar -zxvf ${nagios_core};check
    echo "${txtgrn}Done${txtrst}"
    sleep 2
    
    echo
    echo "${txtylw}Adding user and group for nagios${txtrst}"
    sleep 2
    useradd -m nagios 2>/dev/null
    groupadd nagcmd 2>/dev/null
    usermod -a -G nagcmd nagios
    usermod -a -G nagcmd wwwrun
    echo "${txtgrn}Done${txtrst}"
    sleep 2
    
    echo
    echo "${txtylw}Compiling Nagios${txtrst}"
    sleep 2
    cd ${folder_nagios}
    ./configure --with-command-group=nagcmd --with-httpd-conf=/etc/apache2/vhosts.d;check
    make all;check
    make install-groups-users;check
    make install;check
    make install-init;check
    make install-daemoninit;check
    make install-config;check
    make install-commandmode;check
    make install-webconf;check
    /usr/sbin/a2enmod rewrite 2>/dev/null
    /usr/sbin/a2enmod cgi 2>/dev/null
    /usr/sbin/a2enmod version 2>/dev/null
    /usr/sbin/a2enmod php7 2>/dev/null
    echo "${txtgrn}Done${txtrst}"
    sleep 2
    
    echo
    echo "${txtylw}Creating a NAGIOSADMIN account for logging into the Nagios web interface.${txtrst}"
    echo "${txtylw}Please enter your password below & remember the password you assign to this account.${txtrst}"
    htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin;check
    echo "${txtgrn}Done${txtrst}"
    sleep 2
    
    echo
    echo "${txtylw}Restarting Apache Service${txtrst}"
    sleep 1
    firewall-cmd --zone=public --add-port=80/tcp --permanent 2>/dev/null
    firewall-cmd --reload 2>/dev/null
    systemctl restart apache2 2>/dev/null
    echo "${txtgrn}Done${txtrst}"
    sleep 2
    
    echo
    echo "${txtgrn}Nagios Core ${NAGIOS_VERSION} has been installed!${txtrst}"
    sleep 2
    install_nagios_plugin
else
    echo "${txtred}Failed to download Nagios Core. Please check your internet connection.${txtrst}"
    stop
fi
}

####################################################################
#  Install Prerequisites Functions
####################################################################

install_centos() {
# Check Firewall
firewall-cmd --zone=public --add-port=80/tcp --permanent 2>/dev/null
firewall-cmd --reload 2>/dev/null
setenforce 0 2>/dev/null

echo "${txtylw}Installation Some Packages Needed to Install Nagios.${txtrst}"
sleep 1
yum install -y php php-devel php-gd httpd gcc glibc glibc-common gd gd-devel make net-snmp-* wget zip unzip tar;check
sleep 1
echo "${txtgrn}Done${txtrst}"
echo
sleep 2
nagioscore_centos
}

install_ubuntu() {
echo "${txtylw}Installation Some Packages Needed to Install Nagios.${txtrst}"
sleep 1
apt update
apt-get install -y php libgd-dev php-gd autoconf apache2 libapache2-mod-php automake make openssl autoconf gcc libc6 libmcrypt-dev make unzip libssl-dev wget bc gawk dc build-essential snmp libnet-snmp-perl gettext;check
sleep 1
echo "${txtgrn}Done${txtrst}"
echo
sleep 2
nagioscore_ubuntu
}

install_suse() {
echo "${txtylw}Installation Some Packages Needed to Install Nagios.${txtrst}"
sleep 1
zypper --non-interactive install autoconf gcc glibc make wget unzip apache2 apache2-utils php7 apache2-mod_php7 gd gd-devel libopenssl-devel gettext gettext-runtime automake net-snmp perl-Net-SNMP;check
sleep 1
echo "${txtgrn}Done${txtrst}"
echo
sleep 2
nagioscore_suse
}

####################################################################
#  Check Functions for Install
####################################################################

check_packet_centos() {
echo "${txtylw}Try to check existing Nagios${txtrst}"
find / -name nagios.cfg > check_nagios.txt 2>/dev/null
size1=`ls -al check_nagios.txt 2>/dev/null | awk '{print $5}'`
sleep 2

if [ "$size1" != "0" ] && [ -n "$size1" ]
then
    echo "${txtgrn}It looks like you have installed Nagios. ${txtrst}"
    sleep 1
    echo "${txtgrn}Please, delete your Nagios first. ${txtrst}"
    rm -rf check_nagios.txt
    echo
    sleep 2
    exit
else
    echo "${txtcyn}Ok, I will install Nagios in your server as soon as possible. ${txtrst}"
    rm -rf check_nagios.txt
    sleep 2
    echo
    install_centos
fi
}

check_packet_ubuntu() {
echo "${txtylw}Try to check existing Nagios${txtrst}"
find / -name nagios.cfg > check_nagios.txt 2>/dev/null
size1=`ls -al check_nagios.txt 2>/dev/null | awk '{print $5}'`
sleep 2

if [ "$size1" != "0" ] && [ -n "$size1" ]
then
    echo "${txtgrn}It looks like you have installed Nagios. ${txtrst}"
    sleep 1
    echo "${txtgrn}Please, delete your Nagios first. ${txtrst}"
    rm -rf check_nagios.txt
    echo
    sleep 2
    exit
else
    echo "${txtcyn}Ok, I will install Nagios in your server as soon as possible. ${txtrst}"
    rm -rf check_nagios.txt
    sleep 2
    echo
    install_ubuntu
fi
}

check_packet_opensuse() {
echo "${txtylw}Try to check existing Nagios${txtrst}"
find / -name nagios.cfg > check_nagios.txt 2>/dev/null
size1=`ls -al check_nagios.txt 2>/dev/null | awk '{print $5}'`
sleep 2

if [ "$size1" != "0" ] && [ -n "$size1" ]
then
    echo "${txtgrn}It looks like you have installed Nagios. ${txtrst}"
    sleep 1
    echo "${txtgrn}Please, delete your Nagios first. ${txtrst}"
    rm -rf check_nagios.txt
    echo
    sleep 2
    exit
else
    echo "${txtcyn}Ok, I will install Nagios in your server as soon as possible. ${txtrst}"
    rm -rf check_nagios.txt
    sleep 2
    echo
    install_suse
fi
}

check_os() {
echo "${txtylw}Try to guess your operating system${txtrst}"
sleep 2
if [ -f /etc/debian_version ]
then
    echo "${txtgrn}Your Operating System is $(cat /etc/os-release | grep ^NAME | awk 'NR > 1 {print $1}' RS='"' FS='"') $(cat /etc/debian_version)${txtrst}"
    sleep 2
    echo
    check_packet_ubuntu
elif [ -f /etc/redhat-release ]
then
    echo "${txtgrn}Your Operating System is $(cat /etc/redhat-release)${txtrst}"
    sleep 2
    echo
    check_packet_centos
elif [ -f /etc/SUSE-brand ]
then
    echo "${txtgrn}Your Operating System is $(cat /etc/os-release | grep PRETTY_NAME | sed 's/.*=//' | sed 's/^.//' | sed 's/.$//')${txtrst}"
    sleep 2
    echo
    check_packet_opensuse
else
    echo "${txtred}I think your OS is not Debian/Ubuntu or RedHat-Based (CentOS, AlmaLinux, RockyLinux) or openSUSE${txtrst}"
    echo "${txtred}I am sorry, only work on Linux Debian/Ubuntu, RedHat-Based, and openSUSE${txtrst}"
    echo "${txtred}So, I can not install Nagios in your server${txtrst}"
    stop
fi
}

notice() {
echo
sleep 2
echo "${txtbld}The script will install Nagios Core ${NAGIOS_VERSION} from source code with using default folder (/usr/local/nagios)${txtrst}"
sleep 3
echo
echo
}

install_nagios() {
notice
check_internet
check_user
check_os
}

####################################################################
#  Upgrade Nagios Core Functions
####################################################################

upgrade_nagios_centos() {
echo "${txtpur}Check Nagios Core Version${txtrst}"
core_existing_version=`/usr/local/nagios/bin/nagios --help | grep Core | head -n 1 | tr -dc '0-9' | sed 's/.\{1\}/&./g' | sed 's/.$//'`

echo
echo "${txtylw}I will check existing nagios version in your server. Please wait a minute ...${txtrst}"
sleep 2
echo "${txtcyn}Your Nagios version is ${core_existing_version}${txtrst}"
echo
sleep 2
echo "${txtylw}I will check latest nagios version. Please wait a minute ...${txtrst}"
sleep 2
echo "${txtcyn}Latest Nagios version is ${NAGIOS_VERSION}${txtrst}"
sleep 2
echo

# Compare versions (remove dots for numeric comparison)
core_existing=`echo $core_existing_version | tr -d '.'`
core_latest=`echo $NAGIOS_VERSION | tr -d '.'`

if [ "$core_existing" -ge "$core_latest" ] 2>/dev/null
then
    echo "${txtgrn}Your existing Nagios version is up-to-date.${txtrst}"
    echo
    sleep 2
    check_upgrade_plugin
else
    echo "${txtylw}Your existing Nagios version is not up-to-date.${txtrst}"
    while true
    do
        read -p "${txtylw}Are you sure want to update (y/n)? ${txtrst}" answer
        echo
        case $answer in
            [yY]* )
                sleep 2
                echo
                echo "${txtpur}Okay, I will upgrade your nagios version to ${NAGIOS_VERSION}.${txtrst}"
                echo "${txtpur}I will backup your nagios to /usr/local/nagios-backup.${txtrst}"
                sleep 2
                systemctl stop nagios 2>/dev/null
                service nagios stop 2>/dev/null
                cp -rp /usr/local/nagios /usr/local/nagios-backup
                echo
                echo "${txtpur}Okay, I will download Nagios Core ${NAGIOS_VERSION}.${txtrst}"
                sleep 2
                
                mkdir -p upgrade-nagios
                cd upgrade-nagios
                wget --no-check-certificate "${NAGIOS_URL}" -O ${nagios_core}
                
                count=`ls -1 ${nagios_core} 2>/dev/null | wc -l`
                if [ $count != 0 ]
                then
                    sleep 2
                    tar -zxvf ${nagios_core};check
                    cd ${folder_nagios}
                    ./configure --with-command-group=nagcmd;check
                    make all;check
                    make install;check
                    make install-daemoninit 2>/dev/null
                    systemctl daemon-reload 2>/dev/null
                    systemctl start nagios 2>/dev/null
                    service nagios start 2>/dev/null
                    echo
                    echo "${txtpur}Okay, I will check your existing Nagios Core version.${txtrst}"
                    sleep 1
                    /usr/local/nagios/bin/nagios -V | head -n 2
                    sleep 2
                    echo
                    echo "${txtgrn}Your Nagios Core is updated to version ${NAGIOS_VERSION}.${txtrst}"
                    cd $path
                    rm -rf upgrade-nagios
                    echo
                    check_upgrade_plugin
                    sleep 2
                    echo
                    thankyou
                    sleep 2
                    exit
                else
                    echo "${txtred}Failed to download Nagios Core. Please check your internet connection.${txtrst}"
                    stop
                fi
                break;;
            [nN]* )
                sleep 2
                check_upgrade_plugin
                break;;
            * )
                echo "Just enter Y or N, please.";;
        esac
    done
fi
}

upgrade_nagios_ubuntu() {
echo "${txtpur}Check Nagios Core Version${txtrst}"
core_existing_version=`/usr/local/nagios/bin/nagios --help | grep Core | head -n 1 | tr -dc '0-9' | sed 's/.\{1\}/&./g' | sed 's/.$//'`

echo
echo "${txtylw}I will check existing nagios version in your server. Please wait a minute ...${txtrst}"
sleep 2
echo "${txtcyn}Your Nagios version is ${core_existing_version}${txtrst}"
echo
sleep 2
echo "${txtylw}I will check latest nagios version. Please wait a minute ...${txtrst}"
sleep 2
echo "${txtcyn}Latest Nagios version is ${NAGIOS_VERSION}${txtrst}"
sleep 2
echo

# Compare versions
core_existing=`echo $core_existing_version | tr -d '.'`
core_latest=`echo $NAGIOS_VERSION | tr -d '.'`

if [ "$core_existing" -ge "$core_latest" ] 2>/dev/null
then
    echo "${txtgrn}Your existing Nagios version is up-to-date.${txtrst}"
    echo
    sleep 2
    check_upgrade_plugin
else
    echo "${txtylw}Your existing Nagios version is not up-to-date.${txtrst}"
    while true
    do
        read -p "${txtylw}Are you sure want to update (y/n)? ${txtrst}" answer
        echo
        case $answer in
            [yY]* )
                sleep 2
                echo
                echo "${txtpur}Okay, I will upgrade your nagios version to ${NAGIOS_VERSION}.${txtrst}"
                echo "${txtpur}I will backup your nagios to /usr/local/nagios-backup.${txtrst}"
                sleep 2
                systemctl stop nagios 2>/dev/null
                cp -rp /usr/local/nagios /usr/local/nagios-backup
                echo
                echo "${txtpur}Okay, I will download Nagios Core ${NAGIOS_VERSION}.${txtrst}"
                sleep 2
                
                mkdir -p upgrade-nagios
                cd upgrade-nagios
                wget --no-check-certificate "${NAGIOS_URL}" -O ${nagios_core}
                
                count=`ls -1 ${nagios_core} 2>/dev/null | wc -l`
                if [ $count != 0 ]
                then
                    sleep 2
                    tar -zxvf ${nagios_core};check
                    cd ${folder_nagios}
                    ./configure --with-command-group=nagcmd --with-httpd-conf=/etc/apache2/sites-enabled;check
                    make all;check
                    make install;check
                    make install-daemoninit 2>/dev/null
                    systemctl daemon-reload 2>/dev/null
                    systemctl start nagios 2>/dev/null
                    echo
                    echo "${txtpur}Okay, I will check your existing Nagios Core version.${txtrst}"
                    sleep 1
                    /usr/local/nagios/bin/nagios -V | head -n 2
                    sleep 2
                    echo
                    echo "${txtgrn}Your Nagios Core is updated to version ${NAGIOS_VERSION}.${txtrst}"
                    cd $path
                    rm -rf upgrade-nagios
                    echo
                    check_upgrade_plugin
                    sleep 2
                    echo
                    thankyou
                    sleep 2
                    exit
                else
                    echo "${txtred}Failed to download Nagios Core. Please check your internet connection.${txtrst}"
                    stop
                fi
                break;;
            [nN]* )
                sleep 2
                check_upgrade_plugin
                break;;
            * )
                echo "Just enter Y or N, please.";;
        esac
    done
fi
}

upgrade_nagios_suse() {
echo "${txtpur}Check Nagios Core Version${txtrst}"
core_existing_version=`/usr/local/nagios/bin/nagios --help | grep Core | head -n 1 | tr -dc '0-9' | sed 's/.\{1\}/&./g' | sed 's/.$//'`

echo
echo "${txtylw}I will check existing nagios version in your server. Please wait a minute ...${txtrst}"
sleep 2
echo "${txtcyn}Your Nagios version is ${core_existing_version}${txtrst}"
echo
sleep 2
echo "${txtylw}I will check latest nagios version. Please wait a minute ...${txtrst}"
sleep 2
echo "${txtcyn}Latest Nagios version is ${NAGIOS_VERSION}${txtrst}"
sleep 2
echo

# Compare versions
core_existing=`echo $core_existing_version | tr -d '.'`
core_latest=`echo $NAGIOS_VERSION | tr -d '.'`

if [ "$core_existing" -ge "$core_latest" ] 2>/dev/null
then
    echo "${txtgrn}Your existing Nagios version is up-to-date.${txtrst}"
    echo
    sleep 2
    check_upgrade_plugin
else
    echo "${txtylw}Your existing Nagios version is not up-to-date.${txtrst}"
    while true
    do
        read -p "${txtylw}Are you sure want to update (y/n)? ${txtrst}" answer
        echo
        case $answer in
            [yY]* )
                sleep 2
                echo
                echo "${txtpur}Okay, I will upgrade your nagios version to ${NAGIOS_VERSION}.${txtrst}"
                echo "${txtpur}I will backup your nagios to /usr/local/nagios-backup.${txtrst}"
                sleep 2
                systemctl stop nagios 2>/dev/null
                cp -rp /usr/local/nagios /usr/local/nagios-backup
                echo
                echo "${txtpur}Okay, I will download Nagios Core ${NAGIOS_VERSION}.${txtrst}"
                sleep 2
                
                mkdir -p upgrade-nagios
                cd upgrade-nagios
                wget --no-check-certificate "${NAGIOS_URL}" -O ${nagios_core}
                
                count=`ls -1 ${nagios_core} 2>/dev/null | wc -l`
                if [ $count != 0 ]
                then
                    sleep 2
                    tar -zxvf ${nagios_core};check
                    cd ${folder_nagios}
                    ./configure --with-command-group=nagcmd --with-httpd-conf=/etc/apache2/vhosts.d;check
                    make all;check
                    make install;check
                    make install-daemoninit 2>/dev/null
                    systemctl daemon-reload 2>/dev/null
                    systemctl start nagios 2>/dev/null
                    echo
                    echo "${txtpur}Okay, I will check your existing Nagios Core version.${txtrst}"
                    sleep 1
                    /usr/local/nagios/bin/nagios -V | head -n 2
                    sleep 2
                    echo
                    echo "${txtgrn}Your Nagios Core is updated to version ${NAGIOS_VERSION}.${txtrst}"
                    cd $path
                    rm -rf upgrade-nagios
                    echo
                    check_upgrade_plugin
                    sleep 2
                    echo
                    thankyou
                    sleep 2
                    exit
                else
                    echo "${txtred}Failed to download Nagios Core. Please check your internet connection.${txtrst}"
                    stop
                fi
                break;;
            [nN]* )
                sleep 2
                check_upgrade_plugin
                break;;
            * )
                echo "Just enter Y or N, please.";;
        esac
    done
fi
}

####################################################################
#  Upgrade Nagios Plugin Functions
####################################################################

check_upgrade_plugin() {
echo
echo "${txtpur}Check Nagios Plugins version${txtrst}"
existing_plugin=`/usr/local/nagios/libexec/check_ssh -V 2>/dev/null | awk '{print $2}' | sed 's/^v//'`

echo
echo "${txtylw}I will check existing plugin nagios version in your server. Please wait a minute ...${txtrst}"
sleep 2
echo "${txtcyn}Your Nagios Plugins version is ${existing_plugin:-unknown}${txtrst}"
echo
sleep 2
echo "${txtylw}I will check latest plugin nagios version. Please wait a minute ...${txtrst}"
sleep 2
echo "${txtcyn}Latest Nagios Plugins version is ${NAGIOS_PLUGINS_VERSION}${txtrst}"
sleep 2
echo

if [ "$existing_plugin" = "$NAGIOS_PLUGINS_VERSION" ]
then
    echo "${txtgrn}Your existing Nagios Plugins version is up-to-date.${txtrst}"
    echo
    thankyou
    sleep 3
else
    while true
    do
        read -p "${txtylw}Are you sure want to update your Nagios Plugins (y/n)? ${txtrst}" answer
        echo
        case $answer in
            [yY]* )
                sleep 1
                echo
                upgrade_plugin
                break;;
            [nN]* )
                sleep 1
                echo
                thankyou
                sleep 2
                exit
                break;;
            * )
                echo "Just enter Y or N, please.";;
        esac
    done
fi
}

upgrade_plugin() {
echo "${txtpur}Okay, I will upgrade your nagios plugins version to ${NAGIOS_PLUGINS_VERSION}.${txtrst}"
sleep 1
echo "${txtpur}I will backup your nagios to /usr/local/nagios-backup.${txtrst}"
sleep 2
systemctl stop nagios 2>/dev/null
service nagios stop 2>/dev/null
cp -rp /usr/local/nagios /usr/local/nagios-backup 2>/dev/null
echo
echo "${txtpur}Okay, I will download Nagios Plugins ${NAGIOS_PLUGINS_VERSION}.${txtrst}"
sleep 2

mkdir -p upgrade-plugin
cd upgrade-plugin
wget --no-check-certificate "${NAGIOS_PLUGINS_URL}" -O ${nagios_plugin}

count=`ls -1 ${nagios_plugin} 2>/dev/null | wc -l`
if [ $count != 0 ]
then
    sleep 2
    tar -zxvf ${nagios_plugin};check
    cd ${folder_plugin}
    ./configure --with-nagios-user=nagios --with-nagios-group=nagios;check
    make;check
    make install;check
    systemctl start nagios 2>/dev/null
    service nagios start 2>/dev/null
    echo
    echo "${txtpur}Okay, I will check your existing Nagios Plugins version.${txtrst}"
    sleep 1
    /usr/local/nagios/libexec/check_ssh -V 2>/dev/null | head -n 1
    sleep 2
    echo
    echo "${txtgrn}Your Nagios Plugins is updated to version ${NAGIOS_PLUGINS_VERSION}.${txtrst}"
    cd $path
    rm -rf upgrade-plugin
    echo
    thankyou
    sleep 2
    exit
else
    echo "${txtred}Failed to download Nagios Plugins. Please check your internet connection.${txtrst}"
    stop
fi
}

####################################################################
#  Upgrade Main Functions
####################################################################

check_os_upgrade() {
echo "${txtylw}Try to guess your operating system${txtrst}"
sleep 2
if [ -f /etc/debian_version ]
then
    echo "${txtgrn}Your Operating System is $(cat /etc/os-release | grep ^NAME | awk 'NR > 1 {print $1}' RS='"' FS='"') $(cat /etc/debian_version)${txtrst}"
    sleep 2
    echo
    upgrade_nagios_ubuntu
elif [ -f /etc/redhat-release ]
then
    echo "${txtgrn}Your Operating System is $(cat /etc/redhat-release)${txtrst}"
    sleep 2
    echo
    upgrade_nagios_centos
elif [ -f /etc/SUSE-brand ]
then
    echo "${txtgrn}Your Operating System is $(cat /etc/os-release | grep PRETTY_NAME | sed 's/.*=//' | sed 's/^.//' | sed 's/.$//')${txtrst}"
    sleep 2
    echo
    upgrade_nagios_suse
else
    echo "${txtred}I think your OS is not Debian/Ubuntu or RedHat-Based (CentOS, AlmaLinux, RockyLinux, Fedora) or openSUSE${txtrst}"
    echo "${txtred}I am sorry, only work on Linux Debian/Ubuntu, RedHat-Based, and openSUSE${txtrst}"
    echo "${txtred}So, I can not upgrade Nagios in your server${txtrst}"
    stop
fi
}

upgrade_nagios() {
echo "${txtbld}I will continue your request if you have installed Nagios from the source code${txtrst}"
echo "${txtbld}using default folder (/usr/local/nagios) in this server.${txtrst}"
sleep 2
echo
echo "${txtylw}I will check whether Nagios application exists or not.${txtrst}"
echo "${txtylw}Please wait a minute...${txtrst}"
sleep 2

if [ -d "/usr/local/nagios/" ]
then
    echo "${txtgrn}It looks like you have installed Nagios.${txtrst}"
    sleep 2
    echo
    check_user
    check_internet
    check_os_upgrade
else
    sleep 2
    echo "${txtred}It looks like you have not installed Nagios yet or you installed Nagios not from source but using Yum.${txtrst}"
    echo "${txtred}Please install Nagios using source first.${txtrst}"
    echo "${txtred}You have not installed Nagios${txtrst}" >> $log 2>/dev/null
fi
}

####################################################################
#  Install NRPE Functions
####################################################################

install_nrpe_agent() {
echo "${txtylw}Compiling NRPE${txtrst}"
sleep 2
./configure --enable-command-args;check
make all;check
make install-groups-users 2>/dev/null
make install;check
make install-config;check
make install-init;check

echo '# Nagios services' >> /etc/services
echo 'nrpe    5666/tcp' >> /etc/services

echo "${txtgrn}Done${txtrst}"
sleep 2

echo
echo "${txtylw}Starting NRPE service${txtrst}"
systemctl enable nrpe.service 2>/dev/null
systemctl start nrpe.service 2>/dev/null
echo "${txtgrn}Done${txtrst}"
sleep 2

echo
echo "${txtgrn}NRPE plugin has been installed in your server.${txtrst}"
sleep 2
echo
echo "${txtylw}Testing NRPE service${txtrst}"
sleep 2
echo
echo "${txtblu}/usr/local/nagios/libexec/check_nrpe -H 127.0.0.1${txtrst}"
/usr/local/nagios/libexec/check_nrpe -H 127.0.0.1 2>/dev/null
sleep 2
echo
echo "${txtgrn}NRPE plugin has been installed${txtrst}"
sleep 2
echo
echo "${txtylw}If you want your server to be monitored by the Nagios server,${txtrst}"
echo "${txtylw}add IP address of Nagios server to /usr/local/nagios/etc/nrpe.cfg${txtrst}"
echo "${txtylw}in the allowed_hosts section then restart nrpe:${txtrst}"
echo "${txtblu}systemctl restart nrpe${txtrst}"
sleep 3
thankyou
}

download_nrpe() {
cd $path
echo "${txtylw}Downloading NRPE...${txtrst}"
sleep 2
wget --no-check-certificate https://github.com/NagiosEnterprises/nrpe/archive/nrpe-${NRPE_VERSION}.tar.gz -O nrpe-${NRPE_VERSION}.tar.gz

count=`ls -1 nrpe-${NRPE_VERSION}.tar.gz 2>/dev/null | wc -l`
if [ $count != 0 ]; then
    echo "${txtgrn}Done${txtrst}"
    echo
    echo "${txtylw}Extract package NRPE${txtrst}"
    tar -zxvf nrpe-${NRPE_VERSION}.tar.gz;check
    echo "${txtgrn}Done${txtrst}"
    sleep 2
    cd nrpe-nrpe-${NRPE_VERSION}
    install_nrpe_agent
else
    echo "${txtred}Failed to download NRPE. Please check your internet connection.${txtrst}"
    stop
fi
}

nrpe_agent_install() {
echo
echo "${txtylw}Installing Nagios Plugin first.${txtrst}"
echo "${txtylw}Installing required packages...${txtrst}"
sleep 2

if [ -f /etc/redhat-release ]; then
    yum install -y gcc glibc glibc-common openssl openssl-devel perl make gettext automake wget net-snmp net-snmp-utils epel-release perl-Net-SNMP
elif [ -f /etc/debian_version ]; then
    apt-get install -y autoconf unzip automake make openssl gcc libc6 libmcrypt-dev libssl-dev wget bc gawk dc build-essential snmp libnet-snmp-perl gettext
elif [ -f /etc/SUSE-brand ]; then
    zypper --non-interactive install autoconf gcc glibc libtomcrypt-devel make libopenssl-devel wget gettext gettext-runtime automake net-snmp perl-Net-SNMP
else
    echo "${txtred}Unsupported operating system for NRPE installation${txtrst}"
    stop
fi

echo "${txtgrn}Done${txtrst}"
sleep 2

echo
echo "${txtylw}Downloading Nagios Plugin...${txtrst}"
wget --no-check-certificate "${NAGIOS_PLUGINS_URL}" -O ${nagios_plugin}
sleep 2
echo "${txtgrn}Done${txtrst}"

count=`ls -1 ${nagios_plugin} 2>/dev/null | wc -l`
if [ $count != 0 ]; then
    echo
    echo "${txtylw}Extract Nagios Plugin${txtrst}"
    tar -zxvf ${nagios_plugin};check
    echo "${txtgrn}Done${txtrst}"
    
    cd ${folder_plugin}
    ./configure;check
    make;check
    make install;check
    echo "${txtgrn}Done${txtrst}"
    
    cd $path
    download_nrpe
else
    echo "${txtred}Failed to download Nagios Plugins.${txtrst}"
    stop
fi
}

install_nrpe_centos() {
echo "${txtylw}I will check whether Nagios application exists or not.${txtrst}"
sleep 2

if [ -d "/usr/local/nagios/" ]; then
    echo "${txtgrn}It looks like you have installed Nagios.${txtrst}"
    sleep 2
    echo
    download_nrpe
else
    echo
    echo "${txtylw}Nagios is not installed. Installing NRPE agent for client monitoring.${txtrst}"
    sleep 2
    nrpe_agent_install
fi
}

check_os_nrpe() {
echo "${txtylw}Try to guess your operating system${txtrst}"
sleep 2
if [ -f /etc/debian_version ]; then
    echo "${txtgrn}Your Operating System is $(cat /etc/os-release | grep ^NAME | awk 'NR > 1 {print $1}' RS='"' FS='"') $(cat /etc/debian_version)${txtrst}"
elif [ -f /etc/redhat-release ]; then
    echo "${txtgrn}Your Operating System is $(cat /etc/redhat-release)${txtrst}"
elif [ -f /etc/SUSE-brand ]; then
    echo "${txtgrn}Your Operating System is $(cat /etc/os-release | grep PRETTY_NAME | sed 's/.*=//' | sed 's/^.//' | sed 's/.$//')${txtrst}"
else
    echo "${txtred}Unsupported operating system${txtrst}"
    stop
fi
sleep 2
echo
install_nrpe_centos
}

install_nrpe() {
sleep 2
check_user
check_internet
check_os_nrpe
}

####################################################################
#  Delete Nagios Functions
####################################################################

delete_nagios_default() {
echo "${txtylw}Please backup your Nagios configuration first.${txtrst}"
echo "${txtylw}Press any key to continue...${txtrst}"
read -n 1 -s -r
echo
sleep 1
echo
echo "${txtylw}I will start to remove Nagios from your server.${txtrst}"
sleep 2
echo
echo "${txtylw}Stopping nagios service${txtrst}"
systemctl stop nagios.service 2>/dev/null
service nagios stop 2>/dev/null
sleep 1
echo "${txtgrn}Done${txtrst}"
sleep 2
echo
echo "${txtylw}Deleting user and group nagios${txtrst}"
userdel nagios 2>/dev/null
groupdel nagcmd 2>/dev/null
sleep 2
echo "${txtgrn}Done${txtrst}"
echo
sleep 1
echo "${txtylw}Deleting nagios folder${txtrst}"
rm -rf /usr/local/nagios
rm -rf /etc/systemd/system/nagios.service
rm -rf /etc/httpd/conf.d/nagios.conf
rm -rf /etc/apache2/sites-enabled/nagios.conf
rm -rf /etc/apache2/vhosts.d/nagios.conf
systemctl daemon-reload 2>/dev/null
sleep 2
echo "${txtgrn}Done${txtrst}"
sleep 2
echo
echo "${txtgrn}Nagios has been removed from your server.${txtrst}"
sleep 3
thankyou
}

delete_nagios_rpm() {
echo "${txtylw}Please backup your Nagios configuration first.${txtrst}"
echo "${txtylw}Press any key to continue...${txtrst}"
read -n 1 -s -r
echo
sleep 1
echo
echo "${txtylw}I will start to remove Nagios from your server.${txtrst}"
sleep 2
echo
echo "${txtylw}Stopping nagios service${txtrst}"
systemctl stop nagios.service 2>/dev/null
service nagios stop 2>/dev/null
sleep 1
echo "${txtgrn}Done${txtrst}"
sleep 2
echo
echo "${txtylw}Deleting user and group nagios${txtrst}"
userdel nagios 2>/dev/null
groupdel nagcmd 2>/dev/null
sleep 2
echo "${txtgrn}Done${txtrst}"
echo
sleep 1
echo "${txtylw}Removing Nagios Packages${txtrst}"
apt-get remove -y nagios* 2>/dev/null
yum remove -y nagios* 2>/dev/null
zypper remove -y nagios 2>/dev/null
sleep 2
echo "${txtgrn}Done${txtrst}"
echo
echo "${txtylw}Deleting nagios folders${txtrst}"
rm -rf /usr/local/nagios
rm -rf /etc/nagios
systemctl daemon-reload 2>/dev/null
sleep 2
echo "${txtgrn}Done${txtrst}"
sleep 2
echo
echo "${txtgrn}Nagios has been removed from your server.${txtrst}"
sleep 3
thankyou
}

check_delete() {
if [ -d "/usr/local/nagios/" ]; then
    echo "${txtgrn}It looks like you have installed Nagios using source code.${txtrst}"
    sleep 2
    echo
    delete_nagios_default
else
    rpm -qa 2>/dev/null | grep nagios > rpm_nagios.txt
    apt list --installed 2>/dev/null | grep nagios >> rpm_nagios.txt
    size=`ls -al rpm_nagios.txt 2>/dev/null | awk '{print $5}'`
    
    if [ "$size" != "0" ] && [ -n "$size" ]; then
        echo "${txtgrn}It looks like you have installed Nagios with package manager.${txtrst}"
        sleep 2
        rm -rf rpm_nagios.txt
        echo
        delete_nagios_rpm
    else
        echo "${txtred}It looks like you have not installed Nagios yet.${txtrst}"
        rm -rf rpm_nagios.txt
    fi
fi
}

check_os_delete() {
echo "${txtylw}Try to guess your operating system${txtrst}"
sleep 2
if [ -f /etc/debian_version ]; then
    echo "${txtgrn}Your Operating System is $(cat /etc/os-release | grep ^NAME | awk 'NR > 1 {print $1}' RS='"' FS='"') $(cat /etc/debian_version)${txtrst}"
elif [ -f /etc/redhat-release ]; then
    echo "${txtgrn}Your Operating System is $(cat /etc/redhat-release)${txtrst}"
elif [ -f /etc/SUSE-brand ]; then
    echo "${txtgrn}Your Operating System is $(cat /etc/os-release | grep PRETTY_NAME | sed 's/.*=//' | sed 's/^.//' | sed 's/.$//')${txtrst}"
else
    echo "${txtred}Unsupported operating system${txtrst}"
    stop
fi
sleep 2
echo
echo "${txtylw}I will check whether Nagios application exists or not${txtrst}"
sleep 2
check_delete
}

delete_nagios() {
check_user
check_os_delete
}

####################################################################
#  Main Menu
####################################################################

echo "What do you want from me?"
echo "${txtgrn}1. Install Nagios (version ${NAGIOS_VERSION})${txtrst}"
echo "${txtylw}2. Upgrade Nagios${txtrst}"
echo "${txtblu}3. Install NRPE${txtrst}"
echo "${txtred}4. Delete Nagios${txtrst}"
echo -n "Enter Your choice: "
read PILIHAN
echo
case $PILIHAN in
1)
install_nagios ;;
2)
upgrade_nagios ;;
3)
install_nrpe ;;
4)
delete_nagios ;;
*)
echo "${txtred}Enter the wrong number and exit the program${txtrst}"
echo;;
esac
