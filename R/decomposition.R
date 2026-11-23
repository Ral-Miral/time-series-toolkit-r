moving_average = function(y, p){
  # Takes as input:
  # y = vector containing your data
  # p = periodicity
  # Returns a vector containing the moving averages of y
  
  T = length(y)
  MM = rep(NA, T)
  
  if (p %% 2 == 0) {
    k = p / 2
    
    for (t in (k+1):(T - k)) {
      MM[t] = (y[t-k]/2 + y[t+k]/2 + sum(y[(t-k+1) : (t+k-1)])) / p
    }
  } else {
    k = (p-1) / 2
    
    for (t in ((k+1):(T - k))) {
      MM[t] = sum(y[(t-k) : (t+k)]) / p
    }
  }
  return(MM)
}

seasonal_coefficients = function(y, p, m){
  # Takes as input:
  # y = vector containing your data
  # p = periodicity
  # m = model followed (A for additive, M for multiplicative)
  # Returns a vector containing the seasonal coefficients of y
  
  fnp = moving_average(y, p)
  
  if (m == "A") {
    delta = y - fnp
  } 
  else if (m == "M") {
    delta = y / fnp
  }
  else{
    cat("Please enter A for additive or M for multiplicative")
  }
  
  
  M = matrix(data=delta, 
             nrow=length(delta) / p, 
             ncol=p, 
             byrow=T)
  
  Sprime = apply(M, 2, median, na.rm=T)
  
  Shat = Sprime - mean(Sprime)
  return(Shat)
}

compute_sa = function(y, S, m){
  # Takes as input:
  # y = vector containing your data
  # S = vector containing your seasonal coefficients
  # m = model followed (A for additive, M for multiplicative)
  # Returns a vector containing the seasonally adjusted (SA) series of y
  
  if (m == "A") {
    yCVS = y - S
  } 
  else if (m == "M") {
    yCVS = y / (1 + S)
  }
  else{
    cat("Please enter A for additive or M for multiplicative")
  }
  return(yCVS)
}