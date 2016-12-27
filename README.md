# cmangos-vagrant

This Vagrantfile and associated provisioning scripts will create an ubuntu machine with an almost ready to run a cMaNGOS
WoW emulation server. This is most useful for developers who want to speed up the process of testing or people
interested in learning to administer a server. Please read this entire file before starting, it's very short and will
likely save you some hassle.

### Setup

Follow these steps to get up and running:

- If desired, update the Vagrantfile and set the VM CPU and RAM (defaults to 2 cores/2GB)
- run `vagrant up $expansion` where $expansion is classic, tbc or wotlk

This will build the vagrant box and run the provisioning script. This process includes compiling the server, so it can
take some time depending on how fast your computer is. After this is done, the client data needs to be copied to
the cmangos-vagrant/client-data/$expansion directory:

- Extract all data from the client (outside the scope of this README)
- Move extracted data to the proper cmangos-vagrant/client-data/$expansion directory

Then, the server can be started (both mangosd and realmd must be running, i suggest using screen/tmux/byobu):

- run `vagrant ssh`
- `cd run/bin`
- `./realmd`
- `./mangosd`

If you're not using screen or another multiplexer, run `./realmd &` to run it in the background, then run `./mangosd`.
Once the server has started you can use the CLI to add an account and set its expansion and gm levels:

- account create $username $password
- account set addon $username $addonlvl    # 0 = vanilla, 1 = tbc, etc (only required for TBC and WoTLK)
- account set gmlevel $username 3          # 0 = player, 1/2 = ?, 3 = admin

Set your realmlist to 127.0.0.1 and you should be ready to connect using the account you just created.

### Notes

This has been tested with Classic, TBC, and WotLK as they have "official" cMaNGOS database projects. You can use the
Vagrantfile to bring up VMs for each expansion, you just need the proper client-data for them.

If the world database install fails, there is probably an issue with a recent update sql file. The db install happens 
last as any errors are most likely with this step. It should be fairly easy to find the problem; just fix it and re-run
the db install and you should be good go to when it successfully completes.  

### Issues

Please file any issues at [GitHub](https://github.com/hlarsen/cmangos-vagrant).

### TODO

- Use sed instead of echoing options to end of config files
