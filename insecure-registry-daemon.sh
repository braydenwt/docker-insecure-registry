#!/bin/sh

# docker daemon start script
[ $(id -u) = 0 ] || { echo 'must be root' ; exit 1; }

__is_boot2docker () {
  uname -a | grep "boot2docker" 1>/dev/null && return 0;
  return 1;
}

# make sure daemon is running
if [ ! -f /var/run/docker.pid ]; then
  echo 'docker daemon not running, try to start it...'

  # start docker daemon
  /etc/init.d/docker start

  if [ ! -f /var/run/docker.pid ]; then
    echo 'failed to start docker daemon. exit.'
    exit 1
  fi
fi
  
pid=$(cat /var/run/docker.pid)
# echo $pid

cmd=$(cat /proc/$pid/cmdline | tr '\000' ' ')
# echo $cmd

echo $cmd | grep "\-\-insecure\-registry 10.128.43.55:5000" 1>/dev/null && { echo "insecure registry 10.128.43.55:5000 already enabled. skip and exit."; exit 0; }

cmd="$cmd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --insecure-registry 10.128.43.55:5000"

echo "stop docker daemon first"
/etc/init.d/docker stop

echo "start daemon with new args"
echo "new cmd: $cmd"
__is_boot2docker
if [ $? -eq 0 ]; then
  $cmd >> /var/lib/boot2docker/docker.log 2>&1 &
else
  $cmd &
fi
