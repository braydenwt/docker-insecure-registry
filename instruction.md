# download the script
curl -fsSL https://raw.githubusercontent.com/braydenwt/docker-insecure-registry/master/insecure-registry-daemon.sh -o insecure-registry-daemon.sh

# copy script via ssh [ for windows & mac only ].
docker-machine scp insecure-registry-daemon.sh default:/home/docker/insecure-registry-daemon.sh

# ssh into docker host [ for windows & mac only ].
docker-machine ssh

# update the script file permission
chmod +x ~/insecure-registry-daemon.sh

# run script to support insecure registry (daemon will be stopped first & started again)
sudo ./insecure-registry-daemon.sh

# exit the docker host [ for windows & mac only ].
exit;
