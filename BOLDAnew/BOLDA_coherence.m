function D = BOLDA_coherence(WP, d, w, langs, Voc1)
WP = rectify(WP);
[T,V] = size(WP);
topX = 10;
inds = zeros(topX,1);
Voc = cell(1,2);
Voc{1} = 1:Voc1;
Voc{2} = (Voc1+1):V;
C = cell(1,2);
for lang = 1:2
    w_lang = w(langs==lang);
    d_lang = d(langs==lang);
    C{lang} = zeros(T,1);
    for t = 1:T
        rest = WP(t, :);
        rest = rest(Voc{lang});
        for i = 1:topX
            [~, inds(i)] = max(rest);
            rest(inds(i)) = 0;
        end
        inds = inds+(lang==2)*Voc1;
        docs = cell(topX,1);
        for i = 1:topX
            docs{i} = unique(d(w==inds(i)));
        end
        C{lang}(t)  =  coherence(inds, w_lang, d_lang, docs);
    end
    C{lang} = median(C{lang});
end
D = C{1} + C{2};
end


function C = coherence(inds1, w, d, docs)
    % inds1: indices of top words
    % w: term for each word token
    % d: document identities
    topX = length(inds1); % compute coherence among topX top words
    D_w = zeros(topX, 1);
    for i = 1:topX
            D_w(i) = length(docs{i});
    end
    D_ww = zeros(topX, topX);
    C = 0;
    for i = 2:(topX)
        for j = 1:(i-1)
            D_ww(i,j) = length(intersect(docs{i}, docs{j}));
            C = C + log(D_ww(i,j) + 0.1) - log(D_w(j));
        end
    end
    C = C/nchoosek(topX, 2);
end

function a = rectify(a)
    if size(a, 2)<size(a,1)
        a = a';
    end
end