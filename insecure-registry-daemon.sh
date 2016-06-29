#!/bin/sh

# docker daemon start script
[ $(id -u) = 0 ] || { echo 'must be root' ; exit 1; }

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
#echo $pid

cmd=$(cat /proc/$pid/cmdline | tr '\000' ' ')
#echo $cmd

cmd="$cmd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --insecure-registry 10.128.43.55:5000"
echo $cmd

cat > docker.sh << EOF
#!/bin/sh

# check sudo 
[ $(id -u) = 0 ] || { echo 'must be root' ; exit 1; }

# stop daemon first
/etc/init.d/docker stop

# start daemon with new args
$cmd >> /var/lib/boot2docker/docker.log 2>&1 &
EOF

[ -f docker.sh ] && chmod +x docker.sh && ./docker.sh && rm docker.sh
