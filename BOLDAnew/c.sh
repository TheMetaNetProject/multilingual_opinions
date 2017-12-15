#!/bin/bash


LOGFILE=~/tmp/matlab-shell.log
rm -f $LOGFILE
stty echo
cd /u/metanet/clustering/multilingual_opinions/BOLDAnew/

sbatch --mem 3400 -p gen BOLDArun.sh ru verbadj 40 5 1 news
sbatch --mem 3450 -p gen BOLDArun.sh ru verbadj 50 5 1 news
sbatch --mem 3520 -p gen BOLDArun.sh ru verbadj 60 5 1 news
sbatch --mem 3610 -p gen BOLDArun.sh ru verbadj 70 5 1 news
sbatch --mem 3720 -p gen BOLDArun.sh ru verbadj 80 5 1 news
sbatch --mem 6000 -p gen BOLDArun.sh ru verbadj 100 5 1 news
sbatch --mem 6000 -p gen BOLDArun.sh ru verbadj 120 5 1 news
sbatch --mem 3450 -p gen BOLDArun.sh es verbadj 50 5 1 news
sbatch --mem 3520 -p gen BOLDArun.sh es verbadj 60 5 1 news
sbatch --mem 3610 -p gen BOLDArun.sh es verbadj 70 5 1 news
sbatch --mem 3720 -p gen BOLDArun.sh es verbadj 80 5 1 news
sbatch --mem 6000 -p gen BOLDArun.sh es verbadj 100 5 1 news
sbatch --mem 6000 -p gen BOLDArun.sh es verbadj 120 5 1 news
sbatch --mem 3400 -p gen BOLDArun.sh ru verbadj 40 6 1 news
sbatch --mem 3450 -p gen BOLDArun.sh ru verbadj 50 6 1 news
sbatch --mem 3520 -p gen BOLDArun.sh ru verbadj 60 6 1 news
sbatch --mem 3610 -p gen BOLDArun.sh ru verbadj 70 6 1 news
sbatch --mem 3720 -p gen BOLDArun.sh ru verbadj 80 6 1 news
sbatch --mem 6000 -p gen BOLDArun.sh ru verbadj 100 6 1 news
sbatch --mem 6000 -p gen BOLDArun.sh ru verbadj 120 6 1 news
sbatch --mem 3450 -p gen BOLDArun.sh es verbadj 50 6 1 news
sbatch --mem 3520 -p gen BOLDArun.sh es verbadj 60 6 1 news
sbatch --mem 3610 -p gen BOLDArun.sh es verbadj 70 6 1 news
sbatch --mem 3720 -p gen BOLDArun.sh es verbadj 80 6 1 news
sbatch --mem 6000 -p gen BOLDArun.sh es verbadj 100 6 1 news
sbatch --mem 6000 -p gen BOLDArun.sh es verbadj 120 6 1 news


#sbatch --mem 4600 -p vision BOLDArun.sh ru verbadj 130 5 0
