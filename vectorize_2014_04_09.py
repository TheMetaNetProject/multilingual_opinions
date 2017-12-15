 
'''
Last modified on Nov 7, 2013

@author: E.D. Gutierrez email: edg@icsi.berkeley.edu
Treats each line as a document; turns a file into a term-document matrix and wordlist.
'''
import numpy
import scipy.io
import sys


resume = False ### Whether to use old files to resume partially completed previous work

key = sys.argv[2] #'verb_' #verbadj_' #'adj_'
if key[-1]!='_':
    key += '_'
    print key
lang = sys.argv[1]
corpus_name = 'twitter5'
#corpus_name = 'news'
out_dir1 = '/u/metanet/clustering/multilingual_opinions/'+corpus_name+'/vectorize_out/'
in_dir1 = '/u/metanet/clustering/multilingual_opinions/'+corpus_name+'/pos_split_out/'
if key=='verbadj_':
    wordtypes= {'topic': ['noun'], 'opinion': ['verb', 'adj']}  # the first Specify which parts of speech you want to do
else:
    if key=='verb_':
        wordtypes= {'topic': ['noun'], 'opinion': ['verb']}  # the first Specify which parts of speech you want to do
    else:
        wordtypes= {'topic': ['noun'], 'opinion': ['adj']}  # the first Specify which parts of speech you want to do
max_tokens = {'topic': 1, 'opinion': 1} # remove the top max_tokens words; set to 2 if max_doc_freq < 1
if key=='verbadj_':
    max_tokens['opinion'] = 1 # remove the top max_tokens words; set to 2 if max_doc_freq < 1
sample_size = int(5e5)
## OLD SETTINGS: 
## min_tokens = {'topic': 2.5e3, 'opinion': 2e3}# take the top min_tokens words excluding the top max_tokens words
## max_doc_freq = .05 #remove any word type0s that appear in more than max_doc_freq proportion of documents
## OLD SETTINGS ABOVE
max_doc_freq = {}
max_doc_freq['topic'] = .0625
max_doc_freq['opinion'] = .125 #remove any word type0s that appear in more than max_doc_freq proportion of documents
min_tokens = {'topic': 2.5e3, 'opinion': 3e3}# take the top min_tokens words excluding the top max_tokens words
max_docs1 = 3e5
min_doc_length = 4

# Main process: computes term and document vectors

def msgwrite(path, message):
    open(path, 'a').write(message)

def compute_vecs(lang, min_tokens, max_tokens, wordtypes, out_dir = out_dir1, in_dir = in_dir1, max_docs = max_docs1, min_doc_length = 3, max_doc_length = 1e2):
    resume1 = resume
    print('run after pos_splitter.py; run dict_processor2.py or prune.mat next \n')
    print lang
    indices, wordvec, docvec, vocab1, wordcounts, type0_str, vocab_shorter = {}, {}, {}, {}, {}, {}, {}
    for type0 in wordtypes:
        print type0
        type0_str[type0] = ''
        in_filenames = {}
        wordcounts[type0], vocab1[type0], wordvec[type0], docvec[type0] = [], [], [], []
        oldmax = 0
        for pos in wordtypes[type0]:
            type0_str[type0] +=  pos #this specifies the type0 label assigned to output files
            in_filename = in_dir + pos + '_' + corpus_name + '_' + lang + '.txt'
            large_matfile = out_dir + pos + '_' + corpus_name+'_' + lang +'_large.mat'
            large_vocabfile = out_dir +'vocab' + pos + '_' + corpus_name + '_' + lang +'_large.txt'
