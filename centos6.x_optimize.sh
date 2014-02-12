#!/bin/bash
# CentOS 6.x optimize script
# Author    jalinpeng@gmail.com
# Date      2013/12/21

# check the OS
PLATFORM=`uname -i`
if [ $PLATFORM != "x86_64" ]; then
    echo "This script is only for 64bit OS!"
    exit 1
fi

VERSION=`lsb_release -r | awk '{print substr($2,1,1)}'`
if [ $VERSION != 6 ]; then
    echo "This script is only for CentOS 6.x!"
    exit 1
fi

cat << EOF
+-----------------------------------------------------+
|                  CentOS 6.x x86_64                  |
|               start optimizing......                |
+-----------------------------------------------------+
EOF

if false; then
# set ntp
/usr/bin/ntpdate ntp.api.bz
echo "*/5 * * * * /usr/sbin/utpdate ntp.api.bz > /dev/null 2>&1" >> /var/spool/cron/root
service crond restart
echo "set ntp...done"
fi

if false; then
# set max user processes
sed -i 's/1024.*/10240/' /etc/security/limits.d/90-nproc.conf
echo "set max user processes...done"
fi

if false; then
# set file limit
echo "ulimit -SHn 102400" >> /etc/rc.local
cat >> /etc/security/limits.conf << EOF
*                soft    nofile          65535
*                hard    nofile          65535
EOF
echo "set file limit...done"
fi

if false; then
# set core_pattern with absolute path
mkdir /tmp/coredump
echo "/tmp/coredump/core.%e.%p.%t" >> /proc/sys/kernel/core_pattern
fi

if false; then
# call pam_limits.so to init user's resource limits when login
cat >> /etc/pam.d/login << EOF
session    required     /lib64/security/pam_limits.so
EOF
fi

if false; then
# close useless system services
chkconfig bluetooth off
chkconfig cups off
chkconfig ip6tables off
echo "close useless services...done"
fi

if false; then
# disable the ipv6
cat > /etc/modprobe.d/ipv6.conf << EOFI
alias net-pf-10 off
options ipv6 disable=1
EOFI
echo "NETWORKING_IPV6=off" >> /etc/sysconfig/network
echo "disable ipv6...done"
fi

if false; then
# config iptables
# open port 3900
iptables -A INPUT -p tcp -m tcp --dport 3900 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 3090 -j ACCEPT
iptables save
echo "iptables...done"
fi

if false; then
# tune kernel parametres
modprobe bridge
echo "modprobe bridge" >> /etc/rc.local
cat >> /etc/sysctl.conf << EOF
net.ipv4.ip_local_port_range = 1024 65000
net.netfilter.nf_conntrack_max = 10240
net.ipv4.tcp_fin_timeout = 1
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 262144
net.core.somaxconn = 262144
net.core.rmem_default = 8388608
net.core.wmem_default = 8388608
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_max_syn_backlog = 262144
EOF
sysctl -p
echo "sysctl...done"
fi

echo "Optimize is done."
echo "It's recommand to restart OS!"
