'''
Created on Jan 18, 2013

@author: e4gutier
'''
'''
Created on Jan 17, 2013

@author: E.D. Gutierrez email: edg@icsi.berkeley.edu
'''
import numpy
import scipy.io

mindoclength = 3
o_text = ''
language = 'en'
o_condition = '_verbsonly'
extrasuffix = '_nocomments'
basedir = '/u/metanet/Parsing/parsedblogs_'+language+'/'
o_infilename = basedir+'o_'+language+extrasuffix+o_condition+'.txt'
vocabfilename_o = 'o_vocab_'+language+extrasuffix+'.txt'
o_vocab = []
OP = numpy.zeros(1e8)
ODP = numpy.zeros(1e8)

wordcount_o = 0
doccount = 0
infile = open(o_infilename,'r')
voccount_o = 0
for line in infile:
    doccount = doccount + 1
    print str(doccount)
    words = line.split()
    if len(words)>=mindoclength:
        for word in words:
            try: 
                OP[wordcount_o] = o_vocab.index(word) + 1
            except:
                o_vocab.append(word)
                OP[wordcount_o] = o_vocab.index(word) + 1
                voccount_o = voccount_o + 1
            ODP[wordcount_o] = doccount
            wordcount_o = wordcount_o + 1
#        doccount = doccount + 1            
infile.close()
OP = OP[:wordcount_o]
ODP = ODP[:wordcount_o] 
scipy.io.savemat(basedir+'WPDP_blogs_'+language+o_condition+extrasuffix+'.mat',{'OP':OP, 'ODP':ODP, 'voccount_o': voccount_o, 'wordcount_o':wordcount_o})


scipy.io.savemat(basedir+'WPDP_blogs_'+language+o_condition+extrasuffix+'.mat',{'OP':OP, 'ODP':ODP, 'voccount_o': voccount_o, 'wordcount_o':wordcount_o})

voc_string = ''
for word in o_vocab:
    voc_string = voc_string + ' ' + word
outfile = open(basedir + 'o_vocab_'+language+o_condition+extrasuffix+'.txt', 'w')
outfile.write(voc_string)
outfile.close()

for item in vocab_shorter:
    outfile.write("%s " % item)
outfile.close()
        
indices = indices[:counter]
OP_shorter = numpy.zeros(wordcount_o+1)
ODP_shorter = numpy.zeros(wordcount_o+1)
counter = 0
for i in range(wordcount_o):
    try:
        a = numpy.where(indices==OP[i])[0]
        if len(a)>0:
            OP_shorter[counter] = inverse_indices[OP[i]]
            ODP_shorter[counter] = inverse_indices[ODP[i]]
            counter = counter + 1
    except:
        0


OP = OP_shorter[:counter]
ODP = ODP_shorter[:counter]

scipy.io.savemat(basedir+'WPDP_blogs_short_'+language+extrasuffix+o_condition+'.mat',{'OP':OP, 'ODP':ODP})
