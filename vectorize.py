'''
Last modified on Nov 7, 2013

@author: E.D. Gutierrez email: edg@icsi.berkeley.edu
Treats each line as a document; turns a file into a term-document matrix and wordlist.


'''
import numpy
import numpy as np
import scipy.io
import sys
import collections
import pickle

# shell input args:
# $1: language--two letter code: es or ru or en
# $2: key (i.e. opinion word types)--either verb_, adj_ or verbadj_
# $3: corpus_name --e.g., 'news' or 'twitter5'

resume = False ### Whether to use old files to resume partially completed previous work
try:
    key = sys.argv[2] #'verb_' #verbadj_' #'adj_'
    if key[-1]!='_':
        key += '_'
        print key
    lang = sys.argv[1]
    corpus_name = sys.argv[3]
    basepath = '/u/metanet/clustering/multilingual_opinions/'

except IndexError:
    key = 'verbadj_'; lang = 'en'; corpus_name = 'twitter5'
    basepath = 'C:/Users/H/Documents/'

out_dir1 = basepath+corpus_name+'/vectorize_out/'
in_dir1 = basepath+corpus_name+'/pos_split_out/'
#corpus_name = 'news'
if key=='verbadj_':
    wordtypes= {'topic': ['noun'], 'opinion': ['verb', 'adj']}  # the first Specify which parts of speech you want to do
else:
    if key=='verb_':
        wordtypes= {'topic': ['noun'], 'opinion': ['verb']}  # the first Specify which parts of speech you want to do
    else:
        wordtypes= {'topic': ['noun'], 'opinion': ['adj']}  # the first Specify which parts of speech you want to do
max_tokens = {'topic': int(0), 'opinion': int(0)} # remove the top max_tokens words
if key=='verbadj_':
    max_tokens['opinion'] = int(0) # remove the top max_tokens words
sample_size = int(2.5e5)
## OLD SETTINGS:
## min_tokens = {'topic': 2.5e3, 'opinion': 2e3}# take the top min_tokens words excluding the top max_tokens words
## max_doc_freq = .05 #remove any word type0s that appear in more than max_doc_freq proportion of documents
## OLD SETTINGS ABOVE
max_doc_freq = {}
max_doc_freq['topic'] = .0625
max_doc_freq['opinion'] = .125 #remove any word type0s that appear in more than max_doc_freq proportion of documents
min_tokens = {'topic': int(2.5e3), 'opinion': int(2.5e3)}# take the top min_tokens words excluding the top max_tokens words
max_docs1 = 1.5e5
min_doc_length = 4
max_wordvec_length = int(1e7)  #maximum pre-condensation length of wordvec and docvec

########################################################
#  MISCELLANEOUS UTILITY FUNCTIONS                     #
########################################################
def msgwrite(path, message):
    """Function that writes a message to a path
    :param path: The path to write to
    :type path: str.
    :param message: the message to write
    :type message: str.
    :returns: None
    """
    open(path, 'a').write(message)
def intarray(list1):
    """Function that turns a list into a numpy array
    :param list1: The list
    :type list: list.
    :returns: an object of type np.array with dtype='int'
    """
    return numpy.array(list1,dtype='int')