#            if (resume or True):
#                (resume1, mat_dict, wordvec_pos, docvec_pos, vocab_pos) = load_old(large_matfile, large_vocabfile, type0, oldmax)  #load previous matrix and vocabfiles
#                if oldmax==0:
#                    wordvec[type0] = wordvec_pos
#                else:
#                    wordvec[type0] = numpy.concatenate([wordvec[type0], wordvec_pos + int(oldmax)])
#                (resume1, indices) = try_loadmat(large_matfile, 'indices', indices, 'topic')
#                msgwrite('/u/metanet/clustering/multilingual_opinions/'+corpus_name + 'stage2.txt', ' done with load_old of '+large_vocabfile+'\n')
            if (True):
                print pos + ': .mat not found'
                msgwrite('/u/metanet/clustering/multilingual_opinions/'+corpus_name +  key +  'stage2.txt', lang+' '+pos+' making mat\n')   
                if type0=='topic':
                    (wordvec_pos, docvec_pos, vocab_pos, indices[type0]) = matrixbuild(in_filename, max_doc_length, max_docs)
                else:
                    (wordvec_pos, docvec_pos, vocab_pos, indices[type0]) = matrixbuild(in_filename, max_doc_length, max_docs, indices['topic'])
                scipy.io.savemat(large_matfile, mdict = {'WP':wordvec_pos, 'WDP':docvec_pos, 'indices':indices[type0]})
                write_to_string(vocab_pos, large_vocabfile)
                msgwrite('/u/metanet/clustering/multilingual_opinions/'+corpus_name +  key +  'stage2.txt', lang+' '+pos+'finished making mat\n')
            wordvec_pos = common_words(wordvec_pos, docvec_pos, oldmax, max_doc_freq[type0])
            ## APPEND the FOLLOWING TO THE CORRECT WORD type0
            if (resume or True):
                indices['topic'] = list(numpy.array(indices['topic']))
                if type0=='topic':
                    vocab1[type0] = vocab_pos
                else:
                    for word in vocab_pos:
                        vocab1[type0].append(word+"."+pos)
                msgwrite('/u/metanet/clustering/multilingual_opinions/'+lang+corpus_name+  key + 'log2.txt', lang+' '+pos+'vocab appended\n')
                if oldmax==0:
                    wordvec[type0] = wordvec_pos
                else:
                    wordvec[type0] = numpy.concatenate([wordvec[type0], wordvec_pos + int(oldmax)])
            msgwrite('/u/metanet/clustering/multilingual_opinions/'+corpus_name+  key + 'log2.txt', lang+' '+pos+'wordvec appended\n')
            if oldmax==0:
                docvec[type0] = docvec_pos
            else:
                docvec[type0] = numpy.concatenate([docvec[type0], docvec_pos])
            oldmax = numpy.max(wordvec[type0])+1
            scipy.io.savemat(out_dir + type0 + '_concat' + corpus_name+'_' + lang +'_large.mat', mdict = {'WP_concat':wordvec[type0], 'DP_concat':docvec[type0]})
            msgwrite('/u/metanet/clustering/multilingual_opinions/'+corpus_name+  key + 'log2.txt', lang+' '+type0+'docvec appended\n')
        resume1 = resume
        if (resume or True):
            if type0 == 'topic':
                (resume1, wordcounts) = try_loadmat(out_dir + 'wordcounter_'+type0+lang+'.mat', 'a', wordcounts, type0)
            else:
                (resume1, wordcounts) = try_loadmat(out_dir + 'wordcounter_'+key+lang+'.mat', 'a', wordcounts, type0)
        if not resume1:
            msgwrite('/u/metanet/clustering/multilingual_opinions/'+corpus_name+  key + 'log2.txt', lang+' '+type0+'about to run wordcounter\n')
            wordvec[type0] = wordvec[type0].astype(int)
            wordcounts[type0] = numpy.bincount(numpy.transpose(wordvec[type0])[0])###   wordcounts[type0] = wordcounter(wordvec[type0])
            if type0 == 'topic':
                scipy.io.savemat(out_dir + 'wordcounter_'+type0+lang+'.mat', {'a': wordcounts[type0]})
            else:
                scipy.io.savemat(out_dir + 'wordcounter_'+key+lang+'.mat', {'a': wordcounts[type0]})
        msgwrite('/u/metanet/clustering/multilingual_opinions/'+corpus_name+  key + 'log2.txt', lang+' '+type0+'ran wordcounter\n')
        print('wordcounts:'+ str(len(wordcounts[type0]))) 
        min_tokens[type0] = min(min_tokens[type0], numpy.max(wordcounts[type0]))          
        msgwrite('/u/metanet/clustering/multilingual_opinions/'+corpus_name+  key + 'log2.txt', lang+' '+type0+'finding limit\n')     
        (min_tokens[type0], max_tokens[type0]) = find_limit(min_tokens[type0], max_tokens[type0], wordcounts[type0])
        print '\n cutoffs: ' + str(min_tokens[type0]) + ' - ' +str(max_tokens[type0])
    ## THE FOLLOWING DEPENDS ON THE TOPIC WORDS SO IT'S OUT OF THE LOOP
    (wordvec, docvec, word_lists) = shorten_vectors(wordcounts, wordvec, docvec, min_tokens, max_tokens, min_doc_length, wordtypes)
    for type0 in wordtypes:
        small_matfile = out_dir + type0_str[type0] + '_' + corpus_name + lang +'_small.mat'
        scipy.io.savemat(small_matfile, mdict =  {'WP':wordvec[type0], 'WDP':docvec[type0]})    
        small_vocabfile = out_dir +'vocab_' + type0_str[type0] + '_' + corpus_name + '_' + lang +'_small.txt'
        resume1 = resume
        if resume:
            try:
                vocab_shorter[type0] = file_to_list(small_vocabfile)
            except:
                resume1 = False
        if not resume1:
            vocab_shorter[type0] = shorten_vocab(word_lists[type0], vocab1[type0])
            write_to_string(vocab_shorter[type0], small_vocabfile) 
