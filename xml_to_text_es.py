#takes a corpus in directory path and removes XML tags, stopwords, punctuation, and uppercases, and then lemmatizes and removes stems
# Returns the cleaned corpus in a path specified by out_path
# author: E.D. Gutierrez
# Modified: 16 September 2013
from lxml import etree
from os import walk, sep, path
from nltk.stem.wordnet import WordNetLemmatizer
from nltk import SnowballStemmer
from nltk.corpus import stopwords
import string
import re
lang = 'spanish'
stemmer = SnowballStemmer(lang)
#lemmatizer = WordNetLemmatizer()
wire = 'afp'
def xml_to_text():
    path = '/u/metanet/clustering/m4source/gigaword_es/'+wire
    out_path = '/u/metanet/clustering/m4source/out_es_2/'+wire
    for (dirpath, dirnames, filenames) in walk(path):
        for filename in filenames:
            if True: #filename[-4:] == '.':
                print(filename+' ')
                filenames = split_text(dirpath+'/'+filename, out_path)
                poetic = False # remove_poems(dirpath+'/'+filename)
                for name in filenames:
                    filepath = etree.parse(name)
                    notags = etree.tostring(filepath, encoding='utf8', method='text')
                    notags_tokens = remove_stopwords(notags[notags.find('\n'):].lower().split())  # Remove the BNC header
                    notags = ' '.join(notags_tokens)
                    outfile = open(name,'w')
                    outfile.write(notags)
                    outfile.close()
            open('/u/metanet/clustering/multilingual_opinions/xml.out', 'a').write(filename+'\n')                    

def split_text(file_in, out_path):
    with open(file_in, 'r') as infile:
        counter = 0
        str1 = ''
        filenames = []
        filename_found = False
        count_docs = 0
        for line in infile.readlines():
            if not filename_found&(count_docs<1.5e4):
                str1 = str1 + line
                if line.find('<DOC id=')>-1:
                    filename = line[line.find('<DOC id=')+9: line.find('" type')] + '.txt'
                filename_found = path.isfile(out_path + filename)
                re1 = (line.find('</DOC>')>-1)
                if re1:
                    open(out_path + filename, 'w').write(str1)
                    str1 = ''
                    filenames.append(out_path + filename)
                count_docs +=1
            else:
                0
    return filenames

def remove_stopwords(list1, stem=1):
    for index, token in enumerate(list1):
        token = remove_punctuation(token)
        if (token not in stopwords.words(lang)):
            if stem==1:
                try:
                    list1[index] = stemmer.stem(token)
                except:
                    list1[index] = ''
            else:
                list1[index] = lemmatizer.lemmatize(token)
        else:
            list1[index] = ''
    return list1

def remove_punctuation(token):
    return token.translate(None, string.punctuation)

def is_ascii(token):
    return all((ord(c) < 123)&(ord(c) > 64)  for c in token)
    
xml_to_text()
