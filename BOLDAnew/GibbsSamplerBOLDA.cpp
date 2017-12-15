#include "mex.h"
#include "cokus.cpp"

// NEW VARIABLES: MM, L_O, OS
// Syntax
//   [ WP , DP , Z_W, OP , Z_O ] = GibbsSamplerBOLDA( WS , DS , T , N , ALPHA , BETA_W , L_O , MM , OS , ODS , BETA_O , SEED , OUTPUT, RELEGATE )

// Syntax
//   [ WP , DP , Z_W, OP , Z_O ] = GibbsSamplerBOLDA( WS , DS , T , N , ALPHA , BETA_W , L_O , MM , OS , ODS  , BETA_O , SEED , OUTPUT , RELEGATE, Z_W_IN, Z_O_IN )

// l_O should be specified as 0 or 1
// OS is set up such that the vocab indices run from 1 to Voc_O1+Voc_O2 ? --i.e., unique indices across the two languages

// Updated for 64-bit compilers
// GibbsSamplerLDA(          ALPHA,        BETA_W,        BETA_O,     Voc_W,     Voc_O1,     Voc_O2,     M,     T,     D,     NN,     OUTPUT,     n_W,     n_O,      z_W,      z_O,      d_W,      d_O,      w_W,      w_O,         mm,      wp,      dp,      op,       l_O,     ztot_W,      ztot_W_matched,      ztot_O1,      ztot_O2,      order_W,      order_O,         probs,      startcond,     relegate );
void GibbsSamplerLDA( double ALPHA, double BETA_W, double BETA_O, int Voc_W, int Voc_O1, int Voc_O2, int M, int T, int D, int NN, int OUTPUT, int n_W, int n_O, int *z_W, int *z_O, int *d_W, int *d_O, int *w_W, int *w_O, double *mm, int *wp, int *dp, int *op, int *l_O, int *ztot_W, int *ztot_W_matched, int *ztot_O1, int *ztot_O2, int *order_W, int *order_O, double *probs,  int startcond, int relegate)
{
  int ci, wi_W, wi2_W, di_W, wi_O, di_O, li, i,ii,j,topic, rp, temp, iter, wioffset, wioffset2, dioffset;
  double totprob, WBETA, r, max, WBETA_O1, WBETA_O2;
  mexPrintf("\tNewest Version 12:55 pm\n");
  mexPrintf("\tStartcondition = %d\n", startcond);
  mexPrintf("\tRelegate = %d\n", relegate);
  if (startcond==1) 
  { //START FROM INITIAL CONDITIONS
 mexPrintf("\tStarting from Initial Conditions\n");
	  for (i=0; i<n_W; i++) {
             wi_W = w_W[ i ];
             di_W = d_W[ i ];
             ci = (int) mm[wi_W];
             topic = z_W[ i ];
             dp[ di_W*T + topic ]++; // increment dp count matrix
             ztot_W[ topic ]++; // increment ztot_W matrix
             if (ci>-1 || relegate==0) {
                 wp[ wi_W*T + topic ]++; // increment dp count matrix
                 ztot_W_matched[ topic ]++;
             }
	  }
mexPrintf("\tFinished n_W; starting n_O\n");
	  for (i=0; i<n_O; i++) {
		  wi_O = w_O[ i ];
		  di_O = d_O[ i ];
		  li = l_O[ i ];
		  topic = z_O[ i ];
		  op[ wi_O*T + topic ]++;
		  if (li==1) 
		  {
			  ztot_O1[ topic ]++;
		  }  else {
			  ztot_O2[ topic ]++;
		  }
	  }
  }
//\/\/\/\***INITIALIZATION***/\/\/\/\\  
  if (startcond == 0)
  {
      if (OUTPUT==2) mexPrintf( "Starting Random initialization\n" );
      for (i=0; i<n_W; i++) {
          wi_W = w_W[ i ];
          di_W = d_W[ i ];
          ci = (int) mm[wi_W];
          // pick a random topic 0..T-1
          topic = (int) ( (double) randomMT() * (double) T / (double) (4294967296.0 + 1.0) );
          z_W[ i ] = topic; // assign this word token to this topic
          
          dp[ di_W*T + topic ]++; // increment dp count matrix
          ztot_W[ topic ]++; // increment ztot_W matrix
          if (ci>-1 || relegate==0) {
              wp[ wi_W*T + topic ]++; // increment wp count matrix
              ztot_W_matched[topic]++;
          }

	}

       for (i=0; i<n_O; i++) {
           wi_O = w_O[ i ];
           di_O = d_O[ i ];
           li = l_O[ i ];
           // pick a random topic 0..T-1
           topic = (int) ( (double) randomMT() * (double) T / (double) (4294967296.0 + 1.0) );
           z_O[ i ] = topic; // assign this word token to this topic
           op[ wi_O*T + topic ]++; // increment op count matrix
           if (li==1) {
               ztot_O1[ topic ]++; // increment ztot_O1 matrix
           } else {
               ztot_O2[ topic ]++; // increment ztot_O2 matrix
           }
       }
  }
 
  if (OUTPUT==2) mexPrintf( "Determining random order_W update sequence\n" );
  

//\/\/\/\***PERMUTATION***/\/\/\/
  for (i=0; i<n_W; i++) order_W[i]=i; // fill with increasing series
  for (i=0; i<(n_W-1); i++) {
      // pick a random integer between i and nw
      rp = i + (int) ((double) (n_W-i) * (double) randomMT() / (double) (4294967296.0 + 1.0));
      
      // switch contents on position i and position rp
      temp = order_W[rp];
      order_W[rp]=order_W[i];
      order_W[i]=temp;
  }

  if (OUTPUT==2) mexPrintf( "Determining random order_O update sequence\n" );
  
  for (i=0; i<n_O; i++) order_O[i]=i; // fill with increasing series
  for (i=0; i<(n_O-1); i++) {
      // pick a random integer between i and nw
      rp = i + (int) ((double) (n_O-i) * (double) randomMT() / (double) (4294967296.0 + 1.0));
      
      // switch contents on position i and position rp
      temp = order_O[rp];
      order_O[rp]=order_O[i];
      order_O[i]=temp;
  }


//\/\/\/\***SAMPLE***/\/\/\/\\  
  //for (i=0; i<n; i++) mexPrintf( "i=%3d order_W[i]=%3d\n" , i , order_W[ i ] );
  if (relegate==1) {
      WBETA = (double) M*BETA_W;  //M is number of matchings
  } else {
      WBETA = (double) (Voc_W - M)*BETA_W;
  }
  WBETA_O1 = (double) Voc_O1*BETA_O;
  WBETA_O2 = (double) Voc_O2*BETA_O;
  for (iter=0; iter<NN; iter++) { //NN is total number of iterations
      if (OUTPUT >=1) {
          if ((iter % 10)==0) mexPrintf( "\tIteration %d_W of %d_W\n" , iter , NN );
          if ((iter % 10)==0) mexEvalString("drawnow;");
      }
      for (ii = 0; ii < n_W; ii++) {
          i = order_W[ ii ]; // current word token to assess
          wi_W  = w_W[i]; // current word index
          di_W  = d_W[i]; // current document index  
          ci = (int) mm[wi_W]; //word index of word in other language matched to the current word
          topic = z_W[i]; // current topic assignment to word token
          ztot_W[topic]--;  // substract this from counts
          wioffset = wi_W*T;
          dioffset = di_W*T;
          if (ci>-1 || relegate==0) {
              ztot_W_matched[topic]--;
              wp[wioffset+topic]--; //decrement wp count matrix
          }
          dp[dioffset+topic]--; //decrement dp count matrix
          //mexPrintf( "(1) Working on ii=%d_W i=%d_W wi_W=%d_W di_W=%d_W topic=%d_W wp=%d_W dp=%d_W\n" , ii , i , wi_W , di_W , topic , wp[wi_W+topic*Voc_W] , dp[wi_W+topic*D] );
          
          totprob = (double) 0;
           if (ci > -1) {
               wi2_W = ci; // ****** GETS WORD INDEX FOR MATCHED WORD ***** \\//
               wioffset2 = wi2_W*T; // ****** IBID. *****\\//
               for (j = 0; j < T; j++) {  //For each topic, calculate the proportional probability
                  probs[j] = ((double) wp[ wioffset+j ] + (double) wp[wioffset2+j] + (double) BETA_W)/( (double) ztot_W_matched[j]+ (double) WBETA)*( (double) dp[ dioffset+ j ] + (double) ALPHA);
                  totprob += probs[j];
               }
           } else {
               if (relegate==0) {
                  for (j = 0; j < T; j++) {  //For each topic, calculate the proportional probability
                      probs[j] = ((double) wp[ wioffset+j ] + (double) BETA_W)/( (double) ztot_W_matched[j] + (double) WBETA)*( (double) dp[ dioffset+ j ] + (double) ALPHA);
                      totprob += probs[j];
                   }
               } else {
                   for (j = 0; j < T; j++) {  //For each topic, calculate the proportional probability
                       probs[j] = ( (double) dp[ dioffset+ j ] + (double) ALPHA);
                       totprob += probs[j];
                   }
               }
           }

          // sample a topic from the distribution
          r = (double) totprob * (double) randomMT() / (double) 4294967296.0;
          max = probs[0];
          topic = 0;
          while (r>max) {
               topic++;
               max += probs[topic];
           }

           z_W[i] = topic; // assign current word token i to topic j
           if (ci>-1 || relegate==0) {
               ztot_W_matched[topic]++;
               wp[wioffset + topic ]++; // and update counts
           }
           dp[dioffset + topic ]++;
           ztot_W[topic]++;
       }
          
          //mexPrintf( "(2) Working on ii=%d_W i=%d_W wi_W=%d_W di_W=%d_W topic=%d_W wp=%d_W dp=%d_W\n" , ii , i , wi_W , di_W , topic , wp[wi_W+topic*Voc_W] , dp[wi_W+topic*D] );
		  
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~OPINION SAMPLING~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if ((iter % 10 ) == 0) mexPrintf("\tStarting Opinion Sampling; total steps are %d \n", n_O);
	  for (ii = 0; ii<n_O; ii++)
	  {
		  i = order_O[ ii ]; // current word token to assess
		  wi_O  = w_O[i]; // current word index
		  di_O  = d_O[i]; // current document index  
		  li = l_O[i]; //*** STATES LANGUAGE OF THE WORD TOKEN ****
          topic = z_O[i]; // current topic assignment to word token
		  if (li==1) {
			  ztot_O1[topic]--;  // substract this from counts
		  } else {
			  ztot_O2[topic]--;  // substract this from counts
		  }
          wioffset = wi_O*T;
	   dioffset = di_O*T;
          op[wioffset+topic]--; //decrement wp count matrix
          //mexPrintf( "(1) Working on ii=%d_O i=%d_O wi_O=%d_O di_O=%d_O topic=%d_O op=%d_O dp=%d_O\n" , ii , i , wi_O , di_O , topic , op[wi_O+topic*Voc_O]  );
          totprob = (double) 0;
		  if (li==1) 
		  {
			 for (j = 0; j < T; j++) {  //For each topic, calculate the proportional probability
                  probs[j] = ((double) op[ wioffset+j ] + (double) BETA_O)/( (double) ztot_O1[j] + (double) WBETA_O1)*( (double) dp[ dioffset+ j ] );
                  totprob += probs[j];
              }
			  // sample a topic from the distribution
              r = (double) totprob * (double) randomMT() / (double) 4294967296.0;
			  max = probs[0];
              topic = 0;
			  while (r>max) {
                  topic++;
                  max += probs[topic];
			  }
      	      z_O[i] = topic; // assign current word token i to topic j
			  op[wioffset + topic ]++; // and update counts
			  ztot_O1[topic]++;          
		  } else {
 //mexPrintf("\t wioffset = %d, dioffset = %d, di_W = %d, D= %d \n", wioffset, dioffset, di_W, D);
              for (j = 0; j < T; j++) {  //For each topic, calculate the proportional probability
				  probs[j] = ((double) op[ wioffset+j ] + (double) BETA_O)/( (double) ztot_O2[j] + (double) WBETA_O2)*( (double) dp[ dioffset+ j ] ); 
				  totprob += probs[j];
			  }
			  // sample a topic from the distribution
              r = (double) totprob * (double) randomMT() / (double) 4294967296.0;
              max = probs[0];
              topic = 0;
              while (r>max) {
                  topic++;
                  max += probs[topic];
			  }
      	      z_O[i] = topic; // assign current word token i to topic j
              op[wioffset + topic ]++; // and update counts
              ztot_O2[topic]++;
		  }
          //mexPrintf( "(2) Working on ii=%d_W i=%d_W wi_W=%d_W di_W=%d_W topic=%d_W wp=%d_W dp=%d_W\n" , ii , i , wi_W , di_W , topic , wp[wi_W+topic*Voc_W] , dp[wi_W+topic*D] );
	  }
  }
  mexPrintf( "Done with sampling. Creating output."); 
}

