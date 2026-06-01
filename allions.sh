#!/usr/bin/env bash
#
##########################################################################################################################
#
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
# File   : allion.sh : A simple shell script to Install Nagios Monitoring Tool.
# Refactor: 2026 - Single parametrized install/upgrade path, automatic latest-version
#           detection via GitHub, proper TLS, sort -V version compare, contained build
#           directory, and corrected error handling. Pinned fallback versions updated to
#           Nagios Core 4.5.13 / Nagios Plugins 2.5 / NRPE 4.1.3.
#
##########################################################################################################################

# Use a sane shell setup. We deliberately avoid `set -e` because many commands below
# are expected to "fail" harmlessly (they are guarded with 2>/dev/null and per-distro
# fallbacks). Errors that matter are caught explicitly by check()/run().
set -o pipefail

############ Text color variables ############
if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
    txtbld=$(tput bold)
    txtred=$(tput setaf 1)
    txtgrn=$(tput setaf 2)
    txtylw=$(tput setaf 3)
    txtblu=$(tput setaf 4)
    txtcyn=$(tput setaf 6)
    txtrst=$(tput sgr0)
else
    txtbld="" ; txtred="" ; txtgrn="" ; txtylw="" ; txtblu=""; txtcyn="" ; txtrst=""
fi

############ Pinned fallback versions (used if auto-detection fails) ############
# These are overwritten by detect_versions() when the server can reach GitHub.
NAGIOS_VERSION="4.5.13"
NAGIOS_PLUGINS_VERSION="2.5"
NRPE_VERSION="4.1.3"

# Set to "no" to skip querying GitHub for the newest release and use the pinned values above.
AUTO_DETECT_LATEST="yes"

############ Globals ############
LOG="/tmp/nagios_setup.log"
NAGIOS_HOME="/usr/local/nagios"
# A private build directory; cleaned up automatically on exit. Nothing outside it is touched.
WORKDIR="$(mktemp -d /tmp/allion.XXXXXX)"

# Distro-dependent values, populated by detect_os().
OS_FAMILY=""          # debian | rhel | suse
PKG_INSTALL=""        # full package-install command
APACHE_USER=""        # www-data | apache | wwwrun
APACHE_SVC=""         # apache2 | httpd
HTTPD_CONF_FLAG=""    # extra ./configure flag for the web config location

cleanup() { rm -rf "$WORKDIR" 2>/dev/null; }
trap cleanup EXIT

############ Output helpers ############
say()  { echo "${txtylw}$*${txtrst}"; }
ok()   { echo "${txtgrn}$*${txtrst}"; }
warn() { echo "${txtylw}${txtbld}$*${txtrst}"; }
err()  { echo "${txtred}$*${txtrst}"; }
note() { echo "${txtcyn}$*${txtrst}"; }
log()  { echo "$*" >> "$LOG" 2>/dev/null; }

banner() {
    echo
    echo "#############################################################"
    echo "##${txtgrn}         Welcome To All In One Nagios (AllION) Script${txtrst}    ##"
    echo "##                  Created By sysnote                     ##"
    echo "##          ${txtylw}       sysnotecom@gmail.com   ${txtrst}                 ##"
    echo "#############################################################"
    echo
}

thankyou() {
    echo
    echo "#############################################################"
    echo "##${txtgrn}  Thank You for using All In One Nagios (AllION) Script${txtrst}  ##"
    echo "##                  Created By sysnote                     ##"
    echo "##          ${txtylw}       sysnotecom@gmail.com   ${txtrst}                 ##"
    echo "#############################################################"
    echo
}

# Abort cleanly. The EXIT trap removes the build directory.
die() {
    err "I am sorry, I cannot continue because there was a problem: $*"
    log "ABORT: $*"
    thankyou
    exit 1
}

# Check the exit status of the immediately preceding command.
check() {
    local rc=$?
    [ "$rc" -eq 0 ] || die "previous step exited with status $rc"
}

# Run a command and abort with a clear message if it fails.
run() {
    "$@" || die "command failed: $*"
}

############ Pre-flight checks ############

