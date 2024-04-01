#!/bin/bash
# Based on original setup.sh script and https://pancho.dev/posts/linux-router-with-containers/

if ! rpm -qa | grep 'iproute'>/dev/null 2>&1; then
  echo "installing iproute"
  sudo dnf update
  sudo dnf install -y iproute
fi

serv_id=$(docker ps --format '{{.ID}}' --filter name=serv)
rout_id=$(docker ps --format '{{.ID}}' --filter name=rout)

# Check if veth0, veth1, veth2, or veth3 already exist, and delete them if they do
if ip link show veth0 > /dev/null 2>&1; then
    echo "veth0 already exists, deleting..."
    sudo ip link delete veth0
fi

if ip link show veth1 > /dev/null 2>&1; then
    echo "veth1 already exists, deleting..."
    sudo ip link delete veth1
fi

if ip link show veth2 > /dev/null 2>&1; then
    echo "veth2 already exists, deleting..."
    sudo ip link delete veth2
fi

if ip link show veth3 > /dev/null 2>&1; then
    echo "veth3 already exists, deleting..."
    sudo ip link delete veth3
fi


# Create a veth pairs
sudo ip link add veth0 type veth peer name veth1
sudo ip link add veth2 type veth peer name veth3


serv_pid=$(docker inspect -f '{{.State.Pid}}' $serv_id)
rout_pid=$(docker inspect -f '{{.State.Pid}}' $rout_id)


# move veth1 and 2 to the router namespace
sudo ip link set veth1 netns $rout_pid
sudo ip link set veth2 netns $rout_pid

# move veth3 to the server namespace
sudo ip link set veth3 netns $serv_pid


TXQLEN=20000
MTU=1500



# Assign an IP address to veth0 in the host namespace
sudo ip addr add 192.168.1.1/24 dev veth0
sudo ip link set veth0 up txqueuelen $TXQLEN mtu $MTU

# Assign an IP address to veth1 in the router's network namespace
sudo nsenter -t $rout_pid -n ip addr add 192.168.1.2/24 dev veth1
sudo nsenter -t $rout_pid -n ip link set veth1 up mtu $MTU
sudo nsenter -t $rout_pid -n ip link set lo up
# Assign an IP address to veth2 in the router's network namespace
sudo nsenter -t $rout_pid -n ip addr add 192.168.4.2/24 dev veth2
sudo nsenter -t $rout_pid -n ip link set veth2 up mtu $MTU
sudo nsenter -t $rout_pid -n ip link set lo up
# Assign an IP address to veth3 in the server's network namespace
sudo nsenter -t $serv_pid -n ip addr add 192.168.4.1/24 dev veth3
sudo nsenter -t $serv_pid -n ip link set veth3 up txqueuelen $TXQLEN mtu $MTU
sudo nsenter -t $serv_pid -n ip link set lo up


if sudo nsenter -t $serv_pid -n ip route | grep -q default; then
    echo "Default route already exists, deleting..."
    sudo nsenter -t $serv_pid -n ip route delete default
fi


# set route to server through router from localhost
sudo ip route add 192.168.4.0/24 via 192.168.1.2 dev veth0
sudo nsenter -t $serv_pid -n ip route add default via 192.168.4.2 dev veth3



# sudo nsenter -t $rout_pid -n tc qdisc add dev veth1 root handle 1: netem limit 4136 delay 300ms
# sudo nsenter -t $rout_pid -n tc qdisc add dev veth1 parent 1:1 tbf rate 150mbit burst 150kb latency 4s
# sudo nsenter -t $rout_pid -n tc qdisc add dev veth2 root handle 2: netem limit 4136 delay 300ms
# sudo nsenter -t $rout_pid -n tc qdisc add dev veth2 parent 2:2 tbf rate 150mbit burst 150kb latency 4s


# Ideally, would be the most correct? Sets the proper outlink rate to the sat, with the proper limit and delay... but doesn't drop packets
# sudo nsenter -t $rout_pid -n tc qdisc add dev veth1 root handle 1: tbf rate 150mbit burst 150kb limit 36mb
# sudo nsenter -t $rout_pid -n tc qdisc add dev veth1 parent 1:1 netem limit 4136 delay 300ms
# sudo nsenter -t $rout_pid -n tc qdisc add dev veth2 root handle 2: tbf rate 150mbit burst 150kb limit 36mb
# sudo nsenter -t $rout_pid -n tc qdisc add dev veth2 parent 2:2 netem limit 4136 delay 300ms


