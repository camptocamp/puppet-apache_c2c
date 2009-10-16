#!/bin/sh
# file managed by puppet

if [ $# -ne 3 ]; then
  echo "Usage: $0 hostname template outputdir"
  exit 1
fi

hostname=$1
template=$2
outputdir=$3

TMPFILE=`mktemp` || exit 1

sed -e s#@HostName@#"$hostname"# $template > $TMPFILE

export RANDFILE=/dev/random

if [ ! -e $outputdir/$hostname.crt ] || [ ! -e $outputdir/$hostname.key ]; then
  openssl req -config $TMPFILE -new -x509 -nodes -days 3650 -out $outputdir/$hostname.crt -keyout $outputdir/$hostname.key || exit 1
  chmod 600 $outputdir/$hostname.key
fi

openssl req -new -key $outputdir/$hostname.key -config $TMPFILE > $outputdir/$hostname.csr || exit 1

rm -f $TMPFILE || exit 0
