

lik <- function(x, SG, y) {
  theta = x
  
  
  Q  = max(SG$uo[1:SG$uoCOUNT,])
  CiS = list(matrix(1,1,1),Q*SG$d)
  lS = matrix(0, nrow = max(SG$uo[1:SG$uoCOUNT,]), ncol = SG$d)
  for (lcv2 in 1:SG$d) {
    for (lcv1 in 1:max(SG$uo[1:SG$uoCOUNT,lcv2])) {
      Xbrn = SG$xb[1:SG$sizest[lcv1]]
      Xbrn = Xbrn[order(Xbrn)]
      S = CorrMat(Xbrn, Xbrn , theta[lcv2])
      CiS[[(lcv2-1)*Q+lcv1]] = solve(S)
      lS[lcv1, lcv2] = sum(log(eigen(S)$values))
    }
  }
  
  
  if (max(x) >= (4 - 10 ^ (-6))) {
    return(Inf)
  } else{
    pw = rep(0, length(y))
    for (lcv1 in 1:SG$uoCOUNT) {
      narrowd = which(SG$uo[lcv1,] > 1.5)
      Ci = 1
      if (lcv1 == 1) {
        narrowd = 1
      } else{
        narrowd = which(SG$uo[lcv1,] > 1.5)
      }
      for (e in narrowd) {
        Ci = kronecker(Ci, CiS[[((e-1)*Q+SG$uo[lcv1,e])]])
      }
      pw[SG$dit[lcv1, 1:SG$gridsizet[lcv1]]] = pw[SG$dit[lcv1, 1:SG$gridsizet[lcv1]]] +
        SG$w[lcv1] * Ci %*% y[SG$dit[lcv1, 1:SG$gridsizet[lcv1]]]
    }
    sigma_hat = t(y) %*% pw / length(y)
    
    
    lDet = 0
    
    for (lcv1 in 1:SG$uoCOUNT) {
      for (lcv2 in 1:SG$d) {
        levelnow = SG$uo[lcv1, lcv2]
        if (levelnow > 1.5) {
          lDet = lDet + (lS[levelnow, lcv2] - lS[levelnow - 1, lcv2]) * (SG$gridsize[lcv1]) /
            (SG$gridsizes[lcv1, lcv2])
        }
      }
    }
    
    return(log(sigma_hat)+sum(theta^2)/length(y)) + 1 / length(y) * lDet 
  }
  
}
glik <- function(x, SG, y) {
  theta = x
  
  
  Q  = max(SG$uo[1:SG$uoCOUNT,])
  CiS = list(matrix(1,1,1),Q*SG$d)
  dCiS = list(matrix(1,1,1),Q*SG$d)
  lS = matrix(0, nrow = max(SG$uo[1:SG$uoCOUNT,]), ncol = SG$d)
  dlS = matrix(0, nrow = max(SG$uo[1:SG$uoCOUNT,]), ncol = SG$d)
  for (lcv2 in 1:SG$d) {
    for (lcv1 in 1:max(SG$uo[1:SG$uoCOUNT,lcv2])) {
      Xbrn = SG$xb[1:SG$sizest[lcv1]]
      Xbrn = Xbrn[order(Xbrn)]
      S = CorrMat(Xbrn, Xbrn , theta[lcv2])
      dS = dCorrMat(Xbrn, Xbrn , theta[lcv2])
      CiS[[(lcv2-1)*Q+lcv1]] = solve(S)
      dCiS[[(lcv2-1)*Q+lcv1]] = -CiS[[(lcv2-1)*Q+lcv1]]  %*% dS %*% CiS[[(lcv2-1)*Q+lcv1]] 
      lS[lcv1, lcv2] = sum(log(eigen(S)$values))
      dlS[lcv1, lcv2] = sum(eigen(CiS[[(lcv2-1)*Q+lcv1]] %*% dS)$values)
    }
  }
  
  pw = rep(0, length(y))
  
  dpw = matrix(0, nrow = length(y), ncol = SG$d)
  for (lcv1 in 1:SG$uoCOUNT) {
    if (lcv1 == 1) {
      narrowd = 1
    } else{
      narrowd = which(SG$uo[lcv1,] > 1.5)
    }
    Ci = 1
    for (e in narrowd) {
      Ci = kronecker(Ci, CiS[[((e-1)*Q+SG$uo[lcv1,e])]])
    }
    pw[SG$dit[lcv1, 1:SG$gridsizet[lcv1]]] = pw[SG$dit[lcv1, 1:SG$gridsizet[lcv1]]] +
      SG$w[lcv1] * Ci %*% y[SG$dit[lcv1, 1:SG$gridsizet[lcv1]]]
    
    for (e in narrowd) {
      Ci = 1
    for (e2 in narrowd) {
      if (e == e2) {
        Ci = kronecker(Ci,dCiS[[((e2-1)*Q+SG$uo[lcv1,e2])]])
      } else {
        Ci = kronecker(Ci, CiS[[((e2-1)*Q+SG$uo[lcv1,e2])]])
      }
    }
      
      dpw[SG$dit[lcv1, 1:SG$gridsizet[lcv1]], e] = dpw[SG$dit[lcv1, 1:SG$gridsizet[lcv1]], e] +
        SG$w[lcv1] * Ci %*% y[SG$dit[lcv1, 1:SG$gridsizet[lcv1]]]
    
    }
  }
  sigma_hat = t(y) %*% pw / length(y)
  
  
  
  dsigma_hat = t(y) %*% dpw / length(y)
  
  
  
  
  lDet = 0
  
  dlDet = rep(0, SG$d)
  
  for (lcv1 in 1:SG$uoCOUNT) {
    for (lcv2 in 1:SG$d) {
      levelnow = SG$uo[lcv1, lcv2]
      if (levelnow > 1.5) {
        lDet[lcv2] = lDet[lcv2] + (dlS[levelnow, lcv2] - dlS[levelnow - 1, lcv2]) * (SG$gridsize[lcv1]) /
          (SG$gridsizes[lcv1, lcv2])
      }
    }
  }
 ddL = dsigma_hat / sigma_hat[1] + 2 / length(y) *theta +  dlDet / length(y) 
  return(ddL)
  
}



thetaMLE <- function(SG, y,theta0 = rep(0,SG$d),tol=1e-1) {
  x2 = optim(
    theta0,
    fn = lik,
    gr = glik,
    y <- y - mean(y),
    SG = SG,
    method = "BFGS",
    hessian = FALSE,
    control = list(abstol = tol)
  )
  return(x2$par)
}