# Same as above, but we create a gigabit link to the sat, and let the sat do the rate limiting. Still doesn't drop packets
# I suspect these are linked in some way that I am not understanding. 
# sudo nsenter -t $rout_pid -n tc qdisc add dev veth1 root handle 1: tbf rate 1000mbit burst 1mb limit 36mb
# sudo nsenter -t $rout_pid -n tc qdisc add dev veth1 parent 1:1 netem delay 300ms rate 150mbit limit 4136
# sudo nsenter -t $rout_pid -n tc qdisc add dev veth2 root handle 2: tbf rate 1000mbit burst 1mb limit 36mb
# sudo nsenter -t $rout_pid -n tc qdisc add dev veth2 parent 2:2 netem delay 300ms rate 150mbit limit 4136


# Reverse the netem and the tbf declarations, TCP seems normal(?) but QUIC has packet loss at second 4
# sudo nsenter -t $rout_pid -n tc qdisc add dev veth1 root handle 1: netem limit 4136 delay 300ms
# sudo nsenter -t $rout_pid -n tc qdisc add dev veth1 parent 1:1 tbf rate 150mbit burst 150kb limit 36mb
# sudo nsenter -t $rout_pid -n tc qdisc add dev veth2 root handle 2: netem limit 4136 delay 300ms
# sudo nsenter -t $rout_pid -n tc qdisc add dev veth2 parent 2:2 tbf rate 150mbit burst 150kb limit 36mb


# Add 300ms forward delay to the router's interfaces, and a backing fifo to simulate the queue
# sudo nsenter -t $rout_pid -n tc qdisc add dev veth1 root handle 1: netem delay 300ms rate 150mbit
# sudo nsenter -t $rout_pid -n tc qdisc add dev veth1 parent 1:1 bfifo limit 18mb
# sudo nsenter -t $rout_pid -n tc qdisc add dev veth2 root handle 2: netem delay 300ms rate 150mbit
# sudo nsenter -t $rout_pid -n tc qdisc add dev veth2 parent 2:2 bfifo limit 18mb

# Feng Original setting
# sudo nsenter -t $rout_pid -n tc qdisc add dev veth1 root netem limit 32000 delay 300ms rate 200mbit
# sudo nsenter -t $rout_pid -n tc qdisc add dev veth2 root netem delay 300ms rate 10mbit


# Benjamin Peter's Vorma settings. Still fail to see packet loss with TCP
# sudo nsenter -t $rout_pid -n tc qdisc add dev veth1 root handle 1:0 netem limit 1000mbit delay 300ms
# sudo nsenter -t $rout_pid -n tc qdisc add dev veth1 parent 1:1 handle 10: tbf rate 144mbit buffer 1mbit limit 1000mbit 
# sudo nsenter -t $rout_pid -n tc qdisc add dev veth1 parent 10:1 handle 100: tbf rate 144mbit burst .05mbit limit 1000mbit 
# sudo nsenter -t $rout_pid -n tc qdisc add dev veth2 root handle 1:0 netem limit 1000mbit delay 300ms
# sudo nsenter -t $rout_pid -n tc qdisc add dev veth2 parent 1:1 handle 10: tbf rate 144mbit buffer 1mbit limit 1000mbit 
# sudo nsenter -t $rout_pid -n tc qdisc add dev veth2 parent 10:1 handle 100: tbf rate 144mbit burst .05mbit limit 1000mbit 


# 
RATE=150 #mbit - 150mbit default
QUEUE=36 #mb - 36mb default
LIMIT=20000 #packets - 20000 default
RTT=300 #ms - 300ms default
sudo nsenter -t $rout_pid -n tc qdisc add dev veth1 root handle 1: netem limit ${LIMIT} delay ${RTT}ms
sudo nsenter -t $rout_pid -n tc qdisc add dev veth1 parent 1:1 handle 10: tbf rate ${RATE}mbit burst ${RATE}kb limit ${QUEUE}mb

sudo nsenter -t $rout_pid -n tc qdisc add dev veth2 root handle 2: netem limit ${LIMIT} delay ${RTT}ms
sudo nsenter -t $rout_pid -n tc qdisc add dev veth2 parent 2:2 handle 20: tbf rate ${RATE}mbit burst ${RATE}kb limit ${QUEUE}mb

# sudo nsenter -t $serv_pid -n tc qdisc add dev veth3 root handle 3: tbf rate 200mbit burst 400kb limit 5mb

# ping server from localhost
ping -c 4 192.168.4.1

# ping localhost from server
docker exec $serv_id ping -c 4 192.168.1.1

