#!/bin/sh
# This script should be executed by the root user
# It installs some packages and sets up mysql
. /vagrant/provision-scripts/config_default.sh

echo "WoW WoW WoW WoW WoW WoW WoW WoW WoW WoW WoW WoW WoW WoW WoW"
echo "setup_root.sh starting"

echo "Updating apt repository"
apt-get update

echo "Installing MySQL"
export DEBIAN_FRONTEND="noninteractive"
echo "debconf-set-selections <<< mysql-server mysql-server/root_password password '$MYSQL_SERVER_ROOT_PASS'"
echo "debconf-set-selections <<< mysql-server mysql-server/root_password_again password '$MYSQL_SERVER_ROOT_PASS'"
apt-get install -y mysql-server
# need to tweak mysql config so we can log in as root from a non-root user
echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_SERVER_ROOT_PASS';" | mysql -uroot -p"$MYSQL_SERVER_ROOT_PASS"

echo "Installing dependencies"
apt-get install -y build-essential gcc g++ automake git-core autoconf make patch libmysql++-dev mysql-server libtool \
                   libssl-dev grep binutils zlibc libc6 libbz2-dev cmake subversion libboost-all-dev

echo "setup_root.sh finished"
echo "WoW WoW WoW WoW WoW WoW WoW WoW WoW WoW WoW WoW WoW WoW WoW"
