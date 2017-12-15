#!/bin/bash
#WARNING: RUN DATAGEN.SH FIRST

LOGFILE=~/tmp/matlab-shell.log
rm -f $LOGFILE
stty echo
cd /u/metanet/clustering/multilingual_opinions/BOLDAnew/

#sbatch --mem 7500 -p ai BOLDArun.sh es verbadj 250 1 0 news
#sbatch --mem 7500 -p ai BOLDArun.sh ru verbadj 250 1 0 news
#sbatch --mem 7500 -p ai BOLDArun.sh es verbadj 250 2 0 news
#sbatch --mem 7500 -p ai BOLDArun.sh ru verbadj 250 2 0 news
#sbatch --mem 7500 -p ai BOLDArun.sh es verbadj 250 3 0 news
#sbatch --mem 7500 -p ai BOLDArun.sh ru verbadj 250 3 0 news
#sbatch --mem 7500 -p ai BOLDArun.sh es verbadj 250 4 0 news
#sbatch --mem 7500 -p ai BOLDArun.sh ru verbadj 250 4 0 news
#sbatch --mem 7500 -p ai BOLDArun.sh es verbadj 250 5 0 news
#sbatch --mem 7500 -p ai BOLDArun.sh ru verbadj 250 5 0 news
#sbatch --mem 7500 -p ai BOLDArun.sh es verbadj 250 6 0 news
#sbatch --mem 7500 -p ai BOLDArun.sh ru verbadj 250 6 0 news

#sbatch --mem 7000 -p ai BOLDArun.sh es verbadj 225 1 0 news
#sbatch --mem 7000 -p ai BOLDArun.sh ru verbadj 225 1 0 news
#sbatch --mem 7000 -p ai BOLDArun.sh es verbadj 225 2 0 news
#sbatch --mem 7000 -p ai BOLDArun.sh ru verbadj 225 2 0 news
#sbatch --mem 7000 -p ai BOLDArun.sh es verbadj 225 3 0 news
#sbatch --mem 7000 -p ai BOLDArun.sh ru verbadj 225 3 0 news
#sbatch --mem 7000 -p ai BOLDArun.sh es verbadj 225 4 0 news
#sbatch --mem 7000 -p ai BOLDArun.sh ru verbadj 225 4 0 news
#sbatch --mem 7000 -p ai BOLDArun.sh es verbadj 225 5 0 news
#sbatch --mem 7000 -p ai BOLDArun.sh ru verbadj 225 5 0 news
#sbatch --mem 7000 -p ai BOLDArun.sh es verbadj 225 6 0 news
#sbatch --mem 7000 -p ai BOLDArun.sh ru verbadj 225 6 0 news

sbatch --mem 6100 -p ai BOLDArun.sh es verbadj 200 1 0 news
sbatch --mem 6100 -p ai BOLDArun.sh ru verbadj 200 1 0 news
sbatch --mem 6100 -p ai BOLDArun.sh es verbadj 200 2 0 news
sbatch --mem 6100 -p ai BOLDArun.sh ru verbadj 200 2 0 news
sbatch --mem 6100 -p ai BOLDArun.sh es verbadj 200 3 0 news
sbatch --mem 6100 -p ai BOLDArun.sh ru verbadj 200 3 0 news
sbatch --mem 6100 -p ai BOLDArun.sh es verbadj 200 4 0 news
sbatch --mem 6100 -p ai BOLDArun.sh ru verbadj 200 4 0 news
sbatch --mem 6100 -p ai BOLDArun.sh es verbadj 200 5 0 news
sbatch --mem 6100 -p ai BOLDArun.sh ru verbadj 200 5 0 news
sbatch --mem 6100 -p ai BOLDArun.sh es verbadj 200 6 0 news
sbatch --mem 6100 -p ai BOLDArun.sh ru verbadj 200 6 0 news