########################################################
# Main process: computes term and document vectors     #
########################################################
def compute_vecs(lang, min_tokens, max_tokens, wordtypes, out_dir = out_dir1, in_dir = in_dir1, max_docs = max_docs1, min_doc_length = 3, max_doc_length = 1e2):
    """Main process: computes term and document vectors
    :param lang: The language we're computing vectors for. 'en', 'es', or 'ru'
    :type lang: str.
    :param min_tokens: the length of the vocab/lexicon that we want to return
    :type min_tokens: int.
    :param max_tokens: exclude the max_tokens most frequent words from the vocab/lexicon
    :type max_tokens: int.
    :param wordtypes: a dict that specifies what wortypes are topic and what wordtypes are opinion
    :type wordtypes: dict.
    :param out_dir: directory into which to write the output
    :type out_dir: str.
    :param in_dir: directory from which to read the input (i.e., the formatted documents)
    :type in_dir: str.
    :param max_docs: maximum number of documents to take.
    :type max_docs: int.
    :param min_doc_length: take only documents with a doc length >min_doc_length.
    :type: min_doc_length: int.
    :param max_doc_length: take only the first max_doc_length words of any document.
    :type: int.
    :returns: None
    """
    resume1 = resume
    print('run after pos_splitter.py; run dict_processor2.py or prune.mat next \n')
    print lang
    indices, wordvec, docvec, vocab1, wordcounts, type0_str, vocab_shorter, max_freq, min_freq = {}, {}, {}, {}, {}, {}, {},{},{}
    for type0 in wordtypes.keys():
        print type0
        type0_str[type0] = ''
        in_filenames = {}
        wordcounts[type0], vocab1[type0], wordvec[type0], docvec[type0] = [], [], [], []
        oldmax = 0
        small_matfile = out_dir + type0_str[type0] + '_' + corpus_name + lang +'_uncondensed.mat'
        try:
            A = scipy.io.loadmat(out_dir + type0 + '_concat' + corpus_name+'_' + lang +'_large.mat')
            wordvec[type0] = A['WP_concat'].transpose().tolist()[0]
            A['WP_concat'] = []
            docvec[type0] = A['DP_concat'].transpose().tolist()[0]
            A = {}
            msgwrite(basepath+corpus_name +  key +  'stage2.txt', lang+' '+type0+' loaded wordvec and docvec from source\n')
        except IoError:
            for pos in wordtypes[type0]:
                type0_str[type0] +=  pos #this specifies the type0 label assigned to output files
            for pos in wordtypes[type0]:
                in_filename = in_dir + '_'.join([pos, corpus_name,lang+'.txt'])
                large_matfile = out_dir + '_'.join([pos, corpus_name, lang, 'large.mat'])
                large_vocabfile = out_dir +'_'.join(['vocab',pos,corpus_name,lang,'large.txt'])
                print pos + ': .mat not found'
                msgwrite(basepath+corpus_name +  key +  'stage2.txt', lang+' '+pos+' making mat\n')
                indices[type0] = []
                try:
                    a = scipy.io.loadmat(large_matfile, oned_as='row')
                    wordvec_pos = a['WP'][0]
                    docvec_pos = a['WDP'][0]
                    print 'shape'
                    print int(docvec_pos.shape[0])
                    indices[type0] = a['indices'][0]
                    vocab_pos = file_to_list(large_vocabfile)
                except IoError:
                    (wordvec_pos, docvec_pos, vocab_pos, indices[type0]) = matrixbuild(in_filename, max_doc_length, max_docs,indices['topic'])
                    scipy.io.savemat(large_matfile, mdict = {'WP':wordvec_pos, 'WDP':docvec_pos, 'indices':indices[type0]}, oned_as='row')
                    write_to_string(vocab_pos, large_vocabfile)
                    msgwrite(basepath + corpus_name +  key +  'stage2.txt', lang+' '+pos+'finished making mat\n')
                (wordvec_pos, docvec_pos) = common_words(wordvec_pos, docvec_pos, max_doc_freq[type0])
                ## APPEND the FOLLOWING TO THE CORRECT WORD type0
                if type0=='opinion':
                    vocab_pos2 = []
                    for (i,word) in enumerate(vocab_pos):
                        vocab_pos2.append(word+'.'+pos)
                    vocab_pos = vocab_pos2
                    #vocab_pos = [word+'.'+pos for word in vocab_pos]
                for word in vocab_pos:
                    vocab1[type0].append(word)
                msgwrite(basepath+lang+corpus_name+  key + 'log2.txt', lang+' '+pos+'vocab appended\n')
                if oldmax==0:
                    wordvec[type0] = wordvec_pos
                else:
                    wordvec[type0] = numpy.concatenate([wordvec[type0], wordvec_pos + int(oldmax)])
                msgwrite(basepath+corpus_name+  key + 'log2.txt', lang+' '+pos+'wordvec appended\n')
                if oldmax==0:
                    docvec[type0] = docvec_pos
                else:
                    docvec[type0] = numpy.concatenate([docvec[type0], docvec_pos])
                oldmax = numpy.max(wordvec[type0])+1
            print 'voc length '+ type0 +': ' + str(len(vocab1[type0]))        
            scipy.io.savemat(out_dir + type0 + '_concat' + corpus_name+'_' + lang +'_large.mat', mdict = {'WP_concat':wordvec[type0], 'DP_concat':docvec[type0]})
            msgwrite(basepath+corpus_name+  key + 'log2.txt', lang+' '+type0+'docvec appended\n')
            wordvec[type0] = wordvec[type0].astype(int)
            msgwrite(basepath+corpus_name+  key + 'log2.txt', lang+' '+type0+'removing rare/common words\n')
      #      for word in vocab1[type0]:
    #            print bytes(word).decode('utf-8')
       #         print word
        #        print '\t' + str(len(word)) + '\n' 
            scipy.io.savemat(small_matfile, mdict =  {'WP':wordvec[type0], 'WDP':docvec[type0]})
    #            write_corpus(vocab1[type0],wordvec[type0]-1,docvec[type0],small_matfile+'.corpus.txt')
            (wordvec[type0], docvec[type0]) = remove_extremefreqs(wordvec[type0], docvec[type0], max_tokens[type0], min_tokens[type0])
    ## THE FOLLOWING DEPENDS ON THE TOPIC WORDS SO IT'S OUT OF THE LOOP
    for type0 in wordtypes.keys():
        wordvec[type0] = wordvec[type0][:max_wordvec_length]
        docvec[type0] = docvec[type0][:max_wordvec_length]
        msgwrite(basepath+corpus_name+  key + 'log2.txt', lang+' '+type0+'wordvec length clipped at '+str(max_wordvec_length)+'\n')
    msgwrite(basepath+corpus_name+  key + 'log2.txt', lang+' '+type0+'condensing vectors\n')

    (wordvec, docvec, word_lists) = condense(wordvec, docvec, min_doc_length, wordtypes)
    msgwrite(basepath+corpus_name+  key + 'log2.txt', lang+' '+type0+'saving\n')
    for type0 in wordtypes:
        
        small_matfile = out_dir +  '_'.join(['vocab',type0_str[type0],corpus_name,lang,'small.mat'])
        scipy.io.savemat(small_matfile, mdict =  {'WP':wordvec[type0], 'WDP':docvec[type0], 'word_lists':word_lists[type0]})
        small_vocabfile = out_dir +'_'.join(['vocab',type0_str[type0],corpus_name,lang,'small.txt'])
        vocab_shorter[type0] = [vocab1[type0][item] for item in word_lists[type0]]        
        if type0=='opinion':
            scipy.io.savemat('wordlists.mat',{'word':word_lists[type0]})
        write_to_string(vocab_shorter[type0], small_vocabfile)
