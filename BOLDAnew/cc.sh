#!/bin/bash


LOGFILE=~/tmp/matlab-shell.log
rm -f $LOGFILE
stty echo
cd /u/metanet/clustering/multilingual_opinions/BOLDAnew/

sbatch --mem 6800 -p ai BOLDArun.sh ru verbadj 40 5 0 news
sbatch --mem 7000 -p ai BOLDArun.sh ru verbadj 50 5 0 news
sbatch --mem 7000 -p ai BOLDArun.sh ru verbadj 60 5 0 news
sbatch --mem 7000 -p ai BOLDArun.sh ru verbadj 70 5 0 news
sbatch --mem 7000 -p ai BOLDArun.sh ru verbadj 80 5 0 news
sbatch --mem 8000 -p ai BOLDArun.sh ru verbadj 90 5 0 news
sbatch --mem 9000 -p ai BOLDArun.sh ru verbadj 100 5 0 news
sbatch --mem 10000 -p ai BOLDArun.sh ru verbadj 110 5 0 news
sbatch --mem 7000 -p ai BOLDArun.sh es verbadj 50 5 0 news
sbatch --mem 7100 -p ai BOLDArun.sh es verbadj 60 5 0 news
sbatch --mem 7200 -p ai BOLDArun.sh es verbadj 70 5 0 news
sbatch --mem 7500 -p ai BOLDArun.sh es verbadj 80 5 0 news
sbatch --mem 8000 -p ai BOLDArun.sh es verbadj 90 5 0 news
sbatch --mem 10000 -p ai BOLDArun.sh es verbadj 100 5 0 news
sbatch --mem 12000 -p ai BOLDArun.sh es verbadj 110 5 0 news


#sbatch --mem 4600 -p vision BOLDArun.sh ru verbadj 130 5 0
