#!/bin/bash
#
# $1 is the second language; $2 is the opinion words (e.g., verbadj); $3 is the corpus (e.g., twitter5)
#
# Usage example:
#     sbatch -p ai --mem 5000 datagen.sh ru verbadj news
#

stty echo
cd /u/metanet/clustering/multilingual_opinions/BOLDAnew

matlab -nodesktop -nojvm -r "BOLDA_DataGen('en', '$1', '$2', '$3');"

exit $?