sbatch --mem 5900 -p ai BOLDArun.sh es verbadj 175 1 0 news
sbatch --mem 5900 -p ai BOLDArun.sh ru verbadj 175 1 0 news
sbatch --mem 5900 -p ai BOLDArun.sh es verbadj 175 2 0 news
sbatch --mem 5900 -p ai BOLDArun.sh ru verbadj 175 2 0 news
sbatch --mem 5900 -p ai BOLDArun.sh es verbadj 175 3 0 news
sbatch --mem 5900 -p ai BOLDArun.sh ru verbadj 175 3 0 news
sbatch --mem 5900 -p ai BOLDArun.sh es verbadj 175 4 0 news
sbatch --mem 5900 -p ai BOLDArun.sh ru verbadj 175 4 0 news
sbatch --mem 5900 -p ai BOLDArun.sh es verbadj 175 5 0 news
sbatch --mem 5900 -p ai BOLDArun.sh ru verbadj 175 5 0 news
sbatch --mem 5900 -p ai BOLDArun.sh es verbadj 175 6 0 news
sbatch --mem 5900 -p ai BOLDArun.sh ru verbadj 175 6 0 news

sbatch --mem 5700 -p ai BOLDArun.sh es verbadj 150 1 0 news
sbatch --mem 5700 -p ai BOLDArun.sh ru verbadj 150 1 0 news
sbatch --mem 5700 -p ai BOLDArun.sh es verbadj 150 2 0 news
sbatch --mem 5700 -p ai BOLDArun.sh ru verbadj 150 2 0 news
sbatch --mem 5700 -p ai BOLDArun.sh es verbadj 150 3 0 news
sbatch --mem 5700 -p ai BOLDArun.sh ru verbadj 150 3 0 news
sbatch --mem 5700 -p ai BOLDArun.sh es verbadj 150 4 0 news
sbatch --mem 5700 -p ai BOLDArun.sh ru verbadj 150 4 0 news
sbatch --mem 5700 -p ai BOLDArun.sh es verbadj 150 5 0 news
sbatch --mem 5700 -p ai BOLDArun.sh ru verbadj 150 5 0 news
sbatch --mem 5700 -p ai BOLDArun.sh es verbadj 150 6 0 news
sbatch --mem 5700 -p ai BOLDArun.sh ru verbadj 150 6 0 news

sbatch --mem 5400 -p ai BOLDArun.sh es verbadj 125 1 0 news
sbatch --mem 5400 -p ai BOLDArun.sh ru verbadj 125 1 0 news
sbatch --mem 5400 -p ai BOLDArun.sh es verbadj 125 2 0 news
sbatch --mem 5400 -p ai BOLDArun.sh ru verbadj 125 2 0 news
sbatch --mem 5400 -p ai BOLDArun.sh es verbadj 125 3 0 news
sbatch --mem 5400 -p ai BOLDArun.sh ru verbadj 125 3 0 news
sbatch --mem 5400 -p gen BOLDArun.sh es verbadj 125 4 0 news
sbatch --mem 5400 -p gen BOLDArun.sh ru verbadj 125 4 0 news
sbatch --mem 5400 -p gen BOLDArun.sh es verbadj 125 5 0 news
sbatch --mem 5400 -p gen BOLDArun.sh ru verbadj 125 5 0 news
sbatch --mem 5400 -p gen BOLDArun.sh es verbadj 125 6 0 news
sbatch --mem 5400 -p gen BOLDArun.sh ru verbadj 125 6 0 news

sbatch --mem 5200 -p gen BOLDArun.sh es verbadj 100 1 0 news
sbatch --mem 5200 -p gen BOLDArun.sh ru verbadj 100 1 0 news
sbatch --mem 5200 -p gen BOLDArun.sh es verbadj 100 2 0 news
sbatch --mem 5200 -p gen BOLDArun.sh ru verbadj 100 2 0 news
sbatch --mem 5200 -p gen BOLDArun.sh es verbadj 100 3 0 news
sbatch --mem 5200 -p gen BOLDArun.sh ru verbadj 100 3 0 news
sbatch --mem 5200 -p gen BOLDArun.sh es verbadj 100 4 0 news
sbatch --mem 5200 -p gen BOLDArun.sh ru verbadj 100 4 0 news
sbatch --mem 5200 -p gen BOLDArun.sh es verbadj 100 5 0 news
sbatch --mem 5200 -p gen BOLDArun.sh ru verbadj 100 5 0 news
sbatch --mem 5200 -p gen BOLDArun.sh es verbadj 100 6 0 news
sbatch --mem 5200 -p gen BOLDArun.sh ru verbadj 100 6 0 news

