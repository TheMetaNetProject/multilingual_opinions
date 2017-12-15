import numpy
import string
import scipy
from scipy import io
import scipy.io


language = 'es'

#basedir = 'C:/Users/e4gutier/Dropbox/IARPA/Metaphor Extraction/Opinion Mining/'
basedir = '/u/metanet/Parsing/parsedblogs_'+language+'/'
basedir2 = '/u/metanet/clustering/multilingual_opinions/'
o_condition = '_adjectives'
extrasuffix = '_nocomments'

w_vocabfile = open(basedir+'w_vocab_'+language+extrasuffix+'.txt', 'r')
o_vocabfile = open(basedir+'o_vocab_'+language+o_condition+extrasuffix+'.txt', 'r')
w_vocabfile_short = open(basedir2+'w_vocab_short_'+language+extrasuffix+'.txt', 'w')
o_vocabfile_short = open(basedir2+'o_vocab_short_'+language+o_condition+extrasuffix+'.txt', 'w')

#a = scipy.io.loadmat(basedir2+'WPDP_short_'+language+'.mat')
a = scipy.io.loadmat(basedir2+'WPDP_short_'+language+o_condition+extrasuffix+'.mat')
indices_w = a['indices_W']
indices_o = a['indices_O']

w_vocab = []
for line in w_vocabfile:
    w_vocab.append(line.split())

w_vocab = w_vocab[0]
w_vocab_short = []
for i in range(len(w_vocab)):
    if int(sum(indices_w==(i+1))):
        w_vocab_short.append(w_vocab[i])


o_vocab = []
for line in o_vocabfile:
    o_vocab.append(line.split())
o_vocab = o_vocab[0]

o_vocab_short = []
for i in range(len(o_vocab)):
    if int(sum(indices_o==(i+1))):
        o_vocab_short.append(o_vocab[i])

for line in w_vocab_short:
    w_vocabfile_short.write(line+' \n')
for line in o_vocab_short:
    o_vocabfile_short.write(line+' \n')
w_vocabfile_short.close()
o_vocabfile_short.close()

w_vocabfile.close()
o_vocabfile.close()
