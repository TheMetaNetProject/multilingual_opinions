
function [ WP , DP , OP, Z_O, Z_W, mm, cost] = BOLDA(x_w, d_w, x_o, d_o, l_o, l_w, alpha, beta_W, beta_O, gamma, T, EM_iters, pi, matchmode, savefilename, optimize)
%phi_W, phi_O1, phi_O2, rho_1, rho_2, theta,
  %  pi = pi(2:end, 2:end);    
if strcmp(matchmode,'activematch')
    Gibbs_iters = 250; % Gibbs sampling iterations per EM iteration
else
    Gibbs_iters = 2e3;
end
    EM_iters = 3;
    OUTPUT = 2;
    seed = 3;
    iter = 1;
    Voc_W1 = length(unique(x_w((l_w==1))));
    c_new = match_rules(pi, iter,x_w, l_w, Voc_W1);    
    M1_indices = unique(x_w(find((c_new==1).*(l_w==1)))); M2_indices = unique(x_w(find((c_new==1).*(l_w==2))));
    NotM1_indices = unique(x_w(find((l_w==1).*(c_new==0)))); NotM2_indices = unique(x_w(find((l_w==2).*(c_new==0))));
    Voc_O1 = length(unique(x_o(l_o==1))); Voc_O2 = length(unique(x_o(l_o==2))); Voc_W1M = length(M1_indices); Voc_W2M = length(M2_indices); Voc_W1U = length(NotM1_indices); Voc_W2U = length(NotM2_indices);
    
  %  pi = zeros(Voc_W1M, Voc_W2M);

            
    if Voc_W1M+Voc_W2M~=length(unique(x_w(c_new==1))), disp('Voc_W1+Voc_W2 does not equal Voc_W');end
    
    mm = zeros(Voc_W1M+Voc_W1U+Voc_W2M+Voc_W2U, 1);
    save(savefilename)    
'phase a'
    [Matching,cost] = lapjv(-pi(M1_indices, M2_indices-Voc_W1)+1); % HUNGARIAN LOOKS FOR MINIMUM EDGE WE WANT MAX EDGE
save('edump.mat', 'M1_indices', 'M2_indices', 'Voc_W1', 'pi', 'Voc_W2M', 'Voc_W1M', 'Matching')
'phase b'
    if Voc_W1M < Voc_W2M 
        for i = 1:Voc_W1M
            for j = 1:Voc_W2M
                if Matching(i)==j
                    mm(M1_indices(i)) = M2_indices(j); 
                    mm(M2_indices(j)) = M1_indices(i);
                end
            end
        end 
    else
        for i = 1:Voc_W2M
            for j = 1:Voc_W1M
                if Matching(i)==j
                    mm(M1_indices(j)) = M2_indices(i); 
                    mm(M2_indices(i)) = M1_indices(j);
                end
            end
        end
    end
    save(savefilename)
    mm = mm-1;
    for i = find(c_new==1)
        if mm(x_w(i))<0
            c_new(i) = 0;
        end
    end
'phase c'
    if (optimize==1)&&strcmp(matchmode, 'noactivematch')
        iterrs = 20;
        [ WP , DP , Z_W, OP , Z_O ] = GibbsSamplerBOLDA(x_w, d_w, T, iterrs, alpha, beta_W, l_o, mm, x_o, d_o, c_new, beta_O , gamma, seed, OUTPUT );
        for i = 2:round(Gibbs_iters/iterrs)
            [ WP , DP , Z_W, OP , Z_O ] = GibbsSamplerBOLDA(x_w, d_w, T, iterrs, alpha, beta_W, l_o, mm, x_o, d_o, c_new, beta_O , gamma, seed, OUTPUT, Z_W, Z_O);
        end
    
    else if strcmp(matchmode, 'noactivematch')
            [ WP , DP , Z_W, OP , Z_O ] = GibbsSamplerBOLDA(x_w, d_w, T, Gibbs_iters, alpha, beta_W, l_o, mm, x_o, d_o, c_new, beta_O , gamma, seed, OUTPUT );
        end
    end
'phase d'
    if strcmp(matchmode,'activematch')
        WP = zeros(max(x_w), T);
        [mm,cost, mu] = matcher(pi, WP, beta_W, gamma,T,  M1_indices, M2_indices, Voc_W1M, Voc_W2M, iter, x_w, l_w, Voc_W1);
        mm = mm-1; % SUBTRACT 1 BECAUSE IN C++ INDICES START FROM ZERO...
        [ WP , DP , Z_W, OP , Z_O ] = GibbsSamplerBOLDA(x_w, d_w, T, Gibbs_iters, alpha, beta_W, l_o, mm, x_o, d_o, c_new, beta_O, gamma, seed, OUTPUT);
  %  [phi_W, phi_O1, phi_O2, rho_1, rho_2, theta] = inference(WP, OP, DP, l_w, x_w, alpha, beta_W, beta_O, gamma, NotM1_indices, NotM2_indices, M1_indices, M2_indices, Voc_O1, Voc_O2,T);
        for iter = 2:EM_iters
            save(savefilename)
            if strcmp(matchmode, 'activematch')
                disp('starting match rules') 
                [c_new] = match_rules(mu, iter,x_w, l_w, Voc_W1, EM_iters);
            end
           for i = find(c_new==1)
               try
                   if mm(x_w(i))<0
                       c_new(i) = 0;
                   end
               catch
                   0;
               end
            end
            [ WP , DP , Z_W, OP , Z_O ] = GibbsSamplerBOLDA(x_w, d_w, T, Gibbs_iters, alpha, beta_W, l_o, mm, x_o, d_o, c_new, beta_O, gamma, seed, OUTPUT, Z_W, Z_O );
            save(savefilename)
            if strcmp(matchmode, 'activematch')  
                 disp('starting matcher')     
                [mm,cost, mu] = matcher(pi, WP, beta_W, gamma,T,  M1_indices, M2_indices, Voc_W1M, Voc_W2M, iter, x_w, l_w, Voc_W1);
                mm = mm-1;% SUBTRACT 1 BECAUSE IN C++ INDICES START FROM ZERO...
            end
        end
    end

  %  [phi_W, phi_O1, phi_O2, rho_1, rho_2, theta] = inference(WP, OP, DP, l_w, x_w, alpha, beta_W, beta_O, gamma, NotM1_indices, NotM2_indices, M1_indices, M2_indices, Voc_O1, Voc_O2,T);
    if strcmp(matchmode, 'activematch')
            disp('starting final matcher') 

        [mm, cost] = matcher(pi, WP, beta_W, gamma,T,  M1_indices, M2_indices, Voc_W1M, Voc_W2M, iter, x_w, l_w, Voc_W1);
        mm = mm-1;  % SUBTRACT 1 BECAUSE IN C++ INDICES START FROM ZERO...
    end
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

