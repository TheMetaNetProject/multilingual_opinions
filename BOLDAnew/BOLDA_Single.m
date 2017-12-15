function [ out ] = BOLDA_Single(train, test, alpha, beta_W, beta_O, T, EM_iters, pi1, matchmode, savefilename, optimize)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Author: E.D. Gutierrez (edg@icsi.berkeley.edu)
  % The single-match-per-word version of the multilingual opinion mining algorithm
  %
  % NOTE: The bilingual dictionary, pi1, must be of the form pi1(i, j) = 1 if 
  %   word i in language 1 and word j in language 2 are matched.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    %echo static_match on; echo infer_match on; echo TrySampler on; echo init2 on; echo BOLDA_coherence on; echo BOLDA_loglik on;
try 
   echo static_match on; echo init2 on; echo BOLDA_loglik on; echo TrySampler on;
    restart = 1; i =0; j = 0;
    [x_w, d_w, l_o, l_w, Voc_W1, mm, x_o, d_o, seed, OUTPUT, samps, burn_in, thinningGaps, pi1, EM_iters, gibbs_iters, leftovers, relegate, restart] = init2(train, alpha, beta_W, beta_O, T, EM_iters, pi1, matchmode, savefilename, optimize);
tprob_O = 0; tprob_W = 0;
    clear train
    Voc_O1 = length(unique(x_o(l_o==1)));
%    DP = 1; %%%%%%%%%%%%%%%%why the hell was this line here?
    switch matchmode{2}
    case 'Static'
        if optimize, burn_in = 1e2; samps = 12; tots = 1.2e3; thinningGaps = round(tots/samps); end
        if rem(T,1)==.75, T = T-0.75; burn_in=1; end 
        [ WP , DP , Z_W, OP , Z_O ] = TrySampler(x_w, d_w, T, burn_in, alpha, beta_W, l_o, mm, x_o, d_o, beta_O, seed, OUTPUT, relegate);    
        tcoh_W = BOLDA_coherence(WP, d_w, x_w, l_w, Voc_W1); tcoh_O = BOLDA_coherence(OP, d_o, x_o, l_o, Voc_O1); fprintf('tcoh: %6.4f\n', tcoh_W)
        [tprob_W, tprob_O] = BOLDA_loglik(test, WP, OP, DP, beta_W, beta_O, alpha, relegate, mm, size(pi1,1)); fprintf('tprob: %6.4f\n', tprob_W)
        probs_W(1) = tprob_W; probs_O(1) = tprob_O; 
        cohers_W(1) = tcoh_W; cohers_O(1) = tcoh_O;
        if optimize
            save([savefilename,'.probs.mat'], 'probs_W', 'probs_O', 'cohers_W', 'cohers_O')
            for i= 2:samps
                [ WP , DP , Z_W, OP , Z_O ] = TrySampler(x_w, d_w, T, thinningGaps, alpha, beta_W, l_o, mm, x_o, d_o, beta_O , seed, OUTPUT, relegate, Z_W, Z_O);
                tcoh_W = BOLDA_coherence(WP, d_w, x_w, l_w, Voc_W1); tcoh_O = BOLDA_coherence(OP, d_o, x_o, l_o, Voc_O1); fprintf('tcoh: %6.4f\t', tcoh_W)
                [tprob_W, tprob_O] = BOLDA_loglik(test, WP, OP, DP, beta_W, beta_O, alpha, relegate, mm, size(pi1,1)); fprintf('tprob: %6.4f\t', tprob_W)
                probs_W(i) = tprob_W; probs_O(i) = tprob_O;  %#ok<*AGROW,*AGROW,*AGROW,*AGROW>
                cohers_W(i) = tcoh_W; cohers_O(i) = tcoh_O; %#ok<*AGROW,*AGROW>
                save([savefilename,'.probs.mat'], 'probs_W', 'probs_O', 'cohers_W', 'cohers_O')
                save([savefilename])
            end
        end
    case 'Infer'
        if optimize
            sti = 1; stj = j;
            for i = sti:(EM_iters+2)
                J = 2; thinningGaps = 125; 
                tots = 0; j = 0;
                while tots < J*thinningGaps
                    j = j + 1;
                    j
                    if (i==1)*(j==1)
                        [ WP , DP , Z_W, OP , Z_O ] = TrySampler(x_w, d_w, T, thinningGaps, alpha, beta_W, l_o, mm, x_o, d_o, beta_O , seed, OUTPUT, relegate);    
                    else
                        [ WP , DP , Z_W, OP , Z_O ] = TrySampler(x_w, d_w, T, thinningGaps, alpha, beta_W, l_o, mm, x_o, d_o, beta_O , seed, OUTPUT, relegate, Z_W, Z_O);    
                    end
                    tots = tots + thinningGaps;
