function [totprob_w, totprob_o] = BOLDA_Test(x_w, x_o, d_w, d_o, WP, OP, DP,... 
                   beta_w, beta_o, alpha_d, relegate, mm, Voc_W1, multiple)
    if nargin<15
       multiple = 0;
    end
    %%% Getting the matrices into the right orientation
    WP = rectify(WP);
    DP = rectify(DP); %docs are in the columns
    OP = rectify(OP);
    if multiple
        M = length(WP(1,:));
    else
        %%% Manipulations to get the dictionary into the right format
        mm = mm(:); mm = mm - min(mm);  
        U_indices = find(mm==0); % Matched indices in either language
        M1_indices = find(mm(1:Voc_W1)>0); % Matched indices in language 1
        M = length(U_indices) + length(M1_indices);    
        WP(:, M1_indices) = WP(:,M1_indices) + WP(:, mm(M1_indices));
        mm(M1_indices) = M1_indices;
        WP(:, mm(M1_indices)) = 0;
        mm(U_indices) = U_indices;
    end
    DP = sum(DP,2);
    %%% Actual likelihood computations
    p_w_k = normalize(WP, beta_w, M);
    p_o_k = normalize(OP, beta_o, length(OP(1,:)));
%    p_k_d = normalize(DP', alpha_d, length(DP(:,1)))';
    p_k_d = DP/sum(DP);
    if multiple
        totprob_w = compute_prob(x_w, d_w, p_w_k, p_k_d);
    else
        totprob_w = compute_prob(mm(x_w), d_w, p_w_k, p_k_d);
    end
    totprob_o = compute_prob(x_o, d_o, p_o_k, p_k_d);
end

%% NORMALIZES THE COUNT MATRIX INTO A SMOOTHED PROBABILITY TABLE
function p = normalize(counts, prior, dims)
    p = (counts + prior)./repmat(sum(counts,2)+dims*prior,1,size(counts,2));
end

%% COMPUTES LIKELIHOOD GIVEN WORD/DOC ASSIGNMENTS AND PROBABILITY TABLES
function totprob = compute_prob(words, docs, pWords, pDocs)
    totprob = 0;
    N = length(words);
    for i = 1:N
        totprob = totprob + log(pWords(:, words(i)), pDocs(:, 1)))/N;
    end
end

%% RUDIMENTARY HANDLING OF ORIENTATIONS
function a = rectify(a)
    if size(a, 2)<size(a,1)
        a = a';
    end
end