#!/bin/bash
#
# puppet-lint.sh
#
#     Recursively calls puppet-lint
#
# Marcus Vinicius Fereira            ferreira.mv[ at ].gmail.com
# 2012-03
#

usage() {

    echo
    echo "Usage: $0 [-h] | [dirname1] [dirname2]"
    echo
    echo "    Recursively call puppet-lint on *.pp files."
    echo "    If no [dirname] is provided: looks into 'modules'"
    echo "    and 'manifests' directories."
    echo
    exit 2

}

[ "$1" == "-h" ] && usage

if [ -z "$1" ]
then
    [ -d ./manifests ] && DIR="manifests"
    [ -d ./modules   ] && DIR="modules $DIR"
    [ -z "$DIR"      ] && usage
else
    DIR="$@"  # all dirs
fi


echo "Dir: $DIR"
log=/tmp/$$.log

for d in $DIR
do

    [ ! -d "$d" ] && usage

    for pp in $( find $d -type f -name '*.pp' )
    do
        echo "File: $pp"
        puppet-lint \
            --log-format '%{path}: %{kind} - %{check}: %{message}: LINE %{linenumber}' \
            --no-80chars-check \
            $pp | tee $log
    done

done

if egrep 'warning|error' $log 2>/dev/null
then
    printf "\Lint: failed.\n\n"
    err=1
else
    printf "\Lint: ok\n\n"
    err=0
fi

/bin/rm -f $log
exit $err

# vim:ft=sh:

