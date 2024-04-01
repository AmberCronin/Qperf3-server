#!/bin/bash

# Check if a container ID was provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <container_id>"
    exit 1
fi

# Container ID
CONTAINER_ID=$1

# Install iproute2 if not already installed
if ! rpm -qa | grep 'iproute'>/dev/null 2>&1; then
  echo "installing iproute"
  sudo dnf update
  sudo dnf install -y iproute
fi

# Check if veth0 or veth1 already exist, and delete them if they do
if ip link show veth0 > /dev/null 2>&1; then
    echo "veth0 already exists, deleting..."
    sudo ip link delete veth0
fi

if ip link show veth1 > /dev/null 2>&1; then
    echo "veth1 already exists, deleting..."
    sudo ip link delete veth1
fi

# Create a veth pair
sudo ip link add veth0 type veth peer name veth1

# Check that veth1 was created successfully
if ! ip link show veth1 > /dev/null 2>&1; then
    echo "Error: veth1 could not be created"
    exit 1
fi

# Get the process ID for the Docker container
PID=$(docker inspect -f '{{.State.Pid}}' $CONTAINER_ID)

# Move veth1 to the Docker container's network namespace
sudo ip link set veth1 netns $PID

# Assign an IP address to veth0 in the host namespace
sudo ip addr add 192.168.1.1/24 dev veth0
sudo ip link set veth0 up

# Assign an IP address to veth1 in the Docker container's network namespace
sudo nsenter -t $PID -n ip addr add 192.168.1.2/24 dev veth1
sudo nsenter -t $PID -n ip link set veth1 up
sudo nsenter -t $PID -n ip link set lo up

# Enable IP forwarding in the host namespace
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward

# Check if a default route already exists and delete it if it does
if sudo nsenter -t $PID -n ip route | grep -q default; then
    echo "Default route already exists, deleting..."
    sudo nsenter -t $PID -n ip route delete default
fi

# Add a default route in the Docker container's network namespace
sudo nsenter -t $PID -n ip route add default via 192.168.1.1

#Adding delays to the veths
sudo nsenter -t $PID -n tc qdisc add dev veth1 root netem limit 32000 delay 300ms rate 200mbit
sudo tc qdisc add dev veth0 root netem delay 300ms rate 10mbit
#sudo nsenter -t $PID -n ifconfig veth1 txqueuelen 8000 #number of packets
#sudo ifconfig veth0 txqueuelen 250 #number of packets

# Ping from host to Docker container
ping -c 4 192.168.1.2

# Ping from Docker container to host
docker exec $CONTAINER_ID ping -c 4 192.168.1.1

# Start the qperf server in the Docker container
# docker exec -d $CONTAINER_ID /usr/bin/qperf -s
