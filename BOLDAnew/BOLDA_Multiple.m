function [ out ] = BOLDA_Multiple(train, test, alpha, beta_W, beta_O, T, EM_iters, pi1, matchmode, savefilename, optimize)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Author: E.D. Gutierrez (edg@icsi.berkeley.edu)
    % The Multiple-match version of the multilingual opinion mining algorithm
    % NOTE: The bilingual dictionary, pi1, must be of the form pi1(i+1, j+1) = 1 if word i in language 1 and word j in language 2 are matched.  
    % If word i in language 1 has no match, then pi1(i,1) = 1.  Similarly, if word j in language 2 has no match, pi1(1,j) = 1.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    stream = RandStream('mt19937ar','Seed',sum(100*clock));
    RandStream.setGlobalStream(stream);
if ~isempty(strfind(savefilename, 'twitter5'))
    burn_in = 1.3e3;  samps = 1; thinningGaps = 1e2;
    if ~isempty(strfind(savefilename, 'ru'))
        load('/u/metanet/clustering/multilingual_opinions/twitter5-dataen-ru_verbadj.mat')
    else
        load('/u/metanet/clustering/multilingual_opinions/twitter5-dataen-es_verbadj.mat')
    end
end
if ~isempty(strfind(savefilename, 'news'))
    burn_in = 3e3;  samps = 1; thinningGaps = 1e2;
    if ~isempty(strfind(savefilename, 'ru'))
        load('/u/metanet/clustering/multilingual_opinions/news-dataen-ru_verbadj.mat')
    else
        load('/u/metanet/clustering/multilingual_opinions/news-dataen-es_verbadj.mat')
    end
end
tprob_W=0; tprob_O =0;
    i = 0;
    DP = 1;
    l_w = train.l_w;
    x_w = train.x_w;
    d_w = train.d_w;
    l_o = train.l_o;
    x_o = train.x_o;
    d_o = train.d_o;
clear train
    relegate = strcmp(matchmode{3}, 'Relegate')*1;
    pi1(2:end, 2:end) = pi1(2:end, 2:end)/max(max(pi1(2:end, 2:end)));
    pi1 = pi1 > .1;
    for i = 1:size(pi1,1)
        if sum(pi1(i,:))==0
            pi1(i,1) = 1;
        end
    end
    for j = 1:size(pi1,2)
        if sum(pi1(:, j))==0
           pi1(1, j) = 1;
        end
    end
    if optimize
        burn_in = 1e2; samps = 12; thinningGaps = 1.2e3/samps;
        probs_W = zeros(100,1); probs_O = zeros(100,1);
    end