#        write_corpus(vocab_shorter[type0],wordvec[type0], docvec[type0], small_vocabfile+'.corpus.txt')

def write_corpus(vocab, WP, DP, filename):
    """Reconstructs the corpus using the wordvec and docvec, and writes the (reconstructed) corpus to a file. Only used for debugging purposes
    :param vocab: the list with the vocab elements
    :type vocab:list of str.
    :param WP: vector of word indices.  list format is best, but 1darray should work too.
    :type WP:list.
    :param DP: vector of document indices.  list format is best, but 1darray should work too.
    :type DP: list.
    :param filename: filepath of the output corpus reconstruction
    :type filename: str.
    :returns: None
    """
    file1 = open(filename,'w')
    for (i,j) in enumerate(WP):
        file1.write(vocab[j]+' ')
        ii = min(i+1, len(DP)-1)
        if DP[ii]>DP[i]:
            file1.write('\n')
    file1.close()

def file_to_list(filename):
    """Creates a list that contains every line from a text file in a separate list item.
    :param filename: the filepath of the text file containing the list
    :type filename: str.
    :returns: list1, a list of strings with each item being a line from filename
    """
    file1 = open(filename, 'r')
    list1 = []
    for line in file1:
        list1.append(line.strip())
    return list1

def write_to_string(list1, file1):
    """Creates a list that contains every line from a text file in a separate list item.
    :param list1: the list of str entries to be written to file1.
    :type list1: list.
    :param file1: the filepath of the text file that will containe the list
    :type file1: str.
    :returns: None.
    """
    outfile = open(file1, 'w')
    outfile.write("\n".join(list1))
    outfile.close()

