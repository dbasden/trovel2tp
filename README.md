trovel2tp
=========

layer 2 tunneling over the top of Anchor Trove, or another object store
with an S3 compatible API.

One end of the tunnel takes individual frames from a TAP interface and 
stores them in a bucket. The other end of the tunnel takes each object 
from the same bucket, and sends it out the TAP interface.  A second 
bucket is used for the reverse direction of the tunnel.  

Although IPv4 is configured over the tunnel to start with, any protocol
will run across the interface.

Requires:

 * socat compiled with TUN/TAP support
 * s3 from libs3-2
 * python (for the split.py stub)

To start the tunnel make sure the s3 command is setup to talk to the S3 api
and then run `layer2_over_trove.sh' with the buckets, the local IP and the
interface name:

	 alice$ ./layer2_over_trove.sh l2tp.bucket0 l2tp.bucket1 169.254.0.1/24 trove0

Then do the same on the other end of the tunnel. Specify a IP on the same
network and remember to swap the inbound and outbound buckets around:

	 bob$ ./layer2_over_trove.sh l2tp.bucket1 l2tp.bucket0 169.254.0.2/24 trove0

You should then be able to ping the other end on IPv4 

	~$ ping 169.254.0.2
	PING 169.254.0.2 (169.254.0.2) 56(84) bytes of data.
	64 bytes from 169.254.0.2: icmp_req=1 ttl=64 time=1928 ms
	64 bytes from 169.254.0.2: icmp_req=2 ttl=64 time=1864 ms
	64 bytes from 169.254.0.2: icmp_req=3 ttl=64 time=1451 ms
	64 bytes from 169.254.0.2: icmp_req=4 ttl=64 time=922 ms
	^C
	--- 169.254.0.2 ping statistics ---
	4 packets transmitted, 4 received, 0% packet loss, time 2998ms
	rtt min/avg/max/mdev = 922.907/1541.700/1928.266/401.381 ms, pipe 2

or IPv6:

	~$ ping6 ff02::1%trove0
	PING ff02::1%trove0(ff02::1) 56 data bytes
	64 bytes from fe80::78df:3fff:fe00:6e5b: icmp_seq=1 ttl=64 time=0.045 ms
	64 bytes from fe80::d005:e3ff:fe5b:2a27: icmp_seq=1 ttl=64 time=380 ms (DUP!)
	64 bytes from fe80::78df:3fff:fe00:6e5b: icmp_seq=2 ttl=64 time=0.035 ms
	64 bytes from fe80::d005:e3ff:fe5b:2a27: icmp_seq=2 ttl=64 time=931 ms (DUP!)
	64 bytes from fe80::78df:3fff:fe00:6e5b: icmp_seq=3 ttl=64 time=0.064 ms
	64 bytes from fe80::d005:e3ff:fe5b:2a27: icmp_seq=3 ttl=64 time=339 ms (DUP!)
	64 bytes from fe80::78df:3fff:fe00:6e5b: icmp_seq=4 ttl=64 time=0.041 ms
	64 bytes from fe80::d005:e3ff:fe5b:2a27: icmp_seq=4 ttl=64 time=357 ms (DUP!)
	^C
	--- ff02::1%trove0 ping statistics ---
	4 packets transmitted, 4 received, +4 duplicates, 0% packet loss, time 3002ms
	rtt min/avg/max/mdev = 0.035/251.195/931.364/306.356 ms

