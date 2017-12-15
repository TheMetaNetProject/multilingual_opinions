########################################################
# Unit testing utilities
########################################################
def revengineer(vocab, wordvec, docvec, outpath):
    outfile = open(outpath, 'w')
    doc = 0
    str1 = ''
    for i in range(len(wordvec)):
        if docvec[i]!=doc:
            doc = docvec[i]
            outfile.write(str1+'\n')
            str1 = ''
        else:
            str1 = str1 + ' ' + vocab[wordvec[i]]
    outfile.close()