def try_loadmat(filepath, dict_key_in, outmat, dict_key_out):  # wrapper for .mat file loader
    try:
        a = scipy.io.loadmat(filepath)
        outmat[dict_key_out] = a[dict_key_in]
        return (True, outmat)
    except:
        return(False, outmat)
        
def matrixbuild(infilename, max_doc_length, max_docs, indices=[]):
    infile = open(infilename, 'r')
    debugfile = open(infilename+'.shorter','w')
# Builds a vector of the word type0 identities of each word token, and a vector of the document identities of each word token
    def process_line(get_new_inds, linecounter, indices, line, doccount):
        if get_new_inds:
            words_in_doc = line.split()
            if (len(words_in_doc) >= min_doc_length):
                indices.append(linecounter)
                print 'T1\n'
                return (True, words_in_doc, indices)
            else:
                print 'F2\n'
                return (False, None, indices)
        else:
            if indices[0]==linecounter:
                msgwrite('matbuild_trunc.txt', str(linecounter)+ '\t'+str(doccount)+'\n')
                indices = indices[1:]
                words_in_doc = line.split()
                print 'F3\n'
                return (len(indices)>0, words_in_doc, indices)
            else:
                if (linecounter > indices[-1]):
                    print 'F4\n'
                    return (False,None,[])
                else:
                    print 'F5\n'
                    return (False, None, indices)
    doccount = 0 
    wordcount = 0
    vocab = []
    voccount = 0
    ansatz = 1e8
    wordvector = numpy.zeros((ansatz,1), dtype = int)
    docvector = numpy.zeros((ansatz,1), dtype = int)
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
                        wordvector[wordcount] = vocab.index(word) + 1    
                    voccount = voccount + 1
                    docvector[wordcount] = doccount
                    wordcount = wordcount + 1
                    counter3 = counter3 + 1
        linecounter+=1
        if (len(indices)==0)&(get_new_inds==0):
            msgwrite('wordcount.txt', 'wordcount is'+str(wordcount))
            return (wordvector[:wordcount], docvector[:wordcount], vocab, indices)
    msgwrite('wordcount.txt', 'wordcount is'+str(wordcount))
    infile.close()
    return (wordvector[:wordcount], docvector[:wordcount], vocab, indices)

def common_words(WP, WDP, oldmax, max_doc_freq0):
    sample_size1 = min([sample_size, len(WDP)-1])
    print 'sample size in common words:' + str(sample_size1)
    max_freq = WDP[sample_size1]*max_doc_freq0
    vocab_size = numpy.max(WP)
    last_DP = numpy.zeros((vocab_size,1))
    count_DPs = numpy.zeros((vocab_size,1))
    for i in range(sample_size1):
        if last_DP[int(WP[i]-1)]<WDP[i]:
            last_DP[int(WP[i]-1)] = WDP[i]
            count_DPs[int(WP[i]-1)] += 1
    for i in range(count_DPs.size):
        if count_DPs[i] > max_freq:
            print i
    for i in range(numpy.size(WP,0)):
        if count_DPs[int(WP[i]-1)] > max_freq:
            WP[i] = -oldmax-1
    return WP

def write_to_string(list1, file1):
    string1 = ''
    init = True
    for word in list1:
        if init:
           init = False
           string1 = word
        else:
           string1 += ' '+word
    outfile = open(file1, 'w')
    outfile.write(string1)
    outfile.close()
	
