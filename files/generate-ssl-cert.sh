#!/bin/sh
# file managed by puppet

hostname=$1
template=$2
outputdir=$3

TMPFILE=`mktemp` || exit 1

sed -e s#@HostName@#"$hostname"# $template > $TMPFILE

export RANDFILE=/dev/random
openssl req -config $TMPFILE -new -x509 -nodes -days 3650 -out $outputdir/$hostname.crt -keyout $outputdir/$hostname.key
chmod 600 $outputdir/$hostname.key
openssl req -new -key $outputdir/$hostname.key -config $TMPFILE > $outputdir/$hostname.csr
