#takes a corpus in directory path and removes XML tags, stopwords, punctuation, and uppercases, and then lemmatizes and removes stems
# Returns the cleaned corpus in a path specified by out_path
# author: E.D. Gutierrez
# Modified: 16 September 2013
from lxml import etree
from os import walk, sep, path
from nltk.stem.wordnet import WordNetLemmatizer
#from nltk import SnowballStemmer
from nltk.corpus import stopwords
import string
import re
import codecs
lang = 'russian'
stemmer = SnowballStemmer(lang)
#lemmatizer = WordNetLemmatizer()
if lang=='russian':
    stemmer = nltk.stem.snowball.RussianStemmer(True)

def xml_to_text():
    in_path = '/u/metanet/corpolexica/RU/RU-WAC/ruwac-parsed.out'
    out_path = '/u/metanet/clustering/m4source/ru_wac_out_2/'
    split_text(in_path, out_path)
    open('/u/metanet/clustering/multilingual_opinions/xml.out', 'a').write(filename+'\n')                    

def split_text(file_in, out_path):
    with open(file_in, 'r') as infile:
        counter = 0
        str1 = ''
        for line in infile:
            if counter < 40000:
                if line.find('text')>-1:
                    if line.find('<text')>-1:
                        counter+=1
                        filename = str(counter) + '.txt'
                    else:
                        codecs.open(out_path + filename, 'w', 'utf-8').write(str1)
                        str1 = ''
                        open('ru-wac_log.txt', 'w').write(filename + '\n')
                else:
                    line1 = line.split()
                    if (line1[2] not in stopwords.words(lang)):
                        str1 +=  line1[2].decode('utf-8') + ' '
            else:
                0

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