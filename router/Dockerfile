
# Use an official Ubuntu runtime as a parent image
FROM ubuntu:latest

# Prevent dpkg errors
ENV DEBIAN_FRONTEND=noninteractive

# Update the system
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    iputils-ping \
    net-tools \
    tcpdump \
    libev4 \
    libev-dev \
    openssl \
    libssl-dev \
    iproute2 \
    iperf3 \
    && rm -rf /var/lib/apt/lists/*

COPY router_tcpdump.sh /

# Expose default qperf port
EXPOSE 18080/udp

# Run command to keep the container running indefinitely
CMD ["tail", "-f", "/dev/null"]
