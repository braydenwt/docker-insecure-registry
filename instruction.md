# copy script via ssh
docker-machine scp insecure-registry-daemon.sh default:/home/docker/insecure-registry-daemon.sh

# ssh into docker host
docker-machine ssh

# check daemon status & stop it.
sudo /etc/init.d/docker status
sudo /etc/init.d/docker stop

# run script to generate another script
sudo ./insecure-registry-daemon.sh

# run new generated script to start daemon again.
sudo ./docker.sh