sbatch --mem 5000 -p gen BOLDArun.sh es verbadj 75 1 0 news
sbatch --mem 5000 -p gen BOLDArun.sh ru verbadj 75 1 0 news
sbatch --mem 5000 -p gen BOLDArun.sh es verbadj 75 2 0 news
sbatch --mem 5000 -p gen BOLDArun.sh ru verbadj 75 2 0 news
sbatch --mem 5000 -p gen BOLDArun.sh es verbadj 75 3 0 news
sbatch --mem 5000 -p gen BOLDArun.sh ru verbadj 75 3 0 news
sbatch --mem 5000 -p gen BOLDArun.sh es verbadj 75 4 0 news
sbatch --mem 5000 -p gen BOLDArun.sh ru verbadj 75 4 0 news
sbatch --mem 5000 -p gen BOLDArun.sh es verbadj 75 5 0 news
sbatch --mem 5000 -p gen BOLDArun.sh ru verbadj 75 5 0 news
sbatch --mem 5000 -p gen BOLDArun.sh es verbadj 75 6 0 news
sbatch --mem 5000 -p gen BOLDArun.sh ru verbadj 75 6 0 news

sbatch --mem 3900 -p gen BOLDArun.sh es verbadj 50 1 0 news
sbatch --mem 3900 -p gen BOLDArun.sh ru verbadj 50 1 0 news
sbatch --mem 3900 -p gen BOLDArun.sh es verbadj 50 2 0 news
sbatch --mem 3900 -p gen BOLDArun.sh ru verbadj 50 2 0 news
sbatch --mem 3900 -p gen BOLDArun.sh es verbadj 50 3 0 news
sbatch --mem 3900 -p gen BOLDArun.sh ru verbadj 50 3 0 news
sbatch --mem 3900 -p gen BOLDArun.sh es verbadj 50 4 0 news
sbatch --mem 3900 -p gen BOLDArun.sh ru verbadj 50 4 0 news
sbatch --mem 3900 -p gen BOLDArun.sh es verbadj 50 5 0 news
sbatch --mem 3900 -p gen BOLDArun.sh ru verbadj 50 5 0 news
sbatch --mem 3900 -p gen BOLDArun.sh es verbadj 50 6 0 news
sbatch --mem 3900 -p gen BOLDArun.sh ru verbadj 50 6 0 news

#sbatch --mem 3700 -p gen BOLDArun.sh es verbadj 30 1 0 news
#sbatch --mem 3700 -p gen BOLDArun.sh ru verbadj 30 1 0 news
#sbatch --mem 3700 -p gen BOLDArun.sh es verbadj 30 2 0 news
#sbatch --mem 3700 -p gen BOLDArun.sh ru verbadj 30 2 0 news
#sbatch --mem 3700 -p gen BOLDArun.sh es verbadj 30 3 0 news
#sbatch --mem 3700 -p gen BOLDArun.sh ru verbadj 30 3 0 news
#sbatch --mem 3700 -p gen BOLDArun.sh es verbadj 30 4 0 news
#sbatch --mem 3700 -p gen BOLDArun.sh ru verbadj 30 4 0 news
#sbatch --mem 3700 -p gen BOLDArun.sh es verbadj 30 5 0 news
#sbatch --mem 3700 -p gen BOLDArun.sh ru verbadj 30 5 0 news
#sbatch --mem 3700 -p gen BOLDArun.sh es verbadj 30 6 0 news
#sbatch --mem 3700 -p gen BOLDArun.sh ru verbadj 30 6 0 news

#sbatch --mem 3500 -p gen BOLDArun.sh es verbadj 20 1 0 news
#sbatch --mem 3500 -p gen BOLDArun.sh ru verbadj 20 1 0 news
#sbatch --mem 3500 -p gen BOLDArun.sh es verbadj 20 2 0 news
#sbatch --mem 3500 -p gen BOLDArun.sh ru verbadj 20 2 0 news
#sbatch --mem 3500 -p gen BOLDArun.sh es verbadj 20 3 0 news
#sbatch --mem 3500 -p gen BOLDArun.sh ru verbadj 20 3 0 news
#sbatch --mem 3500 -p gen BOLDArun.sh es verbadj 20 4 0 news
#sbatch --mem 3500 -p gen BOLDArun.sh ru verbadj 20 4 0 news
#sbatch --mem 3500 -p gen BOLDArun.sh es verbadj 20 5 0 news
#sbatch --mem 3500 -p gen BOLDArun.sh ru verbadj 20 5 0 news
#sbatch --mem 3500 -p gen BOLDArun.sh es verbadj 20 6 0 news
#sbatch --mem 3500 -p gen BOLDArun.sh ru verbadj 20 6 0 news