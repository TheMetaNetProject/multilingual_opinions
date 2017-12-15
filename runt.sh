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
#python "a = 3"
#matlab -nodesktop -nosplash -nodisplay -r "lang1='en',lang2='es', T=1e2, gamma=0.04, maxdocnum=8e4,matchmode=4, optimize = 0, run1(lang1, lang2, T, gamma, maxdocnum, matchmode, optimize); quit();"
python BOLDA_contrasts_a.py
matlab -nodesktop -nosplash -nodisplay -r "lang1='en',lang2='es', T=1e2, gamma=0.04, maxdocnum=8e4,matchmode=4, optimize = 0, BOLDA_contrasts_b; quit();"
# Return with Matlab's return code
exit $?