require_root() {
    say "Checking your account..."
    if [ "$(id -u)" -eq 0 ]; then
        ok "Good, you are running as root."
        log "Running as root"
    else
        die "Please run this script as root (try: sudo $0)."
    fi
}

check_internet() {
    say "Checking internet connectivity, please wait..."
    if   command -v curl >/dev/null 2>&1 && curl -fsSL --max-time 15 -o /dev/null https://github.com; then :
    elif command -v wget >/dev/null 2>&1 && wget -q --timeout=15 -O /dev/null https://github.com; then :
    elif ping -q -c2 -W3 github.com >/dev/null 2>&1; then :
    else
        die "This server does not appear to have internet access. Please connect it first."
    fi
    ok "Great, your server is connected to the internet."
    log "Internet connectivity OK"
}

############ Version helpers ############

# Print the tag_name of the latest GitHub release for owner/repo (empty on failure).
gh_latest_tag() {
    local repo="$1"
    command -v curl >/dev/null 2>&1 || return 0
    curl -fsSL --max-time 15 "https://api.github.com/repos/${repo}/releases/latest" 2>/dev/null \
        | grep -m1 '"tag_name"' \
        | sed -E 's/.*"tag_name"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/'
}

# Return 0 (true) if version $1 >= version $2 (proper semantic comparison).
version_ge() {
    [ "$1" = "$2" ] && return 0
    [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]
}

detect_versions() {
    [ "$AUTO_DETECT_LATEST" = "yes" ] || { note "Auto-detect disabled; using pinned versions."; return; }
    say "Looking up the newest available releases on GitHub..."
    local t
    t=$(gh_latest_tag NagiosEnterprises/nagioscore);     [ -n "$t" ] && NAGIOS_VERSION="${t#nagios-}"
    t=$(gh_latest_tag nagios-plugins/nagios-plugins);    [ -n "$t" ] && NAGIOS_PLUGINS_VERSION="${t#release-}"
    t=$(gh_latest_tag NagiosEnterprises/nrpe);           [ -n "$t" ] && NRPE_VERSION="${t#nrpe-}"
    note "Target versions -> Nagios Core ${NAGIOS_VERSION}, Plugins ${NAGIOS_PLUGINS_VERSION}, NRPE ${NRPE_VERSION}"
}

# Derived download URLs / paths (call after versions are finalized).
set_urls() {
    NAGIOS_TGZ="nagios-${NAGIOS_VERSION}.tar.gz"
    NAGIOS_DIR="nagios-${NAGIOS_VERSION}"
    NAGIOS_URL="https://github.com/NagiosEnterprises/nagioscore/releases/download/nagios-${NAGIOS_VERSION}/${NAGIOS_TGZ}"

    PLUGIN_TGZ="nagios-plugins-${NAGIOS_PLUGINS_VERSION}.tar.gz"
    PLUGIN_DIR="nagios-plugins-${NAGIOS_PLUGINS_VERSION}"
    PLUGIN_URL="https://github.com/nagios-plugins/nagios-plugins/releases/download/release-${NAGIOS_PLUGINS_VERSION}/${PLUGIN_TGZ}"

    NRPE_TGZ="nrpe-${NRPE_VERSION}.tar.gz"
    NRPE_DIR="nrpe-${NRPE_VERSION}"
    NRPE_URL="https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-${NRPE_VERSION}/${NRPE_TGZ}"
}

# Read the currently installed Nagios Core version (empty if not installed).
installed_core_version() {
    [ -x "${NAGIOS_HOME}/bin/nagios" ] || return 0
    "${NAGIOS_HOME}/bin/nagios" --version 2>/dev/null \
        | grep -oE '[0-9]+(\.[0-9]+)+' | head -n1
}

# Read the currently installed Nagios Plugins version (empty if unknown).
installed_plugin_version() {
    [ -x "${NAGIOS_HOME}/libexec/check_nagios" ] || [ -x "${NAGIOS_HOME}/libexec/check_ssh" ] || return 0
    "${NAGIOS_HOME}/libexec/check_nagios" --version 2>/dev/null \
        | grep -oE '[0-9]+(\.[0-9]+)+' | head -n1
}

