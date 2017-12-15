#!/bin/bash


LOGFILE=~/tmp/matlab-shell.log
rm -f $LOGFILE
stty echo
cd /u/metanet/clustering/multilingual_opinions/BOLDAnew/

#sbatch --mem 15000 -p gen BOLDArun.sh es verbadj 200 1 1
#sbatch --mem 15000 -p gen BOLDArun.sh es verbadj 200 2 1
#sbatch --mem 15000 -p gen BOLDArun.sh es verbadj 200 3 1
#sbatch --mem 15000 -p gen BOLDArun.sh es verbadj 200 4 1
#sbatch --mem 15000 -p gen BOLDArun.sh es verbadj 200 5 1
#sbatch --mem 15000 -p gen BOLDArun.sh es verbadj 200 6 1

#sbatch --mem 10000 -p gen BOLDArun.sh es verbadj 175 1 1
#sbatch --mem 10000 -p gen BOLDArun.sh es verbadj 175 2 1
#sbatch --mem 10000 -p gen BOLDArun.sh es verbadj 175 3 1
#sbatch --mem 10000 -p gen BOLDArun.sh es verbadj 175 4 1
#sbatch --mem 10000 -p gen BOLDArun.sh es verbadj 175 5 1
#sbatch --mem 10000 -p gen BOLDArun.sh es verbadj 175 6 1

#sbatch --mem 5500 -p gen BOLDArun.sh es verbadj 150 1 1
#sbatch --mem 5500 -p gen BOLDArun.sh es verbadj 150 2 1
#sbatch --mem 5500 -p gen BOLDArun.sh es verbadj 150 3 1
#sbatch --mem 5500 -p gen BOLDArun.sh es verbadj 150 4 1
#sbatch --mem 5500 -p gen BOLDArun.sh es verbadj 150 5 1
#sbatch --mem 5500 -p gen BOLDArun.sh es verbadj 150 6 1

#sbatch --mem 5000 -p ai BOLDArun.sh es verbadj 125 1 1
#sbatch --mem 5000 -p ai BOLDArun.sh es verbadj 125 2 1
#sbatch --mem 5000 -p ai BOLDArun.sh es verbadj 125 3 1
#sbatch --mem 5000 -p ai BOLDArun.sh es verbadj 125 4 1
#sbatch --mem 5000 -p ai BOLDArun.sh es verbadj 125 5 1
#sbatch --mem 5000 -p ai BOLDArun.sh es verbadj 125 6 1

#sbatch --mem 5000 -p ai  BOLDArun.sh es verbadj 100 1 1
#sbatch --mem 5000 -p ai BOLDArun.sh es verbadj 100 2 1
#sbatch --mem 5000 -p ai BOLDArun.sh es verbadj 100 3 1
#sbatch --mem 5000 -p ai BOLDArun.sh es verbadj 100 4 1
#sbatch --mem 5000 -p ai BOLDArun.sh es verbadj 100 5 1
#sbatch --mem 5000 -p ai BOLDArun.sh es verbadj 100 6 1

#sbatch --mem 4500 -p gen BOLDArun.sh es verbadj 80 1 1
#sbatch --mem 4500 -p gen BOLDArun.sh es verbadj 80 2 1
#sbatch --mem 4500 -p gen BOLDArun.sh es verbadj 80 3 1
#sbatch --mem 4500 -p gen BOLDArun.sh es verbadj 80 4 1
#sbatch --mem 4500 -p gen BOLDArun.sh es verbadj 80 5 1
#sbatch --mem 4500 -p gen BOLDArun.sh es verbadj 80 6 1

#sbatch --mem 4000 -p gen BOLDArun.sh es verbadj 60 1 1
#sbatch --mem 4000 -p gen BOLDArun.sh es verbadj 60 2 1
#sbatch --mem 4000 -p gen BOLDArun.sh es verbadj 60 3 1
#sbatch --mem 4000 -p gen BOLDArun.sh es verbadj 60 4 1
#sbatch --mem 4000 -p gen BOLDArun.sh es verbadj 60 5 1
#sbatch --mem 4000 -p gen BOLDArun.sh es verbadj 60 6 1

#sbatch --mem 3500 -p gen BOLDArun.sh es verbadj 40 1 1
#sbatch --mem 3500 -p gen BOLDArun.sh es verbadj 40 2 1
#sbatch --mem 3500 -p gen BOLDArun.sh es verbadj 40 3 1
#sbatch --mem 3500 -p gen BOLDArun.sh es verbadj 40 4 1
#sbatch --mem 3500 -p gen BOLDArun.sh es verbadj 40 5 1
#sbatch --mem 3500 -p gen BOLDArun.sh es verbadj 40 6 1