def find_limit(min_tokens, max_tokens, wordcounts):
    totalgreater = 0   
    try:
        metacounts = numpy.bincount([int(i) for i in wordcounts.transpose()[0]])
    except:
        metacounts = numpy.bincount([int(i) for i in wordcounts.transpose()])
    x = metacounts[-1]
    j = 1
    max_limit = j
    continue0 = True
    while ((x < (min_tokens+max_tokens)) and continue0):
        while x <= max_tokens:
            x += metacounts[-j]
            j += 1
            max_limit = j
        try:
            j +=1
            x += metacounts[-j]
            min_limit = j
        except:
            print str(j)
            continue0 = False
    max_limit = len(metacounts) - max_limit
    min_limit = len(metacounts) - min_limit
  #  for j in range(2, len(metacounts)+1):
#        metacounts[-j] = metacounts[-j] + x
 #       x = metacounts[-j]
  #  max_limit = numpy.where(metacounts<max_tokens)
   # min_limit = numpy.where(metacounts<=max_tokens+min_tokens)
    #max_limit = max_limit[0]
#    min_limit = min_limit[0]
 #   min_limit = numpy.max(wordcounts)
  #  max_limit = numpy.max(wordcounts)
   # while totalgreater>max_tokens:
    #    max_limit = max_limit -1
     #   totalgreater = sum(1 for j in wordcounts if j>max_limit)
#    while totalgreater<min_tokens:
 #       min_limit = min_limit - 1
  #      totalgreater = sum(1 for j in wordcounts if (j>min_limit)&(j<max_limit)) 
    try:
        max_limit = max_limit[0]
        min_limit = min_limit[0]
    except:
        pass
    print 'max limit: '+ str(max_limit) + '\t min limit: ' + str(min_limit)
    return (min_limit, max_limit)
	
def file_to_list(filename):
    file1 = open(filename, 'r')
    list1 = []
    for line in file1:
        split_line = line.split()
        for word in split_line:
           list1.append(word)
    return list1

def shorten_vocab(word_lists, vocab1):
 # Returns the shortened vocab list consisting of the words between the frequency cutoffs min_tokens and max_tokens 
    vocab_shorter = []
    for word_ind in word_lists:
        if word_ind > -1:
            vocab_shorter.append('E_R_R')
    count = 0
    for (old_ind, new_ind) in enumerate(word_lists):
        if new_ind > -1:
            vocab_shorter[int(new_ind[0])] = vocab1[old_ind]
    return vocab_shorter
	
def shorten_vectors(wordcounts, wordvec, docvec, min_tokens, max_tokens, min_doc_length, wordtypes):
    resume1 = resume
    #Find words that pass the freq threshhold and assign them new consecutive indices
    counter1 = 0
    wordvec_shorter, docvec_shorter, counts_per_doc = {}, {}, {}
    for type0 in wordtypes:
        docvec[type0] = docvec[type0] - numpy.min(docvec[type0]) + 1
        if (resume or True):
            if type0=='topic':
                (resume1, wordvec_shorter) = try_loadmat(out_dir1 + 'vec_shorters_'+type0+'_'+lang+'.mat', 'wordvec_shorter', wordvec_shorter, type0)
                (resume1, docvec_shorter) = try_loadmat(out_dir1 + 'vec_shorters_'+type0+'_'+lang+'.mat', 'docvec_shorter', docvec_shorter, type0)
            else:
                (resume1, wordvec_shorter) = try_loadmat(out_dir1 + 'vec_shorters_'+key+'_'+lang+'.mat', 'wordvec_shorter', wordvec_shorter, type0)
                (resume1, docvec_shorter) = try_loadmat(out_dir1 + 'vec_shorters_'+key+'_'+lang+'.mat', 'docvec_shorter', docvec_shorter, type0)
            if resume1:
                counts_per_doc[type0] = numpy.zeros((numpy.max(docvec[type0]),1), int)
                counter1 = 0
                for i in range(len(wordvec[type0])):
                    word_id = wordvec[type0][i]
                    doc_id = docvec[type0][i]
                    if wordcounts[type0][int(word_id)] >= min_tokens[type0]:
                        if wordcounts[type0][int(word_id)] < max_tokens[type0]:
                            counts_per_doc[type0][int(doc_id - 1)] += 1 
                            counter1 += 1
        if not resume1:
            msgwrite('/u/metanet/clustering/multilingual_opinions/'+lang+corpus_name+  key + 'svlog.txt', 'loading failed. shortening phase I: '+lang + '\n')
            for type0 in wordtypes:
                wordvec_shorter[type0] = numpy.zeros((len(wordvec[type0]),1),int)
                docvec_shorter[type0] = numpy.zeros((len(docvec[type0]),1),int)
                counts_per_doc[type0] = numpy.zeros((numpy.max(docvec[type0]),1), int)
                msgwrite('/u/metanet/clustering/multilingual_opinions/'+lang+corpus_name+  key + 'svlog.txt', 'shortening phase I: '+lang+ ' '+ type0+'\n') # str(word_id)+'\n')
                # find documents with topic words above the frequency threshhold; remove any words below threshhold
                counter1 = 0
                for i in range(len(wordvec[type0])):
                    word_id = wordvec[type0][i]
                    doc_id = docvec[type0][i]
