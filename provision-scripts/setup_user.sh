#!/bin/sh
# This script should be executed by a non-root user
# It takes care of compilation, db updates and configs
. /vagrant/provision-scripts/config_default.sh

echo "setup_user.sh starting"

echo "Using $INSTALL_PREFIX as the install directory"

echo "Retrieving and building source"
cd "$INSTALL_PREFIX"
if [ ! -d "build" ]; then
    mkdir "build"
fi
if [ ! -d "run" ]; then
    mkdir "run"
fi
if [ ! -d "run/log" ]; then
    mkdir "run/log"
fi
if [ ! -d "$GIT_REPO_CORE_ABBR" ]; then
    mkdir "$GIT_REPO_CORE_ABBR"
fi
if [ ! -d "$GIT_REPO_DB_ABBR" ]; then
    mkdir "$GIT_REPO_DB_ABBR"
fi

# build the code
echo "Retrieving and building the core"
rm -rf "$GIT_REPO_CORE_ABBR/*"
git clone -b "$GIT_REPO_CORE_BRANCH" "$GIT_REPO_CORE" "$GIT_REPO_CORE_ABBR"
rm -rf build/*
cd build
cmake "../$GIT_REPO_CORE_ABBR" -DCMAKE_INSTALL_PREFIX=\../run -DPCH=1 -DDEBUG=0
make -j "$VAGRANT_VM_CORES"
make -j "$VAGRANT_VM_CORES" install

# Setup configs
echo "Copying configs"
cd "$INSTALL_PREFIX/run/etc"
if [ ! -e "mangosd.conf" ]; then
    cp mangosd.conf.dist mangosd.conf
    echo "DataDir = \"/vagrant/client-data\"" >> mangosd.conf
    echo "LogsDir = \"../log\"" >> mangosd.conf
fi

if [ ! -e "realmd.conf" ]; then
    cp realmd.conf.dist realmd.conf
    echo "LogsDir = \"../log\"" >> realmd.conf
fi

# create user and databases
cd "$INSTALL_PREFIX/$GIT_REPO_CORE_ABBR/sql/"
echo "Resetting DBs and Users"
mysql -uroot -p"$MYSQL_SERVER_ROOT_PASS" < create/db_drop_mysql.sql
echo "FLUSH PRIVILEGES;" | mysql -uroot -p"$MYSQL_SERVER_ROOT_PASS"
echo "Creating DB Users"
mysql -uroot -p"$MYSQL_SERVER_ROOT_PASS" < create/db_create_mysql.sql
echo "FLUSH PRIVILEGES;" | mysql -uroot -p"$MYSQL_SERVER_ROOT_PASS"
mysql -uroot -p"$MYSQL_SERVER_ROOT_PASS" characters < base/characters.sql
mysql -uroot -p"$MYSQL_SERVER_ROOT_PASS" realmd < base/realmd.sql

# install world database
cd "$INSTALL_PREFIX"
echo "Retrieving and importing $GIT_REPO_DB_ABBR"
rm -rf "$GIT_REPO_DB_ABBR/*"
git clone -b "$GIT_REPO_DB_BRANCH" "$GIT_REPO_DB" "$GIT_REPO_DB_ABBR"
cd "$GIT_REPO_DB_ABBR/"
if [ ! -e "InstallFullDB.config" ]; then
    ./InstallFullDB.sh
    echo "CORE_PATH=\"../$GIT_REPO_CORE_ABBR/\"" >> InstallFullDB.config
fi
./InstallFullDB.sh

echo "setup_user.sh finished"
