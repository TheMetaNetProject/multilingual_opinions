function run1(lang1, lang2, T, gamma, maxdocnum, matchmode, optimize,o_condition,extrasuffix)
%clear
%lang1 = 'en';
%lang2 = 'es';
%T = 100, gamma = 0.04, maxdocnum = 8e4,matchmode = 'activematch' %noactivematch' %27114 'joint-BOLDA' 'noactivematch'
%T = 100, gamma = 0.04, maxdocnum = 8e4,matchmode = 'joint-BOLDA' %27115
%T = 50, gamma = 0.04, maxdocnum = 8e4, matchmode = 'joint-BOLDA' %27116
%T = 50, gamma = 0.04, maxdocnum = 4e4, matchmode = 'joint-BOLDA' %27117
%T = 100, gamma = 0.04, maxdocnum = 4e4, matchmode = 'joint-BOLDA' %27118
%T = 200, gamma = 0.04, maxdocnum = 4e4, matchmode = 'joint-BOLDA'%27119
%T = 5, gamma = 0.04, maxdocnum = 8e4, matchmode = 'joint-BOLDA'
%T = 200, gamma = 0.02, maxdocnum = 8e4, matchmode = 'joint-BOLDA' %27121
%extrasuffix = '_nocomments'
%o_condition = '_verbsonly'
langs = {'en', 'es'}
basedir = '/u/metanet/clustering/multilingual_opinions/'
addpath(gen(basedir))
extrasuffix = '_nocomments'
corpus_name = 'twitter'
opinion_words = {'adjectives', 'verbs'};
topic_words = {'nouns'};
for i=1:length(opinion_words)
    o_condition = [o_condition, '-',opinion_words{i}];
end

switch matchmode 
    case 1, matchmode = 'activematch'
    case 2, matchmode = 'noactivematch' 
    case 3, matchmode = 'joint-BOLDA'
    case 4, matchmode = 'joint-BOLDA-matchonly'
end

path_out = [basedir, 'BOLDA_results/', corpusname,'/', matchmode,'/']


filenamesave = [langs{1},'-', langs{1}, '_results_T-',int2str(T), '_MaxDocs-',int2str(maxdocnum/1e4),'e4_gamma-',int2str(gamma*1e3),'e-3_',matchmode,o_condition,'.mat']
if optimize==1;
    filenamesave = ['optim_', filenamesave ];
end
matchesonly = 0;
if strcmp(matchmode,'joint-BOLDA-matchonly')
    matchesonly = 1;
end

try
crash
    load([path_out, langs{1},'_', langs{1}, '_prelim',filenamesave])
