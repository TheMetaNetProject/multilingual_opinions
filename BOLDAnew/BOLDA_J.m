
function [ WP , DP , OP, Z_O, Z_W, phi_W, phi_O1, phi_O2, theta, ENTRY_SERIES, entrymap] = BOLDA_Multiple(x_w, d_w, x_o, d_o, l_o, l_w, alpha, beta_W, beta_O, gamma, T, EM_iters, pi, matchmode, savefilename)
    pi = ceil(pi);
if strcmp(matchmode, 'special')
    Gibbs_iters = 200; % Gibbs sampling iterations per EM iteration
else
    Gibbs_iters = 4e3; % Gibbs sampling iterations per EM iteration
end
%    EM_iters = 3;
    OUTPUT = 2;
    seed = 3;
    Voc_O1 = length(unique(x_o(l_o==1)));Voc_O2 = length(unique(x_o(l_o==2))); Voc_W1 = length(unique(x_w(l_w==1))); Voc_W2 = length(unique(x_w(l_w==2)));
    total_M = sum(sum(pi));
    M = max([sum(pi), sum(pi')]);
    m = 0;
    dictionary = zeros(total_M, 2);

    for i = 1:size(pi,1) %nonzero rows
        for j = 1:size(pi,2) %nonzero columns
            if pi(i,j)>0
                m = m + 1;
                dictionary(m,1) = i-1;
                dictionary(m,2) = j-1;
            end
        end
    end
    numentriesvector = zeros(Voc_W1 + Voc_W2,1);
    for m = 1:total_M
        if dictionary(m,1)>0
            wi = dictionary(m,1);
            numentriesvector(wi) = numentriesvector(wi)+1;
        end
        if dictionary(m,2)>0
            wi = dictionary(m,2)+ Voc_W1;
            numentriesvector(wi) = numentriesvector(wi)+1;
        end

    end
M = max(numentriesvector)
entryvector = zeros((Voc_W1 + Voc_W2)*M,1);
placevec = numentriesvector;
    for m = 1:total_M
        wi = dictionary(m,1);
        if wi>0
            entryvector((wi-1)*M+placevec(wi)) = m;
            placevec(wi) = placevec(wi) - 1;
        end
        wi = dictionary(m,2)+ Voc_W1;
        if wi>Voc_W1
            entryvector((wi-1)*M+placevec(wi)) = m;
            placevec(wi) = placevec(wi) - 1;
        end

    end

    entrymap.numentriesvector = numentriesvector; 
    entrymap.dictionary = dictionary;
    entrymap.entryvector = entryvector;
    save(savefilename)
    [ WP , DP , Z_W, OP , Z_O, ENTRY_SERIES ] = GibbsSamplerBOLDA_Multiple(x_w, d_w, T, Gibbs_iters, alpha, beta_W, l_o, x_o, d_o, numentriesvector, beta_O , gamma, seed, OUTPUT, entryvector);
    save(savefilename)
    [phi_W, phi_O1, phi_O2, theta] = inference(WP, OP, DP, alpha, beta_W, beta_O, total_M, Voc_O1, Voc_O2,T);
    save(savefilename)
end


function [phi_W, phi_O1, phi_O2, theta] = inference(WP, OP, DP, alpha, beta_W, beta_O, total_M, Voc_O1, Voc_O2,T)
    phi_W = zeros(total_M, T); phi_O1 = zeros(Voc_O1, T); phi_O2 = zeros(Voc_O2, T);
    theta = zeros(T, size(DP,1)); if T~=size(DP,2), disp('DP and Docnum not equivalent'), end
    for k = 1:T
        for i = 1:total_M
            phi_W(i,k) = (WP(i,k) + beta_W);
        end
        phi_W(:,k) = phi_W(:,k)/sum(sum(phi_W(:,k))); % NOT SURE IF THIS IS RIGHT... IS THIS A SUM OVER ALL *POSSIBLE* MATCHINGS OR OVER ALL CURRENT MATCHINGS?
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
    for d = 1:size(DP,1)
        for k = 1:T
            theta(k,d) = DP(d,k)+alpha;
        end
        theta(:,d) = theta(:,d)/sum(theta(:,d));
    end
end
               