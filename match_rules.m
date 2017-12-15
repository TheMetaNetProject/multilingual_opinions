function [c_new] = match_rules(pi, iter, x_w, l_w, Voc_W1, iters)

if iter==1

    indices_1 = [];
    indices_2 = [];
    for i = 1:size(pi,1)
        if sum(abs(pi(i, :)))>0
            indices_1 = [indices_1, i];
        end
    end
    for j = 1:size(pi,2)
        if sum(abs(pi(:,j)))>0
            indices_2 = [indices_2, j];
        end
    end
    indices_2 = indices_2 + Voc_W1;
    c_new =zeros(size(x_w));
    for i = 1:length(x_w)
        if l_w(i)==1
            if sum(x_w(i)==indices_1)
                c_new(i) = 1;
            end
        else
            if sum(x_w(i)==indices_2)
                c_new(i) = 1;
            end
        end
    end
else
    indices_1 = [];
    indices_2 = [];
    for i = 1:size(pi,1)
        if sum(pi(i, :))>(median(median(pi))+(2.5-2*iter)*sqrt(var(pi(:))))
            indices_1 = [indices_1, i];
        end
    end
    for j = 1:size(pi,2)
        if sum(pi(:, j))>(median(median(pi))+(2.5-2*iter)*sqrt(var(pi(:))))
            indices_2 = [indices_2, j];
        end
    end
    indices_2 = indices_2 + Voc_W1;
    c_new =zeros(size(x_w));
    for i = 1:length(x_w)
        if l_w(i)==1
            if sum(x_w(i)==indices_1)
                c_new(i) = 1;
            end
        else
            if sum(x_w(i)==indices_2)
                c_new(i) = 1;
            end
        end
    end
                
end