%'b'
                    tcoh_W = BOLDA_coherence(WP, d_w, x_w, l_w, Voc_W1); tcoh_O = BOLDA_coherence(OP, d_o, x_o, l_o, Voc_O1);disp('_'); fprintf('tcoh: %6.4f\n', tcoh_W1)
%'c'
                    [tprob_W, tprob_O] = BOLDA_loglik(test, WP, OP, DP, beta_W, beta_O, alpha, relegate, mm, size(pi1,1)); fprintf('tprob: %6.4f\n', tprob_W1)
%'d'
                    save([savefilename]) %#ok<NBRAK>
                    probs_W((i-1)*J + j) = tprob_W; probs_O((i-1)*J + j) = tprob_O; 
                    cohers_W((i-1)*J + j) = tcoh_W; cohers_O((i-1)*J + j) = tcoh_O; 
                    save([savefilename,'.probs.mat'], 'probs_W', 'probs_O', 'cohers_W', 'cohers_O')
                end
                if i<=EM_iters
                    [mm, pi1] = infer_match(pi1, WP, beta_W, beta_W*2, i, EM_iters, savefilename);
                    'subtracting'
                    mm = mm-(1+min(mm));% SUBTRACT 1 BECAUSE IN C++ INDICES START FROM ZERO...
                   'subtracted'
                end
            end
        else
            [ WP , DP , Z_W, OP , Z_O ] = TrySampler(x_w, d_w, T, gibbs_iters, alpha, beta_W, l_o, mm, x_o, d_o, beta_O , seed, OUTPUT, relegate);   
            [mm, mu] = infer_match(pi1, WP, beta_W, beta_W*2, 1, EM_iters, savefilename);
            for i = 1:(EM_iters+1)
                %%%% save(savefilename)
                [ WP , DP , Z_W, OP , Z_O ] = TrySampler(x_w, d_w, T, gibbs_iters, alpha, beta_W, l_o, mm, x_o, d_o, beta_O, seed, OUTPUT, relegate, Z_W, Z_O );
                %%%% save([savefilename,int2str(i),'.tmp'])
                if i<=EM_iters
                    [mm, mu] = infer_match(mu, WP, beta_W, beta_W*2, i, EM_iters, savefilename);
                    mm = mm-(1+min(mm));% SUBTRACT 1 BECAUSE IN C++ INDICES START FROM ZERO...
                end
            end
           tcoh_W = BOLDA_coherence(WP, d_w, x_w, l_w, Voc_W1); tcoh_O = BOLDA_coherence(OP, d_o, x_o, l_o, Voc_O1);
           [tprob_W, tprob_O] = BOLDA_loglik(test, WP, OP, DP, beta_W, beta_O, alpha, relegate, mm, size(pi1,1));
           fprintf('tprob: %6.4f\n', tprob_W)
           fprintf('tcoh: %6.4f\n', tcoh_W)
        end
    end
    if optimize
        save([savefilename])
    end
    out.WP = WP;             out.DP = DP;             out.OP = OP;
    out.Z_O = Z_O;           out.Z_W = Z_W; 
    out.tprob_W = tprob_W;   out.tprob_O = tprob_O; 
    out.tcoh_W = tcoh_W;     out.tcoh_O = tcoh_O;
    out.mm = mm;
catch err
fid = fopen('/n/picnic/xw/metanet/edg/clustering/multilingual_opinions/BOLDAnew/error.temp','a+');   %open file
fprintf(fid,'%s\n',err.message);% write the error to file; first line: message
for e=1:length(err.stack); fprintf(fid,'%sin %s at %i\n',txt,err.stack(e).name,err.stack(e).line); end; % following lines: stack
fclose(fid);% close file 
end; 
end