def counter(array):
    """A wrapper for the collections.Counter object
    :param array: a numpy 1darray
    :type array: array
    :returns: collections.Counter object
    """
    try:
        return collections.Counter(array.tolist())
    except:
        return collections.Counter(array)

def matrixbuild(infilename, max_doc_length, max_docs, indices=[]):
    """Builds a word vector and document vector given a corpus file.
    :param infilename: path of input file
    :type infilename: str.
    :param max_doc_length: maximum number of tokens to take from a document
    :type max_doc_length: int.
    :param max_docs: maximum number of documents to take
    :type max_docs: int.
    :param indices: (optional; deprecated) a list of line numbers we want to take 
    :type indices: list.
    :returns: (wordvector, docvector, vocab, indices)
    """
    infile = open(infilename, 'r')
    debugfile = open(infilename+'.shorter','w')
# Builds a vector of the word type0 identities of each word token, and a vector of the document identities of each word token
    def process_line(get_new_inds, linecounter, indices, line, doccount):
        if get_new_inds:
            words_in_doc = line.split()
            if (len(words_in_doc) >= min_doc_length):
                indices.append(linecounter)
                return (True, words_in_doc, indices)
            else:
                return (False, None, indices)
        else:
            if indices[0]==linecounter:
                msgwrite('matbuild_trunc.txt', str(linecounter)+ '\t'+str(doccount)+'\n')
                indices = indices[1:]
                words_in_doc = line.split()
                return (len(indices)>0, words_in_doc, indices)
            else:
                if (linecounter > indices[-1]):
                    return (False,None,[])
                else:
                    return (False, None, indices)
    doccount = 0
    wordcount = 0
    vocab = []
    voccount = 0
    ansatz = 1e8
    wordvector = numpy.zeros(ansatz, dtype = int)
    docvector = numpy.zeros(ansatz, dtype = int)
    get_new_inds = (len(indices)==0)
    linecounter = 0
    for line in infile.readlines():
        (addDoc,words_in_doc, indices) = process_line(get_new_inds, linecounter, indices, line, doccount)
        if addDoc:
            debugfile.write(line)
            doccount = doccount + 1
            counter3 = 0
            for word in words_in_doc:
                if counter3 <=max_doc_length:
                    try:
                        wordvector[wordcount] = vocab.index(word) + 1
                    except:
                        vocab.append(word)
                    voccount = voccount + 1
                    docvector[wordcount] = doccount
                    wordcount = wordcount + 1
                    counter3 = counter3 + 1
        linecounter+=1
        if (len(indices)==0)&(get_new_inds==0):
            msgwrite('wordcount.txt', 'wordcount is'+str(wordcount))
            return (wordvector[:wordcount], docvector[:wordcount], vocab, indices)
    print('word num ' + str(len(vocab)))
    msgwrite('wordcount.txt', 'wordcount is'+str(wordcount))
    indices = list(intarray(indices))
    infile.close()
    return (wordvector[:wordcount], docvector[:wordcount], vocab, indices)

def common_words(WP, WDP, max_doc_freq0):
    """Gets the most vocab of the most common words in the corpus
    :param WP: wordvector (list of ints)
    :type WP: list.
    :param WDP: docvector (list of ints)
    :type WDP: list.
    :param max_doc_freq0: maximum number of documents
    :type max_doc_freq0: int.
    :returns (docvec, wordvec)
    """
    sample_size1 = min([sample_size, len(WDP)-1])
    print 'sample size in common words:' + str(sample_size1)
    max_freq = WDP[sample_size1]*max_doc_freq0
    vocab_size = numpy.max(WP)
    last_DP = numpy.zeros(vocab_size+1)
    count_DPs = numpy.zeros(vocab_size+1)
    for i in range(sample_size1):
        if last_DP[int(WP[i])]<WDP[i]:
            last_DP[int(WP[i])] = WDP[i]
            count_DPs[int(WP[i])] += 1
    for i in range(count_DPs.size):
        if count_DPs[i] > max_freq:
            print i
    new_WP = [j for (i,j) in enumerate(WP) if count_DPs[j]<max_freq]
    try:
        new_DP = [WDP[i] for (i,j) in enumerate(WP) if count_DPs[j]<max_freq]
    except:
        scipy.io.savemat(basepath+'dump.mat', {'WP':WP})
        try:
            for (i,j) in enumerate(WP):
                count_DPs[j]
        except:
            print str(j)
            crashnow
    return (intarray(new_WP), intarray(new_DP))

