'''
Created on 17 Jan 2013

Last Modified: 23 Oct 2013

@author: E.D. Gutierrez email: edg@icsi.berkeley.edu

Creates one .txt file per part-of-speec from a corpus of distinct .txt files

This is the first file in the series
'''
import os
import re
import sys

wordtypes1 =  ('verb', 'adj', 'noun') 
#langs1 = [['ru', 'RU'], ['en', 'EN'], ['es', 'ES']]
langs1 = [['ru', 'RU']]
#basedir = '/u/metanet/Parsing/parsedblogs_'+lang+'/'
corpus_name = 'news'
out_dir1 = '/u/metanet/clustering/multilingual_opinions/'+corpus_name+'/pos_split_out/'
if not os.path.exists(out_dir1):
    os.makedirs(out_dir1)
base = '/n/picnic/xw/metanet/temp/pos/'
#in_dir1 = {'en': base+'EN/', 'es': base+'ES/', 'ru': base+'RU/'}  
in_dir1 = {'en': base+'EN/', 'es': base+'ES/', 'ru': base+'RU/'}  
infile_extension = '.final'
#wordtags = {'en': {'adj': ['jj', 'jjs', 'jjr'], 'verb': ['vb', 'vbd', 'vbg', 'vbn', 'vbp', 'vbz'], 'noun': ['nn', 'nns']}, 
#    'es': {'adj': ['aq','rg'], 'verb': ['vm'], 'noun':['nc']},
#    'ru': {'adj': ['ad', 'adjective...'], 'verb': ['ve', 'verb...'], 'noun':['no', 'noun...']}
#    }

wordtags1 = {'en': {'adj': ['jj', 'jjs', 'jjr', 'jj$', 'jjs%', 'jjr$'], 'verb': ['vb', 'vbd', 'vbg', 'vbn', 'vbp', 'vbz', 'vb$', 'vbd$', 'vbg$', 'vbn$', 'vbp$', 'vbz$'], 'noun': ['nn', 'nns', 'nnp', 'nnps','nn$', 'nns$', 'nnp$', 'nnps$']}, 
   'es': {'adj': ['adj','aq','rg'], 'verb': ['vm', 'vlfin', 'vlinf', 'vladj'], 'noun':['nc', 'np']},
    'ru': {'adj': ['af'], 'verb': ['vm', 'vlfin', 'vlinf', 'vladj'], 'noun':['nc', 'np']}
    }

    
        
def pos_splitter(lang, wordtypes, wordtags, in_dir, out_dir, corpus_name):
    print(lang+'\n')
    discardtag_list = ''
    tag_list = {}
    text = {}
    outfilenames = {}
    outfiles = {}
#    type_counter = {}
    for type in wordtypes:
        outfilenames[type] = out_dir+type+'_'+corpus_name+'_'+ lang +'.txt'
        outfiles[type] = open(outfilenames[type], 'w')
        tag_list[type] = wordtags[type]
        print wordtags[type][0]
        text[type] = ''
#        type_counter[type] = 1
    os.chdir(in_dir)
    print 'tag types created\n'
    losttags = ['asdfasdf']
    for file in os.listdir(in_dir):
        if file[-len(infile_extension):]==infile_extension:
            print 'starting file '+ str(file)+'\n'
            infile = open(file, 'r')
    #        documentcounter = 1
            line1 = ''
            for line in infile:
                line = line.replace('\xef\xbb\xbf\xd0\x9c\xd0\xbe\xd1\x81\xd0\xba\xd0\xb2\xd0\xb0.Ncfsnn ,., 1.Mc---d \xd1\x8f\xd0\xbd\xd0\xb2\xd0\xb0\xd1\x80\xd1\x8c.Ncmsgn \xd0\xa0\xd0\x98\xd0\x90.Ncnsgn \xd0\xbd\xd0\xbe\xd0\xb2\xd0\xbe\xd1\x81\xd1\x82\xd1\x8c.Ncfpnn', 'zyxwvuuvwxyz')
                line = line.replace('\xef\xbb\xbf\xd0\xa0\xd0\x98\xd0\x90.Ncnsgn \xd0\xbd\xd0\xbe\xd0\xb2\xd0\xbe\xd1\x81\xd1\x82\xd1\x8c.Ncfpnn', 'zyxwvuuvwxyz')
                if line!=line1:
                    words = str.lower(line)
                    words.replace('|', '')
                    words = words.split()
                    for word in words:
                        if word=='zyxwvuuvwxyz':
                            for type in wordtypes: #clear the cache after every line
                                text[type] = text[type] + '\n'
                                outfiles[type].write(text[type])
                                text[type] = ''                        
                        else:
                            sep_position = word.find('.')
                            tag = word[(sep_position+1):]
                            if lang == 'ru':
                                tag = tag[0:2]
                            word = word[:sep_position]
                            found = 0
                            if not(re.search('[0-9]', word)==None)&(len(word)>=3)&(re.search('<', word)==None)&(re.search('>', word)==None):
                                found = 1
                            for type in wordtypes:
                                if not found:
                                    try:
                                        tag_list[type].index(tag)
                                        found = 1
                                        text[type] = text[type] + word + ' '       
                                    except ValueError:
                                        try:
                                            losttags.index(tag)
                                        except:
                                            print tag
                                            losttags.append(tag)
                    for type in wordtypes: #clear the cache after every line
                        text[type] = text[type] + '\n'
                        outfiles[type].write(text[type])
                        text[type] = ''
                    line1 = line
    for type in wordtypes:
        outfiles[type].close()
        
def main_func(langs,corpus_name, wordtags = wordtags1, in_dir = in_dir1, out_dir = out_dir1, wordtypes = wordtypes1):
    print 'run vectorize.py next'
    for lang in langs:
        pos_splitter(lang, wordtypes, wordtags[lang], in_dir[lang], out_dir, corpus_name)
    
main_func([sys.argv[1]], corpus_name, wordtags1, in_dir1, out_dir1)
