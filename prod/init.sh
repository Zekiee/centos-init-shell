#################################################################
#stop default service
sudo -i
systemctl disable rpcbind
systemctl stop rpcbind
systemctl disable rpcbind.socket
systemctl disable postfix.service
systemctl stop postfix.service

#################################################################
#iptable config
cat <<EOT >> /bin/iptables.sh
#!/bin/sh

/sbin/iptables -F
/sbin/iptables -A INPUT -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT

#for Local HTTP Server:
/sbin/iptables -A INPUT -p tcp --dport 80 -j ACCEPT
/sbin/iptables -A INPUT -p tcp --dport 443 -j ACCEPT

#for shanghai caohejing
/sbin/iptables -A INPUT -s 180.169.88.222  -j ACCEPT

#default:
/sbin/iptables -A INPUT -j DROP
/sbin/iptables -A FORWARD -j DROP
EOT

#################################################################
#kernel config
cat <<EOT >> /etc/sysctl.conf
vm.swappiness = 0
net.ipv4.neigh.default.gc_stale_time = 120

# see details in https://help.aliyun.com/knowledge_detail/41334.html
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.tcp_synack_retries = 2

net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1

kernel.sysrq = 1

net.nf_conntrack_max = 1048576
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 65536
net.ipv4.tcp_max_tw_buckets = 20000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 262144
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_max_orphans = 262144
fs.file-max=2000000
EOT

#################################################################
#boot config
cat <<EOT >> /etc/rc.local
###Start iptables on boot
sh /bin/iptables.sh
EOT