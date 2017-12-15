function BOLDA_contasts_c(basedir_in, langs, out_dir, topic_words, opinion_words, corpus_name)
% Author: E.D. Gutierrez
% E-mail: edg@icsi.berkeley.edu
% Last modified: 3 October 2013
% NOTE: This file uses the following naming conventions, though they can easily be changed:
%  dictionaries: 'match-matrix_'+opinion_words{i}+'_'+langs{1}+'-'+langs{2}+'.mat'
% and dictionary: 'match-matrix_'+topic_words{i}+'_'+langs{1}+'-'+langs{2}+'.mat'
%  word vector: topic_words{i} + '_' + corpus_name+'_' + langs{i} +'_small.mat' 
% Input: 
%  basedir_in: a string containing the input filepath with the two corpora vectors and the dictionary
%  langs: an array of the form {lang1, lang2} where lang1 and lang2 are strings
%  out_dir: a string with the output filepath
%  corpus_name: a sting with the name of the corpus
%  topic_words: an array containing wordtypes that are considered topic or content words. ex: {'noun'}
%  opinion_words: an array containing wordtypes that are considered opinion words. ex: {'verb', 'adjective'}
%  corpus_name: a string containing any additional qualifiers.
%  dict_path: path of the dictionary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(genpath(basedir_in), out_dir)

lang1 = langs{1}; lang2 = langs{2};
load([lang1{1}, '_', lang2{1}, '_BOLDAresults_T-75_MaxDocs-8e4_gamma-40e-3_noactivematch_verbsonly_nocomments',extrasuff,'.mat'])
o_matches = csvread(['vocab_matches_',lang1{1},'-',lang2{1},o_condition,extrasuff,'.csv'])+1;

dictionary: 'match-matrix_'+opinion_words{i}+'_'+langs{1}+'-'+langs{2}+'.mat'
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
