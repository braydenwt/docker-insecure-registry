docker-machine scp insecure-registry-daemon.sh default:/home/docker/insecure-registry-daemon.sh

docker-machine ssh

sudo ./insecure-registry-daemon.sh

sudo ./docker.sh
