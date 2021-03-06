MSE_calc <- function(xl, theta) {
  S = CorrMat(xl, xl, theta)
  t = exp(theta)
  n = length(xl)
  Ci = solve(S)
  
  
  A = matrix(rep(xl, each = n), nrow = n)
  a = pmin(A, t(A))
  b = pmax(A, t(A))
  
  t2 = 1.0 / t
  
  t3 = a + b - 2.0
  
  t4 = t2 * t3
  
  t5 = exp(t4)
  
  t6 = a - b
  
  t7 = t2 * t6
  
  t8 = exp(t7)
  
  t9 = t ^ 2
  
  t10 = a * t2 * 2.0
  
  t11 = exp(t10)
  
  t12 = a * b * 2.0
  
  out1 = t5 * (-3.0 / 2.0) + a * t5 * (3.0 / 4.0) - a * t8 * (3.0 / 4.0) +
    b * t5 * (3.0 / 4.0) + b * t8 * (3.0 / 4.0) - t * t5 * (5.0 / 4.0) - t2 *
    t5 * (1.0 / 2.0) + t * t8 * (5.0 / 4.0) + a * t2 * t5 * (1.0 / 2.0) + b *
    t2 * t5 * (1.0 / 2.0) - t2 * exp(-t2 * (a + b)) * (t9 * 5.0 + t12 + a *
                                                         t * 3.0 + b * t * 3.0 - t9 * t11 * 5.0 + a * t * t11 * 3.0 - b * t * t11 *
                                                         3.0) * (1.0 / 4.0) - a * b * t2 * t5 * (1.0 / 2.0) - 1.0 / t ^ 2 * t6 *
    t8 * (t9 * 6.0 - t12 - a * t * 6.0 + b * t * 6.0 + a ^ 2 + b ^ 2) * (1.0 /
                                                                           6.0)
  
  out1
  MSE = 1 - sum(diag(out1 %*% Ci))
}


MSE_de <- function(valsinds, MSE_v) {
  if(is.matrix(valsinds)){
    MSE_de = rep(0, dim(valsinds)[1])
    
    for (lcv1 in 1:dim(valsinds)[1]) {
      MSE_de[lcv1] = 0
      
      for (lcv2 in 1:dim(valsinds)[2]) {
        if (valsinds[lcv1, lcv2] > 1.5) {
          MSE_de[lcv1] = MSE_de[lcv1] + log(-MSE_v[lcv2, valsinds[lcv1, lcv2]] + MSE_v[lcv2, valsinds[lcv1, lcv2] - 1])
          
        } else {
          MSE_de[lcv1] = MSE_de[lcv1] + log(-MSE_v[lcv2, valsinds[lcv1, lcv2]] + 1)
          
        }
      }
    }
  } else {
    MSE_de = 0
    
    for (lcv2 in 1:length(valsinds)) {
      if (valsinds[lcv2] > 1.5) {
        MSE_de = MSE_de + log(-MSE_v[lcv2, valsinds[lcv2]] + MSE_v[lcv2, valsinds[lcv2] -1])
        
      } else {
        MSE_de = MSE_de + log(-MSE_v[lcv2, valsinds[lcv2]] + 1)
        
      }
    }}
  MSE_de = exp(MSE_de)
  
}


# 

