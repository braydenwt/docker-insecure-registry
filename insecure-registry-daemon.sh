#!/bin/sh

# docker daemon start script
[ $(id -u) = 0 ] || { echo 'must be root' ; exit 1; }

# check the docker daemon host
__is_boot2docker () {
  uname -a | grep "boot2docker" 1>/dev/null && return 0;
  return 1;
}

# Set --insecure-registry flag.
__set_docker_opts () {
  # docker default configuration file
  if [ -f "/etc/default/docker" ]; then
    echo "set DOCKER_OPTS in /etc/default/docker"
    __set_docker_opts_in_file "/etc/default/docker"
    return $?
  fi

  # upstart configuration file
  if [ -f "/etc/init/docker.conf" ]; then
    echo "set DOCKER_OPTS in /etc/init/docker.conf"
    __set_docker_opts_in_file "/etc/init/docker.conf"
    return $?
  fi

  # init.d script
  if [ -f "/etc/init.d/docker" ]; then
    echo "set DOCKER_OPTS in /etc/init.d/docker"
    __set_docker_opts_in_file "/etc/init.d/docker"
    return $?
  fi
}

__set_docker_opts_in_file () {
  if [ $# -le 0 ]; then
    echo "file name required."
    return 1;
  fi

  if [ ! -f $1 ]; then
    echo "file $1 not exist."
    return 1;
  fi

  # normalize the file - make sure there is one line starting with 'DOCKER_OPTS="'
  cp $1 $1.new
  grep "^DOCKER_OPTS=" $1.new 1>/dev/null
  if [ $? -ne 0 ]; then echo 'DOCKER_OPTS=""' >> $1.new; fi

  sed -i 's/^DOCKER_OPTS=$/DOCKER_OPTS=\"\"/' $1.new && sed -i 's/^DOCKER_OPTS=\"/DOCKER_OPTS=\"--insecure-registry 10.128.43.55:5000 /' $1.new

  if [ $? -eq 0 ]; then
    cp $1.new $1
    rm $1.new
    return 0;
  else
    return 1;
  fi
}

# make sure daemon is running
if [ ! -f /var/run/docker.pid ]; then
  echo 'docker daemon not running, try to start it...'

  # start docker daemon
  if __is_boot2docker; then
    /etc/init.d/docker start
  else
    # /etc/init.d/docker start  # this works well, but let's use the popular one.
    service docker start
  fi

  # make sure the docker.pid is generated after service start.
  sleep 1;

  if [ ! -f /var/run/docker.pid ]; then
    echo 'failed to start docker daemon. exit.'
    exit 1
  fi
fi

pid=$(cat /var/run/docker.pid)

# check the cmd and see if the insecure-registry enabled.
cmd=$(cat /proc/$pid/cmdline | tr '\000' ' ')
echo $cmd | grep "\-\-insecure\-registry 10.128.43.55:5000" 1>/dev/null && { echo "insecure registry 10.128.43.55:5000 already enabled. skip and exit."; exit 0; }

echo "stop docker daemon first"
if __is_boot2docker; then
  /etc/init.d/docker stop
else
  service docker stop
fi

if __is_boot2docker; then
  # /etc/init.d/docker doesn't use DOCKER_OPTS at all, so it's hard to hack.
  cmd="$cmd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --insecure-registry 10.128.43.55:5000"
  echo "start daemon with new args"
  echo "new cmd: $cmd"
  $cmd >> /var/lib/boot2docker/docker.log 2>&1 &
else
  if ! __set_docker_opts; then
    echo "failed to set DOCKER_OPTS. start the service anyway."
  fi
  service docker start
fi