catch
    alpha = 50/T;
    beta_W = 0.02;
    beta_O = 0.02;
    EM_iters = 3;

    OP_short = []; ODP_short = [];
    for i=1:length(opinion_words)
        load(['opinion_words{i} + '_' + corpus_name+'_' + langs{1} +'_small.mat']);
        OP_short = [OP_short, WP];
        ODP_short = [ODP_short, WDP];
    end
    WP_short = []; WDP_short = [];
    for i = 1:length(topic_words)
        load(['topic_words{i} + '_' + corpus_name+'_' + langs{1} +'_small.mat']);
        WP_short = [WP_short, WP];
        WDP_short = [WDP_short, WDP];
    end

    Voc_W1 = length(unique(WP_short));
    Docs_W1 =length(unique(WDP_short));
    Voc_O1 = length(unique(OP_short));
    Docs_O1 = length(unique(ODP_short));
    mindocs = min([maxdocnum-1+min(WDP_short), Docs_W1-1+min(WDP_short)]);

    mindocs_w = mindocs;
    cutoffindex_w = find(WDP_short==mindocs_w);
    while length(cutoffindex_w)<1
        cutoffindex_w = find(WDP_short==mindocs_w);
        mindocs_w = mindocs_w - 1;
    end
    cutoffindex_w = cutoffindex_w(1);

    mindocs_o = mindocs;
    cutoffindex_o = find(ODP_short==mindocs_o);
    while length(cutoffindex_o)<1
        cutoffindex_o = find(ODP_short==mindocs_o);
        mindocs_o = mindocs_o - 1;
    end
    cutoffindex_o = cutoffindex_o(1);

    if min(WP_short)<1
        WP_short = WP_short + (1-min(WP_short));
    end
    if size(WP_short,2)==1
        WP_short = WP_short';
    end
    if min(WDP_short)<1
        WDP_short = WDP_short + (1-min(WDP_short));
    end
    if size(WDP_short,2)==1
        WDP_short = WDP_short';
    end
    if min(OP_short)<1
        OP_short = OP_short + (1-min(OP_short));
    end
    if size(OP_short,2)==1
        OP_short = OP_short';
    end
    if min(ODP_short)<1
        ODP_short = ODP_short + (1-min(ODP_short));
    end
    if size(ODP_short,2)==1
        ODP_short = ODP_short';
    end
    x_w = WP_short(1:cutoffindex_w);
    d_w = WDP_short(1:cutoffindex_w);
    l_w = repmat(1, size(x_w,1), size(x_w,2));
    x_o = OP_short(1:cutoffindex_o);
    d_o = ODP_short(1:cutoffindex_o);
    l_o = repmat(1, size(x_o,1), size(x_o,2));

    OP_short = []; ODP_short = [];
    for i=1:length(opinion_words)
        load(['opinion_words{i} + '_' + corpus_name+'_' + langs{2} +'_small.mat']);
        OP_short = [OP_short, WP];
        ODP_short = [ODP_short, WDP];
    end
    WP_short = []; WDP_short = [];
    for i = 1:length(topic_words)
        load(['topic_words{i} + '_' + corpus_name+'_' + langs{2} +'_small.mat']);
        WP_short = [WP_short, WP];
        WDP_short = [WDP_short, WDP];
    end
    Voc_W2 = length(unique(WP_short));
    Docs_W2 =length(unique(WDP_short));
    Voc_O2 = length(unique(OP_short));
    Docs_O2 = length(unique(ODP_short));
    mindocs = min([maxdocnum-1+min(WDP_short), Docs_W2-1+min(WDP_short)]);

    mindocs_w = mindocs;
    cutoffindex_w = find(WDP_short==mindocs_w);
    while length(cutoffindex_w)<1
        cutoffindex_w = find(WDP_short==mindocs_w);
        mindocs_w = mindocs_w - 1;
    end
    cutoffindex_w = cutoffindex_w(1);

    mindocs_o = mindocs;
    cutoffindex_o = find(ODP_short==mindocs_o);
    while length(cutoffindex_o)<1
        cutoffindex_o = find(ODP_short==mindocs_o);
        mindocs_o = mindocs_o - 1;
    end
    cutoffindex_o = cutoffindex_o(1);

    if min(WP_short)<1
        WP_short = WP_short + (1-min(WP_short));
    end
    if size(WP_short,2)==1
        WP_short = WP_short(1:cutoffindex_w)';
    end
    if min(WDP_short)<1
        WDP_short = WDP_short + (1-min(WDP_short));
    end
    if size(WDP_short,2)==1
        WDP_short = WDP_short(1:cutoffindex_w)';
    end
    if min(OP_short)<1
        OP_short = OP_short + (1-min(OP_short));
    end
    if size(OP_short,2)==1
        OP_short = OP_short(1:cutoffindex_o)';
    end
    if min(ODP_short)<1
        ODP_short = ODP_short + (1-min(ODP_short));
    end
    if size(ODP_short,2)==1
        ODP_short = ODP_short(1:cutoffindex_o)';
    end

    x_w = [x_w, WP_short+Voc_W1];
    d_w = [d_w, WDP_short+max(Docs_W1, Docs_O1)];
    l_w = [l_w, repmat(2, size(WP_short,1), size(WP_short,2))];
    x_o = [x_o, OP_short+Voc_O1];
    d_o = [d_o, ODP_short+max(Docs_W1, Docs_O1)];
    l_o = [l_o, repmat(2, size(OP_short,1), size(OP_short,2))];
indices_d = [];
counter = 0;
for i = 1:length(d_w)
    if sum(indices_d==d_w(i))==0
        counter = counter + 1;
        indices_d = [indices_d, d_w(i)];
    end
    d_w(i)=find(indices_d==d_w(i));
end
counter_d_w = counter
maxindicesd = max(indices_d)
clear counter_d_w maxindicesd
%%% DON'T RESET THE COUNTER/INDICES LIST BEFORE DOING D_O - IT MUST USE THE
%%% SAME INDICES AS D_W!!
for i = 1:length(d_o)
    if sum(indices_d==d_o(i))==0
        counter = counter + 1;
        indices_d = [indices_d, d_o(i)];
    end
    d_o(i)=find(indices_d==d_o(i));
end
counter_d = counter
clear counter_d
indices_x_w = [];
counter = 0;
for i = 1:length(x_w)
    if sum(indices_x_w==x_w(i))==0
        counter = counter + 1;
        indices_x_w = [indices_x_w, x_w(i)];
    end
    x_w(i)=find(x_w(i)==indices_x_w);
end
indices_x_o = [];
counter = 0;
for i = 1:length(x_o)
    if sum(indices_x_o==x_o(i))==0
        counter = counter + 1;
        indices_x_o = [indices_x_o, x_o(i)];
    end
    x_o(i)=find(x_o(i)==indices_x_o);
end

last_Voc_W1 = find(indices_x_w<Voc_W1);
last_Voc_W1 = last_Voc_W1(end);

load(['match-matrix_'+topic_words{1}+ '_'+lang1[0]+'-'+lang2[0]+'.mat'])

if strcmp(matchmode,'joint-BOLDA')||strcmp(matchmode,'joint-BOLDA-matchonly')
    pi1 = ceil(pi1);     
    indices_x_w2a = [1, indices_x_w(1:last_Voc_W1) + 1];
    indices_x_w2b = [Voc_W1+1, indices_x_w((last_Voc_W1+1):end) + 1];
    pi1 = pi1(indices_x_w2a,:);
    pi1 = pi1(:, indices_x_w2b-Voc_W1);

    pi2 = sparse(pi1(2:end, 2:end));
    for i = 2:size(pi1,1)
        if sum(pi2(i-1,:))==0
            pi1(i,1) = 1;
        else
            pi1(i,1) = 0;
        end
    end
    for i = 2:size(pi1,2)
        if sum(pi2(:, i-1))==0
           pi1(1,i) = 1;
        else
           pi1(1,i) = 0;
        end
    end

else
    pi1 = pi1(2:end, 2:end);
    pi1 = pi1(indices_x_w(1:last_Voc_W1),:);

try,    pi1 = pi1(:, indices_x_w((last_Voc_W1+1):end)-Voc_W1); catch indices_x_w((last_Voc_W1+1):end)-Voc_W1, end
end
pi1 = sparse(pi1);

save([path_out,'prelim',filenamesave])
end
cd basedir
if strcmp(matchmode,'joint-BOLDA')||strcmp(matchmode,'joint-BOLDA-matchonly')
    [ WP_results , DP_results , OP_results, Z_O, Z_W, phi_W, phi_O1, phi_O2, theta, ENTRY_SERIES, entrymap] = BOLDA_J(x_w, d_w, x_o, d_o, l_o, l_w, alpha, beta_W, beta_O, gamma, T, EM_iters, pi1, matchmode, [path_out,filenamesave],optimize,matchesonly);
else
    [WP_results , DP_results , OP_results, Z_O, Z_W, phi_W, phi_O1, phi_O2, rho_1, rho_2, theta,mm, cost] = BOLDA(x_w, d_w, x_o, d_o, l_o, l_w, alpha, beta_W, beta_O, gamma, T, EM_iters, pi1, matchmode, [path_out, filenamesave],optimize);
end

save([path_out,filenamesave])