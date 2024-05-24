#/bin/sh

BASEDIR=$(dirname "$0")

for d in $BASEDIR/*/ ; do (cd "$d" && ./fetch.sh); done
