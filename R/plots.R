time_plot = function(y, ylab, xlab){
  # Takes as input: 
  # y    = vector containing your data
  # ylab = label of the y-axis
  # xlab = label of the x-axis
  # Returns a chronological plot of y
  
  n = length(y) 
  plot(y, 
       xlab=xlab, 
       ylab=ylab, 
       main=paste("Time plot of", ylab, "in", xlab), 
       cex=0, 
       xaxt="n")
  axis(1, at=1:n)
  lines(c(1:n), y)
}

seasonal_plot = function(y, p, ylab, xlab, legend){
  # Takes as input:
  # y      = vector containing your data
  # ylab   = label of the y-axis
  # xlab   = label of the x-axis
  # legend = vector containing: the name of the legend items (cycle, year, ...) and the starting number
  # p      = periodicity
  # Returns a seasonal plot of y
  
  par(mar=c(5, 4, 4, 7))
  n = length(y)
  plot(y, 
       xlab=xlab, 
       ylab=ylab, 
       main=paste("Seasonal plot of", ylab, "in", xlab), 
       xlim=c(1, p), 
       cex=0, 
       xaxt="n")
  axis(1, at=1:p)
  
  col=rainbow(n/p)
  for(i in 0:(n/p - 1)){
    lines(c(1:p), 
          (y[(1 + p*i) : (p + p*i)]), 
          col=col[i+1])
  }
  legend(p, max(y),
         legend=paste(legend[1], 
                      legend[2]:(as.numeric(legend[2]) + n/p - 1)), 
         col=col, 
         lty=1, 
         xpd=TRUE)
}

full_plot = function(y, p, m, ylab, xlab){
  # Takes as input:
  # y    = vector containing your data
  # p    = periodicity of y
  # m    = model followed (A for additive, M for multiplicative)
  # ylab = label of the y-axis
  # xlab = label of the x-axis
  # Returns a complete plot of y with its raw, smoothed and SA series
  
  time_plot(y, ylab, xlab) 
  lines(moving_average(y, p), col="firebrick")
  lines(compute_sa(y, seasonal_coefficients(y, p, m), m), col="royalblue")
  legend("topright",
         legend=c("Raw", "Smoothed", "SA"),
         col=c("black", "firebrick", "royalblue"),
         lty=1, 
         bty="n", 
         cex=0.8,
         inset=0.01)
}