#                    msgwrite('/u/metanet/clustering/multilingual_opinions/'+corpus_name+  key + 'svlog.txt', 'word_id: ' + str(word_id)+'\n')
                    if wordcounts[type0][int(word_id)] >= min_tokens[type0]:
                        if wordcounts[type0][int(word_id)] < max_tokens[type0]:
                            wordvec_shorter[type0][counter1] = word_id
                            docvec_shorter[type0][counter1] = doc_id
                            counts_per_doc[type0][int(doc_id - 1)] += 1 
                            counter1 += 1
                wordvec_shorter[type0] = wordvec_shorter[type0][:counter1]
                docvec_shorter[type0] = docvec_shorter[type0][:counter1]
                if type0=='topic':
                    scipy.io.savemat(out_dir1 + 'vec_shorters_'+type0+'_'+lang+'.mat', {'wordvec_shorter': wordvec_shorter[type0], 'docvec_shorter': docvec_shorter[type0]})
                else:
                    scipy.io.savemat(out_dir1 + 'vec_shorters_'+key+'_'+lang+'.mat', {'wordvec_shorter': wordvec_shorter[type0], 'docvec_shorter': docvec_shorter[type0]})
# throw out elements that are not in a doc with sufficient topic words above threshhold
    doc_lists = numpy.zeros((max_docs1+1,1), dtype = int)-2  # The doc_list has to be the same for both wordtypes!
    counter_doc = 0
    scipy.io.savemat(out_dir1 + 'counts_per_doc' + lang + '.mat', {'counts_per_doc':counts_per_doc['topic']})
    word_lists = {}
    resume1 = resume
    for type0 in wordtypes:
        msgwrite('/u/metanet/clustering/multilingual_opinions/'+lang+corpus_name+  key + 'svlog.txt', 'shortening phase II: '+lang+ ' '+ type0+'\n') # str(word_id)+'\n')        
        if False: #resume:
            if type0=='topic':
                (resume1, word_lists) = try_loadmat(out_dir1 + 'word_lists_'+type0+'_'+lang+'.mat', 'word_list', word_lists, type0) 
            else:
                (resume1, word_lists) = try_loadmat(out_dir1 + 'word_lists_'+key+'_'+lang+'.mat', 'word_list', word_lists, type0) 
        if not resume1:
            word_lists[type0] = numpy.zeros((numpy.max(wordvec_shorter[type0]),1), dtype = int)-2 # the word_list is different for the two wordtypes
        counter2 = 0
        counter_word = 0
        for i in range(len(wordvec_shorter[type0])):
            try:
                doc_id = docvec_shorter[type0][i]
                if counts_per_doc['topic'][int(doc_id - 1)]>=min_doc_length:
                    try:
                        word_id = wordvec_shorter[type0][i]
                    except:
                        print str(i)+' len = '+str(len(wordvec_shorter[type0]))+' doc_id '+str(doc_id) +'\n'
                        crash
                    new_word_id = word_lists[type0][int(word_id-1)]
                    if new_word_id>-1:
                        word_id = int(new_word_id)
                    else:
          #         msgwrite('/u/metanet/clustering/multilingual_opinions/'+lang+corpus_name+  key + 'svlog.txt', 'word id: '+ str(word_id))
                        word_lists[type0][int(word_id-1)] = int(counter_word)
                        word_id = int(counter_word)
                        counter_word += 1
          #          msgwrite('/u/metanet/clustering/multilingual_opinions/'+lang+corpus_name+  key + 'svlog.txt', ''+ str(word_id)+'\t')
                    new_doc_id = doc_lists[int(doc_id-1)]
                    if (new_doc_id<0):
                        try:
                            doc_lists[int(doc_id-1)] = int(counter_doc)
                            new_doc_id = int(counter_doc)
                            counter_doc += 1
                        except:
                            msgwrite('/u/metanet/clustering/multilingual_opinions/'+lang+corpus_name+  key + 'svlog.txt', 'Error on doc id: '+ str(doc_id)+ ' type0: ' +type0 + '\n')
                    if (new_doc_id>-1):  #not an 'else' statement because the document can be added in the step above
                        doc_id = int(new_doc_id)
                        wordvec_shorter[type0][int(counter2)] = int(word_id)
                        docvec_shorter[type0][int(counter2)] = int(doc_id)
                        counter2 +=1	
            except:
                print 'i = '+str(i)+'\t len(docvec)= '+str(len(docvec_shorter[type0]))+'\t len(wordvec)= '+str(len(wordvec_shorter[type0]))+'\n'
        wordvec_shorter[type0] = wordvec_shorter[type0][:int(counter2)]
        docvec_shorter[type0] = docvec_shorter[type0][:int(counter2)]
        if type0=='topic':
            scipy.io.savemat(out_dir1 + 'vec_shorters_'+type0+'_'+lang+'2.mat', {'wordvec_shorter': wordvec_shorter[type0], 'docvec_shorter': docvec_shorter[type0]})
        else:
            scipy.io.savemat(out_dir1 + 'vec_shorters_'+key+'_'+lang+'2.mat', {'wordvec_shorter': wordvec_shorter[type0], 'docvec_shorter': docvec_shorter[type0]})
        if type0=='topic':
            scipy.io.savemat(out_dir1 + 'word_lists_'+type0+'_'+lang+'2.mat', {'word_list': word_lists[type0]})                     
        else:
            scipy.io.savemat(out_dir1 + 'word_lists_'+key+lang+'.mat', {'word_list': word_lists[type0]})                                 
        scipy.io.savemat(out_dir1 + 'doc_lists_'+lang+'.mat', {'doc_list': doc_lists})                                 
        wordvec_shorter[type0] = wordvec_shorter[type0] + 1
        docvec_shorter[type0] = docvec_shorter[type0] + 1
    return (wordvec_shorter, docvec_shorter, word_lists)