# Download $1 to $WORKDIR/$2 over HTTPS with certificate verification.
download() {
    local url="$1" out="$2"
    say "Downloading ${out}..."
    ( cd "$WORKDIR" && run curl -fSL --retry 3 -o "$out" "$url" )
    [ -s "${WORKDIR}/${out}" ] || die "download produced an empty file: ${out}"
    ok "Done"
}

############ OS detection ############

detect_os() {
    say "Detecting your operating system..."
    if [ -f /etc/debian_version ]; then
        OS_FAMILY="debian"
        ok "Operating System: Debian/Ubuntu family"
        APACHE_USER="www-data"
        APACHE_SVC="apache2"
        HTTPD_CONF_FLAG="--with-httpd-conf=/etc/apache2/sites-enabled"
        PKG_INSTALL="apt-get install -y php libgd-dev php-gd autoconf apache2 apache2-utils libapache2-mod-php automake make openssl gcc libc6 libssl-dev wget curl unzip bc gawk dc build-essential snmp libnet-snmp-perl gettext"
    elif [ -f /etc/redhat-release ]; then
        OS_FAMILY="rhel"
        ok "Operating System: $(cat /etc/redhat-release)"
        APACHE_USER="apache"
        APACHE_SVC="httpd"
        HTTPD_CONF_FLAG=""   # RHEL webconf default: /etc/httpd/conf.d
        local pm="yum"
        command -v dnf >/dev/null 2>&1 && pm="dnf"
        PKG_INSTALL="$pm install -y php php-gd httpd httpd-tools gcc glibc glibc-common gd gd-devel make automake autoconf net-snmp net-snmp-utils openssl openssl-devel perl wget curl unzip tar gettext"
    elif [ -f /etc/SUSE-brand ] || [ -f /etc/SuSE-release ]; then
        OS_FAMILY="suse"
        ok "Operating System: openSUSE family"
        APACHE_USER="wwwrun"
        APACHE_SVC="apache2"
        HTTPD_CONF_FLAG="--with-httpd-conf=/etc/apache2/vhosts.d"
        PKG_INSTALL="zypper --non-interactive install autoconf gcc glibc make wget curl unzip apache2 apache2-utils php8 apache2-mod_php8 gd gd-devel libopenssl-devel gettext gettext-runtime automake net-snmp perl-Net-SNMP"
    else
        die "Unsupported OS. This script supports Debian/Ubuntu, RHEL-based (CentOS/AlmaLinux/Rocky), and openSUSE only."
    fi
}

############ SELinux / firewall (explicit, never silent) ############

handle_selinux() {
    command -v getenforce >/dev/null 2>&1 || return 0
    if [ "$(getenforce 2>/dev/null)" = "Enforcing" ]; then
        warn "SELinux is in ENFORCING mode and may block the Nagios web interface."
        warn "Setting SELinux to PERMISSIVE for THIS BOOT ONLY (not persistent)."
        warn "To re-enable now:        setenforce 1"
        warn "For a proper persistent policy, see the Nagios SELinux documentation."
        setenforce 0 2>/dev/null
        log "SELinux set to permissive (temporary)"
    fi
}

open_firewall() {
    if command -v firewall-cmd >/dev/null 2>&1; then
        say "Opening TCP port 80 in firewalld..."
        firewall-cmd --zone=public --add-port=80/tcp --permanent >/dev/null 2>&1
        firewall-cmd --reload >/dev/null 2>&1
    fi
}

############ Install: prerequisites ############

install_prereqs() {
    say "Installing the packages required to build Nagios..."
    if [ "$OS_FAMILY" = "debian" ]; then
        apt-get update
    fi
    run eval "$PKG_INSTALL"
    ok "Done"
}

############ Install: users and groups ############

create_users() {
    say "Creating the nagios user and nagcmd group..."
    useradd -m nagios 2>/dev/null
    groupadd nagcmd 2>/dev/null
    usermod -a -G nagcmd nagios 2>/dev/null
    # Add the web server user to nagcmd so the CGIs can write to the command file.
    usermod -a -G nagcmd "$APACHE_USER" 2>/dev/null
    ok "Done"
}

############ Install: Nagios Core ############