function [ WP , DP , Z_W, OP , Z_O ] = TrySampler(varargin)
    fails = 0; 
    success = 0;
    while (fails < 5)&&(success==0)
        try [ WP , DP , Z_W, OP , Z_O ] = GibbsSamplerBOLDA(varargin{:}); success = 1;
        catch err, fid = fopen('/n/picnic/xw/metanet/edg/clustering/multilingual_opinions/BOLDAnew/error.temp','a+'); fprintf(fid,'%s\n',err.message); fails = fails + 1; for e=1:length(err.stack); fprintf(fid,'%sin %s at %i\n',txt,err.stack(e).name,err.stack(e).line); end; fclose(fid);
        end
    end
    if fails > 4 %throw(MException('ResultChk:OutOfRange','Sampler failed too many times')), end
        disp('sampler failed 4 times\n'); [ WP , DP , Z_W, OP , Z_O ] = GibbsSamplerBOLDA(varargin{:});
    end
end

function mm = static_match(pi1, savefilename)
    Voc_W1 = size(pi1,1); Voc_W2 = size(pi1,2);
    M1_indices = find(sum(abs(pi1),2)); M2_indices = find(sum(abs(pi1),1));
    pi2 = zeros(length(M1_indices), size(pi1,2));
    for i = 1:length(M1_indices)
        pi2(i, :) = pi1(M1_indices(i),:);
    end
    pi1 = pi2; pi2 = zeros(size(pi1,1), length(M2_indices));
    for j = 1:length(M2_indices)
        pi2(:,j) = pi1(:,M2_indices(j));
    end
    pi1 = pi2; clear pi2
    Voc_W1M = length(M1_indices); Voc_W2M = length(M2_indices);    
    [Matching, cost] = lapjv(-pi1); %#ok<NASGU> % HUNGARIAN LOOKS FOR MINIMUM EDGE WE WANT MAX EDGE
    mm = zeros(Voc_W1 + Voc_W2,1);
%disp('statmatch10')
    if Voc_W1M<Voc_W2M
        for i = 1:Voc_W1M
            for j = 1:Voc_W2M
                if Matching(i)==j
                    mm(M1_indices(i)) = M2_indices(j)+Voc_W1; 
                    mm(M2_indices(j)+Voc_W1) = M1_indices(i);
                end
            end 
        end
    else
        for j = 1:Voc_W2M
            for i = 1:Voc_W1M
                if Matching(j)==i
                    mm(M1_indices(i)) = M2_indices(j)+Voc_W1; 
                    mm(M2_indices(j)+Voc_W1) = M1_indices(i);
                end
            end 
        end
    end
%disp('statmatch10.5')
    save([savefilename,'.match.mat'], 'Matching', 'mm', 'M1_indices', 'M2_indices')
%disp('statmatch11')
end


function [mm, mu] = infer_match(pi1, WP, beta_W, gamma, iter, EM_iters, savefilename)
   %echo static_match on;
    Voc_W1 = size(pi1, 1);
    if Voc_W1 > size(WP,1)
        WP = WP';
    end
    N_1 = sum(WP(1:Voc_W1,:),2); N_1_log_rho_1 = (N_1 .*(log(N_1 + gamma) - log(sum(N_1+gamma))))';
    N_2 = sum(WP((Voc_W1+1):end,:),2); N_2_log_rho_2 = (N_2.*(log(N_2 + gamma) - log(sum(N_2+gamma))))';
%    mm1 = mm + 1;
 %   mm2 = zeros(size(mm1));
 %   for i = find(mm1>-1)
 %       mm2(i) = mu(i, mm1(i));
 %   end
    
    Voc_W2 = size(WP,1) - Voc_W1;
    phi = (WP + beta_W)./repmat(sum(WP+beta_W,1),size(WP,1), 1);
    mu  = zeros(size(pi1));
    save([savefilename,'.mu.mat'])

tic();
    jj = (Voc_W1+1):(Voc_W1 + Voc_W2);
fprintf('mu_n_rows: %d\n', size(mu,1));
fprintf('mu_n_cols: %d\n', size(mu,2));
fprintf('Voc_W2: %d\n', Voc_W2)
    for i = 1:Voc_W1
        a = repmat(WP(i,:), Voc_W2,1);
        a = (a+WP(jj, :))';
        b = repmat(phi(i,:), Voc_W2,1);
        b = log(b + phi(jj,:))';
        a = dot(a,b);
        b = - repmat(N_1_log_rho_1(i),1, Voc_W2)  - N_2_log_rho_2;
