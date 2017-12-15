T = 100, gamma = 0.04, maxdocnum = 8e4
filenamesave = ['BOLDAresults_T-',int2str(T), '_MaxDocs-',int2str(maxdocnum/1e4),'e4_gamma-',int2str(gamma*1e3),'e-3_.mat']
load(['prelim',filenamesave])
[ WP_results , DP_results , OP_results, Z_O, Z_W, phi_W, phi_O1, phi_O2, rho_1, rho_2, theta,mm, cost, iter1, iter5] = BOLDA1(x_w, d_w, x_o, d_o, l_o, l_w, alpha, beta_W, beta_O, gamma, T, EM_iters, pi, filenamesave);
