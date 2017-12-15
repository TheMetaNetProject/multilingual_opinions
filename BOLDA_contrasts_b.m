basedir_results = '/u/metanet/clustering/multilingual_opinions/'
basedir_dict = '/u/metanet/clustering/multilingual_opinions/prune_out/'
addpath('/u/metanet/clustering/multilingual_opinions/','/u/metanet/clustering/multilingual_opinions/prune_out/')

o_condition = '_verbsonly';
lang1 = {'en','EN'};
lang2 = {'es', 'ES'};
extrasuff = '_20130301';

load([basedir_results, lang1{1}, '_', lang2{1}, '_BOLDAresults_T-75_MaxDocs-8e4_gamma-40e-3_noactivematch_verbsonly_nocomments',extrasuff,'.mat'])
%o_matches = csvread([basedir_dict,'vocab_matches_',lang1{1},'-',lang2{1},o_condition,extrasuff,'.csv'])+1;

load('match-matrix_o_en-es_verbsonly_nocomments.mat')
if size(pi1,1)>size(pi1,2)
    a = lapjv(-pi1);
else
    a = lapjv(-pi1');
end

lang1_include = find(sum(pi1,2)>0);
lang2_include = find(sum(pi1,1)>0);
o_matches = [0 0];
counter = 0;

for i = 1:length(a)
    if sum(i==lang2_include)>0
        if sum(a(i)==lang1_include)>0
            counter = counter + 1;
            o_matches(counter,1) = a(i);
            o_matches(counter,2) = i;
        end
    end  
end


temp_OP1 = OP(1:Voc_O1,:);
temp_OP2 = OP((Voc_O1+1):end,:);
scores = zeros(size(o_matches,1),size(OP,2)) +NaN;
for topic = 51:75 %size(OP,2)
    N1 = sum(temp_OP1(:,topic));
    N2 = sum(temp_OP2(:,topic));
    memo = zeros(N1+1,N2+1);
    if N1>0&&N2>0
        temp_OP1(:,topic) = temp_OP1(:,topic)/N1;
        temp_OP2(:,topic) = temp_OP2(:,topic)/N2;
        for i = 1:size(o_matches,1)
            omatch1 = o_matches(i,1);
            omatch2 = o_matches(i,2);
            try
                diff = abs(temp_OP1(omatch1,topic) - temp_OP2(omatch2,topic));
                tic()
                [scores(i,topic), memo] = diffprob(diff, N1, N2, beta_O, beta_O*mean(Voc_O1, size(OP,1)-Voc_O1), memo);        
                toc()
                if isnan(scores(i,topic))
                    break
                end
            catch
                [omatch1, omatch2]
            end
        end
    end
    if isnan(scores(i,topic))
        break
    end
try
   load(['scores',lang1{1},'-',lang2{1},o_condition,'_20130905.mat'])
   scores1 = scores + scores1;
catch
   scores1 = scores;
end
   save(['scores',lang1{1},'-',lang2{1},o_condition,'_20130905.mat'], 'scores1')
end
