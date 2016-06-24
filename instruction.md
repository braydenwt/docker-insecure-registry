# copy script via ssh
docker-machine scp insecure-registry-daemon.sh default:/home/docker/insecure-registry-daemon.sh

# ssh into docker host
docker-machine ssh

# check daemon status
sudo /etc/init.d/docker status

# run script to generate another script (daemon will be stopped first & started again)
sudo ./insecure-registry-daemon.sh

# run new generated script to start daemon again.
# sudo ./docker.sh
