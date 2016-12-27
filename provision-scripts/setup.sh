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

echo "\n\nWoW WoW WoW WoW WoW WoW WoW WoW WoW WoW WoW WoW WoW WoW WoW\n\n"
echo "\nStarting base system setup\n"

echo "\nUpdating apt repository\n"
apt-get update

echo "\nInstalling MySQL\n"
export DEBIAN_FRONTEND="noninteractive"
export MYSQL_SERVER_ROOT_PASS="root"
echo "debconf-set-selections <<< mysql-server mysql-server/root_password password '$MYSQL_SERVER_ROOT_PASS'"
echo "debconf-set-selections <<< mysql-server mysql-server/root_password_again password '$MYSQL_SERVER_ROOT_PASS'"
apt-get install -y mysql-server
# need to tweak mysql config so we can log into mysql as root from a non-root (os) user account
echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_SERVER_ROOT_PASS';" | mysql -uroot -p"$MYSQL_SERVER_ROOT_PASS"

echo "\nInstalling dependencies\n"
apt-get install -y build-essential gcc g++ automake git-core autoconf make patch libmysql++-dev mysql-server libtool \
                   libssl-dev grep binutils zlibc libc6 libbz2-dev cmake subversion libboost-all-dev

echo "\n\nBase system setup finished"

# run user script
sudo -i -u vagrant /vagrant/provision-scripts/setup_user.sh $1

echo "\n    The vagrant virtual machine should be ready for use :)"
echo "\n    To login to your VM:"
echo "        vagrant ssh"
echo "\n    Then start the server with the following commands:"
echo "      $ cd run/bin"
echo "      $ ./realmd &"
echo "      $ ./mangosd"
echo "\n    This will run realmd in the background and mangosd"
echo "    in the foreground so you can follow the output."
echo "\n    Once the server is loaded, create your admin account:"
echo "     M> account create LOGIN PASS PASS"
echo "     M> account set gm LOGIN 3"
echo "     M> account set addon LOGIN 1"
echo "    And eventually set your realmlist to"
echo "        set realmlist 127.0.0.1\n"
