#!/usr/bin/python

import os
import posix
import sys

tempdir = sys.argv[1]

stdin = sys.stdin
pktnum=0
while True:
	pktnum+=1
	packet = posix.read(0,10240)
	#packet = stdin.read()
	if len(packet) == 0: break
	print >> sys.stderr, "chunking packet", pktnum,'hash',hash(packet), 'and writing to file'
	out = open(tempdir+'/'+str(pktnum),'w')
	out.write(packet)
	out.flush()
	out.close()