def load_old(large_matfile, large_vocabfile,type0, oldmax):
    try:
        msgwrite('/u/metanet/clustering/multilingual_opinions/'+corpus_name + 'stage2.txt', ' loading '+large_matfile+'\n')
        mat_dict = scipy.io.loadmat(large_matfile)
        msgwrite('/u/metanet/clustering/multilingual_opinions/'+corpus_name + 'stage2.txt', ' loaded '+large_matfile+'\n')
        wordvec_pos = mat_dict['WP']
        docvec_pos = mat_dict['WDP']
        msgwrite('/u/metanet/clustering/multilingual_opinions/'+corpus_name + 'stage2.txt', 'running common_words\n')
        wordvec_pos = common_words(wordvec_pos, docvec_pos, oldmax, max_doc_freq[type0])
        msgwrite('/u/metanet/clustering/multilingual_opinions/'+corpus_name + 'stage2.txt', ' loading '+large_vocabfile+'\n')
        vocab_pos = file_to_list(large_vocabfile)
        msgwrite('/u/metanet/clustering/multilingual_opinions/'+corpus_name + 'stage2.txt', ' loaded '+large_vocabfile+'\n')
        return (True, mat_dict, wordvec_pos, docvec_pos, vocab_pos)
    except:
        return(False, None, None, None, None)
    
compute_vecs(lang, min_tokens, max_tokens, wordtypes)


#def wordcounter(word_vector):
#    voccount = int(numpy.max(word_vector)) + 1
#    wordcounts = numpy.zeros((voccount,1))
#    msgwrite('/u/metanet/clustering/multilingual_opinions/'+lang+corpus_name+  key + 'wclog.txt', 'voccount: '+str(voccount)+'\n')
#    largestcount = 0
#    for i in range(int(voccount)):
#        wordcounts[i] = sum(1 for j in word_vector if (j-1)==i)
#####        msgwrite('/u/metanet/clustering/multilingual_opinions/'+lang+corpus_name+  key + 'wclog2.txt', 'word: '+str(i)+'\n')
#    return (wordcounts)
