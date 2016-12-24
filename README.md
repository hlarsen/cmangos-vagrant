# cmangos-vagrant

This Vagrantfile and associated provisioning scripts will create an ubuntu machine with an almost ready to run a cMaNGOS
WoW emulation server. This is most useful for developers who want to speed up the process of testing or people
interested in learning to administer a server. Please read this entire file before starting, it's very short and will
likely save you some hassle.

### Setup

Follow these steps to get up and running:

- Edit the Vagrantfile and set the VM CPU and RAM (more is better)
- Edit provision-scripts/config_default.sh and set GIT_REPO_CORE_ABBR and GIT_REPO_DB_ABBR to your preferred expansion
- run `vagrant up`

This will build the vagrant box and run the two provisioning scripts. This process includes compiling the server, so
it can take some time depending on how fast your computer is. After this is done, the client data needs to be copied to
the /vagrant/client-data directory:

- Extract all data from the client (Outside the scope of this README)
- Move extracted data to /client-data (in the directory with the Vagrantfile - this dir is shared with the Vagrant box)

Then, the server can be started (both mangosd and realmd must be running, i suggest screen/tmux/byobu):

- run `vagrant ssh`
- `cd /home/vagrant/run/bin`
- `./realmd`
- `./mangosd`

If you're not using screen or another multiplexer, run `./realmd &` to run it in the background, then run `./mangosd`.
Once the server has started you can use the CLI to add an account and set its expansion and gm levels:

- account create $username $password
- account set addon $username $addonlvl    # 0 = vanilla, 1 = tbc, etc
- account set gmlevel $username 3          # 0 = player, 1/2 = ?, 3 = admin

Set your realmlist to 127.0.0.1 when connecting and you should be good to go.

### Notes

This has been tested with Classic, TBC, and WotLK as they have "official" cMaNGOS database projects.

If the world database install fails, there is probably an issue with a recent update sql file. It should be fairly easy
to find the problem; fix it and re-run the db install and you should be good go to when it successfully completes.

### Issues

Please file any issues at [GitHub](https://github.com/hlarsen/cmangos-vagrant).

### TODO

- Use sed instead of echoing options to end of config files
