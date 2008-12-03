#!/bin/sh

hostname=$1
template=$2
output=$3

TMPFILE=`mktemp` || exit 1

sed -e s#@HostName@#"$hostname"# $template > $TMPFILE

export RANDFILE=/dev/random
openssl req -config $TMPFILE -new -x509 -nodes -days 3650 -out $output -keyout $output
