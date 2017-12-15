'''
Created on 17 Jan 2013

Last Modified: 29 Jan 2013

@author: E.D. Gutierrez email: edg@icsi.berkeley.edu
'''
w_text = ''
o_text = ''
lang = 'es'
#basedir = '/u/metanet/Parsing/parsedblogs_en/'
basedir = '/u/metanet/Parsing/parsedblogs_'+lang+'/'
o_outfilename = basedir+'o_'+lang+'nocomments_C.txt'
w_outfilename = basedir+'w_'+lang+'nocomments_C.txt'
for ii in range(12,18):
    number = str(ii)
    infilename = basedir+number+'.lem'#matized'
    infile = open(infilename)
    documentcounter = 1
    o_counter = 1
    w_counter = 1
    if lang=='es':
        wtag_list = ['nc']
        otag_list = ['vm', 'aq', 'rg']
        discardtag_list = ['p0', 'np','pr','pp','da','sp', 'rn', 'di','fc','fp', 'cs','cc', 'vs','pi','va','fx','z']
    else:
        wtag_list = ['nn', 'nns']
        otag_list = ['jj', 'jjs', 'vb', 'vbd', 'vbg', 'vbn', 'vbp', 'vbz','jjr']
        discardtag_list = ['rb', 'rbr','rbs','in', 'nnp', 'nnps', 'dt', '_:', 'ls', 'fw', '_``','wrb',  'rp','ban_torture-subscribe@yahaoogroups.com_nn', 'sym', 'prp', 'prp$', '$', 'moh\/_nn', 'pdt', 'to', 'md', 'wp$', 'wdt', '-lrb-', 'pos','cc', 'pos' ',', '.', '``', '\'\'', 'uh','cd', '-rrb-',',',':','_\'\'', 'ex', 'wp', '_nnp','__nnp','___nnp','____nnp','_____nnp','_________nnp', '________nnp','_nn','__nn','___nn','____nn','_____nn','___cd','_____rb','_______nnp','____rb','__fw','____fw','pub_nn']
    for line in infile:
        words = str.lower(line)
        words = words.split()
        for word in words:
            try:
                tag = word[(word.find('_')+1):(word.find('_')+3)]
                word = word[:word.find('_')]
            except:
                tag = word[(word.find('_')+1):(word.find('_')+2)]
                word = word[:word.find('_')]
            try:
                wtag_list.index(tag)
                w_text = w_text+word + ' '          
            except:
                try:
                    otag_list.index(tag)
                    o_text = o_text + word + ' '
                except:
                    try:
                        discardtag_list.index(tag)
                    except:
                        discardtag_list.append(tag)
                        print tag+' '+number
        w_text = w_text + '\n'
        o_text = o_text + '\n'
outfile1 = open(o_outfilename,'w')
outfile1.write(o_text)
outfile1.close()
outfile2 = open(w_outfilename,'w')
outfile2.write(w_text)
outfile2.close()