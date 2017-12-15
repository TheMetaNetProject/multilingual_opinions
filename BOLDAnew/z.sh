#!/bin/bash


LOGFILE=~/tmp/matlab-shell.log
rm -f $LOGFILE
stty echo
cd /u/metanet/clustering/multilingual_opinions/BOLDAnew/


python zzzzz.py

exit $?