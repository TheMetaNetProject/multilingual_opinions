import scipy
import scipy.io
import sklearn.metrics
import sklearn.cluster
import sys

def cluster(simmatrix,n_clusters,savefile):
 print n_clusters
 n_iters = 50
 opt_score = -1e4
 for i in range(n_iters):
  print('iter '+str(i)+'\n')
  labels0 = sklearn.cluster.spectral_clustering(simmatrix, n_clusters)
  score0 = sklearn.metrics.silhouette_score(simmatrix,labels0,'precomputed')
  if score0>opt_score:
   opt_labels = labels0
   opt_score = score0
   scipy.io.savemat(savefile,{'labels':opt_labels, 'score':opt_score})
 return(opt_labels, opt_score)

n_clusters = int(sys.argv[1])
A = scipy.io.loadmat('/u/metanet/clustering/may-2014-relations/data/F-sims.txt.mat')
a= A['simmatrix']
cluster(a, n_clusters, '/u/metanet/clustering/may-2014-relations/data/test'+str(n_clusters)+'.mat')