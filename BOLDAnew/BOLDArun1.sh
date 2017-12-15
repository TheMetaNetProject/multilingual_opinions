#!/bin/bash
EXTENSION=.out
FILENAME=$(echo ${1}_${2}_${3}_${4}_${5}_${6}_${EXTENSION})
cd /u/metanet/clustering/multilingual_opinions/BOLDAnew

#stty echo
echo $1 $2 $3 $4 $5
#matlab -nodesktop -nojvm -nosplash -r "lngs={'en','$1'},cname='$6',opinion_words='$2',T=$3,mmode=$4,opt=$5,BOLDArun(lngs,T,3e6,mmode, opt,opinion_words, cname); quit();"
#matlab -nodesktop -nojvm -r "ru='ru';es='es';lngs={'en',$1},news='news', twitter5 = 'twitter5',cname=$6,verb='verb';verbadj='verbadj';verbadjective='verbadjective';ow=$2,T=$3,mmode=$4,opt=$5,BOLDArun(lngs,T,3e6,mmode, opt,ow, cname); quit();"
cat <<EOF | matlab -nodesktop -nosplash -nodisplay /> $FILENAME 
echo on, echo BOLDArun on, lngs={'en','$1'},cname='$6',opinion_words='$2',T=$3,mmode=$4,opt=$5,BOLDArun(lngs,T,3e6,mmode, opt,opinion_words, cname); quit();
exit
EOF

#exit $?