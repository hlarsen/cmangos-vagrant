#!/bin/sh
#

sudo /vagrant/provision-scripts/setup_root.sh
sudo -u vagrant /vagrant/provision-scripts/setup_user.sh

echo ""
echo "    The vagrant virtual machine should be ready for use :)"
echo ""
echo "    To login to your VM:"
echo "        vagrant ssh"
echo ""
echo "    Then start the server with the following commands:"
echo "      $ cd bin"
echo "      $ ./realmd &"
echo "      $ ./mangosd"
echo ""
echo "    This will run realmd in the background and mangosd"
echo "    in the foreground so you can follow the output."
echo ""
echo "    Once the server is loaded, create your admin account:"
echo "     M> account create LOGIN PASS PASS"
echo "     M> account set gm LOGIN 3"
echo "     M> account set addon LOGIN 1"
echo "    And eventually set your realmlist to"
echo "        set realmlist 127.0.0.1"
echo ""
