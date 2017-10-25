#!/bin/sh
#
# This script should be executed by a non-root user (it should be called from setup.sh)
# It takes care of compilation, db updates and configs
#

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
 "cata")
  export GIT_REPO_CORE_ABBR="mangos-cata"
  export GIT_REPO_DB_ABBR="cata-db"
  ;;
*)
  echo "No expansion name passed to setup_user.sh" 1>&2
  exit 1
  ;;
esac

# cmangos repos and branches
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
#export GIT_REPO_DB_BRANCH="master"

# other setup data
export MYSQL_SERVER_ROOT_PASS="root"
export INSTALL_PREFIX="/home/vagrant"
export VAGRANT_VM_CORES=`nproc`
export MYSQL_PWD=${MYSQL_SERVER_ROOT_PASS}

printf "\n\n%s\n\n" "Core and database setup starting"
printf "%s\n" "Using $INSTALL_PREFIX as the install directory"
printf "%s\n" "Retrieving and building source"

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
if [ ! -d "run/etc" ]; then
    mkdir "run/etc"
fi
if [ ! -d "$GIT_REPO_CORE_ABBR" ]; then
    mkdir "$GIT_REPO_CORE_ABBR"
fi
if [ ! -d "$GIT_REPO_DB_ABBR" ]; then
    mkdir "$GIT_REPO_DB_ABBR"
fi

# build the code
printf "%s\n" "Retrieving and building the core"
rm -rf "$GIT_REPO_CORE_ABBR/*"
git clone -b "$GIT_REPO_CORE_BRANCH" "$GIT_REPO_CORE" "$GIT_REPO_CORE_ABBR"
if [ "$?" != "0" ]; then
  printf "\n\n%s" "Error cloning core repo" 1>&2
  exit 1
fi
rm -rf build/*
cd build
cmake "../$GIT_REPO_CORE_ABBR" -DCMAKE_INSTALL_PREFIX=\../run -DBUILD_EXTRACTORS=ON -DBUILD_PLAYERBOT=ON -DPCH=1 -DDEBUG=0
make -j "$VAGRANT_VM_CORES"
if [ "$?" != "0" ]; then
  printf "\n\n%s" "Error compiling core" 1>&2
  exit 1
fi
make -j "$VAGRANT_VM_CORES" install

# Setup configs
printf "%s\n" "Copying configs"
cd "$INSTALL_PREFIX/run/etc"
if [ ! -e "mangosd.conf" ]; then
    cp "../../$GIT_REPO_CORE_ABBR/src/mangosd/mangosd.conf.dist.in" mangosd.conf
    echo "DataDir = \"/vagrant/client-data/$1\"" >> mangosd.conf
    echo "LogsDir = \"../log\"" >> mangosd.conf
fi

if [ ! -e "realmd.conf" ]; then
    cp "../../$GIT_REPO_CORE_ABBR/src/realmd/realmd.conf.dist.in" realmd.conf
    echo "LogsDir = \"../log\"" >> realmd.conf
fi

if [ ! -e "playerbot.conf" ]; then
    cp "../../$GIT_REPO_CORE_ABBR/src/mangosd/playerbot.conf.dist.in" playerbot.conf
fi

# create user and databases
cd "$INSTALL_PREFIX/$GIT_REPO_CORE_ABBR/sql/"
printf "%s\n" "Resetting DBs and Users"
#mysql -uroot < create/db_drop_mysql.sql
mysql -uroot -e "DROP USER IF EXISTS mangos;"
mysql -uroot -e "DROP DATABASE IF EXISTS mangos; DROP DATABASE IF EXISTS characters; DROP DATABASE IF EXISTS realmd;"
mysql -uroot -e "FLUSH PRIVILEGES;"
printf "%s\n" "Creating DB Users"
mysql -uroot < create/db_create_mysql.sql
mysql -uroot -e "FLUSH PRIVILEGES;"
mysql -uroot mangos < base/mangos.sql
mysql -uroot characters < base/characters.sql
mysql -uroot realmd < base/realmd.sql

# install full database
cd "$INSTALL_PREFIX"
printf "%s\n" "Retrieving and importing $GIT_REPO_DB_ABBR"
rm -rf "$GIT_REPO_DB_ABBR/*"
git clone -b "$GIT_REPO_DB_BRANCH" "$GIT_REPO_DB" "$GIT_REPO_DB_ABBR"
if [ "$?" != "0" ]; then
  printf "\n\n%s" "Error cloning db repo" 1>&2
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
  printf "\n\n%s" "Error installing db - fix and run ./InstallFullDB.sh to try again" 1>&2
  exit 1
fi

printf "\n\n%s\n\n" "Core and database setup finished"
