'''
Created on Jan 17, 2013

@author: E.D. Gutierrez email: edg@icsi.berkeley.edu
'''
lang = 'en'
w_text = ''
o_text = ''
basedir = '/u/metanet/Parsing/parsedblogs_'+lang+'/'
o_outfilename = basedir+'o_'+lang+'_nocomments_I.txt'
w_outfilename = basedir+'w_'+lang+'_nocomments_I.txt'
for ii in range(48,54):
    number = str(ii)
    infilename = basedir+number+'.lem'
    infile = open(infilename)
    documentcounter = 1
    o_counter = 1
    w_counter = 1
    wtag_list = ['nn', 'nns']
    otag_list = ['jj', 'jjs', 'vb', 'vbd', 'vbg', 'vbn', 'vbp', 'vbz','jjr']
    discardtag_list = ['rb', 'rbr','rbs','in', 'nnp', 'nnps', 'dt', '_:', 'ls', 'fw', '_``','wrb',  'rp','ban_torture-subscribe@yahaoogroups.com_nn', 'sym', 'prp', 'prp$', '$', 'moh\/_nn', 'pdt', 'to', 'md', 'wp$', 'wdt', '-lrb-', 'pos','cc', 'pos' ',', '.', '``', '\'\'', 'uh','cd', '-rrb-',',',':','_\'\'', 'ex', 'wp', '_nnp','__nnp','___nnp','____nnp','_____nnp','_________nnp', '________nnp','_nn','__nn','___nn','____nn','_____nn','___cd','_____rb','_______nnp','____rb','__fw','____fw','pub_nn']
    for line in infile:
        words = str.lower(line)
        words = words.split()
        for word in words:
            tag = word[(word.find('_')+1):]
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