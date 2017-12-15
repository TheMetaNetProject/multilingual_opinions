function BOLDArun(langs, T, maxdocnum, matchmode, optimize,opinion_words, corpus_name)
     %clear  verb_twitter3_en_small.mat
     %lang1 = 'en'; %lang2 = 'es';
     %T = 100, gamma = 0.04, matchmode=1, langs = {'en', 'ru'}; %noactivematch' %27114 'joint-BOLDA' 'noactivematch', 
     %T = 100, gamma = 0.04, maxdocnum = 8e4,matchmode = 'joint-BOLDA' %27115
     %extrasuffix = '_nocomments'
     %o_condition = '_verbsonly'
     maxdocnum = maxdocnum; %#ok<ASGSL,NASGU>
     basedir = '/u/metanet/clustering/multilingual_opinions/'; disp([basedir,'\n'])
     addpath(genpath(basedir))
     %extrasuffix = '_nocomments'
     %corpus_name = 'twitter'
     %opinion_words = 'verbadjective';

     topic_words = 'noun';
     switch matchmode 
         case 1, matchmode = {'Single','Infer','Include'}  %#ok<NOPRT>
         case 2, matchmode = {'Single','Static','Include'}  %#ok<NOPRT>
         case 3, matchmode = {'Single','Infer','Relegate'} %#ok<NOPRT>
         case 4, matchmode = {'Single','Static','Relegate'}  %#ok<NOPRT>
         case 5, matchmode = {'Multiple','Static','Include'}%#ok<NOPRT>
         case 6, matchmode = {'Multiple','Static','Relegate'}%#ok<NOPRT>
     end
     path_out = [basedir, corpus_name,'/BOLDA_results/', opinion_words,'/',matchmode{1}, matchmode{2}, matchmode{3},'/'];
     startupfile = [basedir,corpus_name,'-data', langs{1},'-',langs{2}, '_', opinion_words, '.mat']; %strcat(path_out, 'prelim_', langs{1}, '_', langs{2}, '_', opinion_words, '.mat');
     load(startupfile)

     savefilename = strcat(path_out, langs{1}, '_', langs{2}, '_','results_T-', int2str(T), '_', corpus_name,'_',matchmode{1}, matchmode{2}, matchmode{3},'_',opinion_words,'.mat');
     if optimize==1;
        savefilename = [savefilename, '.optim.mat' ];
     end

     load(strcat('match-matrix_', corpus_name,'_', topic_words, '_', langs{1}, '-', langs{2}, '.mat'))  % the dictionary; should be called 'pi1'
     if strcmp(matchmode{1},'Multiple')   %strcmp(matchmode,'joint-BOLDA')||strcmp(matchmode,'joint-BOLDA-matchonly')
         pi1 = ceil(pi1); %#ok<NODEF>
     else
         try
             pi1 = pi1(2:end, 2:end); %#ok<NODEF>
         catch %#ok<*CTCH>
   	      load(strcat('match-matrix_', corpus_name,'_', topic_words, '_', langs{1}, '-', langs{2}, '.mat'))  % the dictionary; should be called 'pi1'
             pi1 = pi1(2:end, 2:end);%#ok<NODEF>
         end
     end
     pi1 = sparse(pi1);

     alpha = 50/T;
     beta_W = 0.02;
     beta_O = 0.02;
     EM_iters = 3;
     lik0 = -1/eps;
     if optimize, iters1 = 1; else iters1 = 10; end
     try, load([savefilename,'.best.mat']), lastit = iter1; catch, lastit = 0; end
     for iter1 = lastit:iters1
         fprintf('iteration %d\n', iter1)
         if strcmp(matchmode{1},'Multiple')
             [ WP_results1 , DP_results1 , OP_results1, Z_O, Z_W, E_W, entrymap, tprob_W, tprob_O] = BOLDA_Multiple(train, test, alpha, beta_W, beta_O, T, EM_iters, pi1, matchmode, savefilename, optimize); %#ok<ASGLU>
         else                                                                                                                                                                                                                         
             [WP_results1, DP_results1, OP_results1, Z_O, Z_W,mm, tprob_W, tprob_O] = BOLDA_Single(train, test, alpha, beta_W, beta_O, T, EM_iters, pi1, matchmode, savefilename, optimize); %#ok<ASGLU>
         end
         save([savefilename, '.params.',int2str(iter1),'.mat'], 'WP_results1', 'DP_results1', 'OP_results1')
         if optimize==0    
             if (tprob_W + tprob_O) > lik0
                 lik0 = tprob_W + tprob_O;
                 fprintf('new lik0: %6.4f\n', lik0)
                 WP_results = WP_results1; OP_results = OP_results1; DP_results = DP_results1; %#ok<NASGU>
                 save([savefilename,'.best.mat'])
             end
         end
     end
     save(savefilename)
end  % END OF MAIN FUNCTION %