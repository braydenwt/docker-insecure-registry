#!/bin/sh
# docker daemon start script
[ $(id -u) = 0 ] || { echo 'must be root' ; exit 1; }

#if [ $# -gt 0 ]
#then
#  echo "reading command..."
#  cmd=$1
#fi

# get pid
if [ ! -f /var/run/docker.pid ]; then
  echo 'docker daemon not running'
  exit 1
fi
  
pid=$(cat /var/run/docker.pid)
#echo $pid

cmd=$(cat /proc/$pid/cmdline | tr '\000' ' ')
#echo $cmd

cmd="$cmd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --insecure-registry 10.128.43.55:5000"
echo $cmd

cat >> docker.sh << EOF
#!/bin/sh

# check sudo 
[ $(id -u) = 0 ] || { echo 'must be root' ; exit 1; }

# start daemon
$cmd >> /var/lib/boot2docker/docker.log 2>&1 &
EOF

[ -f docker.sh ] && chmod +x docker.sh