build_nagios_core() {
    download "$NAGIOS_URL" "$NAGIOS_TGZ"
    say "Extracting Nagios Core..."
    run tar -xzf "${WORKDIR}/${NAGIOS_TGZ}" -C "$WORKDIR"
    ok "Done"

    create_users

    say "Compiling Nagios Core ${NAGIOS_VERSION}..."
    cd "${WORKDIR}/${NAGIOS_DIR}" || die "cannot enter ${NAGIOS_DIR}"
    # shellcheck disable=SC2086
    run ./configure --with-command-group=nagcmd $HTTPD_CONF_FLAG
    run make all
    # install-groups-users is a no-op on older trees; ignore if absent.
    make install-groups-users 2>/dev/null
    run make install
    # Prefer the systemd unit target; fall back to the SysV init target.
    make install-daemoninit 2>/dev/null || make install-init 2>/dev/null
    run make install-commandmode
    run make install-config
    run make install-webconf
    ok "Done"

    if [ "$OS_FAMILY" = "debian" ] || [ "$OS_FAMILY" = "suse" ]; then
        a2enmod rewrite 2>/dev/null
        a2enmod cgi 2>/dev/null
    fi

    say "Creating the nagiosadmin web login. Please choose and remember a password."
    run htpasswd -c "${NAGIOS_HOME}/etc/htpasswd.users" nagiosadmin
    ok "Done"

    systemctl daemon-reload 2>/dev/null
    say "Enabling and restarting the web server..."
    systemctl enable "$APACHE_SVC" 2>/dev/null
    systemctl restart "$APACHE_SVC" 2>/dev/null
    ok "Nagios Core ${NAGIOS_VERSION} installed."
}

############ Install: Nagios Plugins ############

build_nagios_plugins() {
    download "$PLUGIN_URL" "$PLUGIN_TGZ"
    say "Extracting Nagios Plugins..."
    run tar -xzf "${WORKDIR}/${PLUGIN_TGZ}" -C "$WORKDIR"
    ok "Done"

    say "Compiling Nagios Plugins ${NAGIOS_PLUGINS_VERSION}..."
    cd "${WORKDIR}/${PLUGIN_DIR}" || die "cannot enter ${PLUGIN_DIR}"
    run ./configure --with-nagios-user=nagios --with-nagios-group=nagios
    run make
    run make install
    ok "Done"

    say "Enabling the Nagios service..."
    systemctl enable nagios 2>/dev/null
    ok "Done"

    say "Verifying the Nagios configuration..."
    run "${NAGIOS_HOME}/bin/nagios" -v "${NAGIOS_HOME}/etc/nagios.cfg"
    ok "Done"

    say "Starting Nagios..."
    systemctl restart nagios 2>/dev/null || service nagios start 2>/dev/null
    ok "Done"
}

############ Install: orchestration ############

finish_install() {
    ok "Congratulations, the Nagios installation completed successfully."
    log "Installation completed successfully"
    echo
    note "Web interface URL          : http://localhost/nagios  or  http://<server-ip>/nagios"
    note "Web interface username     : nagiosadmin"
    note "Install directory          : ${NAGIOS_HOME}/"
    note "Main configuration file    : ${NAGIOS_HOME}/etc/nagios.cfg"
    note "Object configuration files : ${NAGIOS_HOME}/etc/objects/"
    case "$OS_FAMILY" in
        rhel)   note "Apache config              : /etc/httpd/conf.d/nagios.conf" ;;
        debian) note "Apache config              : /etc/apache2/sites-enabled/nagios.conf" ;;
        suse)   note "Apache config              : /etc/apache2/vhosts.d/nagios.conf" ;;
    esac
    echo
    note "Nagios Core version : $(installed_core_version)"
    note "Plugins version     : $(installed_plugin_version)"
    echo
    warn "If the web UI is unreachable, check that the firewall and/or SELinux are not blocking it."
    err  "Remember to set your contacts in ${NAGIOS_HOME}/etc/objects/contacts.cfg"
    err  "Installation log: ${LOG}"
    thankyou
}

