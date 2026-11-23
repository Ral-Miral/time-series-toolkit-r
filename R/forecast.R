prediction = function(y, p, m, h){
  # Takes as input:
  # y = vector containing your data
  # p = periodicity of y
  # m = model followed (A for additive, M for multiplicative)
  # h = desired forecast horizon
  # Returns a list containing the forecast vectors of the different models as well as their MSEs
  
  y = ts(y, frequency=p)
  
  simple = ets(y, model=paste0(m, "NN"), opt.crit="mse")
  double = ets(y, model=paste0(m, "AN"), opt.crit="mse", damped=F)
  holt = ets(y, model=paste0(m, "AN"), opt.crit="mse", damped=T)
  winters = ets(y, model=paste0(m, "AA"), opt.crit="mse")
  
  yalpha_simple = forecast(simple, h=h)
  yalpha_double = forecast(double, h=h)
  yalpha_holt = forecast(holt, h=h)
  yalpha_winters = forecast(winters, h=h)
  
  mse_simple = mean((y - fitted(simple))^2)
  mse_double = mean((y - fitted(double))^2)
  mse_holt = mean((y - fitted(holt))^2)
  mse_winters = mean((y - fitted(winters))^2)
  
  return(list(yalpha_simple=yalpha_simple$mean,
              yalpha_double=yalpha_double$mean,
              yalpha_holt=yalpha_holt$mean,
              yalpha_winters=yalpha_winters$mean,
              mse_simple=mse_simple,
              mse_double=mse_double,
              mse_holt=mse_holt,
              mse_winters=mse_winters))
}