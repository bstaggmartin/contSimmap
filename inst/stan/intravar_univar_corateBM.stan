functions {
  //get tip means given rates, root trait value, tree info, and 'seed' for trait change along each edge
  vector get_X (int n, real X0, vector prune_T, vector R, vector raw_X,
                int[] preorder, int[] real_e, int[,] des_e, int[] tip_e){
    vector[2 * n - 1] XX; //node-wise trait values, indexed by ancestral edge
    vector[2 * n - 1] SS; //trait change along each edge
    XX[1] = X0;
    SS = rep_vector(0, 2 * n - 1);
    SS[real_e] = sqrt(prune_T[real_e] .* exp(R)) .* raw_X;
    for(i in preorder){
      XX[des_e[i, ]] = XX[i] + SS[des_e[i, ]];
    }
    return(XX[tip_e]);
  }
}
data {
  //basic data
  int obs; //number of observations
  int n; //number of tips
  int e; //number of edges
  vector[obs] Y; //observed trait values
  int X_id[obs]; //indicates to which tip each observation belongs
  matrix[e, e] eV; //edge variance-covariance matrix
  
  
  //data for pruning algorithm: note tree is coerced to be bifurcating and 1st edge is zero-length stem
  vector[2 * n - 1] prune_T; //edge lengths
  int des_e[2 * n - 1, 2]; //edge descendants (-1 for no descendants)
  int tip_e[n]; //edges with no descendants
  int real_e[e]; //non-zero length edges
  
  
  //prior specification: see below for parameter definitions
  real Ysig2_prior;
  real R0_prior;
  real Rsig2_prior;
  real X0_prior;
  real Rmu_prior;
  
  
  //parameter constraints
	int constr_Rsig2;
	int constr_Rmu;
}

transformed data {
  matrix[e, e] chol_eV; //cholesky decomp of edge variance-covariance matrix
  vector[e] T_midpts; //overall 'height' of edge mid-points
  int preorder[n - 1]; //'cladewise' sequence of nodes excluding tips, numbered by ancestral edge
  
  
  //for sampling from R prior
  chol_eV = cholesky_decompose(eV);
  T_midpts = diagonal(eV) + prune_T[real_e] / 6;
  
  
  //for sampling from X prior
  {int counter;
  counter = 0;
  for(i in 1:(2 * n - 1)){
    if(des_e[i, 1] == -1){
      continue;
    }
    counter = counter + 1;
    preorder[counter] = i;
  }}
}

parameters {
  //parameters on sampling scale: see below for parameter definitions
  real<lower=-pi()/2, upper=pi()/2> unif_R0;
  real<lower=-pi()/2, upper=pi()/2> unif_X0;
  real<lower=0, upper=pi()/2> unif_Rsig2[constr_Rsig2 ? 0:1];
  real<lower=-pi()/2, upper=pi()/2> unif_Rmu[constr_Rmu ? 0:1];
  real<lower=0, upper=pi()/2> unif_Ysig2;
  vector[constr_Rsig2 ? 0:e] raw_R;
  vector[e] raw_X;
}

transformed parameters {
  real R0; //(ln)rate at root
  real X0; //trait value at root of tree
  real<lower=0> Rsig2[constr_Rsig2 ? 0:1]; //rate of (ln)rate variance accumulation
  real Rmu[constr_Rmu ? 0:1]; //trend in (ln)rate
  real<lower=0> Ysig2; //tip variance
  vector[e] R; //edge-wise average (ln)rates
  vector[n] X; //tip means
  vector[obs] cent_Y; //centered data
  
  
  //high level priors
  R0 = R0_prior * tan(unif_R0); //R0 prior: cauchy(0, R0_prior)
  X0 = X0_prior * tan(unif_X0); //X0 prior: cauchy(0, X0_prior)
	if(!constr_Rsig2){
	  Rsig2[1] = Rsig2_prior * tan(unif_Rsig2[1]); //Rsig2 prior: half-cauchy(0, Rsig2_prior)
	}
	if(!constr_Rmu){
	  Rmu[1] = Rmu_prior * tan(unif_Rmu[1]); //Rmu prior: cauchy(0, Rmu_prior)
	}
	Ysig2 = Ysig2_prior * tan(unif_Ysig2); //Ysig2 prior: half-cauchy(0, Ysig2_prior)
  
  
  //R prior: multinormal(R0 + Rmu * T_midpts, Rsig2 * eV); Rsig2/Rmu = 0 when constrained
  R = rep_vector(R0, e);
  if(!constr_Rmu){
    R = R + Rmu[1] * T_midpts;
  }
  if(!constr_Rsig2){
    R = R + sqrt(Rsig2[1]) * chol_eV * raw_R;
  }
  
  
  //X prior: multinormal(X0, tree topology with branch lengths multiplied by R)
  X = get_X(n, X0, prune_T, R, raw_X, preorder, real_e, des_e, tip_e);
  
  
  //center observations based on X
  cent_Y = Y - X[X_id];
}

model {
  //'seed' for sampling from R prior: see above
	if(!constr_Rsig2){
	  raw_R ~ std_normal();
	}
	
	
	//'seed' for sampling from X prior: see above
	raw_X ~ std_normal();
  
  
  //likelihood of Y
  cent_Y ~ normal(0, sqrt(Ysig2));
}