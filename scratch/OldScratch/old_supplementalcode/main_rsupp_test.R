rm(list = ls())
library(SGGP)

source("../R/SGGP_fastcalcassist_fs.R")
source("supp_speedup_fit.R")
borehole <- function(x) {
  rw <- x[, 1] * (0.15 - 0.05) + 0.05
  r <-  x[, 2] * (50000 - 100) + 100
  Tu <- x[, 3] * (115600 - 63070) + 63070
  Hu <- x[, 4] * (1110 - 990) + 990
  Tl <- x[, 5] * (116 - 63.1) + 63.1
  Hl <- x[, 6] * (820 - 700) + 700
  L <-  x[, 7] * (1680 - 1120) + 1120
  Kw <- x[, 8] * (12045 - 9855) + 9855
  
  m1 <- 2 * pi * Tu * (Hu - Hl)
  m2 <- log(r / rw)
  m3 <- 1 + 2 * L * Tu / (m2 * rw ^ 2 * Kw) + Tu / Tl
  
  Yn = m1 / m2 / m3
 # return(abs(cbind(Yn,Yn^0.75,Yn^0.5,Yn^1.1)))
  return(Yn)
}


d = 8
testf<-function (x) {  return(borehole(x))} 

Npred <- 1000
library("lhs")
Xp = randomLHS(Npred, d)
Yp = testf(Xp)

Xs = randomLHS(100, d)
Ys = testf(Xs)
# 
# SGGP = SGGPcreate(d,200) #create the design.  it has so many entries because i am sloppy
# Y = testf(SGGP$design) #the design is $design, simple enough, right?
# SGGP1 = SGGP#create the design.  it has so many entries because i am sloppy
# Y1 = testf(SGGP1$design) #the design is $design, simple enough, right?
# SGGP = SGGPfit(SGGP,Y)
# SGGP = SGGPappend(SGGP,200) #create the design.  it has so many entries because i am sloppy
# Y = testf(SGGP$design) #the design is $design, simple enough, right?
# SGGP = SGGPfit(SGGP,Y)
# SGGP = SGGPappend(SGGP,200) #create the design.  it has so many entries because i am sloppy
# Y = testf(SGGP$design) #the design is $design, simple enough, right?
# SGGP = SGGPfit(SGGP,Y)
# SGGP = SGGPappend(SGGP,200) #create the design.  it has so many entries because i am sloppy
# Y = testf(SGGP$design) #the design is $design, simple enough, right?
# SGGP = SGGPfit(SGGP,Y)
# Pred = SGGPpred(SGGP,Xp)
# mean(abs(Yp-Pred$mean)^2)  #prediction should be much better
# mean(abs(Yp-Pred$mean)^2/Pred$var+log(Pred$var)) #score should be much better
library(tictoc)
SGGP = SGGPcreate(d,1000) #create the design.  it has so many entries because i am sloppy
Y = testf(SGGP$design) #the design is $design, simple enough, right?
#SGGPGreedy = SGGPfit(SGGP,Y,Xs=Xs,Ys=Ys)
#PredGreedy = SGGPpred(SGGPGreedy,Xp)
mean(abs(Yp-PredGreedy$mean)^2)  #prediction should be much better
mean(abs(Yp-PredGreedy$mean)^2/PredGreedy$var+log(PredGreedy$var)) #score should be much better

#SGGPGreedy = SGGPfit(SGGP,Y,Xs=Xs,Ys=Ys)
source("supp_speedup_returnthings.R")
source("supp_speedup_neglogpost.R")
source("supp_speedup_gneglogpost.R")
source("supp_speedup_postvarcalc.R")
source("supp_speedup_fit.R")
SGGPGreedy = SGGPfit(SGGP,Y,Xs=Xs,Ys=Ys)

