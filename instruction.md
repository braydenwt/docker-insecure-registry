# download the script
curl -fsSL https://raw.githubusercontent.com/braydenwt/docker101/master/insecure-registry-daemon.sh -o insecure-registry-daemon.sh

# copy script via ssh
docker-machine scp insecure-registry-daemon.sh default:/home/docker/insecure-registry-daemon.sh

# ssh into docker host
docker-machine ssh

# check daemon status
sudo /etc/init.d/docker status

# update the script file permission
chmod +x ~/insecure-registry-daemon.sh

# run script to generate another script (daemon will be stopped first & started again)
sudo ./insecure-registry-daemon.sh