do_install() {
    if [ -d "$NAGIOS_HOME" ] || find / -name nagios.cfg -print -quit 2>/dev/null | grep -q .; then
        warn "It looks like Nagios is already installed. Please remove it first (menu option 4)."
        exit 0
    fi
    note "This will build Nagios Core ${NAGIOS_VERSION} from source into ${NAGIOS_HOME}."
    require_root
    check_internet
    detect_versions
    set_urls
    detect_os
    handle_selinux
    open_firewall
    install_prereqs
    build_nagios_core
    build_nagios_plugins
    finish_install
}

############ Upgrade ############

do_upgrade() {
    note "This upgrades a source-based install located at ${NAGIOS_HOME}."
    require_root
    if [ ! -d "$NAGIOS_HOME" ]; then
        die "Nagios was not found at ${NAGIOS_HOME}. This option only upgrades source installs."
    fi
    check_internet
    detect_versions
    set_urls
    detect_os

    local cur_core
    cur_core="$(installed_core_version)"
    note "Installed Nagios Core : ${cur_core:-unknown}"
    note "Latest  Nagios Core   : ${NAGIOS_VERSION}"

    if [ -n "$cur_core" ] && version_ge "$cur_core" "$NAGIOS_VERSION"; then
        ok "Nagios Core is already up to date."
    else
        if confirm "Upgrade Nagios Core to ${NAGIOS_VERSION}?"; then
            say "Backing up ${NAGIOS_HOME} to ${NAGIOS_HOME}-backup ..."
            systemctl stop nagios 2>/dev/null || service nagios stop 2>/dev/null
            run cp -rp "$NAGIOS_HOME" "${NAGIOS_HOME}-backup"
            download "$NAGIOS_URL" "$NAGIOS_TGZ"
            run tar -xzf "${WORKDIR}/${NAGIOS_TGZ}" -C "$WORKDIR"
            cd "${WORKDIR}/${NAGIOS_DIR}" || die "cannot enter ${NAGIOS_DIR}"
            # shellcheck disable=SC2086
            run ./configure --with-command-group=nagcmd $HTTPD_CONF_FLAG
            run make all
            run make install
            make install-daemoninit 2>/dev/null || make install-init 2>/dev/null
            systemctl daemon-reload 2>/dev/null
            systemctl start nagios 2>/dev/null || service nagios start 2>/dev/null
            ok "Nagios Core upgraded to $(installed_core_version)."
        fi
    fi

    local cur_plugin
    cur_plugin="$(installed_plugin_version)"
    echo
    note "Installed Plugins : ${cur_plugin:-unknown}"
    note "Latest  Plugins   : ${NAGIOS_PLUGINS_VERSION}"

    if [ -n "$cur_plugin" ] && version_ge "$cur_plugin" "$NAGIOS_PLUGINS_VERSION"; then
        ok "Nagios Plugins are already up to date."
    elif confirm "Upgrade Nagios Plugins to ${NAGIOS_PLUGINS_VERSION}?"; then
        systemctl stop nagios 2>/dev/null || service nagios stop 2>/dev/null
        download "$PLUGIN_URL" "$PLUGIN_TGZ"
        run tar -xzf "${WORKDIR}/${PLUGIN_TGZ}" -C "$WORKDIR"
        cd "${WORKDIR}/${PLUGIN_DIR}" || die "cannot enter ${PLUGIN_DIR}"
        run ./configure --with-nagios-user=nagios --with-nagios-group=nagios
        run make
        run make install
        systemctl start nagios 2>/dev/null || service nagios start 2>/dev/null
        ok "Nagios Plugins upgraded to $(installed_plugin_version)."
    fi

    thankyou
}

############ NRPE ############