if i==1; fprintf('a_n_rows: %d\n', size(a,1));fprintf('a_n_cols: %d\n', size(a,2));fprintf('b_n_rows: %d\n', size(b,1));fprintf('b_n_cols: %d\n', size(b,2)); end
        mu(i,:) = a + b;
        
%        mu(i, :) = dot((repmat(WP(i,:), Voc_W2,1)+WP(jj, :))', log(repmat(phi(i,:), Voc_W2,1) + phi(jj,:))') - repmat(N_1_log_rho_1(i),1, Voc_W2)  - N_2_log_rho_2;        
%        mu(i, :) = dot((repmat(WP(i,:), Voc_W2,1)+WP(jj, :))', log(repmat(phi(i,:), Voc_W2,1) + phi(jj,:))') - repmat(N_1_log_rho_1(i),1, Voc_W2)  - N_2_log_rho_2;
    end
toc(), tic()
    mu = .3*mu/(max(abs(mu(:)))*(EM_iters - iter + 2)) + .7*pi1/max(abs(pi1(:)));
    mu = mu/max(abs(mu(:)));
    sortedmu = -sort(-mu(:)); % it's negative so we can sort from largest  to smallest
    num_positive = sum(pi1(:)>0); % number of non-zero weights in last match matrix
    cut = min(max(mu(:))*.9,sortedmu(round(num_positive*1.15))); % increase the number of zero weights each time    
    mu = mu.*(mu>cut);
    'starting staticmatch'
    mm = static_match(mu, savefilename);
    'static_match done'
toc()
end

function [x_w, d_w, l_o, l_w, Voc_W1, mm, x_o, d_o, seed, OUTPUT, samps, burn_in, thinningGaps, pi1, EM_iters, gibbs_iters, leftovers, relegate, restart] = init2(train, alpha, beta_W, beta_O, T, EM_iters, pi1, matchmode, savefilename, optimize)
echo static_match on;
gibbs_iters = 2.5e2; burn_in = 1e3; samps = 1; thinningGaps= 1e2;
if length(strfind(savefilename, 'twitter5'))>0
    if ~isempty(strfind(savefilename, 'ru'))
        load('/u/metanet/clustering/multilingual_opinions/twitter5-dataen-ru_verbadj.mat')
    else
        load('/u/metanet/clustering/multilingual_opinions/twitter5-dataen-es_verbadj.mat')
    end
end
    x_w = train.x_w;
    d_w = train.d_w;
    l_o = train.l_o;
    l_w = train.l_w;
    x_o = train.x_o;
    d_o = train.d_o;
    Voc_W1 = length(unique(x_w(l_w==1)));
    stream = RandStream('mt19937ar','Seed',sum(100*clock));
    RandStream.setGlobalStream(stream);
    EM_iters = 3;
    leftovers = 0;
    gibbs_iters = 0;
    if strcmp(matchmode{2},'Infer')
        burn_in = 2e3;
        gibbs_iters = 2.5e2; % Gibbs sampling iterations per EM iteration       
        EM_iters = 3;    
        leftovers = burn_in - gibbs_iters*(EM_iters + 1);
        if optimize
            gibbs_iters = 2.5e2; % Gibbs sampling iterations per EM iteration
            EM_iters = 3;    
            leftovers = burn_in - gibbs_iters*(EM_iters + 1);
        end
    else
        burn_in = 3e3; samps = 1; thinningGaps= 1e2;
        if optimize
            burn_in = 1e2; tots = 1.2e3; thinningGaps = 1e2; samps = tots/thinningGaps;
        end
       fprintf('burn_in: %d', burn_in)
       fprintf('\tsamps: %d\n', samps)
    end

    OUTPUT = 0;
    seed = round(rand(1)*50+1);
    mm = static_match(pi1, savefilename);
    save(savefilename)    
    mm = mm-(1+min(mm));  % Matlab indices start at 1, but C++ indices start at 0, and we are passing these indices to C++ code...
    relegate = strcmp(matchmode{3}, 'Relegate')*1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    restart = 1;
end