#!/bin/sh

#
# Uncomment the two export lines below for
# the expansion you want.
#

# World of Warcraft
#export GIT_REPO_CORE_ABBR="mangos-classic"
#export GIT_REPO_DB_ABBR="classic-db"

# World of Warcraft: The Burning Crusade
#export GIT_REPO_CORE_ABBR="mangos-tbc"
#export GIT_REPO_DB_ABBR="tbc-db"

# World of Warcraft: Wrath of the Lich King
export GIT_REPO_CORE_ABBR="mangos-wotlk"
export GIT_REPO_DB_ABBR="wotlk-db"

# cMaNGOS Github repos
export GIT_REPO_CORE="https://github.com/cmangos/$GIT_REPO_CORE_ABBR.git"
export GIT_REPO_DB="https://github.com/cmangos/$GIT_REPO_DB_ABBR.git"

# override to use other repo branches
export GIT_REPO_CORE_BRANCH="master"
export GIT_REPO_DB_BRANCH="master"

# other setup data
export MYSQL_SERVER_ROOT_PASS="root"
export INSTALL_PREFIX="/home/vagrant"
export VAGRANT_VM_CORES=`nproc`

#
# Override with your own repos/branches here
#
#export GIT_REPO_CORE="https://github.com/hlarsen/$GIT_REPO_CORE_ABBR.git"
#export GIT_REPO_DB="https://github.com/hlarsen/$GIT_REPO_DB_ABBR.git"
#export GIT_REPO_CORE_BRANCH="master"
#export GIT_REPO_DB_BRANCH="fix-alter-game-event"
