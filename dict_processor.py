import numpy
from numpy import *
import scipy.io

basedir = '/u/metanet/Parsing/'
lang1 = ['en', 'eng']
#lang2 = ['es', 'spa']
lang2 = ['ru', 'rus']
basedir_in = '/u/metanet/clustering/multilingual_opinions/prune_out/'
basedir_dict_in = '/u/metanet/clustering/multilingual_opinions/dictionaries/'
basedir_out = '/u/metanet/clustering/multilingual_opinions/prune_out/'
vocabfilename1 = 'w_vocab_'+str(lang1[0])+'_short_nocomments.txt'
vocabfilename2 = 'w_vocab_'+str(lang2[0])+'_short_nocomments.txt'
dictfilename = 'dict-'+str(lang1[1])+'-'+str(lang2[1])+'-noun.tsv'

vocabfile1 = open(basedir_in+vocabfilename1, 'r')
vocab1 = []
for line in vocabfile1:
    vocab1.append(line.strip())

vocab2 = []    
vocabfile2 = open(basedir_in+vocabfilename2, 'r')
for line in vocabfile2:
    vocab2.append(line.strip())

dictfile = open(basedir_dict_in+dictfilename,'r')
maxa = 0
maxb = 0    
dictmatrix = numpy.zeros(shape=(5000,5000))
counterr = 0
for line in dictfile:
    counterr = counterr + 1
    line0 = line.strip()
    line1 = line0.split('\t')
    try:
        a = vocab1.index(line1[0])
    except:
        a = -1
    try:
        b = vocab2.index(line1[1])
    except: 
        b = -1        
    if (a+b>-2):
        a = a + 1
        b = b + 1
        if a>0:
            if b>0:
                dictmatrix[a,b] = float(line1[2])
            else:
                dictmatrix[a,b] = 1
        else:
            dictmatrix[a,b] = 1
    if a>maxa:
        maxa = a
    if b>maxb:
        maxb = b

dictmatrix = dictmatrix[:len(vocab1)+1, :len(vocab2)+1] #dictmatrix = dictmatrix[:(maxa+1), :(maxb+1)]
scipy.io.savemat(basedir_out+'match-matrix_'+str(lang1[0])+'-'+str(lang2[0])+'_nocomments.mat',{'pi1':dictmatrix})