if rem(T,1)==.75, T = T-0.75; burn_in=1; end
    fprintf('burn-in: %d\t', burn_in)
    fprintf('samps: %d\t', samps)
    fprintf('gaps: %d\t', thinningGaps)
    OUTPUT = 1;
    seed = round(rand(1)*50)+1;

    % Compute the size of the vocabularies and the total number of matches, as well as the max number of matches for a single entry
    Voc_O1 = length(unique(x_o(l_o==1))); Voc_O2 = length(unique(x_o(l_o==2))); 
    Voc_W1 = max([size(pi1,1)-1,length(unique(x_w(l_w==1)))]); Voc_W2 = max([size(pi1,2)-1,length(unique(x_w(l_w==2)))]); %we subtract 1 here from size(pi1) because pi1 includes an extra row and column for unmatched words
    total_M = sum(sum(pi1));
    % disp('M shld be %d\n', max([sum(pi1,1), sum(pi1,2)']))
%%% Turn the matrix form of the dictionary into a sparse 2-column correspondence matrix
    m = 0;
    dictionary = zeros(total_M, 2);
    for i = 1:size(pi1,1) %all rows
        for j = 1:size(pi1,2) %all columns
            if pi1(i,j)>0
                m = m + 1;
                dictionary(m,1) = i-1;  % remember that the indices are all +1 because the first row/column is the no-match column
                dictionary(m,2) = j-1;
            end
        end
    end
    numEntriesVec = zeros(Voc_W1 + Voc_W2,1);
    for m = 1:total_M
        wi = dictionary(m,1);
        if wi>0
            if (relegate==0)||(dictionary(m,2)>0)
                numEntriesVec(wi) = numEntriesVec(wi)+1;
            end
        end
        wi = dictionary(m,2)+Voc_W1; 
        if wi>Voc_W1
            if (relegate==0)||(dictionary(m,1)>0)
                numEntriesVec(wi) = numEntriesVec(wi)+1;
            end
        end
    end
    M = max(numEntriesVec);
    entryVec = zeros((Voc_W1 + Voc_W2)*M,1);
    placevec = numEntriesVec;
    for m = 1:total_M
        wi = dictionary(m,1);
        if wi>0
            if (relegate==0)||(dictionary(m,2)>0)
                entryVec((wi-1)*M+placevec(wi)) = m;
                placevec(wi) = placevec(wi) - 1;
            end
        end
        wi = dictionary(m,2)+ Voc_W1;
        if wi>Voc_W1
            if (relegate==0)||(dictionary(m,1)>0)
                entryVec((wi-1)*M+placevec(wi)) = m;
                placevec(wi) = placevec(wi) - 1;
            end
        end
    end
    entryVec = entryVec';
    entrymap.numEntriesVec = numEntriesVec; 
    entrymap.dictionary = dictionary;
    entrymap.entryVec = entryVec; %#ok<STRNU>
    out.entrymap = entrymap;
    [ WP , ~ , Z_W, OP , Z_O, E_W ] = TrySampler(x_w, d_w, T, burn_in, alpha, beta_W, l_o, x_o, d_o, numEntriesVec, beta_O , seed, OUTPUT, entryVec, relegate);
    save(savefilename)
    [tprob_W, tprob_O] = BOLDA_loglik(test, WP, OP, DP, beta_W, beta_O, alpha, relegate, 0, 0, 1, E_W, x_w); fprintf('tprob: %6.4f\t', tprob_W)
    tcoh_W = BOLDA_coherence(WP, d_w, x_w, l_w, Voc_W1); tcoh_O = BOLDA_coherence(OP, d_o, x_o, l_o, Voc_O1); fprintf('tcoh: %6.4f\n', tcoh_W)
    if optimize
        probs_W(1) = tprob_W; probs_O(1) = tprob_O; 
        cohers_W(1) = tcoh_W; cohers_O(1) = tcoh_O;
        save([savefilename,'.probs.mat'], 'probs_W', 'probs_O', 'cohers_W', 'cohers_O')
    end
%   save(savefilename)
st = 2;
    if optimize
        for i = st:samps
            [ WP , ~ , Z_W, OP , Z_O, E_W ] = TrySampler(x_w, d_w, T, thinningGaps, alpha, beta_W, l_o, x_o, d_o, numEntriesVec, beta_O , seed, OUTPUT, entryVec, relegate, Z_W, Z_O, E_W );
            [tprob_W, tprob_O] = BOLDA_loglik(test, WP, OP, DP, beta_W, beta_O, alpha, relegate, 0, 0, 1, E_W, x_w); fprintf('tprob: %6.4f\t', tprob_W)
            tcoh_W = BOLDA_coherence(WP, d_w, x_w, l_w, Voc_W1); tcoh_O = BOLDA_coherence(OP, d_o, x_o, l_o, Voc_O1); fprintf('tcoh: %6.4f\n', tcoh_W)
            probs_W(i+1) = tprob_W; probs_O(i+1) = tprob_O;
            cohers_W(1) = tcoh_W; cohers_O(1) = tcoh_O;
            save(savefilename)
            save([savefilename,'.probs.mat'], 'probs_W', 'probs_O', 'cohers_W', 'cohers_O')
        end
    end
 %   save(savefilename)
    out.WP = WP;  out.DP = DP; out.OP = OP;
    out.Z_O = Z_O; out.Z_W = Z_W; out.E_W = E_W;
    out.tprob_W = tprob_W;  out.tprob_O = tprob_O;
    out.tcoh_W = tcoh_W; out.tcoh_O = tcoh_O;
end

function [ WP1 , DP1 , Z_W, OP1 , Z_O, E_W ] = TrySampler(varargin)
    DP1 = 1;
    fails = 0; success = 0;
    while (fails < 5)&&(success==0)
        try [ WP1 , ~ , Z_W, OP1 , Z_O, E_W, ~ ] = GibbsSamplerBOLDA_MultiMatch(varargin{:}); success = 1;
        catch, fails = fails + 1; %#ok<*CTCH>
        end
    end
    if fails > 4; 
       disp('sampler failed 4 times\n')
       [ WP1 , ~ , Z_W, OP1 , Z_O, E_W, ~ ] = GibbsSamplerBOLDA_MultiMatch(varargin{:}); success = 1;
%throw(MException('ResultChk:OutOfRange','Sampler failed too many times')), 
    end
end