do_nrpe() {
    require_root
    check_internet
    detect_versions
    set_urls
    detect_os

    if [ ! -d "$NAGIOS_HOME" ]; then
        warn "Nagios is not installed here; installing the Nagios Plugins first (needed by NRPE)."
        install_prereqs
        download "$PLUGIN_URL" "$PLUGIN_TGZ"
        run tar -xzf "${WORKDIR}/${PLUGIN_TGZ}" -C "$WORKDIR"
        cd "${WORKDIR}/${PLUGIN_DIR}" || die "cannot enter ${PLUGIN_DIR}"
        run ./configure
        run make
        run make install
    fi

    download "$NRPE_URL" "$NRPE_TGZ"
    say "Extracting NRPE..."
    run tar -xzf "${WORKDIR}/${NRPE_TGZ}" -C "$WORKDIR"
    ok "Done"

    say "Compiling NRPE ${NRPE_VERSION}..."
    cd "${WORKDIR}/${NRPE_DIR}" || die "cannot enter ${NRPE_DIR}"
    run ./configure --enable-command-args
    run make all
    make install-groups-users 2>/dev/null
    run make install
    run make install-config
    make install-init 2>/dev/null || make install-daemoninit 2>/dev/null
    ok "Done"

    # Register the NRPE service port only if it isn't already present.
    if ! grep -q '^nrpe' /etc/services 2>/dev/null; then
        {
            echo '# Nagios services'
            echo 'nrpe    5666/tcp'
        } >> /etc/services
    fi

    say "Enabling and starting the NRPE service..."
    systemctl enable nrpe 2>/dev/null
    systemctl start nrpe 2>/dev/null
    ok "Done"

    echo
    say "Testing NRPE locally:"
    note "${NAGIOS_HOME}/libexec/check_nrpe -H 127.0.0.1"
    "${NAGIOS_HOME}/libexec/check_nrpe" -H 127.0.0.1 2>/dev/null
    echo
    warn "To allow your Nagios server to query this host, add its IP to the allowed_hosts"
    warn "line in ${NAGIOS_HOME}/etc/nrpe.cfg and then run: systemctl restart nrpe"
    thankyou
}

############ Delete ############

do_delete() {
    require_root
    detect_os
    echo
    warn "Please make sure you have backed up your Nagios configuration."
    confirm "Continue removing Nagios from this server?" || { thankyou; exit 0; }

    say "Stopping the Nagios service..."
    systemctl stop nagios 2>/dev/null || service nagios stop 2>/dev/null
    ok "Done"

    say "Removing the nagios user and nagcmd group..."
    userdel nagios 2>/dev/null
    groupdel nagcmd 2>/dev/null
    ok "Done"

    if [ -d "$NAGIOS_HOME" ]; then
        say "Removing the source install..."
        rm -rf "$NAGIOS_HOME"
        rm -f /etc/systemd/system/nagios.service \
              /lib/systemd/system/nagios.service \
              /etc/httpd/conf.d/nagios.conf \
              /etc/apache2/sites-enabled/nagios.conf \
              /etc/apache2/vhosts.d/nagios.conf
    else
        say "Removing packaged Nagios (if any)..."
        case "$OS_FAMILY" in
            debian) apt-get remove -y 'nagios*' 2>/dev/null ;;
            rhel)   { command -v dnf >/dev/null 2>&1 && dnf remove -y 'nagios*'; } 2>/dev/null || yum remove -y 'nagios*' 2>/dev/null ;;
            suse)   zypper --non-interactive remove 'nagios*' 2>/dev/null ;;
        esac
        rm -rf /etc/nagios
    fi
    systemctl daemon-reload 2>/dev/null
    ok "Nagios has been removed from your server."
    thankyou
}

############ Small interactive helper ############

# Ask a yes/no question; return 0 for yes, 1 for no.
confirm() {
    local prompt="$1" answer
    while true; do
        read -r -p "${txtylw}${prompt} (y/n)? ${txtrst}" answer
        case "$answer" in
            [yY]|[yY][eE][sS]) return 0 ;;
            [nN]|[nN][oO])     return 1 ;;
            *) echo "Please enter Y or N." ;;
        esac
    done
}

############ Main menu ############

clear
banner
echo "What would you like to do?"
echo "${txtgrn}1. Install Nagios (latest, currently ${NAGIOS_VERSION})${txtrst}"
echo "${txtylw}2. Upgrade Nagios${txtrst}"
echo "${txtblu}3. Install NRPE${txtrst}"
echo "${txtred}4. Delete Nagios${txtrst}"
echo -n "Enter your choice: "
read -r choice
echo

case "$choice" in
    1) do_install ;;
    2) do_upgrade ;;
    3) do_nrpe ;;
    4) do_delete ;;
    *) err "Invalid choice. Exiting." ; exit 1 ;;
esac
