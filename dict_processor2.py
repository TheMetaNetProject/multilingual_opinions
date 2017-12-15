# Description: Turns the bilingual dictionaries for the inputted word classes into similarity matrices
# where if word i in language 1 and word j in language 2 match, then matrix[i,j] = similarity
# if word i in langauge 1 has no match, then matrix[i,0] = 1, similarly for word j in language 2
# matrix[0,j] = 1
#
# As of now, we usually call this using the dict.sh bash shell script
# 
# Command line inputs:
# **Takes a variable number N of inputs, greater than 2
#    $1: two-letter language code for the language being compared to English (es or ru)
#    $2 through ${N-1}: the wordtypes to be converted--e.g., noun verb adj
#    ${N}: the corpus name (e.g., twitter5, news)
#


#date = '_20130301'
import numpy
from numpy import *
import scipy.io
from itertools import combinations
import sys

print('run after vectorize.py, run before bolda_contrasts.m \n')


if sys.argv[1]=='es':
    langs = [['en', 'eng'],['es', 'spa']] 
else:
    langs = [['en', 'eng'], ['ru', 'rus']]

corpus_name = sys.argv[-1]
wordtypes = [item for item in sys.argv[2:-1]]
print wordtypes
vocab_dir = '/u/metanet/clustering/multilingual_opinions/'+corpus_name+'/vectorize_out/'
dict_dir = '/u/metanet/clustering/multilingual_opinions/dictionaries/'
out_dir = vocab_dir

## MAIN PROCESS BELOW ##
def dict_process(langs = langs, wordtypes = wordtypes, vocab_dir = vocab_dir, dict_dir = dict_dir, out_dir = out_dir):
    """Main function.  
    :param langs:  
    :type langs: list.
    :param wordtypes:
    :type wordtypes: dict. 
    :param vocab_dir: Directory where the vocabulary list is located
    :type vocab_dir: str.
    :param dict_dir: Directory where the dictionary is located.
    :type dict_dir: str.
    :param out_dir: Output directory
    :type out_dir: str.

#    for (lang1, lang2) in combinations(langs1):
    for type in wordtypes:
        open('log_dict.txt', 'a').write(langs[0][0] +'-'+ langs[1][0] + 'stage0.5\n')
        vocab_filename1 = vocab_dir + 'vocab_' + type + '_' + corpus_name+'_' + langs[0][0] +'_small.txt'
        vocab_filename2 = vocab_dir + 'vocab_' + type + '_' + corpus_name+'_' + langs[1][0] +'_small.txt'
        vocab1 = readlist(vocab_filename1)
        vocab2 = readlist(vocab_filename2)
        if type=='verbadjective':
            compile(langs, 'verb', dict_dir, out_dir, corpus_name, vocab1, vocab2, '', 'V')
            compile(langs, 'adjective', dict_dir, out_dir, corpus_name, vocab1, vocab2, '', 'A')
        if (type == 'noun')|(corpus_name=='twitter3'):
            compile(langs, type, dict_dir, out_dir, corpus_name, vocab1, vocab2, '', '')
        elif type == 'verbadj':
            compile(langs, 'verb', dict_dir, out_dir, corpus_name, vocab1, vocab2, '.verb', 'V')
            compile(langs, 'adj', dict_dir, out_dir, corpus_name, vocab1, vocab2, '.adj', 'A')
        else:
            compile(langs, type, dict_dir, out_dir, corpus_name, vocab1, vocab2, '.'+type, '')
        open('log_dict.txt', 'a').write(type+'-'+langs[0][0]+'-'+langs[1][0]+'stage5\n')

def compile(langs, type, dict_dir, out_dir, corpus_name, vocab1, vocab2, suffix, num=''):
    dict_filename1 = dict_dir + 'dict-'+str(langs[0][1])+'-'+str(langs[1][1])+'-'+type+'.tsv'
    dict_filename2 = dict_dir + 'dict-'+str(langs[1][1])+'-'+str(langs[0][1])+'-'+type+'.tsv'
    dict_matrix = matrix_build(vocab1, vocab2, dict_filename1, suffix) + numpy.transpose(matrix_build(vocab2, vocab1, dict_filename2, suffix))
    scipy.io.savemat(out_dir+'match-matrix_'+corpus_name+'_'+type+ str(num) +'_'+langs[0][0]+'-'+langs[1][0]+'.mat',{'pi1':dict_matrix})
    
        
def readlist(filename):
    file1 = open(filename, 'r')
    list1 = []
    for line in file1:
        split_line = line.split()
        counter = 0
        for word in split_line:
           list1.append(word)
           print str(counter)+ ' ' + word
           counter+=1
    return list1

def matrix_build(vocab11, vocab22, dictfilename, suffix):
    dict_file = open(dictfilename,'r')   
    dict_matrix = numpy.zeros(shape=(len(vocab11)+1,len(vocab22)+1))
    counter1 = 0
    for line in dict_file:
        counter1 = counter1 + 1
        line0 = line.strip()
        line1 = line0.split('\t')
        try:
            print line1[0] + suffix
            index1 = int(vocab11.index(line1[0]+suffix))
            try:
                index2 = int(vocab22.index(line1[1]+suffix))
                dict_matrix[index1+1,index2+1] = float(line1[2])
                if index1==0:
                    print str(index1) + " " + str(index2) + line1[0] + " " + line1[1]
            except:
                0
        except: 
            0
    for i in range(len(vocab11)+1):
        if sum(dict_matrix[i,:])==0:
            dict_matrix[i, 0] = 1
    for j in range(len(vocab22)+1):
        if sum(dict_matrix[:, j])==0:
            dict_matrix[0, j] = 1

    return dict_matrix

dict_process()