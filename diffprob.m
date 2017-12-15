% compare = [5, 5];                               

% Calculates the probability that two draws from multinomial distributions
% with the same probability parameter (but possibly different total counts)
% would result in a discrepancy of diff for one particular element.

function [p, memo] = diffprob(diff, N1, N2, alpha_i, sum_alphas, memo)
    %memo = zeros(N1+1,N2+1);
    underflowthreshhold =  log(1e-6/((1-diff)^2*(N1*N2))); %or for max precision try -745.132; %under this level, exp(b) = 0
    multiplicativeconstant = 15; %to avoid underflow
    diff = abs(diff);
    if diff>0
        betalnalphas = (betaln(alpha_i, sum_alphas - alpha_i));
        sum1 = 0;
        for n = ceil(N1*diff):N1
            %tic()
            nchooseklnN1n = nchoosekln(N1, n);
            sum11 = 0;
            for mm = 0:floor(N2*(n/N1-diff)); %(N2*(n-N1*diff)/N1)
                m = floor(N2*(n/N1-diff)) - mm; % m = floor(N2*(n-N1*diff)/N1) - mm;
                if memo(n+1,m+1)==0
                    b = nchooseklnN1n+nchoosekln(N2, m)+betaln(n+m+alpha_i, N1+N2-n-m+sum_alphas-alpha_i)-betalnalphas;
                    memo(n+1,m+1) = b;
                else
                    b = memo(n+1,m+1);
                end
                if b<underflowthreshhold
                    break
                end
                sum11 = sum11 + exp(b);
            end
            sum1 = sum1 + sum11;
            %c= toc()
        end
        
        sum2 = 0;
        for n = ceil(N2*diff):N2
            %tic()
            nchooseklnN2n = nchoosekln(N2, n);
            sum22 = 0;
            for mm = 0:floor(N1*(n/N2-diff)) %floor(N1*(n-N2*diff)/N2)
                m = floor(N1*(n/N2-diff)) -mm; %floor(N1*(n-N2*diff)/N2) - mm;
                if memo(m+1,n+1)==0
                    b=  nchooseklnN2n+nchoosekln(N1, m)+betaln(n+m+alpha_i, N1+N2-n-m+sum_alphas-alpha_i)-betalnalphas;
                    memo(m+1,n+1) = b;
                else
                    b = memo(m+1,n+1);
                end
                if b<underflowthreshhold
                    break
                end
                sum22 = sum22+exp(b);                
            end
            sum2 = sum2 + sum22;
            %c = toc()
        end
        p = (sum1 + sum2);%/(beta(alpha_i, sum_alphas - alpha_i));
    else
        p=1;
%         sum0 = 0;
%         for n = 0:min(N1, N2)
%             sum0 = sum0 + nchoosek(N1,n)*nchoosek(N2,n)*beta(2*n+alpha_i, N1+N2-2*n+sum_alphas-alpha_i);
%         end
%         
%         sum1 = 0;
%         for n = (diff+1):N1
%             sum11 = 0;
%             for psi = (diff+1):n
%                 sum11 = sum11 + nchoosek(N2, n-psi)*beta(2*n-psi+alpha_i, N1+N2-2*n+psi+sum_alphas-alpha_i);
%             end
%             sum1 = sum1 + sum11*nchoosek(N1, n);
%         end
%         
%         sum2 = 0;
%         for n = (diff+1):N2
%             sum22 = 0;
%             for psi = (diff+1):n
%                 sum22 = sum22 + nchoosek(N1, n-psi)*beta(2*n-psi+alpha_i, N1+N2-2*n+psi+sum_alphas-alpha_i);
%             end
%             sum2 = sum2 + sum22*nchoosek(N2,n);    
%         end
% 
%         
%         p = (sum1 + sum2 + sum0)/(beta(alpha_i, sum_alphas - alpha_i));
    end
    
end% compare = [5, 5];                               
function c = nchoosekln(n,k)
   n = double(n); 
   k = double(k);

   if k > n 
     error(message('MATLAB:nchoosek:KOutOfRange')); 
   end 
   if k > n/2, k = n-k; end
   if k <= 1
      c = k*log(n);
   else
      tolerance = 1e15;
      nums = (n-k+1):n;
      dens = 1:k;
      nums = log(nums)-log(dens);
      c = sum(nums);
      if c > tolerance
         warning(message('MATLAB:nchoosek:LargeCoefficient', sprintf( '%e', tolerance ), log10( tolerance )));
      end
   end
end
% Calculates the probability that two draws from multinomial distributions
% with the same probability parameter (but possibly different total counts)
% would result in a discrepancy of diff for one particular element.
% 
% function p = diffprob(diff, N1, N2, alpha_i, sum_alphas)
%     if diff>0
%         sum1 = 0;
%         for n = diff:N1
%             sum11 = 0;
%             for psi = diff:n
%                 sum11 = sum11 + nchoosek(N2, n-psi)*beta(2*n-psi+alpha_i, N1+N2-2*n+psi+sum_alphas-alpha_i);
%             end
%             sum1 = sum1 + sum11*nchoosek(N1, n);
%         end
%         
%         sum2 = 0;
%         for n = diff:N2
%             sum22 = 0;
%             for psi = diff:n
%                 sum22 = sum22 + nchoosek(N1, n-psi)*beta(2*n-psi+alpha_i, N1+N2-2*n+psi+sum_alphas-alpha_i);
%             end
%             sum2 = sum2 + sum22*nchoosek(N2,n);
%         end
%         p = (sum1 + sum2)/(beta(alpha_i, sum_alphas - alpha_i));
%     else
%         sum0 = 0;
%         for n = 0:min(N1, N2)
%             sum0 = sum0 + nchoosek(N1,n)*nchoosek(N2,n)*beta(2*n+alpha_i, N1+N2-2*n+sum_alphas-alpha_i);
%         end
%         
%         sum1 = 0;
%         for n = (diff+1):N1
%             sum11 = 0;
%             for psi = (diff+1):n
%                 sum11 = sum11 + nchoosek(N2, n-psi)*beta(2*n-psi+alpha_i, N1+N2-2*n+psi+sum_alphas-alpha_i);
%             end
%             sum1 = sum1 + sum11*nchoosek(N1, n);
%         end
%         
%         sum2 = 0;
%         for n = (diff+1):N2
%             sum22 = 0;
%             for psi = (diff+1):n
%                 sum22 = sum22 + nchoosek(N1, n-psi)*beta(2*n-psi+alpha_i, N1+N2-2*n+psi+sum_alphas-alpha_i);
%             end
%             sum2 = sum2 + sum22*nchoosek(N2,n);    
%         end
% 
%         
%         p = (sum1 + sum2 + sum0)/(beta(alpha_i, sum_alphas - alpha_i));
%     end
%     
% end

