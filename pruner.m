function basedir = pruner(basedir_in, basedir_out, language, o_condition, extrasuffix)

%clear
%basedir = '';
%language = 'es'
%o_condition = '_verbsonly'
%extrasuffix = '_nocomments'
filename = ['WPDP_blogs_',language,extrasuffix,'.mat'];
load([basedir_in,filename])
filename = ['OPDP_blogs_',language,o_condition, extrasuffix,'.mat'];
load([basedir_in,filename])
cutoff_w = 2500;
switch o_condition
case '_adjectives'
    cutoff_o = 1250;
case '_verbsonly'
    cutoff_o = 2000;
case ''
    cutoff_o = 2000;
end

Voc_W = length(unique(WP));
wordcounts = zeros(Voc_W,1);
for i = 1:Voc_W
    wordcounts(i) = sum(WP==i);
end

limits = unique(wordcounts);

i = 1;
while i >0
    
    if sum(wordcounts>limits(i))<=cutoff_w
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
    if sum(WP(i)==indices_W)>0
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
    
    if sum(wordcounts>limits(i))<=cutoff_o
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
    if sum(OP(i)==indices_O)&&(sum(doc_indices==ODP(i)))
        counter = counter + 1;
        OP_short(counter) = find(OP(i)==indices_O);
        % if 
          %  doc_indices = [doc_indices, ODP(i)];
           % maxdoc = ODP(i);
        %end
        ODP_short(counter) = find(doc_indices==ODP(i));
        
    end
end

OP_short = OP_short(1:counter);
ODP_short = ODP_short(1:counter);

save([basedir_out, 'WPDP_short_',language,o_condition, extrasuffix,'.mat'])

save([basedir_out,'prune2config.mat'], 'language', 'o_condition', 'extrasuffix')