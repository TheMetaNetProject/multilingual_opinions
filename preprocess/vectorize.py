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

compute_o = 'y'
compute_w = 'y'

o_cutoff = 1.5e3
w_cutoff = 2.5e3

mindoclength = 3
w_text = ''
o_text = ''
language = 'ru'
o_condition = ''
if o_condition=='_verbsonly':
    POS = 'verbs'
if o_condition=='_adjectives':
    POS = 'adjectives'
if o_condition=='':
    POS = 'both'
#validWords = set(map(str.strip, open('list-'+language+'-'+POS+'.txt')))


extrasuffix = '_nocomments'
basedir = '/u/metanet/Parsing/parsedblogs_'+language+'/'
o_infilename = basedir+'o_'+language+extrasuffix+o_condition+'.txt'
w_infilename = basedir+'w_'+language+extrasuffix+'.txt'
vocabfilename_w = 'w_vocab_'+language+'.txt'
vocabfilename_o = 'o_vocab_'+language+o_condition+extrasuffix+'.txt'
w_vocab = [] 
o_vocab = []
WP = numpy.zeros(1e8)
OP = numpy.zeros(1e8)
ODP = numpy.zeros(1e8)
WDP = numpy.zeros(1e8)

if compute_o=='y':
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
#                if (word in validWords):
                try: 
                    OP[wordcount_o] = o_vocab.index(word) + 1
                except:
                    o_vocab.append(word)
                    OP[wordcount_o] = o_vocab.index(word) + 1
                    voccount_o = voccount_o + 1
                ODP[wordcount_o] = doccount
                wordcount_o = wordcount_o + 1

    infile.close()
    OP = OP[:wordcount_o]
    ODP = ODP[:wordcount_o] 
    scipy.io.savemat(basedir+'OPDP_blogs_'+language+o_condition+extrasuffix+'.mat',{'OP':OP, 'ODP':ODP, 'voccount_o': voccount_o, 'wordcount_o':wordcount_o})

    voc_string = ''
    for word in o_vocab:
        voc_string = voc_string + ' ' + word
    outfile = open(basedir + 'o_vocab_'+language+o_condition+extrasuffix+'.txt', 'w')
    outfile.write(voc_string)
    outfile.close()

    wordcounts = numpy.zeros(voccount_o)
    largestcount = 0
    for i in range(int(voccount_o)):
        wordcounts[i] = sum(1 for j in OP if (j-1)==i)
        if largestcount<wordcounts[i]:
            largestcount = wordcounts[i]
    scipy.io.savemat('wordcounts.mat', {'wordcounts':wordcounts})
    limit = largestcount 
    o_cutoff = min(o_cutoff, len(wordcounts))

    totalgreater = 0   
    while totalgreater<o_cutoff:
        limit = limit - 1
        print 'limit: '+str(limit)
        totalgreater = sum(1 for j in wordcounts if j>limit) 

    vocabfile1 = open(basedir+vocabfilename_o, 'r')
    for line in vocabfile1:
        vocab1 = line.split()
    vocab_shorter = []
    indices = numpy.zeros(len(wordcounts))
    inverse_indices = numpy.zeros(wordcount_o+1)
    counter = 0      
    print str(wordcounts)  
    for i in range(len(wordcounts)):    
        if wordcounts[i] > limit:
            print 'counter: ' + str(int(counter))
            indices[counter] = i
            inverse_indices[i] = counter
            counter = counter + 1
            vocab_shorter.append(vocab1[int(i)])
    outfile = open(basedir + 'o_vocab_short_'+language+extrasuffix+o_condition+'.txt', 'w')
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
    scipy.io.savemat(basedir+'OPDP_blogs_short_'+language+extrasuffix+o_condition+'.mat',{'OP':OP, 'ODP':ODP})


if compute_w=='y':
    wordcount_w = 0
    doccount = 0
    voccount_w = 0
    infile = open(w_infilename,'r')
    for line in infile:
        words = line.split()
        doccount = doccount + 1
        if len(words)>=mindoclength:
            for word in words:
                try: 
                    WP[wordcount_w] = w_vocab.index(word) + 1
                except:
                    w_vocab.append(word)
                    WP[wordcount_w] = w_vocab.index(word) + 1
                    voccount_w = voccount_w + 1
                WDP[wordcount_w] = doccount
                wordcount_w = wordcount_w + 1

    infile.close()
    WP = WP[:wordcount_w]
    WDP = WDP[:wordcount_w]

    scipy.io.savemat(basedir+'WPDP_blogs_'+language+o_condition+extrasuffix+'.mat',{'WP':WP, 'WDP':WDP, 'voccount_w': voccount_w, 'wordcount_w':wordcount_w})

    voc_string = ''
    for word in w_vocab:
        voc_string = voc_string + ' ' + word
    outfile = open(basedir+vocabfilename_w, 'w')
    outfile.write(voc_string)
    outfile.close()


    wordcounts = numpy.zeros(voccount_w)
    largestcount = 0
    for i in range(voccount_w):
        wordcounts[i] = sum(1 for j in WP if (j-1)==i)
        if largestcount<wordcounts[i]:
            largestcount = wordcounts[i]
    scipy.io.savemat(basedir+'wordcounts_'+language+extrasuffix+'.mat',{'wordcounts_w':wordcounts})

    limit = largestcount 
    w_cutoff = min(o_cutoff, len(wordcounts))

    totalgreater = 0   
    while totalgreater<w_cutoff:
        limit = limit - 1
        print 'limit: '+str(limit)
        totalgreater = sum(1 for j in wordcounts if j>limit) 


    scipy.io.savemat(basedir+'wordcounts_'+language+extrasuffix+'.mat',{'wordcounts_w':wordcounts, 'totalgreater_w':totalgreater})

    vocabfile1 = open(basedir+vocabfilename_w, 'r')
    for line in vocabfile1:
        vocab1 = line.split()
    vocab_shorter = []
    indices = numpy.zeros(w_cutoff)
    inverse_indices = numpy.zeros(wordcount_w+1)

    counter = 0      
    print str(wordcounts)  
    for i in range(len(wordcounts)):    
        if wordcounts[i] > limit:
            print 'counter: ' + str(int(counter))
            indices[counter] = i
            inverse_indices[i] = counter
            counter = counter + 1
            vocab_shorter.append(vocab1[int(i)])

    outfile = open(basedir + 'w_vocab_short_'+language+extrasuffix+'.txt', 'w')
    for item in vocab_shorter:
        outfile.write("%s " % item)
    outfile.close()
        
    indices = indices[:counter]
    WP_shorter = numpy.zeros(wordcount_w+1)
    WDP_shorter = numpy.zeros(wordcount_w+1)
    counter = 0
    for i in range(wordcount_w):
        try:
            a = numpy.where(indices==WP[i])[0]
            if len(a)>0:
                WP_shorter[counter] = inverse_indices[WP[i]]
                WDP_shorter[counter] = inverse_indices[WDP[i]]
                counter = counter + 1
        except:
            0
    scipy.io.savemat(basedir+'WPshorter_'+language+extrasuffix+'.mat',{'WP_Shorter':WP_shorter, 'WDP_shorter':WDP_shorter})
    WP = WP_shorter[:counter]
    WDP = WDP_shorter[:counter]
    scipy.io.savemat(basedir+'WPDP_blogs_short_'+language+extrasuffix+o_condition+'.mat',{'WP':WP, 'WDP':WDP})
