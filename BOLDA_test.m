function [ WP , DP , OP, Z_O, Z_W, phi_W, phi_O1, phi_O2, rho_1, rho_2, theta,mm, cost, iter1, iter5] = BOLDA_test()
filename = 'BOLDAresults_T-50_MaxDocs-4e4_gamma-40e-3_.mat'
%filename = 'BOLDAresults_T-200_MaxDocs-8e4_gamma-40e-3_.mat'
load(filename)
mu1 = load('BOLDAresults_T-50_MaxDocs-4e4_gamma-40e-3_.mat', 'mu');
mu = mu1.mu;
alpha1 = load('BOLDAresults_T-50_MaxDocs-4e4_gamma-40e-3_.mat', 'alpha');
alpha = alpha1.alpha;
alpha1 = load('BOLDAresults_T-50_MaxDocs-4e4_gamma-40e-3_.mat', 'gamma');
gamma = alpha1.gamma;
curr_iter = iter;
clear alpha1;
clear mu1;
    for iter = curr_iter:EM_iters
        save(savefilename)
        [c_new] = match_rules(mu, iter,x_w, l_w, Voc_W1, EM_iters);
        [ WP , DP , Z_W, OP , Z_O ] = GibbsSamplerBOLDA(x_w, d_w, T, Gibbs_iters, alpha, beta_W, l_o, mm, x_o, d_o, c_new, beta_O, gamma, seed, OUTPUT, Z_W, Z_O );
        [mm,cost, mu] = matcher(pi, WP, beta_W, gamma,T,  M1_indices, M2_indices, Voc_W1M, Voc_W2M);
        mm = mm-1;% SUBTRACT 1 BECAUSE IN C++ INDICES START FROM ZERO...
    end
    [phi_W, phi_O1, phi_O2, rho_1, rho_2, theta] = inference(WP, OP, DP, l_w, x_w, alpha, beta_W, beta_O, gamma, NotM1_indices, NotM2_indices, M1_indices, M2_indices, Voc_O1, Voc_O2,T);
    [mm, cost] = matcher(pi, WP, beta_W, gamma,T,  M1_indices, M2_indices, Voc_W1M, Voc_W2M);
    mm = mm-1;  % SUBTRACT 1 BECAUSE IN C++ INDICES START FROM ZERO...
    save(savefilename)
end


function [phi_W, phi_O1, phi_O2, rho_1, rho_2, theta] = inference(WP, OP, DP, l_w, x_w, alpha, beta_W, beta_O, gamma, NotM1_indices, NotM2_indices, M1_indices, M2_indices, Voc_O1, Voc_O2,T)
    Voc_W1M = length(M1_indices); Voc_W2M = length(M2_indices);
    Voc_W1U = length(NotM1_indices); Voc_W2U = length(NotM2_indices);
    phi_W = zeros(Voc_W1M, Voc_W2M, T); phi_O1 = zeros(Voc_O1, T); phi_O2 = zeros(Voc_O2, T);
    rho_1 = zeros(Voc_W1U, 1); rho_2 = zeros(Voc_W2U, 1);
    theta = zeros(T, size(DP,1)); if T~=size(DP,2), disp('DP and Docnum not equivalent'), end
    for k = 1:T
        for i = 1:Voc_W1M
            for j = 1:Voc_W2M
                phi_W(i,j,k) = (WP(M1_indices(i),k) + WP(M2_indices(j),k) + beta_W);
            end
        end
        phi_W(:,:,k) = phi_W(:,:,k)/sum(sum(phi_W(:,:,k))); % NOT SURE IF THIS IS RIGHT... IS THIS A SUM OVER ALL *POSSIBLE* MATCHINGS OR OVER ALL CURRENT MATCHINGS?
    end
    for i = 1:Voc_O1
        for k = 1:T
            phi_O1(i,k) = OP(i,k) + beta_O;
        end
        phi_O1(:,k) = phi_O1(:,k)/sum(phi_O1(:,k)); 
    end
    for j = 1:Voc_O2
        for k = 1:T
            phi_O2(j,k) = OP(Voc_O1 + j,k) + beta_O;
        end
        phi_O2(:,k) = phi_O2(:,k)/sum(phi_O2(:,k)); 
    end
    for i = 1:Voc_W1U
        rho_1(i) = sum( (x_w==NotM1_indices(i))) + gamma;
    end
    rho_1 = rho_1/sum(rho_1);
    for j = 1:Voc_W2U
        rho_2(j) = sum( (x_w==NotM2_indices(j))) + gamma;
    end
    rho_2 = rho_2/sum(rho_2);
    for d = 1:size(DP,1)
        for k = 1:T
            theta(k,d) = DP(d,k)+alpha;
        end
        theta(:,d) = theta(:,d)/sum(theta(:,d));
    end
end

function [mm, cost, mu] = matcher(pi, WP, beta_W, gamma,T, M1_indices, M2_indices, Voc_W1M, Voc_W2M)
    
    mm = zeros(Voc_W1M+Voc_W2M,1);
    rho_1 = zeros(Voc_W1M, 1); rho_2 = zeros(Voc_W2M, 1);
    mu = zeros(Voc_W1M, Voc_W2M);
    phi_W = zeros(Voc_W1M, Voc_W2M, T);  %%This is too large; will try a space-saving trick
    for k = 1:T
        for i = 1:Voc_W1M
            for j = 1:Voc_W2M
                phi_W(i,j,k) = (WP( M1_indices(i),k) + WP( M2_indices(j),k) + beta_W);
            end
        end
        phi_W(:,:,k) = phi_W(:,:,k)/sum(sum(phi_W(:,:,k))); % NOT SURE IF THIS IS RIGHT... IS THIS A SUM OVER ALL *POSSIBLE* MATCHINGS OR OVER ALL CURRENT MATCHINGS?
    end

    for i = 1:Voc_W1M
        rho_1(i) = sum(WP(M1_indices(i),:)) + gamma;
    end
    rho_1 = rho_1/sum(rho_1);
    for j = 1:Voc_W2M
        rho_2(j) = sum(WP(M2_indices(j),:)) + gamma;
    end
    rho_2 = rho_2/sum(rho_2);
    for i = 1:Voc_W1M
        for j = 1:Voc_W2M
            mu(i,j) = pi(i,j) + sum(log(reshape(phi_W(i,j,:),size(WP(1,:)))).*(WP(M1_indices(i),:)+WP(M2_indices(j),:))) - sum(WP(M1_indices(i),:))*log(rho_1(i)) - sum(WP(M2_indices(j),:))*log(rho_2(j));
        end
    end
sizemu = size(mu)
    [Matching, cost] = lapjv(-mu); % Hungarian looks for MINIMUM EDGE, we want MAXIMUM EDGE
    for i = 1:Voc_W1M
        for j = 1:Voc_W2M
            if Matching(i)==j
                mm(M1_indices(i)) = M2_indices(j); 
                mm(M2_indices(j)) = M1_indices(i);
            end
        end
    end
end

% function [ WP , DP , Z_W, OP , Z_O ] =  GibbsSamplerBOLDA1(x_w, d_w, T, Gibbs_iters, alpha, beta_W, l_o, mm, x_o, d_o, c_new, beta_O, gamma, seed, OUTPUT, Z_W, Z_O )
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
%    for iter = 1:Gibbs_iters
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
           
               