function basedir = pruner(basedir, language, o_condition, extrasuffix)
%language = 'es'
%o_condition = '_adjectives'
%extrasuffix = '_nocomments'
language_o = [language, o_condition, extrasuffix];
language = [language, o_condition, extrasuffix];
filename_o = ['OPDP_blogs_',language_o,'.mat'];
filename = ['WPDP_blogs_',language,'.mat'];
load([basedir,filename])
load([basedir,filename_o])
cutoff = 2050;
Voc_W = length(unique(WP));
wordcounts = zeros(Voc_W,1);
for i = 1:Voc_W
    wordcounts(i) = sum(WP==i);
end

limits = unique(wordcounts);

i = 1;
while i >0
    
    if sum(wordcounts>limits(i))<=cutoff
        limit_w = limits(i);
        i = -30;
    else
        i = i + 1;
    end
end
    

indices_W = find(wordcounts>limit_w);
counter = 0;
maxdoc = 0;
WP_short = zeros(length(WP),1);
WDP_short = zeros(length(WP),1);
maxdoc = 0;
doc_indices = [];
for i = 1:length(WP)
    if sum(WP(i)==indices_W)
        counter = counter + 1;
        WP_short(counter) = find(WP(i)==indices_W);
        if sum(doc_indices==WDP(i))<1
            doc_indices = [doc_indices, WDP(i)];
            maxdoc = WDP(i);
        end
        WDP_short(counter) = find(doc_indices==WDP(i));
        
    end
end
WP_short = WP_short(1:counter);
WDP_short = WDP_short(1:counter);

%%%%%%%%%%%%%%%%%%%%%%%%
Voc_O = length(unique(OP));
wordcounts = zeros(Voc_O,1);
for i = 1:Voc_O
    wordcounts(i) = sum(OP==i);
end

limits = unique(wordcounts);

i = 1;
while i >0
    
    if sum(wordcounts>limits(i))<=cutoff
        limit_o = limits(i)
        i = -30;
    else
        i = i + 1;
    end
end
    
indices_O = find(wordcounts>limit_o);
counter = 0;
OP_short = zeros(length(OP),1);
ODP_short = zeros(length(OP),1);
for i = 1:length(OP)
    if sum(OP(i)==indices_O)
        counter = counter + 1;
        OP_short(counter) = find(OP(i)==indices_O);
         if sum(doc_indices==WDP(i))<1
            doc_indices = [doc_indices, ODP(i)];
            maxdoc = ODP(i);
        end
        ODP_short(counter) = find(doc_indices==ODP(i));
        
    end
end
OP_short = OP_short(1:counter);
ODP_short = ODP_short(1:counter);

save(['WPDP_short_',language,'.mat'])