def remove_extremefreqs(wordvec,docvec,max_tokens,min_tokens):
    """Removes the most frequent words and the least frequent words from the 
    lexicon.
    :param wordvec: vector containing the word indices representing the corpus
    :type wordvec: list.
    :param docvec:  vector containing the document indices representing the corpus
    :type docvec: list.
    :param max_tokens: remove tokens that appear more than max_tokens times
    :type max_tokens: int.
    :param min_tokens: remove tokens that appear less than min_tokens times
    :type min_tokens: int.
    :returns:the wordvec and docvec without the removed words
    """
    most_common = counter(wordvec).most_common(max_tokens+min_tokens)
    most_common = most_common[max_tokens:]
    print '\n cutoffs: ' + str(most_common[-1][1]) + ' - ' +str(most_common[0][1])
    most_common_tokens = dict(most_common).keys()
    wordvec1 = [j for j in wordvec if j in most_common_tokens]
    docvec1 = [docvec[i] for (i,j) in enumerate(wordvec) if j in most_common_tokens]
    return (wordvec1, docvec1)

def condense(wordvec, docvec, min_doc_length, wordtypes):
    """Gets a list of documents that have at least min_doc_length topic words
    :param wordvec: vector of word indices (ints) representing the corpus
    :type wordvec: list.
    :param docvec: vector of doc indices (ints) representing the corpus
    :type docvec: list.
    :param min_doc_length: minimum length of documents to include in vectors
    :type min_doc_length: int.
    :param wordtypes: a dict that specifies what wortypes are topic and what wordtypes are opinion
    :type wordtypes: dict.
    :returns: (wordvec, docvec, unique_words)
    """
    unique_docs = list(set(docvec['topic']))
    words_per_doc = counter(docvec['topic'])
    unique_docs = [i for i in unique_docs if words_per_doc[i]>=min_doc_length]
    # remove documents that don't have enough topic words
    docvec_shorter, wordvec_shorter, unique_words = {},{},{}
    for type0 in wordtypes:
        msgwrite(basepath+'condenselog2.txt', 'step e\n')
        msgwrite(basepath+'veclengthlog.txt',str(len(docvec[type0]))+'\n')
#        unique_docs = unique_docs[:int(5e5)]
        msgwrite(basepath+'condenselog2.txt', 'length of unique_docs:'+str(len(unique_docs))+'\n')
#        wordvec_shorter0 = [j for (i,j) in enumerate(wordvec[type0]) if docvec[type0][i] in unique_docs]
        wordvec_shorter0 = []
        prev = -100
        for (i, j) in enumerate(wordvec[type0]):
            if docvec[type0][i]==prev:
                wordvec_shorter0.append(j)
            elif docvec[type0][i] in unique_docs:
                prev = docvec[type0][i]
                wordvec_shorter0.append(j)
                if i % 1000==0:
                    msgwrite(basepath+'proglog-temp.txt', str(docvec[type0][i])+'\n')
        msgwrite(basepath+'condenselog2.txt', 'step f\n')
        docvec_shorter0 = [j for (i,j) in enumerate(docvec[type0]) if j in unique_docs]
        msgwrite(basepath+'condenselog2.txt', 'step g\n')
        #condense the indices assigned to the words
        unique_words[type0] = list(set(wordvec_shorter0))
        msgwrite(basepath+'condenselog2.txt', 'step h\n')
        wordvec_shorter[type0] = intarray([unique_words[type0].index(j) for j in wordvec_shorter0])
        msgwrite(basepath+'condenselog2.txt', 'step i\n')
        docvec_shorter[type0] = intarray([unique_docs.index(j) for j in docvec_shorter0])
        msgwrite(basepath+'condenselog2.txt', 'step j\n')
        unique_words[type0] = intarray(unique_words[type0])
    return (wordvec_shorter, docvec_shorter, unique_words)

compute_vecs(lang, min_tokens, max_tokens, wordtypes)