//+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_
//+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+MEX FUNCTION_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_
//+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_

void mexFunction(int nlhs, mxArray *plhs[], int nrhs,
                 const mxArray *prhs[])
{
  double *srwp, *srop, *srdp, *probs, *Z_W, *Z_O, *WS, *DS, *OS, *ODS, *L_O, *Z_W_IN, *Z_O_IN, *mm;
  double ALPHA,BETA_W,BETA_O;
  mwIndex *irwp, *irop, *jcwp, *jcop, *irdp, *jcdp;
  int *z_W, *z_O, *d_W, *d_O, *w_W, *w_O, *l_O, *order_W, *order_O, *wp, *op, *dp, *ztot_W, *ztot_W_matched, *ztot_O1, *ztot_O2;
  int M, Voc_W, Voc_O1, Voc_O2,T,D,NN,SEED,OUTPUT, RELEGATE, startcond, nzmax, nzmaxwp, nzmaxop, nzmaxdp, ntokens_W, ntokens_O;
  int i,j,c,n,n_W, n_O,nt,wi_W, wi_O, di_W, di_O;
  
  /* Check for proper number of arguments. */
  if (nrhs < 14) {
    mexErrMsgTxt("At least 14 input arguments required");
  } else if (nlhs < 3) {
    mexErrMsgTxt("3 output arguments required");
  }
  
  startcond = 0;
  if (nrhs == 16) startcond = 1;
  
  /* process the input arguments */
  if (mxIsDouble( prhs[ 0 ] ) != 1) mexErrMsgTxt("WS input vector must be a double precision matrix");
  if (mxIsDouble( prhs[ 1 ] ) != 1) mexErrMsgTxt("DS input vector must be a double precision matrix");
  
  // pointer to word indices
  WS = mxGetPr( prhs[ 0 ] );
  //pointer to opinion indices
  OS = mxGetPr( prhs[ 8 ] );

  // pointer to document indices
  DS = mxGetPr( prhs[ 1 ] );
  //pointer to opinion-document indices
  ODS = mxGetPr( prhs[ 9 ] );
  
  // get the number of tokens
  ntokens_W = mxGetM( prhs[ 0 ] ) * mxGetN( prhs[ 0 ] );
  // get the number of opinion tokens
  ntokens_O = mxGetM( prhs[ 8 ] ) * mxGetN( prhs[ 8 ] );

  //*************************************************************************************************************************************
  
  //pointer to matching indices
  mm = mxGetPr( prhs[ 7 ] );
//get the number of matchings
  M = 0;
  for (i=0; i<mxGetM(prhs[ 7 ]) * mxGetN( prhs[ 7] ); i++) {
	  if (mm[ i]>-1) {
		  M = M + 1;
	  }
  }
  M = (int) M/2;
  
  //pointer to matching or lack thereof
  //pointer to language indices
  L_O = mxGetPr( prhs[ 6 ] );
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (ntokens_W == 0) mexErrMsgTxt("WS vector is empty"); 
  if (ntokens_W != ( mxGetM( prhs[ 1 ] ) * mxGetN( prhs[ 1 ] ))) mexErrMsgTxt("WS and DS vectors should have same number of entries");
  
  if (ntokens_O == 0) mexErrMsgTxt("OS vector is empty"); 
  if (ntokens_O != ( mxGetM( prhs[ 9 ] ) * mxGetN( prhs[ 9 ] ))) mexErrMsgTxt("OS and ODS vectors should have same number of entries");

  T    = (int) mxGetScalar(prhs[2]);
  if (T<=0) mexErrMsgTxt("Number of topics must be greater than zero");
  
  NN    = (int) mxGetScalar(prhs[3]);
  if (NN<0) mexErrMsgTxt("Number of iterations must be positive");
  
  ALPHA = (double) mxGetScalar(prhs[4]);
  if (ALPHA<=0) mexErrMsgTxt("ALPHA must be greater than zero");
  
  BETA_W = (double) mxGetScalar(prhs[5]);
  if (BETA_W<=0) mexErrMsgTxt("BETA_W must be greater than zero");

  BETA_O = (double) mxGetScalar(prhs[10]);
  if (BETA_O<=0) mexErrMsgTxt("BETA_O must be greater than zero");

  SEED = (int) mxGetScalar(prhs[11]);
  
  OUTPUT = (int) mxGetScalar(prhs[12]);
  
  RELEGATE = (int) mxGetScalar(prhs[13]);

  if (startcond == 1) {
      Z_W_IN = mxGetPr( prhs[14] );
      if (ntokens_W != ( mxGetM( prhs[14] ) * mxGetN( prhs[14] ))) mexErrMsgTxt("WS and Z_W_IN vectors should have same number of entries");
	  Z_O_IN = mxGetPr( prhs[15] );
	  if (ntokens_O != ( mxGetM( prhs[15] ) * mxGetN( prhs[15] ))) mexErrMsgTxt("OS and Z_O_IN vectors should have same number of entries");
  }
  
  // seeding
  seedMT( 1 + SEED * 2 ); // seeding only works on uneven numbers
  
   
  
/* allocate memory */
  z_W  = (int *) mxCalloc( ntokens_W , sizeof( int ));
  z_O = (int *) mxCalloc( ntokens_O, sizeof( int ));
  l_O = (int *) mxCalloc(ntokens_O, sizeof( int ));

  if (startcond == 1) {
     for (i=0; i<ntokens_W; i++) z_W[ i ] = (int) Z_W_IN[ i ] - 1;
	 for (i=0; i<ntokens_O; i++) z_O[ i ] = (int) Z_O_IN[ i ] - 1;
  }

  for (i=0; i<ntokens_O; i++) l_O[ i ] = (int) L_O[ i ];

  d_W  = (int *) mxCalloc( ntokens_W , sizeof( int ));  
  w_W  = (int *) mxCalloc( ntokens_W , sizeof( int ));
  d_O  = (int *) mxCalloc( ntokens_O , sizeof( int ));
  w_O  = (int *) mxCalloc( ntokens_O , sizeof( int ));
  order_W  = (int *) mxCalloc( ntokens_W , sizeof( int )); 
  order_O = (int *) mxCalloc( ntokens_O, sizeof( int ));
  ztot_W  = (int *) mxCalloc( T , sizeof( int ));
  ztot_W_matched  = (int *) mxCalloc( T , sizeof( int ));
  ztot_O1 = (int *) mxCalloc( T, sizeof( int ));
  ztot_O2 = (int *) mxCalloc( T, sizeof( int ));
  probs  = (double *) mxCalloc( T , sizeof( double ));
  
  // copy over the word and document indices into internal format
  for (i=0; i<ntokens_W; i++) {
     w_W[ i ] = (int) WS[ i ] - 1;
     d_W[ i ] = (int) DS[ i ] - 1;
  }
  for (i=0; i<ntokens_O; i++) {
 	 w_O[ i ] = (int) OS[ i ] - 1;
	 d_O[ i ] = (int) ODS[ i ] - 1;
  }
  
  n_W = ntokens_W;
  n_O = ntokens_O;
  Voc_W = 0;
  Voc_O1 = 0;
  Voc_O2 = 0;
  D = 0;
  for (i=0; i<n_W; i++) {
     if (w_W[ i ] > Voc_W) Voc_W = w_W[ i ];
     if (d_W[ i ] > D) D = d_W[ i ];
  }
 for (i=0; i<n_O; i++) {
     if (d_O[ i ] > D) D = d_O[ i ];
  } 
 for (i=0; i<n_O; i++) {
	  if (l_O[ i ] == 1) {
		  if (w_O[ i ] > Voc_O1) Voc_O1 = w_O[ i ];
	  }
	  else {
		  if (w_O[ i ] > Voc_O2) Voc_O2 = w_O[ i ];
	  }
  }

  Voc_W = Voc_W + 1;
  Voc_O1 = Voc_O1 + 1;
  Voc_O2 = Voc_O2 + 1 - Voc_O1;
  D = D + 1;
  
  wp  = (int *) mxCalloc( T*Voc_W , sizeof( int ));
  dp  = (int *) mxCalloc( T*D , sizeof( int ));
  op = (int *) mxCalloc( T*(Voc_O1 + Voc_O2), sizeof( int ));
   
  //mexPrintf( "N=%d  T=%d Voc_W=%d D=%d\n" , ntokens_W , T , Voc_W , D );
  
  if (OUTPUT==2) {
      mexPrintf( "Running LDA Gibbs Sampler Version 1.0\n" );
      if (startcond==1) mexPrintf( "Starting from previous state Z_W_IN\n" );
      mexPrintf( "Arguments:\n" );
      mexPrintf( "\tNumber of topic words      Voc_W = %d\n"    , Voc_W );
      mexPrintf( "\tNumber of opinion words    Voc_W = %d\n"    , Voc_W );
      mexPrintf( "\tNumber of docs             D = %d\n"    , D );
      mexPrintf( "\tNumber of topics           T = %d\n"    , T );
      mexPrintf( "\tNumber of iterations       N = %d\n"    , NN );
      mexPrintf( "\tHyperparameter             ALPHA = %4.4f\n" , ALPHA );
      mexPrintf( "\tHyperparameter             BETA_W = %4.4f\n" , BETA_W );
      mexPrintf( "\tHyperparameter             BETA_O = %4.4f\n" , BETA_O );
      mexPrintf( "\tSeed number                = %d\n"    , SEED );
      mexPrintf( "\tNumber of topic tokens     = %d\n"    , ntokens_W );
      mexPrintf( "\tNumber of opinion tokens   = %d\n"    , ntokens_O );
      mexPrintf( "Internal Memory Allocation\n" );
      mexPrintf( "\td_W,z_W,order_W indices combined = %d bytes\n" , 4 * sizeof( int) * ntokens_W );
      mexPrintf( "\td_O,z_O,order_O indices combined = %d bytes\n" , 4 * sizeof( int) * ntokens_O );
      mexPrintf( "\twp (full) matrix = %d bytes\n" , sizeof( int ) * Voc_W * T  );
      mexPrintf( "\top (full) matrix = %d bytes\n" , sizeof( int ) * (Voc_O1 + Voc_O2) * T  );
      mexPrintf( "\tdp (full) matrix = %d bytes\n" , sizeof( int ) * D * T  );
      //mexPrintf( "Checking: sizeof(int)=%d sizeof(long)=%d sizeof(double)=%d\n" , sizeof(int) , sizeof(long) , sizeof(double));
  }
  
  /* run the model */
  GibbsSamplerLDA( ALPHA, BETA_W, BETA_O, Voc_W, Voc_O1, Voc_O2, M, T, D, NN, OUTPUT, n_W, n_O, z_W, z_O, d_W, d_O, w_W, w_O, mm, wp, dp, op, l_O, ztot_W, ztot_W_matched, ztot_O1, ztot_O2, order_W, order_O, probs, startcond, RELEGATE);
  
  /* convert the full wp matrix into a sparse matrix */
  nzmaxwp = 0;
  for (i=0; i<Voc_W; i++) {
     for (j=0; j<T; j++) nzmaxwp += (int) ( *( wp + j + i*T )) > 0;
  }  
  if (OUTPUT==2) {
      mexPrintf( "Constructing sparse output matrix wp\n" );
      mexPrintf( "Number of nonzero entries for WP = %d\n" , nzmaxwp );
  }
  
  // MAKE THE WP SPARSE MATRIX
  plhs[0] = mxCreateSparse( Voc_W,T,nzmaxwp,mxREAL);
  srwp  = mxGetPr(plhs[0]);
  irwp = mxGetIr(plhs[0]);
  jcwp = mxGetJc(plhs[0]);  
  n = 0;
  for (j=0; j<T; j++) {
      *( jcwp + j ) = n;
      for (i=0; i<Voc_W; i++) {
         c = (int) *( wp + i*T + j );
         if (c >0) {
             *( srwp + n ) = c;
             *( irwp + n ) = i;
             n++;
         }
      }    
  }  
  *( jcwp + T ) = n;    
   
  // MAKE THE DP SPARSE MATRIX
  nzmaxdp = 0;
  for (i=0; i<D; i++) {
      for (j=0; j<T; j++) nzmaxdp += (int) ( *( dp + j + i*T )) > 0;
  }  
  if (OUTPUT==2) {
      mexPrintf( "Constructing sparse output matrix dp\n" );
      mexPrintf( "Number of nonzero entries for DP = %d\n" , nzmaxdp );
  } 
  plhs[1] = mxCreateSparse( D,T,nzmaxdp,mxREAL);
  srdp  = mxGetPr(plhs[1]);
  irdp = mxGetIr(plhs[1]);
  jcdp = mxGetJc(plhs[1]);
  n = 0;
  for (j=0; j<T; j++) {
      *( jcdp + j ) = n;
      for (i=0; i<D; i++) {
          c = (int) *( dp + i*T + j );
          if (c >0) {
              *( srdp + n ) = c;
              *( irdp + n ) = i;
              n++;
          }
      }
  }
  *( jcdp + T ) = n;
  
  plhs[ 2 ] = mxCreateDoubleMatrix( 1,ntokens_W , mxREAL );
  Z_W = mxGetPr( plhs[ 2 ] );
  for (i=0; i<ntokens_W; i++) Z_W[ i ] = (double) z_W[ i ] + 1;

  /* convert the full op matrix into a sparse matrix */
  nzmaxop = 0;
  for (i=0; i<(Voc_O1 + Voc_O2); i++) {
     for (j=0; j<T; j++) nzmaxop += (int) ( *( op + j + i*T )) > 0;
  }  
  /*if (OUTPUT==2) {
      mexPrintf( "Constructing sparse output matrix op\n" );
      mexPrintf( "Number of nonzero entries for OP = %d\n" , nzmaxop );
  }*/
  
  // MAKE THE OP SPARSE MATRIX
  plhs[3] = mxCreateSparse( (Voc_O1 + Voc_O2) ,T,nzmaxop,mxREAL);
  srop  = mxGetPr(plhs[3]);
  irop = mxGetIr(plhs[3]);
  jcop = mxGetJc(plhs[3]);  
  n = 0;
  for (j=0; j<T; j++) {
      *( jcop + j ) = n;
      for (i=0; i<(Voc_O1+Voc_O2); i++) {
         c = (int) *( op + i*T + j );
         if (c >0) {
             *( srop + n ) = c;
             *( irop + n ) = i;
             n++;
         }
      }    
  }  
  *( jcop + T ) = n;    
   

  plhs[ 4 ] = mxCreateDoubleMatrix( 1,ntokens_O , mxREAL );
  Z_O = mxGetPr( plhs[ 4 ] );
  for (i=0; i<ntokens_O; i++) Z_O[ i ] = (double) z_O[ i ] + 1;
}
