function [totprob_w, totprob_o] = BOLDA_loglik(struct1, WP, OP, DP,... 
                   beta_w, beta_o, alpha_d, relegate, mm, Voc_W1, multiple, E_W, train_x)
echo normalize on; echo rectify on; echo compute_prob on; echo ldae_chibms on; echo log_Tprob_base on; echo sub3ind on; echo ldae_hm on;

    addpath('/u/metanet/clustering/multilingual_opinions/BOLDAnew/')
    addpath('/u/metanet/clustering/multilingual_opinions/lda_eval_matlab_code_20120930')
  %  disp('start loglik')
    if nargin<11
       multiple = 0;
    end
    x_w = struct1.x_w;
    x_o = struct1.x_o;
    d_w = struct1.d_w;
    d_o = struct1.d_o;    
    clear struct1

    %%% Getting the matrices into the right orientation
    WP = rectify(WP);
    OP = rectify(OP);
    DP = rectify(DP); %docs are in the columns
    DP = sum(DP,2);

    if multiple
        M = size(WP,2);
%        Voc = max(x_w);
%        prob_e = zeros(Voc,M);
%tic()
%        for i = 1:Voc
%            prob_e(i,:) = histc(E_W(train_x==i), 1:M);
%            prob_e(i,:) = prob_e(i,:)/sum(prob_e(i,:));
%        end
%        counts_x_w = histc(x_w, 1:max(x_w));
%        counts_e = round(prob_e'*counts_x_w(:));
%toc()
    else
        %%% Manipulations to get the dictionary into the right format
        mm = mm(:); mm = mm - min(mm);  
        U_indices = find(mm==0); % Matched indices in either language
        M1_indices = find(mm(1:Voc_W1)>0); % Matched indices in language 1
        M = length(U_indices) + length(M1_indices);
        for i = 1:M1_indices    
            WP(:, M1_indices(i)) = WP(:,M1_indices(i)) + WP(:, mm(M1_indices(i)));
            mm(M1_indices(i)) = M1_indices(i);
            WP(:, mm(M1_indices(i))) = 0;
        end
        mm(U_indices) = U_indices;
%        counts_x_w = histc(x_w, 1:max(x_w));
        x_w = mm(x_w);
    end
%    counts_x_o = histc(x_o, 1:max(x_o));

    %%% Actual likelihood computations
    p_k_d = DP/sum(DP).*(alpha_d(1));
    p_k = sum(WP,2)/sum(WP(:)).*(alpha_d(1));
    p_w_k = normalize(WP, beta_w, M);
    p_o_k = normalize(OP, beta_o, length(OP(1,:)));
    K = size(p_w_k,1);
%tic()
    totprob_w = 0; totprob_o = 0;
    uu = unique(d_w);
tic() 
    for i = 1:length(uu);
        totprob_w = totprob_w + ldae_hm(x_w(find(d_w==uu(i))), p_w_k, p_k, 10, 10);
        totprob_o = totprob_o + ldae_hm(x_o(find(d_o==uu(i))), p_o_k, p_k, 10, 10);
%        totprob_w = totprob_w + ldae_chibms(x_w(find(d_w==i)), p_w_k, beta_w, M);
%        totprob_o = totprob_o + ldae_chibms(x_o(find(d_o==i)), p_o_k, beta_o, length(OP(1,:)));
 %       fprintf('iter: %6.4f s\n', toc())
    end
fprintf('computing chibms took %6.4f s\n', toc())

totprob_w = totprob_w/length(x_w);
totprob_o = totprob_o/length(x_o);

%    if multiple
%        totprob_w = compute_prob(counts_e, p_w_k, p_k_d);
%    else
%        totprob_w = compute_prob(counts_x_w, p_w_k, p_k_d);
%    end
%    totprob_o = compute_prob(counts_x_o, p_o_k, p_k_d);
end

%% NORMALIZES THE COUNT MATRIX INTO A SMOOTHED PROBABILITY TABLE
function p = normalize(counts, prior, dims)
    p = (counts + prior)./repmat(sum(counts,2)+dims*prior,1,size(counts,2));
end

%% COMPUTES LOG LIKELIHOOD GIVEN WORD/DOC ASSIGNMENTS & PROBABILITY TABLES
function totprob = compute_prob(counts, pWords, pDocs)
    N = sum(counts);
    totprob = 0;
    for k = 1:size(pWords,1)
        totprob = totprob + exp((dot(counts, log(pWords(k,:)))+log(pDocs(k)))/N);
    end
    totprob = log(totprob);
end

%% RUDIMENTARY HANDLING OF ORIENTATIONS
function a = rectify(a)
    if size(a, 2)<size(a,1)
        a = a';
    end
end

function log_evidence = ldae_chibms(words, pWords, beta, M, ms_iters)
%LDAE_CHIBMS Approximate evidence for LDA using Murray & Salakhutdinov's Chib-style method
%
% log_evidence = ldae_chibms(words, pWords, beta);
%
% Inputs:
%             words 1xNd
%            pWords TxV each row is a distribution over a vocabulary of size V 
%       beta 1xT parameters of Dirichlet from which document topic vector is drawn
%          ms_iters 1x1 Default: 1000
%
% Outputs:
%     log_evidence  1x1 

% Iain Murray, January 2009
% 2012-09-30 fixes for bugs reported by Matthew Willson

	BURN_ITERS = 3;

	if ~exist('ms_iters', 'var')
            ms_iters = 500; 
	end

	[T, ~] = size(pWords);
	Nd = length(words);

	% Sanity checking input sizes
%	assert(isvector(beta));
%	assert(T == length(beta));
	assert(isvector(words));

	beta = beta(:)';
	beta_0 = beta*M;
	%topic_mean = beta / beta_0;

	% Assign latents to words in isolation as a simple initialization
%disp('Assign latents to words in isolation as a simple initialization ... '); tic()
       Nz = zeros(1, T);
       zz = zeros(1, Nd);
	for t = 1:Nd
              pz = pWords(:, words(t))'.*beta;
		zz(t) = sample1(pz,1);
		Nz(zz(t)) = Nz(zz(t)) + 1;
	end
%fprintf(' took %6.4f s \n', toc())
	% Run some sweeps of Gibbs sampling
	for sweeps = 1:BURN_ITERS
%fprintf('sweep %d of gibbs: ', sweeps); tic()
              Nz_beta = Nz + beta;
		for t = 1:Nd
			Nz_beta(zz(t)) = Nz_beta(zz(t)) - 1;
			pz = pWords(:, words(t))' .* (Nz_beta);
			zz(t) = sample1(pz,1);
			Nz_beta(zz(t)) = Nz_beta(zz(t)) + 1;
		end
              Nz = Nz_beta - beta;
%fprintf(' %6.4f sec\n', toc())           
	end

	% Find local optimim to use as z^*, "iterative conditional modes"
	% But don't spend forever on this, bail out if necessary
	for i = 1:12
%fprintf('opt sweep %d: ', i);tic()
		old_zz = zz;
              Nz_beta = Nz + beta;
		for t = 1:Nd
			Nz_beta(zz(t)) = Nz_beta(zz(t)) - 1;
			pz = pWords(:, words(t))' .* (Nz_beta);
			[~, zz(t)] = max(pz);
			Nz_beta(zz(t)) = Nz_beta(zz(t)) + 1;
		end
              Nz = Nz_beta - beta;
		if isequal(old_zz, zz)
			break;
		end
%fprintf('  %6.4f s \n', toc())
	end

	% Run Murray & Salakhutdinov algorithm
	zstar = zz;
	log_Tvals = zeros(ms_iters, 1);
	log_Tprob = @(zto, zfrom, Nzfrom) log_Tprob_base(zto, zfrom, Nzfrom, words, pWords, beta);
	% draw starting position
	ss = ceil(rand() * ms_iters);
	% Draw z^(s)
%disp('drawing z'); tic()
       Nz_beta = Nz + beta;
	for t = Nd:-1:1
		Nz_beta(zz(t)) = Nz_beta(zz(t)) - 1;
		pz = pWords(:, words(t))' .* (Nz_beta);
		zz(t) = sample1(pz,1);
		Nz_beta(zz(t)) = Nz_beta(zz(t)) + 1;
	end
       Nz = Nz_beta - beta;
	zs = zz;
	Ns = Nz;
	log_Tvals(ss) = log_Tprob(zstar, zz, Nz);
%fprintf('  %6.4f s \n', toc())

	% Draw forward stuff
	for sprime = (ss+1):ms_iters
%fprintf('forwd iter: %d \t', sprime); tic()
              Nz_beta = Nz + beta;
		for t = 1:Nd
			Nz_beta(zz(t)) = Nz_beta(zz(t)) - 1;
			pz = pWords(:, words(t))' .* (Nz_beta);
			zz(t) = sample1(pz,1);
			Nz_beta(zz(t)) = Nz_beta(zz(t)) + 1;
		end
              Nz = Nz_beta - beta;
		log_Tvals(sprime) = log_Tprob(zstar, zz, Nz);
%fprintf('  %6.4f s \n', toc())
	end
	% Go back to middle
	zz = zs;
	Nz = Ns;
	% Draw backward stuff
       Nz_beta = Nz + beta;
	for sprime = (ss-1):-1:1
%fprintf('back iter: %d \t', sprime); tic()
		for t = Nd:-1:1
			Nz_beta(zz(t)) = Nz_beta(zz(t)) - 1;
			pz = pWords(:, words(t))' .* (Nz_beta);
			zz(t) = sample1(pz,1);
			Nz_beta(zz(t)) = Nz_beta(zz(t)) + 1;
		end
              Nz = Nz_beta - beta;
		log_Tvals(sprime) = log_Tprob(zstar, zz, Nz);
%fprintf('  %6.4f s \n', toc())
	end
	% Final estimate
%disp('final estimate'); tic()
	Nkstar = histc(zstar, 1:T); Nkstar = Nkstar(:)'; % 1xT
	log_pz = sum(gammaln(Nkstar + beta)) + gammaln(beta_0) ...
			- sum(gammaln(beta)) - gammaln(Nd + beta_0);
  %%%%     log_w_given_z = sum(sub3ind(log(pWords), zstar, words));
	log_w_given_z = 0;
	for t = 1:Nd
		log_w_given_z = log_w_given_z + log(pWords(zstar(t), words(t)));
	end
  	log_joint = log_pz + log_w_given_z;
	log_evidence = log_joint - (logsumexp(log_Tvals) - log(ms_iters));
%fprintf('  %6.4f s \n', toc())
end

function vals = sub3ind(M, I, J)
    r = size(M,1);  % Get the size of M
    vals = M(I+r.*(J-1)); 
end

function lp = log_Tprob_base(zto, zfrom, Nz, words, pWords, beta)
	Nd = length(words);
	lp = 0;
     Nz_beta = Nz + beta;
    for t = 1:Nd
		Nz_beta(zfrom(t)) = Nz_beta(zfrom(t)) - 1;
		pz = pWords(:, words(t))' .* (Nz_beta);
		pz = pz/sum(pz);
		lp = lp + log(pz(zto(t)));
		Nz_beta(zto(t)) = Nz_beta(zto(t)) + 1;
    end
end






function [log_evidence, log_ests] = ldae_hm(words, topics, topic_prior, iters, burn)
%LDAE_HM Approximate evidence for LDA by harmonic mean (terrible idea, do not use!)
%
% log_evidence = ldae_chibms(words, topics, topic_prior[, iters=1000[, burn=10]]);
%
% Inputs:
%             words 1xNd
%            topics TxV each row is a distribution over a vocabulary of size V 
%       topic_prior 1xT parameters of Dirichlet from which document topic vector is drawn
%             iters 1x1 Default: 10
%
% Outputs:
%     log_evidence  1x1 

% Iain Murray, January 2009

% TODO I was in a horrible rush. Should be refactored into generic algorithm and
% put Gibbs operators in separate functions.

if ~exist('burn', 'var')
    burn = 10;
end
if ~exist('iters', 'var')
    iters = 10;
end

[T, V] = size(topics);
Nd = length(words);

% Sanity checking input sizes
assert(isvector(topic_prior));
assert(T == length(topic_prior));
assert(isvector(words));

topic_prior = topic_prior(:)';
topic_alpha = sum(topic_prior);
%topic_mean = topic_prior / topic_alpha;
log_topics = log(topics);

crap_initialization = false;
if ~crap_initialization
    % Assign latents to words in isolation as a simple initialization
    Nz = zeros(1, T);
    for t = 1:Nd
        pz = topics(:, words(t))' .* topic_prior;
        zz(t) = sample1(pz, 1);
        Nz(zz(t)) = Nz(zz(t)) + 1;
    end
    
    % Run some sweeps of Gibbs sampling
    for sweeps = 1:burn
        if mod(sweeps, 10) == 0
%            fprintf('Burn Iters %d / %d\r', sweeps, burn);
        end
        for t = 1:Nd
            Nz(zz(t)) = Nz(zz(t)) - 1;
            pz = topics(:, words(t))' .* (Nz + topic_prior);
            zz(t) = sample1(pz,1);
            Nz(zz(t)) = Nz(zz(t)) + 1;
        end
    end
%    fprintf('\n');
else
    zz = ceil(rand(1, Nd) * T);
    Nz = histc(zz, 1:T);
end

% Gibbs sampler accumulating Harmonic Mean estimators
log_ests = zeros(1, iters);
for s = 1:iters
    if mod(s, 10) == 0
%        fprintf('Iters %d / %d\r', s, iters);
    end
    log_like = 0;
    for t = 1:Nd
        Nz(zz(t)) = Nz(zz(t)) - 1;
        pz = topics(:, words(t))' .* (Nz + topic_prior);
        zz(t) = sample1(pz,1);
        Nz(zz(t)) = Nz(zz(t)) + 1;
        log_like = log_like + log_topics(zz(t), words(t));
    end
    log_ests(s) = -log_like;
end
%fprintf('\n');
log_evidence = - (logsumexp(log_ests(:)) - log(iters));
%log_ests
%keyboard

%% pointless thinning for a comparison I was doing once:
%log_ests = log_ests(1:40:end);
%log_evidence = - (logsumexp(log_ests(:)) - log(length(log_ests)));
end