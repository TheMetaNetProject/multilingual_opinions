% MATLAB version of the C code for the Gibbs Sampler; Very slow and possibly buggy
% function [ WP , DP , Z_W, OP , Z_O ] =  GibbsSamplerBOLDA1(x_w, d_w, T, gibbs_iters, alpha, beta_W, l_o, mm, x_o, d_o, c_new, beta_O, gamma, seed, OUTPUT, relegate, Z_W, Z_O )
%     mm = mm + 1;
%     n_w = length(x_w);
%     n_o = length(x_o);
%     D = length(unique(d_w));
%     one = 1;
%     Voc_W = length(unique(x_w)); Voc_O1 = length(unique(x_o(l_o==1)));Voc_O2 = length(unique(x_o(l_o==2)));
%     M = (length(unique(mm))-1)/2;
%     Wbeta_W = M*beta_W;
%     Wbeta_O1 = Voc_O1*beta_O;
%     Wbeta_O2 = Voc_O2*beta_O;
%     OP = zeros(Voc_O1+Voc_O2, T);
%     WP = zeros(Voc_W, T);
%     DP = zeros(D, T);
% %% INITIALIZATION %%	
%     if nargin >15 
%         Ztot_W = zeros(T,1);
%         for i = 1:n_w
%             wi = x_w(i);
%             di = d_w(i);
%             ci = c_new(i);    
%             topic = Z_W(i);
%             DP(di, topic) = DP(di, topic) + 1;
%             if ci==one
%                 WP(wi, topic) = WP(wi, topic) + 1;
%                 Ztot_W(topic) = Ztot_W(topic) + 1;
%             end
%         end
%         Ztot_O1 = zeros(T,1);
%         Ztot_O2 = zeros(T,1);
%         for i = 1:n_o
%             oi = x_o(i); 
%             di = d_o(i);
%             li = l_o(i);
%             topic = Z_O(i);
%             OP(oi, topic) = OP(oi, topic) + 1;
%             if li==1
%                 Ztot_O1(topic) = Ztot_O1(topic) + 1;
%             else
%                 Ztot_O2(topic) = Ztot_O2(topic) + 1;
%             end
%         end
%     else
%         Ztot_W = zeros(T,1);
%         for i = 1:n_w
%             wi = x_w(i);
%             di = d_w(i);
%             ci = c_new(i);    
%             topic = sample(ones(T,1)*1/T,1);
%             Z_W(i) = topic;
%             DP(di, topic) = DP(di, topic) + 1;
%             if ci==one
%                 WP(wi, topic) = WP(wi, topic) + 1;
%                 Ztot_W(topic) = Ztot_W(topic) + 1;
%             end
%         end
%         Ztot_O1 = zeros(T,1);
%         Ztot_O2 = zeros(T,1);
%         for i = 1:n_o
%             oi = x_o(i); 
%             di = d_o(i);
%             li = l_o(i);
%             topic = sample(ones(T,1)*1/T,1);
%             Z_O(i) = topic;
%             OP(oi, topic) = OP(oi, topic) + 1;
%             if li==1
%                 Ztot_O1(topic) = Ztot_O1(topic) + 1;
%             else
%                 Ztot_O2(topic) = Ztot_O2(topic) + 1;
%             end
%         end    
%     end
%     order_W = randperm(n_w);
%     order_O = randperm(n_o);
%     
%     
% %% SAMPLING
%    probs = zeros(T,1);
%    for iter = 1:gibbs_iters
%        if mod(iter,10)==0
%            disp(['iteration ', int2str(iter)])
%        end
%        for i = order_W
%            wi = x_w(i);
%            di = d_w(i);
%            ci = c_new(i);
%            topic = Z_W(i);
%            if ci==one
%                Ztot_W(topic) = Ztot_W(topic) - 1;
%                WP(wi, topic) = WP(wi, topic) - 1;
%            end
%            DP(di, topic) = DP(di, topic) - 1;
%            if ci==one
%                for t=1:T
%                    probs(t) = (WP(wi,t)+WP(mm(wi), t) + beta_W)/(Ztot_W(t)+Wbeta_W)*(DP(di, t) + alpha);
%  
%                end
%            else
%                for t = 1:T
%                    probs(t) = (DP(di, t) + alpha);
%                end
%            end
%            topic = sample(probs,1);
%            Z_W(i) = topic;
%            DP(di, topic) = DP(di, topic) + 1;
%            if ci==one
%                WP(wi, topic) = WP(wi, topic) + 1;
%                Ztot_W(topic) = Ztot_W(topic) + 1;
%            end
%        end
%        for i = order_O
%            oi = x_o(i);
%            di = d_o(i);
%            topic = Z_O(i);
%            OP(oi, topic) = OP(oi, topic) - 1;
%            if li==1
%                Ztot_O1(topic) = Ztot_O1(topic) - 1;
%                for t = 1:T
%                    probs(t) = (OP(oi,t)+ beta_O)/(Ztot_O1(t)+Wbeta_O1)*(DP(di, t) + alpha);
%                end
%            else
%                Ztot_O2(topic) = Ztot_O2(topic) - 1;
%                for t = 1:T
%                    probs(t) = (OP(oi,t)+ beta_O)/(Ztot_O2(t)+Wbeta_O2)*(DP(di, t) + alpha);
%                end
%            end
%            topic = sample(probs,1);
%            Z_O(i) = topic;
%            OP(oi, topic) = OP(oi, topic) + 1;
%            if li==1
%                Ztot_O1(topic) = Ztot_O1(topic) + 1;
%            else
%                Ztot_O2(topic) = Ztot_O2(topic) + 1;
%            end
%        end
%    end
% end
           
               