Similar to the IPERF3 server. 
Originally created from git@github.com:funglee2k22/Qperf3-server.git

Refer to the wiki on how to create the emulation: https://wiki.viasat.com/display/SSG/Docker+Based+Emulation+Setup+for+Development+Using+QPERF

deprecated and don't commit any new changes, and to be remove in August 2023. 

To clone submodules:
git clone ... --recurse-submodules

---

Notes from AKC, c. Mar 2024:

Will generate server keys automagically if they are not already present in server/

Files of note:
- configure.sh - the 'make all', sets up the entire environment for you
- postconfigsetup.sh - used by configure.sh to set up all of the links between each of the Docker containers after they are spooled by configure.sh
- setkernelbufs.sh - run on localhost to up kernel memory significantly for testing the CCAs
- unconfigure.sh - stops the containers (should maybe do some other cleanup too, but thats future work)

router/ contains all Docker-related router files
server/ contains all Docer-related server files, and has some useful scripts for basic testing on the server side
client_scripts/ contains some useful scripts for basic testing on the client side
secrets/ contains all of the connection keys (if pre-made scripts are being used)

---

Notes from AKC, c. Jan 2024:
Added a second 'router' container sitting between the server and the client (localhost)
Configuration of the boxes is as follows:

	| localhost.veth0 (192.168.1.1/24) |
	  			|
	| router.veth1 (192.168.1.2/24) # router.veth2 (192.168.4.2/24) |
												|
									| server.veth3 (192.168.4.1/24) |

All queue disciplines (tc qdiscs) are implemented now on the router, without having to modify host/server configurations. 

The server docker image was reconfigured to transfer all code and build qperf internally to appropriately route all libraries on non- debian-based host systems (in this case, Fedora Linux). 

Router settings are based on conversation with Claypool:
- 600ms RTT (300ms each way)
- 8450 packet queue (optimized for QUIC's 1360B packets), 8450p * 1360B/p = 11.492MB, approximating the BDP of the satellite link
- 150mbps bottleneck link speed, symmetric