################################################################
DEPRECATED
#################################################################
def vec_wrapper(type0_str, type0, pos, corpus_name, lang, in_dir, out_dir, key, indices, max_doc_length, max_docs, max_doc_freq, oldmax, vocab1, wordvec, docvec):
    """Deprecated function.
    """
    in_filename = in_dir + pos + '_' + corpus_name + '_' + lang + '.txt'
    large_matfile = out_dir + pos + '_' + corpus_name+'_' + lang +'_large.mat'
    large_vocabfile = out_dir +'vocab' + pos + '_' + corpus_name + '_' + lang +'_large.txt'
    print pos + ': .mat not found'
    msgwrite(basepath+corpus_name +  key +  'stage2.txt', lang+' '+pos+' making mat\n')
    indices[type0] = []
    try:
        a = scipy.io.loadmat(large_matfile, oned_as='row')
        wordvec_pos = a['WP'][0]
        docvec_pos = a['WDP'][0]
        indices[type0] = a['indices'][0]
        vocab_pos = file_to_list(large_vocabfile)
    except:
        (wordvec_pos, docvec_pos, vocab_pos, indices[type0]) = matrixbuild(in_filename, max_doc_length, max_docs,indices['topic'])
        scipy.io.savemat(large_matfile, mdict = {'WP':wordvec_pos, 'WDP':docvec_pos, 'indices':indices[type0]})
        write_to_string(vocab_pos, large_vocabfile)
        msgwrite(basepath+corpus_name +  key +  'stage2.txt', lang+' '+pos+'finished making mat\n')
        (wordvec_pos, docvec_pos) = common_words(wordvec_pos, docvec_pos, max_doc_freq[type0])
        ## APPEND the FOLLOWING TO THE CORRECT WORD type0
        if type0=='opinion':
            vocab_pos = [word+'.'+pos for word in vocab_pos]
        for word in vocab_pos:
            vocab1[type0].append(word)
        msgwrite(basepath+lang+corpus_name+  key + 'log2.txt', lang+' '+pos+'vocab appended\n')
        if oldmax==0:
            wordvec[type0] = wordvec_pos
        else:
            wordvec[type0] = numpy.concatenate([wordvec[type0], wordvec_pos + int(oldmax)])
        msgwrite(basepath+corpus_name+  key + 'log2.txt', lang+' '+pos+'wordvec appended\n')
        if oldmax==0:
            docvec[type0] = docvec_pos
        else:
            docvec[type0] = numpy.concatenate([docvec[type0], docvec_pos])
        oldmax = numpy.max(wordvec[type0])+1
        print 'voc length '+ type0 +': ' + str(len(vocab1))
        return (wordvec, docvec, oldmax, vocab1, indices)

def load_old(large_matfile, large_vocabfile,type0, oldmax):
    """Deprecated function.
    """
    try:
        msgwrite(basepath+corpus_name + 'stage2.txt', ' loading '+large_matfile+'\n')
        mat_dict = scipy.io.loadmat(large_matfile)
        msgwrite(basepath+corpus_name + 'stage2.txt', ' loaded '+large_matfile+'\n')
        wordvec_pos = mat_dict['WP']
        docvec_pos = mat_dict['WDP']
        msgwrite(basepath+corpus_name + 'stage2.txt', 'running common_words\n')
        (wordvec_pos, docvec_pos) = common_words(wordvec_pos, docvec_pos, max_doc_freq[type0])
        msgwrite(basepath+corpus_name + 'stage2.txt', ' loading '+large_vocabfile+'\n')
        vocab_pos = file_to_list(large_vocabfile)
        msgwrite(basepath+corpus_name + 'stage2.txt', ' loaded '+large_vocabfile+'\n')
        return (True, mat_dict, wordvec_pos, docvec_pos, vocab_pos)
    except IoError:
        return(False, None, None, None, None)


def try_loadmat(filepath, dict_key_in, outmat, dict_key_out):  # wrapper for .mat file loader
    """Deprecated function.
    """
    try:
        a = scipy.io.loadmat(filepath, oned_as='row')
        outmat[dict_key_out] = a[dict_key_in]
        return (True, outmat)
    except:
        return(False, outmat)


def shorten_vocab(word_lists, vocab1):
    """Deprecated function.
    """
    vocab_shorter = []
    for i in range(len(word_lists)):
        vocab_shorter.append(vocab1[word_lists[i]])
    return vocab_shorter