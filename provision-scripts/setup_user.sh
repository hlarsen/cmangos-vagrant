#!/bin/sh
# This script should be executed by a non-root user
# It takes care of compilation, db updates and configs

# use arg to pick expansion
case "$1" in
"classic")
  export GIT_REPO_CORE_ABBR="mangos-classic"
  export GIT_REPO_DB_ABBR="classic-db"
  ;;
"tbc")
  export GIT_REPO_CORE_ABBR="mangos-tbc"
  export GIT_REPO_DB_ABBR="tbc-db"
  ;;
"wotlk")
  export GIT_REPO_CORE_ABBR="mangos-wotlk"
  export GIT_REPO_DB_ABBR="wotlk-db"
  ;;
*)
  echo "No expansion name passed to setup_user.sh" 1>&2
  exit 1
  ;;
esac

# cMaNGOS repos and branches
export GIT_REPO_CORE="https://github.com/cmangos/$GIT_REPO_CORE_ABBR.git"
export GIT_REPO_DB="https://github.com/cmangos/$GIT_REPO_DB_ABBR.git"
export GIT_REPO_CORE_BRANCH="master"
export GIT_REPO_DB_BRANCH="master"

#
# Override with your own repos/branches here
#
#export GIT_REPO_CORE="https://github.com/hlarsen/$GIT_REPO_CORE_ABBR.git"
#export GIT_REPO_DB="https://github.com/hlarsen/$GIT_REPO_DB_ABBR.git"
#export GIT_REPO_CORE_BRANCH="master"
#export GIT_REPO_DB_BRANCH="fix-alter-game-event"

# other setup data
export MYSQL_SERVER_ROOT_PASS="root"
export INSTALL_PREFIX="/home/vagrant"
export VAGRANT_VM_CORES=`nproc`

echo "\nStarting WoW core and database installation\n\n"
echo "\nUsing $INSTALL_PREFIX as the install directory\n"
echo "\nRetrieving and building source\n"

# make sure directories have been created
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
echo "\nRetrieving and building the core\n"
rm -rf "$GIT_REPO_CORE_ABBR/*"
git clone -b "$GIT_REPO_CORE_BRANCH" "$GIT_REPO_CORE" "$GIT_REPO_CORE_ABBR"
if [ "$?" != "0" ]; then
  echo "\n\nError cloning core repo" 1>&2
  exit 1
fi
rm -rf build/*
cd build
cmake "../$GIT_REPO_CORE_ABBR" -DCMAKE_INSTALL_PREFIX=\../run -DPCH=1 -DDEBUG=0
make -j "$VAGRANT_VM_CORES"
if [ "$?" != "0" ]; then
  echo "\n\nError compiling core" 1>&2
  exit 1
fi
make -j "$VAGRANT_VM_CORES" install

# Setup configs
echo "\nCopying configs\n"
cd "$INSTALL_PREFIX/run/etc"
if [ ! -e "mangosd.conf" ]; then
    cp mangosd.conf.dist mangosd.conf
    echo "DataDir = \"/vagrant/client-data/$1\"" >> mangosd.conf
    echo "LogsDir = \"../log\"" >> mangosd.conf
fi

if [ ! -e "realmd.conf" ]; then
    cp realmd.conf.dist realmd.conf
    echo "LogsDir = \"../log\"" >> realmd.conf
fi

# create user and databases
cd "$INSTALL_PREFIX/$GIT_REPO_CORE_ABBR/sql/"
echo "\nResetting DBs and Users\n"
mysql -uroot -p"$MYSQL_SERVER_ROOT_PASS" < create/db_drop_mysql.sql
echo "FLUSH PRIVILEGES;" | mysql -uroot -p"$MYSQL_SERVER_ROOT_PASS"
echo "\nCreating DB Users\n"
mysql -uroot -p"$MYSQL_SERVER_ROOT_PASS" < create/db_create_mysql.sql
echo "FLUSH PRIVILEGES;" | mysql -uroot -p"$MYSQL_SERVER_ROOT_PASS"
mysql -uroot -p"$MYSQL_SERVER_ROOT_PASS" characters < base/characters.sql
mysql -uroot -p"$MYSQL_SERVER_ROOT_PASS" realmd < base/realmd.sql

# install world database
cd "$INSTALL_PREFIX"
echo "\nRetrieving and importing $GIT_REPO_DB_ABBR\n"
rm -rf "$GIT_REPO_DB_ABBR/*"
git clone -b "$GIT_REPO_DB_BRANCH" "$GIT_REPO_DB" "$GIT_REPO_DB_ABBR"
if [ "$?" != "0" ]; then
  echo "\n\nError cloning db repo" 1>&2
  exit 1
fi
cd "$GIT_REPO_DB_ABBR/"
if [ ! -e "InstallFullDB.config" ]; then
    ./InstallFullDB.sh
    echo "CORE_PATH=\"../$GIT_REPO_CORE_ABBR/\"" >> InstallFullDB.config
    echo "FORCE_WAIT=\"NO\"" >> InstallFullDB.config
fi
./InstallFullDB.sh
if [ "$?" != "0" ]; then
  echo "\n\nError installing db - fix and run ./InstallFullDB.sh to try again" 1>&2
  exit 1
fi

echo "\nWoW core and database installation finished\n"
echo "\n\nWoW WoW WoW WoW WoW WoW WoW WoW WoW WoW WoW WoW WoW WoW WoW\n\n"