function [mm, cost, mu] = matcher(pi, WP, beta_W, gamma,T, M1_indices, M2_indices, Voc_W1M, Voc_W2M, iter, x_w, l_w, Voc_W1)
%    try  %***********************************************************************************************
    mm = zeros(Voc_W1M+Voc_W2M,1);
    rho_1 = zeros(Voc_W1M, 1); rho_2 = zeros(Voc_W2M, 1);
    mu = zeros(max(M1_indices), max(M2_indices-Voc_W1));

  %  phi_W = zeros(Voc_W1M, Voc_W2M, T);  %%This is too large; will try a space-saving trick
  %  for k = 1:T
  %      for i = 1:Voc_W1M
  %          for j = 1:Voc_W2M
  %              phi_W(i,j,k) = (WP( M1_indices(i),k) + WP( M2_indices(j),k) + beta_W);
  %          end
  %      end
  %      phi_W(:,:,k) = phi_W(:,:,k)/sum(sum(phi_W(:,:,k))); % NOT SURE IF THIS IS RIGHT... IS THIS A SUM OVER ALL *POSSIBLE* MATCHINGS OR OVER ALL CURRENT MATCHINGS?
  %  end

    normalizer = zeros(1,T);
    temp = zeros(Voc_W1M, Voc_W2M);  %%This is too large; will try a space-saving trick
    for k = 1:T
        for i = 1:Voc_W1M
            for j = 1:Voc_W2M
                temp(i,j) = (WP( M1_indices(i),k) + WP( M2_indices(j),k) + beta_W);
            end
        end
        normalizer(k) = sum(sum(temp(:,:))); % NOT SURE IF THIS IS RIGHT... IS THIS A SUM OVER ALL *POSSIBLE* MATCHINGS OR OVER ALL CURRENT MATCHINGS?
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
            WP1 = WP(M1_indices(i),:);
            WP2 = WP(M2_indices(j),:);
            mu(M1_indices(i),M2_indices(j)-Voc_W1) = pi(M1_indices(i),M2_indices(j)-Voc_W1); %+ sum(log(reshape((WP1 + WP2 + beta_W)./normalizer,size(WP(1,:)))).*(WP1+WP2)) - sum(WP1)*log(rho_1(i)) - sum(WP2)*log(rho_2(j));
%            mu(i,j) = pi(i,j) + sum(log(reshape(phi_W(i,j,:),size(WP(1,:)))).*(WP(M1_indices(i),:)+WP(M2_indices(j),:))) - sum(WP(M1_indices(i),:))*log(rho_1(i)) - sum(WP(M2_indices(j),:))*log(rho_2(j));
        end
    end
% catch %***********************************************************************************************
% save('errordump.mat') %*******************************************************************************
%crashnow
% end   %***********************************************************************************************


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% EXPERIMENTAL CODE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    c_new = match_rules(mu, iter,x_w, l_w, Voc_W1);    
    M1_indices = unique(x_w(find((c_new==1).*(l_w==1)))); M2_indices = unique(x_w(find((c_new==1).*(l_w==2))));
    NotM1_indices = unique(x_w(find((l_w==1).*(c_new==0)))); NotM2_indices = unique(x_w(find((l_w==2).*(c_new==0))));
    Voc_W1M = length(M1_indices); Voc_W2M = length(M2_indices);Voc_W1U = length(NotM1_indices); Voc_W2U = length(NotM2_indices);    
    [Matching,cost] = lapjv(-mu(M1_indices, M2_indices-Voc_W1)); % HUNGARIAN LOOKS FOR MINIMUM EDGE WE WANT MAX EDGE
    if Voc_W1M < Voc_W2M       
       for i = 1:Voc_W1M
            for j = 1:Voc_W2M
                if Matching(i)==j
                    mm(M1_indices(i)) = M2_indices(j); 
                    mm(M2_indices(j)) = M1_indices(i);
                end
            end
        end 
    else
        for i = 1:Voc_W2M
            for j = 1:Voc_W1M
                if Matching(i)==j
                    mm(M1_indices(j)) = M2_indices(i); 
                    mm(M2_indices(i)) = M1_indices(j);
                end
            end
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%    [Matching, cost] = lapjv(-mu); % Hungarian looks for MINIMUM EDGE, we want MAXIMUM EDGE
%    for i = 1:Voc_W1M
%        for j = 1:Voc_W2M
%            if Matching(i)==j
%                mm(M1_indices(i)) = M2_indices(j); 
%                mm(M2_indices(j)) = M1_indices(i);
%            end
%        end
%    end
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
           
               