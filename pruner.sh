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
# basedir = ['/u/metanet/Parsing/parsedblogs_',language,'/']
matlab -nodisplay -nosplash -r "language = 'en', basedir_in = '/u/metanet/clustering/multilingual_opinions/vectorize_out/', basedir_out = '/u/metanet/clustering/multilingual_opinions/prune_out/', o_condition = '_adjectives', extrasuffix = '_nocomments', pruner(basedir_in, basedir_out, language, o_condition, extrasuffix); quit()"
python prune_2.py
#python dict_processor.py
# Return with Matlab's return code
exit $?