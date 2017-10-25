#!/bin/sh
#
# This script installs the base system dependencies, then calls another script
# to download and compile the WoW core and database.
#

# make sure we got an arg, we need it to pick the expansion
if [ "$1" = "" ]; then
  echo "No expansion name passed to setup.sh" 1>&2
  exit 1
fi

printf "\n\n%s\n\n" "cmangos-vagrant provisioning starting"
printf "%s\n" "Base system setup starting"

printf "%s\n" "Updating apt repository"
apt-get update

# config for mysql
export DEBIAN_FRONTEND="noninteractive"
export MYSQL_SERVER_ROOT_PASS="root"
echo "debconf-set-selections <<< mysql-server mysql-server/root_password password '$MYSQL_SERVER_ROOT_PASS'"
echo "debconf-set-selections <<< mysql-server mysql-server/root_password_again password '$MYSQL_SERVER_ROOT_PASS'"

printf "%s\n" "Installing MySQL"
apt-get install -y mysql-server

# need to tweak mysql config so we can log into mysql as root from a non-root (os) user account
export MYSQL_PWD=${MYSQL_SERVER_ROOT_PASS}
mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_SERVER_ROOT_PASS';"

printf "%s\n" "Installing dependencies"
apt-get install -y build-essential gcc g++ automake git-core autoconf make patch libmysql++-dev mysql-server libtool \
                   libssl-dev grep binutils zlibc libc6 libbz2-dev cmake subversion libboost-all-dev

printf "%s\n" "Base system setup finished"

# run user script
sudo -i -u vagrant /vagrant/provision-scripts/setup_user.sh $1

printf "%s\n" "    The vagrant virtual machine should be ready for use :)"
printf "%s\n" "    To login to your VM:"
printf "%s\n" "        $ vagrant ssh"
printf "%s\n" "    Then start the server with the following commands:"
printf "%s\n" "        $ cd run/bin"
printf "%s\n" "        $ ./realmd &"
printf "%s\n" "        $ ./mangosd"
printf "%s\n" "    This will run realmd in the background and mangosd"
printf "%s\n" "    in the foreground so you can follow the output."
printf "%s\n" "    Once the server is loaded, create your admin account:"
printf "%s\n" "        M> account create LOGIN PASS PASS"
printf "%s\n" "        M> account set gm LOGIN 3"
printf "%s\n" "        M> account set addon LOGIN 1"
printf "%s\n" "    And eventually set your realmlist to"
printf "%s\n" "        set realmlist 127.0.0.1\n"

printf "\n\n%s\n\n" "cmangos-vagrant provisioning finished"
