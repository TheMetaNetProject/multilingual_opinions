#include "mex.h"
#include "cokus.cpp"

// Adapted from code by Mark Steyvers
// NEW VARIABLES: c, m, L
// Syntax
//   [ WP , DP , Z_W, OP , Z_O ] = GibbsSamplerBOLDA_MultiMatch( WS , DS , T , N , ALPHA , BETA_W , L_O , MM , OS , ODS , NUMENTRIESVEC, BETA_O  , SEED , OUTPUT, ENTRYVEC, RELEGATE )

// Syntax
//   [ WP , DP , Z_W, OP , Z_O ] = GibbsSamplerBOLDA_MultiMatch( WS , DS , T , N , ALPHA , BETA_W , L_O , MM , OS , ODS , NUMENTRIESVEC, BETA_O , SEED , OUTPUT , ENTRYVEC, RELEGATE, Z_W_IN, Z_O_IN, ENTRYSERIES)

// l_O should be specified as 0 or 1
// OS is set up such that the vocab indices run from 1 to Voc_O1+Voc_O2 ? --i.e., unique indices across the two languages

// Updated for 64-bit compilers
//   GibbsSamplerLDA(        ALPHA,        BETA_W,        BETA_O,     Voc_W,     Voc_O1,     Voc_O2,     MaxMatches,     C,     T,     D,     NN,     OUTPUT,     n_W,     n_O,      z_W,      z_O,      d_W,      d_O,      w_W,      w_O,      wp,      dp,      op,      l_O,      entryVec,      numEntriesPerWord,      entrySeries,      ztot_W,      ztot_O1,      ztot_O2,      order_W,      order_O,         probs,     startcond, int relegate );
void GibbsSamplerBOLDA_MultiMatch( double ALPHA, double BETA_W, double BETA_O, int Voc_W, int Voc_O1, int Voc_O2, int MaxMatches, int C, int T, int D, int NN, int OUTPUT, int n_W, int n_O, int *z_W, int *z_O, int *d_W, int *d_O, int *w_W, int *w_O, int *wp, int *dp, int *op, int *l_O, int *entryVec, int *numEntriesPerWord, int *entrySeries, int *ztot_W, int *ztot_O1, int *ztot_O2, int *order_W, int *order_O, double *probs, int startcond, int relegate )
{
  int wi_W, ni_W, di_W, wi_O, di_O, li, g, h, i,ii,j,topic, entry, rp, temp, iter, wioffset, dioffset;
  double totprob, WBETA, r, max, WBETA_O1, WBETA_O2;
  mexPrintf("\tNewest Version 6:10 pm\n");
  mexPrintf("\tStartcondition = %d\n", startcond);
  if (startcond==1)
  { //START FROM INITIAL CONDITIONS
	  mexPrintf("\tStarting from Initial Conditions\n");
	  if (relegate==0) {
		  for (i=0; i<n_W; i++)
		  {
			  wi_W = w_W[ i ];
			  di_W = d_W[ i ];
			  topic = z_W[ i ];
			  entry = entrySeries[ i ];
			  dp[ di_W*T + topic ]++; // increment dp count matrix
			  ztot_W[ topic ]++; // increment ztot_W matrix
			  wp[ entry*T + topic ]++; // increment dp count matrix
		  }
	  } else {
		  for (i=0; i<n_W; i++)
		  {
			  wi_W = w_W[ i ];
			  di_W = d_W[ i ];
			  ni_W = numEntriesPerWord[ wi_W ];
			  topic = z_W[ i ];
			  entry = entrySeries[ i ];
			  if (ni_W>0) {
                           dp[ di_W*T + topic ]++; // increment dp count matrix
                           ztot_W[ topic ]++; // increment ztot_W matrix
                           wp[ entry*T + topic ]++; // increment dp count matrix
			  }
		  }
	  }
	  for (i=0; i<n_O; i++)
	  {
		  wi_O = w_O[ i ];
		  di_O = d_O[ i ];
		  li = l_O[ i ];
		  topic = z_O[ i ];
		  op[ wi_O*T + topic ]++;
		  if (li==1) 
		  {
			  ztot_O1[ topic ]++;
		  }
		  else {
			  ztot_O2[ topic ]++;
		  }
	  }
  }
//\/\/\/\***INITIALIZATION***/\/\/\/\\  
  if (startcond == 0)
  {
      if (OUTPUT==2) mexPrintf( "Starting Random initialization\n" );
      for (i=0; i<n_W; i++)
      {
          wi_W = w_W[ i ];
          di_W = d_W[ i ]; 
          ni_W = (int) numEntriesPerWord[ wi_W ];
         // pick a random entry 0...ni_W - 1
          if (ni_W>0) {
              entry = (int) ( (double) randomMT() * (double) ni_W / (double) (4294967296.0 + 1.0) );		  
              entry = entryVec[ MaxMatches*wi_W + entry];
              if (entry<0) mexErrMsgTxt("Getting negative entries somehow"); 
              entrySeries[ i ] = entry;
              // pick a random topic 0..T-1
              topic = (int) ( (double) randomMT() * (double) T / (double) (4294967296.0 + 1.0) );
              z_W[ i ] = topic; // assign this word token to this topic
          
              dp[ di_W*T + topic ]++; // increment dp count matrix
              ztot_W[ topic ]++; // increment ztot_W matrix
              wp[ entry*T + topic ]++; // increment wp count matrix
              }
	  }

	  for (i=0; i<n_O; i++)
      {
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
  WBETA = (double) (C*BETA_W);  //C is number of matchings (dictionary entries)
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
          ni_W = (int) numEntriesPerWord[ wi_W ];
          if (ni_W>0) {
              topic = z_W[i]; // current topic assignment to word token
              entry = entrySeries[ i ];
              ztot_W[topic]--;  // substract this from counts
              wioffset = entry*T;
              dioffset = di_W*T;
              wp[wioffset+topic]--; //decrement wp count matrix
              dp[dioffset+topic]--; //decrement dp count matrix
              totprob = (double) 0;
              g = 0;
              for (j = 0; j < T; j++) {  //For each topic, calculate the proportional probability
                  for (h = 0; h < ni_W; h++){			  
                      probs[g] = ((double) wp[ entryVec[MaxMatches*wi_W+h]*T + j ] + (double) BETA_W)/( (double) ztot_W[j]+ (double) WBETA)*( (double) dp[ dioffset+ j ] + (double) ALPHA);
                      totprob += probs[g];
                      g++;
                  }
              }
          // sample a topic and entry from the distribution
          r = (double) totprob * (double) randomMT() / (double) 4294967296.0;
          max = probs[0];
          g = 0;
          while (r>max) {
              g++;
              max += probs[g];
	   }
          entry = g % ni_W;
		  topic = (int) (g-entry)/ni_W;
		  entry = entryVec[ MaxMatches*wi_W + entry];
		  entrySeries[i] = entry; //assign current word token i to entry d_i
  	      z_W[i] = topic; // assign current word token i to topic j
          wp[entry*T + topic ]++; // and update counts
          dp[dioffset + topic ]++;
          ztot_W[topic]++;
          }
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
}


//+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_
//+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+MEX FUNCTION_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_
//+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_


void mexFunction(int nlhs, mxArray *plhs[], int nrhs,
                 const mxArray *prhs[])
{
  double *srwp, *srop, *srdp, *probs, *Z_W, *Z_O, *EntrySeries, *WS, *DS, *OS, *ODS, *L_O, *Z_W_IN, *Z_O_IN, *EntrySeries_IN, *ENTRYVEC, *NumEntriesPerWord; 
  double ALPHA,BETA_W,BETA_O;
  mwIndex *irwp, *irop, *jcwp, *jcop, *irdp, *jcdp;
  int *z_W, *z_O, *d_W, *d_O, *w_W, *w_O, *l_O, *order_W, *order_O, *wp, *op, *dp, *ztot_W, *ztot_O1, *ztot_O2, *entryVec, *numEntriesPerWord, *entrySeries;
  int MaxMatches, C, Voc_W, Voc_O1, Voc_O2,T,D,NN,SEED,OUTPUT, nzmax, nzmaxwp, nzmaxop, nzmaxdp, ntokens_W, ntokens_O, nentries_W;
  int i,j,c,n,n_W, n_O,nt,wi_W, wi_O, di_W, di_O, startcond, relegate, minEntry;
  
  /* Check for proper number of arguments. */
  if (nrhs < 14) {
    mexErrMsgTxt("At least 14 input arguments required");
  } else if (nlhs < 3) {
    mexErrMsgTxt("6 output arguments required");
  }
  
  startcond = 0;
  if (nrhs > 15) startcond = 1;
  
  /* process the input arguments */
  if (mxIsDouble( prhs[ 0 ] ) != 1) mexErrMsgTxt("WS input vector must be a double precision matrix");
  if (mxIsDouble( prhs[ 1 ] ) != 1) mexErrMsgTxt("DS input vector must be a double precision matrix");
  if (mxIsDouble( prhs[ 6 ] ) != 1) mexErrMsgTxt("OWS input vector must be a double precision matrix");
  if (mxIsDouble( prhs[ 7 ] ) != 1) mexErrMsgTxt("ODS input vector must be a double precision matrix");
  if (mxIsDouble( prhs[ 8 ] ) != 1) mexErrMsgTxt("L_O input vector must be a double precision matrix");
  
  // pointer to word indices
  WS = mxGetPr( prhs[ 0 ] ); //0 x_w, 
  //pointer to opinion indices
  OS = mxGetPr( prhs[ 7 ] ); //7 x_o,

  // get the number of topic-word tokens
  ntokens_W = (int) mxGetM( prhs[ 0 ] ) * mxGetN( prhs[ 0 ] );
  // get the number of opinion-word tokens
  ntokens_O = (int) mxGetM( prhs[ 7 ] ) * mxGetN( prhs[ 7 ] );
  // get the number of elements in the entry vector
  nentries_W = (int) mxGetM( prhs[ 13 ] ) * mxGetN( prhs[ 13 ] );


  // pointer to document indices
  DS = mxGetPr( prhs[ 1 ] ); //1 d_w, 
  //pointer to opinion-document indices
  ODS = mxGetPr( prhs[ 8 ] ); //8 d_o,
  
  // pointer to dictionary entry indices and total number of entries for each word
  NumEntriesPerWord = mxGetPr( prhs[ 9 ] ); //9 numentriesvector
 
  //pointer to language indices
  L_O = mxGetPr( prhs[ 6 ] );

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //if (M != mxGetM( prhs[ 13 ] ) * mxGetN( prhs[ 13 ] )) mexErrMsgTxt("Number of dictionary entries not the same in ENTRYVEC and ENTRYVEC");
  if (ntokens_W == 0) mexErrMsgTxt("WS vector is empty"); 
  if (ntokens_W != ( mxGetM( prhs[ 1 ] ) * mxGetN( prhs[ 1 ] ))) mexErrMsgTxt("WS and DS vectors should have same number of entries");
  
  if (ntokens_O == 0) mexErrMsgTxt("OS vector is empty"); 
  if (ntokens_O != ( mxGetM( prhs[ 8 ] ) * mxGetN( prhs[ 8 ] ))) mexErrMsgTxt("OS and ODS vectors should have same number of entries");


  T    = (int) mxGetScalar(prhs[ 2 ]); //2 T
  if (T<=0) mexErrMsgTxt("Number of topics must be greater than zero");
  
  NN    = (int) mxGetScalar(prhs[ 3 ]); //3 Gibbs_iters
  if (NN<0) mexErrMsgTxt("Number of iterations must be positive");
  
  ALPHA = (double) mxGetScalar(prhs[ 4 ]); //4 alpha
  if (ALPHA<=0) mexErrMsgTxt("ALPHA must be greater than zero");
  
  BETA_W = (double) mxGetScalar(prhs[ 5 ]); //5 beta_W
  if (BETA_W<=0) mexErrMsgTxt("BETA_W must be greater than zero");

  BETA_O = (double) mxGetScalar(prhs[ 10 ]); //10 beta_O
  if (BETA_O<=0) mexErrMsgTxt("BETA_O must be greater than zero");

  SEED = (int) mxGetScalar(prhs[ 11 ]); //11 seed
  
  OUTPUT = (int) mxGetScalar(prhs[ 12 ]); //12 OUTPUT

  ENTRYVEC = mxGetPr(prhs[ 13 ]); //13 entryvec

  relegate = (int) mxGetScalar(prhs[ 14 ]); //14 relegate
  
  if (startcond == 1) {
      Z_W_IN = mxGetPr( prhs[ 15 ] );
      if (ntokens_W != ( mxGetM( prhs[ 15 ] ) * mxGetN( prhs[ 15 ] ))) mexErrMsgTxt("WS and Z_W_IN vectors should have same number of entries");
      Z_O_IN = mxGetPr( prhs[ 15 ] );
      if (ntokens_O != ( mxGetM( prhs[ 16 ] ) * mxGetN( prhs[ 16 ] ))) mexErrMsgTxt("OS and Z_O_IN vectors should have same number of entries");
      EntrySeries_IN = mxGetPr( prhs[ 17 ] );
      if (ntokens_W != ( mxGetM( prhs[ 17 ] ) * mxGetN( prhs[ 17 ] ))) mexErrMsgTxt("WS and EntrySeries_IN vectors should have same number of entries");
  }
  
  // seeding
  seedMT( 1 + SEED * 2 ); // seeding only works on uneven numbers
  
   
  
/* allocate memory */
  z_W  = (int *) mxCalloc( ntokens_W , sizeof( int ));
  z_O = (int *) mxCalloc( ntokens_O, sizeof( int ));
  entrySeries = (int *) mxCalloc( ntokens_W, sizeof( int ));
  l_O = (int *) mxCalloc(ntokens_O, sizeof( int )); //6 l_o,

  if (startcond == 1) {
     for (i=0; i<ntokens_W; i++) z_W[ i ] = (int) Z_W_IN[ i ] - 1;
	 for (i=0; i<ntokens_O; i++) z_O[ i ] = (int) Z_O_IN[ i ] - 1;
	 for (i=0; i<ntokens_W; i++) entrySeries[ i ] = (int) EntrySeries_IN[ i ] - 1;
  }

  for (i=0; i<ntokens_O; i++) l_O[ i ] = (int) L_O[ i ];

  for (i=0; i<nentries_W; i++) entryVec[ i ] = (int) ENTRYVEC[ i ] - 1;

  d_W  = (int *) mxCalloc( ntokens_W , sizeof( int ));  
  w_W  = (int *) mxCalloc( ntokens_W , sizeof( int ));
  d_O  = (int *) mxCalloc( ntokens_O , sizeof( int ));
  w_O  = (int *) mxCalloc( ntokens_O , sizeof( int ));
  order_W  = (int *) mxCalloc( ntokens_W , sizeof( int )); 
  order_O = (int *) mxCalloc( ntokens_O, sizeof( int ));
  ztot_W  = (int *) mxCalloc( T , sizeof( int ));
  ztot_O1 = (int *) mxCalloc( T, sizeof( int ));
  ztot_O2 = (int *) mxCalloc( T, sizeof( int ));

  
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
  C = 0;
  for (i=0; i<n_W; i++) {
     if (w_W[ i ] > Voc_W) Voc_W = w_W[ i ];
     if (d_W[ i ] > D) D = d_W[ i ];
  }
 for (i=0; i<n_O; i++) {
     if (d_O[ i ] > D) D = d_O[ i ];
  } 

 for (i=0; i<nentries_W; i++) {
     if ( entryVec[ i ]; > C) C = entryVec[ i ];  //get the total number of dictionary entries
  } 
 mexPrintf("\tC=%d\n", C);

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
  C = C + 1;
  wp  = (int *) mxCalloc( T*C , sizeof( int ));
  dp  = (int *) mxCalloc( T*D , sizeof( int ));
  op = (int *) mxCalloc( T*(Voc_O1 + Voc_O2), sizeof( int ));

  numEntriesPerWord = (int *) mxCalloc(Voc_W, sizeof( int ));
  for (i=0; i<Voc_W; i++) numEntriesPerWord[ i ] = (int) NumEntriesPerWord[ i ];
  MaxMatches = 0;
  for (i=0; i<Voc_W; i++) {
            if (numEntriesPerWord[ i ] > MaxMatches) MaxMatches = numEntriesPerWord[ i ]; 
  }
  probs  = (double *) mxCalloc( T*MaxMatches , sizeof( double ));
  //mexPrintf("\tMaxMatches=%d\n", MaxMatches);
  //mexPrintf( "N=%d_W  T=%d_W Voc_W=%d_W D=%d_W\n" , ntokens_W , T , Voc_W , D );
  
  if (OUTPUT==2) {
      mexPrintf( "Running BOLDA-J Gibbs Sampler Version 1.0\n" );
      if (startcond==1) mexPrintf( "Starting from previous state Z_W_IN\n" );
      mexPrintf( "Arguments:\n" );
      mexPrintf( "\tNumber of words      Voc_W = %d\n"    , Voc_W );
      mexPrintf( "\tNumber of docs       D = %d\n"    , D );
      mexPrintf( "\tNumber of topics     T = %d\n"    , T );
      mexPrintf( "\tNumber of iterations N = %d\n"    , NN );
      mexPrintf( "\tHyperparameter       ALPHA = %4.4f\n" , ALPHA );
      mexPrintf( "\tHyperparameter       BETA_W = %4.4f\n" , BETA_W );
      mexPrintf( "\tHyperparameter       BETA_O = %4.4f\n" , BETA_O );
      mexPrintf( "\tSeed number                 = %d\n"    , SEED );
      mexPrintf( "\tNumber of content tokens= %d\n"    , ntokens_W );
      mexPrintf( "\tNumber of opinion tokens = %d\n"    , ntokens_O );
      mexPrintf( "Internal Memory Allocation\n" );
      mexPrintf( "\tw,d_W,z_W,order_W indices combined = %d_W bytes\n" , 4 * sizeof( int) * ntokens_W );
      mexPrintf( "\tw,d_O,z_O,order_O indices combined = %d_O bytes\n" , 4 * sizeof( int) * ntokens_O );
      mexPrintf( "\twp (full) matrix - topicwords = %d_W bytes\n" , sizeof( int ) * Voc_W * T  );
      mexPrintf( "\twp (full) matrix -opinionwords = %d_O bytes\n" , sizeof( int ) * (Voc_O1 + Voc_O2) * T  );
      mexPrintf( "\tdp (full) matrix = %d_W bytes\n" , sizeof( int ) * D * T  );
      //mexPrintf( "Checking: sizeof(int)=%d_W sizeof(long)=%d_W sizeof(double)=%d_W\n" , sizeof(int) , sizeof(long) , sizeof(double));
  }
  
  /* run the model */
  GibbsSamplerBOLDA_MultiMatch( ALPHA, BETA_W, BETA_O, Voc_W, Voc_O1, Voc_O2, MaxMatches, C, T, D, NN, OUTPUT, n_W, n_O, z_W, z_O, d_W, d_O, w_W, w_O, wp, dp, op, l_O, entryVec, numEntriesPerWord, entrySeries, ztot_W, ztot_O1, ztot_O2, order_W, order_O, probs, startcond, relegate );
  
  /* convert the full wp matrix into a sparse matrix */
  nzmaxwp = 0;
  for (i=0; i<C; i++) {
     for (j=0; j<T; j++) nzmaxwp += (int) ( *( wp + j + i*T )) > 0;
  }  
  if (OUTPUT==2) {
      mexPrintf( "Constructing sparse output matrix wp\n" );
      mexPrintf( "Number of nonzero entries for WP = %d\n" , nzmaxwp );
  }
  
  // MAKE THE WP SPARSE MATRIX
  plhs[0] = mxCreateSparse( C,T,nzmaxwp,mxREAL);
  srwp  = mxGetPr(plhs[0]);
  irwp = mxGetIr(plhs[0]);
  jcwp = mxGetJc(plhs[0]);  
  n = 0;
  for (j=0; j<T; j++) {
      *( jcwp + j ) = n;
      for (i=0; i<C; i++) {
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

  /* convert the full wp matrix into a sparse matrix */
  nzmaxop = 0;
  for (i=0; i<(Voc_O1 + Voc_O2); i++) {
     for (j=0; j<T; j++) nzmaxop += (int) ( *( op + j + i*T )) > 0;
  }  
  /*if (OUTPUT==2) {
      mexPrintf( "Constructing sparse output matrix wp\n" );
      mexPrintf( "Number of nonzero entries for WP = %d_W\n" , nzmaxwp );
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

  plhs[ 5 ] = mxCreateDoubleMatrix( 1,ntokens_W , mxREAL );
  EntrySeries = mxGetPr( plhs[ 5 ] );
  for (i=0; i<ntokens_W; i++) EntrySeries[ i ] = (double) entrySeries[ i ] + 1;
}


