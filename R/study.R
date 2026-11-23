time_series_study = function(y, p, m, ylab, xlab){
  # Takes as input:
  # y    = vector containing your data
  # p    = periodicity of y
  # m    = model followed (A for additive, M for multiplicative)
  # ylab = label of the y-axis
  # xlab = label of the x-axis
  # Returns the useful quantities (plots, trend, seasonal effects, residuals, ...)
  
  MM = moving_average(y, p)
  Shat = seasonal_coefficients(y, p, m)
  yCVS = compute_sa(y, Shat, m)
  t = 1:length(y)
  modele = lm(yCVS ~ t)
  yhat = modele$fitted.values
  e = yCVS - yhat
  
  full_plot(y, p, m, ylab, xlab)
  acf(e, main=paste("Correlogram of the residuals of", ylab))
  
  return(list(MM=MM,
              Shat=Shat,
              yCVS=yCVS,
              modele=modele,
              e=e))
}