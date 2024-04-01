
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

COPY ./qperf/ /qperf/

RUN mkdir build-qperf pcaps secrets; cd build-qperf; cmake ../qperf; make; cd ..; cp build-qperf/qperf /usr/bin/


# Copy the qperf binary to /usr/bin
# COPY ./build-qperf/qperf /usr/bin/

COPY server.crt /build-qperf/
COPY server.key /build-qperf/
COPY server.crt /usr/bin/
COPY server.key /usr/bin/
COPY server.crt /
COPY server.key /

COPY server_scripts/* /


# Expose default qperf port
EXPOSE 18080/udp

# Run command to keep the container running indefinitely
CMD ["tail", "-f", "/dev/null"]
