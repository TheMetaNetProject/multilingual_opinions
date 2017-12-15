function [outfile] = BOLDA_DataGen(lang1, lang2, opinion_words, corpus_name)
    basedir = '/u/metanet/clustering/multilingual_opinions/'; disp([basedir,'\n'])
     addpath(genpath([basedir, corpus_name, '/vectorize_out/']))
     addpath(basedir)
     addpath(basedir,'BOLDAnew/')
    topic_words = 'noun';
    outfile = [basedir,corpus_name,'-data', lang1,'-',lang2, '_', opinion_words, '.mat'];
fileID = fopen([basedir,lang1,lang2,corpus_name,'datagen.txt'],'w');
fprintf(fileID,'loading lang1')
fclose(fileID)
    [x_o, d_o, x_w, d_w] = loader(opinion_words, topic_words, lang1, corpus_name); % The function loader is at the bottom of this script
    Voc_W1 = length(unique(x_w)); Docs_W1 =length(unique(d_w));
    Voc_O1 = length(unique(x_o)); Docs_O1 = length(unique(d_o)); %#ok<NASGU>
fileID = fopen([basedir,lang1,lang2,corpus_name,'datagen.txt'],'w');
fprintf(fileID,'loading lang2');    
fclose(fileID)
    [x_o2, d_o2, x_w2, d_w2] = loader(opinion_words, topic_words, lang2, corpus_name); % The function loader is at the bottom of this script
    Voc_W2 = length(unique(x_w2)); Docs_W2 =length(unique(d_w2)); %#ok<NASGU>
    Voc_O2 = length(unique(x_o2)); Docs_O2 = length(unique(d_o2)); %#ok<NASGU>
fileID = fopen([basedir,lang1,lang2,corpus_name,'datagen.txt'],'w');
fprintf(fileID,'preparing joined vectors');    
fclose(fileID)         
    l_w = [ones(1, size(x_w,2)), 2*ones(1, size(x_w2,2))];
    x_w = [x_w, x_w2+Voc_W1];
    d_w = [d_w, d_w2+Docs_W1];  % Because the number of docs in W1 should be greater than or equal to # in O1
    l_o = [ones(1, size(x_o,2)), 2*ones(1, size(x_o2,2))];
    x_o = [x_o, x_o2+Voc_O1];
    d_o = [d_o, d_o2 + Docs_W1]; % Because the number of docs in W2 should be greater than or equal to # in O2
fileID = fopen([basedir,lang1,lang2,corpus_name,'datagen.txt'],'w');
fprintf(fileID,'preparing permutation');    
fclose(fileID)       
    order = randperm(max(d_w));
fileID = fopen([basedir,lang1,lang2,corpus_name,'datagen.txt'],'w');
fprintf(fileID,'applying permutation to test');    
fclose(fileID)           
    lambda = 0.03;
    lambar = 1-lambda;
    odds = round(1/lambda - 1);
    testdocs = order(1:round(lambda*length(order)));
    test_inds_w = zeros(1,round(length(d_w)*lambda));
    test_inds_o = zeros(1,round(length(d_o)*lambda));
fileID = fopen([basedir,lang1,lang2,corpus_name,'datagen.txt'],'w');
fprintf(fileID,'applying permutation to train');    
fclose(fileID)     
    traindocs = order((round(lambda*length(order))+1):end);
    train_inds_w = zeros(1,round(length(d_w)*lambar));
    train_inds_o = zeros(1,round(length(d_o)*lambar));

    clear order

fileID = fopen([basedir,lang1,lang2,corpus_name,'datagen.txt'],'w');
fprintf(fileID,'getting test train indices');    
fclose(fileID)       
    train = [];
    train = initStruct(train, l_w, x_w, d_w, l_o, x_o, d_o, getInds(1:odds, train_inds_w, d_w, odds), getInds(1:odds, train_inds_o, d_o, odds));

fileID = fopen([basedir,lang1,lang2,corpus_name,'datagen.txt'],'w');
fprintf(fileID,'getting test test indices');    
fclose(fileID)       
    test = [];
    test = initStruct(test, l_w, x_w, d_w, l_o, x_o, d_o,  getInds(0, test_inds_w, d_w, odds), getInds(0, test_inds_o, d_o, odds));
fileID = fopen([basedir,lang1,lang2,corpus_name,'datagen.txt'],'w');
fprintf(fileID,'saving');    
fclose(fileID)       
    clear l_w x_w d_w l_o x_o d_o
    save(outfile, 'train', 'test') 
end

function [struct1] = initStruct(struct1, l_w, x_w, d_w, l_o,x_o, d_o, inds_w, inds_o)
    struct1.l_w = l_w(inds_w);
    struct1.x_w = x_w(inds_w);
    struct1.d_w = d_w(inds_w);

    struct1.l_o = l_o(inds_o);
    struct1.x_o = x_o(inds_o);
    struct1.d_o = d_o(inds_o);
end

function [inds] = getInds(docs, inds, d_w, odds)
    v = arrayfun(@(x) find(rem(d_w,odds+1)==x), docs,'UniformOutput', false);  %quick and dirty
    counter = 1;
    for i = 1:length(v)
        fprintf('getInds i=%d', i)
        g = length(v{i});
        inds(counter:(counter+g-1)) = v{i};
        counter = counter +g;
    end
    inds = inds(1:(counter-1));
end

function [x_o, d_o, x_w, d_w] = loader(opinion_words, topic_words, lang, corpus_name)
    load([opinion_words,  '_', corpus_name, lang,'_small.mat']);
    x_o = double(WP(:)')+double(1 - min(WP));%#ok<NODEF>
    d_o = double(WDP(:)') + double(1 - min(WDP));%#ok<NODEF>
    load([topic_words, '_', corpus_name, lang, '_small.mat']);
    x_w = double(WP(:)') + double(1 - min(WP));
    d_w = double(WDP(:)')+ double(1 - min(WDP));
end