#!/bin/sh
# file managed by puppet

if [ $# -ne 4 ]; then
  echo "Usage: $0 hostname template outputdir days"
  exit 1
fi

hostname=$1
template=$2
outputdir=$3
days=$4

export RANDFILE=/dev/random

if [ ! -e $outputdir/$hostname.crt ] || [ ! -e $outputdir/$hostname.key ]; then
  openssl req -config $template -new -x509 -nodes -days $days -out $outputdir/$hostname.crt -keyout $outputdir/$hostname.key || exit 1
  chmod 600 $outputdir/$hostname.key
fi

openssl req -new -key $outputdir/$hostname.key -config $template > $outputdir/$hostname.csr || exit 1

