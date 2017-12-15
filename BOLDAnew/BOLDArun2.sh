#!/bin/bash

stty echo
cd /u/metanet/clustering/multilingual_opinions/BOLDAnew
echo $1 $2 $3 $4 $5
matlab -nodesktop -nojvm -r "ru='ru';es='es';lngs={'en',$1},cname='twitter5',verb='verb';verbadj='verbadj';verbadjective='verbadjective';ow=$2,T=$3,mmode=$4,opt=$5,BOLDArun(lngs,T,3e6,mmode, opt,ow, cname); quit();"

exit $?