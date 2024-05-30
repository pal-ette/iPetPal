#/bin/sh

BASEDIR=$(dirname "$0")

for d in $BASEDIR/*/fetch.sh ; do ($d); done