#sbatch --mem 4500 -p gen BOLDArun.sh es verbadj 20 1 1
#sbatch --mem 4500 -p gen BOLDArun.sh es verbadj 20 2 1
#sbatch --mem 4500 -p gen BOLDArun.sh es verbadj 20 3 1
#sbatch --mem 4500 -p gen BOLDArun.sh es verbadj 20 4 1
#sbatch --mem 4500 -p gen BOLDArun.sh es verbadj 20 5 1
#sbatch --mem 4500 -p gen BOLDArun.sh es verbadj 20 6 1

#sbatch --mem 5000 -p gen BOLDArun.sh ru verbadj 80 1 1
#sbatch --mem 5000 -p gen BOLDArun.sh ru verbadj 80 2 1
#sbatch --mem 5000 -p gen BOLDArun.sh ru verbadj 80 3 1
#sbatch --mem 5000 -p gen BOLDArun.sh ru verbadj 80 4 1
#sbatch --mem 5000 -p gen BOLDArun.sh ru verbadj 80 5 1
#sbatch --mem 5000 -p gen BOLDArun.sh ru verbadj 80 6 1

#sbatch --mem 3500 -p gen BOLDArun.sh ru verbadj 40 1 1
#sbatch --mem 3500 -p gen BOLDArun.sh ru verbadj 40 2 1
#sbatch --mem 3500 -p gen BOLDArun.sh ru verbadj 40 3 1
#sbatch --mem 3500 -p gen BOLDArun.sh ru verbadj 40 4 1
#sbatch --mem 3500 -p gen BOLDArun.sh ru verbadj 40 5 1
#sbatch --mem 3500 -p gen BOLDArun.sh ru verbadj 40 6 1

#sbatch --mem 5000 -p gen BOLDArun.sh ru verbadj 60 1 1
#sbatch --mem 5000 -p gen BOLDArun.sh ru verbadj 60 2 1
#sbatch --mem 5000 -p gen BOLDArun.sh ru verbadj 60 3 1
#sbatch --mem 5000 -p gen BOLDArun.sh ru verbadj 60 4 1
#sbatch --mem 5000 -p gen BOLDArun.sh ru verbadj 60 5 1
#sbatch --mem 5000 -p gen BOLDArun.sh ru verbadj 60 6 1

###################################################################3
##sbatch --mem 3000 -p gen BOLDArun.sh es verbadj 3 4 1

sbatch --mem 10000 -p ai BOLDArun.sh ru  verbadj 200 1 0
sbatch --mem 10000 -p ai BOLDArun.sh ru verbadj 200 2 0
sbatch --mem 10000 -p ai BOLDArun.sh ru verbadj 200 3 0
sbatch --mem 10000 -p ai BOLDArun.sh ru verbadj 200 4 0
sbatch --mem 10000 -p ai BOLDArun.sh ru verbadj 200 5 0
sbatch --mem 10000 -p ai BOLDArun.sh ru verbadj 200 6 0

sbatch --mem 8000 -p ai BOLDArun.sh ru verbadj 175 1 0
sbatch --mem 8000 -p ai BOLDArun.sh ru verbadj 175 2 0
sbatch --mem 8000 -p ai BOLDArun.sh ru verbadj 175 3 0
sbatch --mem 8000 -p ai BOLDArun.sh ru verbadj 175 4 0
sbatch --mem 8000 -p ai BOLDArun.sh ru verbadj 175 5 0
sbatch --mem 8000 -p ai BOLDArun.sh ru verbadj 175 6 0

sbatch --mem 5000 -p ai  BOLDArun.sh ru verbadj 150 1 0
sbatch --mem 5000 -p ai BOLDArun.sh ru verbadj 150 2 0
sbatch --mem 5000 -p ai BOLDArun.sh ru verbadj 150 3 0
sbatch --mem 5000 -p ai BOLDArun.sh ru verbadj 150 4 0
sbatch --mem 5000 -p ai BOLDArun.sh ru verbadj 150 5 0
sbatch --mem 5000 -p ai BOLDArun.sh ru verbadj 150 6 0

sbatch --mem 4500 -p gen BOLDArun.sh ru verbadj 125 1 0
sbatch --mem 4500 -p gen BOLDArun.sh ru verbadj 125 2 0
sbatch --mem 4500 -p gen BOLDArun.sh ru verbadj 125 3 0
sbatch --mem 4500 -p gen BOLDArun.sh ru verbadj 125 4 0
sbatch --mem 4500 -p gen BOLDArun.sh ru verbadj 125 5 0
sbatch --mem 4500 -p gen BOLDArun.sh ru verbadj 125 6 0

sbatch --mem 5000 -p ai BOLDArun.sh ru verbadj 100 1 0
sbatch --mem 5000 -p ai BOLDArun.sh ru verbadj 100 2 0
sbatch --mem 5000 -p ai BOLDArun.sh ru verbadj 100 3 0
sbatch --mem 5000 -p ai BOLDArun.sh ru verbadj 100 4 0
sbatch --mem 5000 -p ai BOLDArun.sh ru verbadj 100 5 0
sbatch --mem 5000 -p ai BOLDArun.sh ru verbadj 100 6 0

exit $?