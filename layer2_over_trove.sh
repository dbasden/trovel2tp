#!/bin/bash

. S3_KEYS

INBUKKIT=${1:-evilpacketA}
OUTBUKKIT=${2:-evilpacketB}
IP=${3:-169.254.42.1/24}
IFNAME=${4:trove0}

echo 'Inbound bucket (from trove): '${INBUKKIT}
echo 'Outbound bucket (to trove):  '${OUTBUKKIT}
echo 'Local IP:                    '${IP}
echo 'Interface:                   '${IFNAME}

ps ax | grep socat | grep ${IFNAME} | awk '{print $1}' | xargs kill -9

echo 'creating buckets'
s3 create ${INBUKKIT}
s3 create ${OUTBUKKIT}

TEMPDIRA=`mktemp -d`
TEMPDIRB=`mktemp -d`

(
	cd ${TEMPDIRA}
	while true; do 
		for frame in $( s3 -u list ${INBUKKIT} | tail -n +3 | awk '{print $1}' | sort -n ); do
			ln -s trove_consumer_is_fetching_$frame sending_$frame 2>/dev/null && ( 
				echo "receiving frame from trove: ${frame}" >&2
				s3 -u get ${INBUKKIT}/$frame
				s3 -u delete $INBUKKIT/$frame
				sleep 2
		rm sending_$frame) &
		done
	done 
) | socat -x -d  TUN:${IP},up,tun-type=tap,tun-name=${IFNAME} - |  python split.py ${TEMPDIRB} 2>&1 &

(
 cd $TEMPDIRB
 while true; do 
	for f in $(ls); do
		echo 'sending frame to trove: '${f}
		( cat $f | s3 -u put ${OUTBUKKIT}/${f}; rm $f) &
	done
	wait
done )