SGappend <- function(SG,batchsize,theta){
  
  MSE_v = matrix(0, SG$d, 8)
  for (lcv1 in 1:SG$d) {
    for (lcv2 in 1:8) {
      MSE_v[lcv1, lcv2] = max(10 ^ (-7), abs(MSE_calc(SG$xb[1:SG$sizest[lcv2]], theta[lcv1])))
      if (lcv2 > 1.5) {
        MSE_v[lcv1, lcv2] = min(MSE_v[lcv1, lcv2], MSE_v[lcv1, lcv2 - 1])
      }
    }
  }
  
  I_mes = rep(0, SG$ML)
  
  I_mes[1:SG$poCOUNT] = MSE_de(SG$po[1:SG$poCOUNT, ], MSE_v)
  
  SG$bss = SG$bss + batchsize
  
  while (SG$bss > (SG$ss + min(SG$pogsize[1:SG$poCOUNT]) - 0.5)) {
    SG$uoCOUNT = SG$uoCOUNT + 1 #increment used count
    M_comp = max(I_mes[which(SG$pogsize[1:SG$poCOUNT] < (SG$bss - SG$ss + 0.5))])
    possibleO =which((I_mes[1:SG$poCOUNT] >= 0.5*M_comp)&(SG$pogsize[1:SG$poCOUNT] < (SG$bss - SG$ss + 0.5)))
    if(length(possibleO)>1.5){
      pstar = sample(possibleO,1)
    } else{
      pstar = possibleO
    }
    
    l0 =  SG$po[pstar,]
    SG$uo[SG$uoCOUNT,] = l0
    SG$ss =  SG$ss + SG$pogsize[pstar]
    
    new_an = SG$pila[pstar, 1:SG$pilaCOUNT[pstar]]
    total_an = new_an
    for (lcv2 in 1:length(total_an)) {
      if (total_an[lcv2] > 1.5) {
        total_an = unique(c(total_an, SG$uala[total_an[lcv2], 1:SG$ualaCOUNT[total_an[lcv2]]]))
      }
    }
    SG$ualaCOUNT[SG$uoCOUNT]  = length(total_an)
    SG$uala[SG$uoCOUNT, 1:length(total_an)] = total_an
    
    for (lcv2 in 1:length(total_an)) {
      lo = SG$uo[total_an[lcv2],]
      if (max(abs(lo - l0)) < 1.5) {
        SG$w[total_an[lcv2]] = SG$w[total_an[lcv2]] + (-1) ^ abs(round(sum(l0 -
                                                                             lo)))
        
      }
    }
    SG$w[SG$uoCOUNT] = SG$w[SG$uoCOUNT] + 1
    
    
    if (pstar < 1.5) {
      SG$po[1:(SG$poCOUNT - 1),] = SG$po[2:SG$poCOUNT,]
      SG$pila[1:(SG$poCOUNT - 1),] = SG$pila[2:SG$poCOUNT,]
      SG$pilaCOUNT[1:(SG$poCOUNT - 1)] = SG$pilaCOUNT[2:SG$poCOUNT]
      SG$pogsize[1:(SG$poCOUNT - 1)] = SG$pogsize[2:SG$poCOUNT]
      I_mes[1:(SG$poCOUNT - 1)] = I_mes[2:SG$poCOUNT]
    }
    if (pstar > (SG$poCOUNT - 0.5)) {
      SG$po[1:(SG$poCOUNT - 1),] = SG$po[1:(pstar - 1),]
      SG$pila[1:(SG$poCOUNT - 1),] = SG$pila[1:(pstar - 1),]
      SG$pilaCOUNT[1:(SG$poCOUNT - 1)] = SG$pilaCOUNT[1:(pstar - 1)]
      SG$pogsize[1:(SG$poCOUNT - 1)] = SG$pogsize[1:(pstar - 1)]
      I_mes[1:(SG$poCOUNT - 1)] = I_mes[1:(pstar - 1)]
    }
    if (pstar < (SG$poCOUNT - 0.5) && pstar > 1.5) {
      SG$po[1:(SG$poCOUNT - 1),] = SG$po[c(1:(pstar - 1), (pstar + 1):SG$poCOUNT),]
      SG$pila[1:(SG$poCOUNT - 1),] = SG$pila[c(1:(pstar - 1), (pstar +1):SG$poCOUNT),]
      SG$pilaCOUNT[1:(SG$poCOUNT - 1)] = SG$pilaCOUNT[c(1:(pstar - 1), (pstar + 1):SG$poCOUNT)]
      SG$pogsize[1:(SG$poCOUNT - 1)] = SG$pogsize[c(1:(pstar - 1), (pstar + 1):SG$poCOUNT)]
      I_mes[1:(SG$poCOUNT - 1)] = I_mes[c(1:(pstar - 1), (pstar + 1):SG$poCOUNT)]
    }
    SG$poCOUNT = SG$poCOUNT - 1
    
    for (lcv2 in 1:SG$d) {
      lp = l0
      
      lp[lcv2] = lp[lcv2] + 1
      
      if (max(lp) < 7.5 && SG$poCOUNT < 4 * SG$ML) {
        kvals = which(lp > 1.5)
        
        canuse = 1
        ap = rep(0, SG$d)
        nap = 0
        for (lcv3 in 1:length(kvals)) {
          lpp = lp
          lpp[kvals[lcv3]] = lpp[kvals[lcv3]] - 1
          
          ismem = rep(1, SG$uoCOUNT)
          for (lcv4 in 1:SG$d) {
            ismem  = ismem * (SG$uo[1:SG$uoCOUNT, lcv4] == lpp[lcv4])
          }
          
          if (max(ismem) > 0.5) {
            ap[lcv3] = which(ismem > 0.5)
            nap = nap + 1
          } else{
            canuse = 0
          }
        }
        if (canuse > 0.5) {
          SG$poCOUNT = SG$poCOUNT + 1
          SG$po[SG$poCOUNT,] = lp
          SG$pogsize[SG$poCOUNT] = prod(SG$sizes[lp])
          SG$pila[SG$poCOUNT, 1:nap] = ap[1:nap]
          SG$pilaCOUNT[SG$poCOUNT] = nap
          I_mes[SG$poCOUNT] =  MSE_de(as.vector(SG$po[SG$poCOUNT, ]), MSE_v)
        }
      }
    }
  }
  
  SG$gridsizes = matrix(SG$sizes[SG$uo[1:SG$uoCOUNT, ]], SG$uoCOUNT, SG$d)
  SG$gridsizest = matrix(SG$sizest[SG$uo[1:SG$uoCOUNT, ]], SG$uoCOUNT, SG$d)
  SG$gridsize = apply(SG$gridsizes, 1, prod)
  SG$gridsizet = apply(SG$gridsizest, 1, prod)
  
  SG$di = matrix(0, nrow = SG$uoCOUNT, ncol = max(SG$gridsize))
  SG$dit = matrix(0, nrow = SG$uoCOUNT, ncol = sum((SG$gridsize)))
  
  SG$design = matrix(0, nrow = sum(SG$gridsize), ncol = SG$d)
  tv = 0
  for (lcv1 in 1:SG$uoCOUNT) {
    SG$di[lcv1, 1:SG$gridsize[lcv1]] = (tv + 1):(tv + SG$gridsize[lcv1])
    for (lcv2 in 1:SG$d) {
      levelnow = SG$uo[lcv1, lcv2]
      if (levelnow < 1.5) {
        SG$design[(tv + 1):(tv + SG$gridsize[lcv1]), lcv2] = rep(SG$xb[1], SG$gridsize[lcv1])
      } else{
        x0 = SG$xb[(SG$sizest[levelnow - 1] + 1):SG$sizest[levelnow]]
        if (lcv2 < 1.5) {
          SG$design[(tv + 1):(tv + SG$gridsize[lcv1]), lcv2] = rep(x0, "each" = SG$gridsize[lcv1] /
                                                                     SG$gridsizes[lcv1, lcv2])
        }
        if (lcv2 > (SG$d - 0.5)) {
          SG$design[(tv + 1):(tv + SG$gridsize[lcv1]), lcv2] = rep(x0, SG$gridsize[lcv1] /
                                                                     SG$gridsizes[lcv1, lcv2])
        }
        if (lcv2 < (SG$d - 0.5)  && lcv2 > 1.5) {
          SG$design[(tv + 1):(tv + SG$gridsize[lcv1]), lcv2] = rep(rep(x0, "each" =
                                                                         prod(SG$gridsizes[lcv1, (lcv2 + 1):SG$d])), prod(SG$gridsizes[lcv1, 1:(lcv2 -
                                                                                                                                                  1)]))
        }
      }
    }
    
    tvv = 0
    if (lcv1 > 1.5) {
      for (ances in SG$uala[lcv1, 1:SG$ualaCOUNT[lcv1]]) {
        SG$dit[lcv1, (tvv + 1):(tvv + SG$gridsize[ances])] = SG$di[ances, 1:SG$gridsize[ances]]
        tvv = tvv + SG$gridsize[ances]
      }
      SG$dit[lcv1, (tvv + 1):(tvv + SG$gridsize[lcv1])] = SG$di[lcv1, 1:SG$gridsize[lcv1]]
      Xset = SG$design[SG$dit[lcv1, 1:SG$gridsizet[lcv1]], ]
      reorder = do.call(order, lapply(1:NCOL(Xset), function(kvt)
        Xset[, kvt]))
      SG$dit[lcv1, 1:SG$gridsizet[lcv1]] = SG$dit[lcv1, reorder]
    } else{
      SG$dit[lcv1, 1:SG$gridsize[lcv1]] = SG$di[lcv1, 1:SG$gridsize[lcv1]]
    }
    
    tv = tv + SG$gridsize[lcv1]
  }
  
  return(SG)
}
