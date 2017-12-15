#!/bin/bash
# Linux script to support clean calling of Matlab as a 
# command processor for use in make scripts.
#
# Usage:
# >> matlabshell <MATLAB_SCRIPT>
#
# Installation: 
# - The first line must point to a valid shell binary. 
#   This script originally written for the Bash shell.
#
# - Matlab must be in the shell search path.
#
# - LOGFILE must point to a valid directory.
#
# Doug Harriman (http://www.linkedin.com/in/dougharriman)
#

LOGFILE=~/tmp/matlab-shell.log
rm -f $LOGFILE
stty echo
cd /u/metanet/clustering/multilingual_opinions
# vectorize.sh ru verbadj twitter5
export PATH=/l/local64/lang/python-2.7.3/bin
export PYTHONPATH=/l/local64/lang/python-2.7.3/bin
export PYTHONHOME=/l/local64/lang/python-2.7.3
python vectorize.py $1 $2 $3