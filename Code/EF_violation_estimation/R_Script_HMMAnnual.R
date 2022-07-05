# Code for running Hidden Markov Model
# install.packages("depmixS4")
# install.packages("HiddenMarkov")
# install.packages("WriteXLS")
# install.packages("writexl")
# install.packages("lubridate")
# install.packages("R.matlab")
# install.packages("raster")
# install.packages("tidyverse")
# install.packages("ggpubr")

rm(list = ls())

library(R.matlab)
library(raster)
library(tidyverse)
library(dplyr)
library(ggplot2)
library(ggpubr)
library(depmixS4) # hmm library
library(WriteXLS)
library(writexl)
library(lubridate)

# settig WD
setwd("D:/Academic Backups/PostDoc-Usask/PB_files/Analysis/Data_paper_revision/Upper_Lower/HMM")
EFE_full <- readMat("EFE_state_annual_50.mat")
EFE<-EFE_full[["EFE.median.annual"]]
basin<-EFE_full[["basin.hist"]]
basin<-basin[,1]
EFE_viol=EFE_full[["EFE.vioYear.median"]]

# creating date range
startDate<-as.Date("1976/01/01")
YearMonth<-seq(startDate, by="year", length.out = 30)


# 
# # assigning lower boundary violation as 1 and no violation/upper violation as 0
# EFE_viol=ifelse(EFE<0, 1, 0)

#initialization
violation_stay_prob <- NULL
violation_shift_prob <- NULL
violation_shift_prob1 <- NULL
noviolation_shift_prob<-NULL
noviolation_shift_prob1<-NULL
# viol_to_viol <- NULL
# viol_to_noviol <- NULL
# noviol_to_viol <- NULL
basin_sele<-NULL
rowidx<-NULL

# loop for sites
for (row in 1:nrow(EFE)){
  
  
  # extracting EFE values for one site
  # EFE_run <- EFE_h08_viol[row,]
  data1<-data.frame("EFE_state"=EFE_viol[row,],"Date"=YearMonth,"EFE_vio"= EFE[row,])
  
  data1$diff<-c(diff(data1$EFE_state),NA)
  
  # probability of staying in lower bound violation 
  # (if there is a violation in t-1 time step)
  
  p_stay_violate<- length(which(data1$diff==0 & data1$EFE_state==1))/
    length(which(data1$EFE_state==1))
  
  # # new formula
  # p_stay_violate<- length(which(data1$diff==0 & data1$EFE_state==1))/
  #   (nrow(EFE_viol)-1)
  # 
  
  #changing NAN to 0
  p_stay_violate[is.nan(p_stay_violate)] <- 0
  
  
  violation_stay_prob <- rbind(violation_stay_prob, p_stay_violate)
  
  # probability of switching to a low flow state from no violation state
  p_shift_vio<- length(which(data1$diff==1 & data1$EFE_state==0))/
    length(which(data1$EFE_state==0))
  
  # p_shift_vio<- length(which(data1$diff==1 & data1$EFE_state==0))/
  #   (nrow(EFE_viol)-1)
  # 
  p_shift_vio=ifelse(p_stay_violate>0.95, -1, p_shift_vio)
  p_shift_vio[is.nan(p_shift_vio)] <- 0
  
  violation_shift_prob <- rbind(violation_shift_prob, p_shift_vio)
  
  # probability to switch from a violated state to a non violated state
  # out of all non violated 
  
  p_shift_novio<- length(which(data1$diff==-1 & data1$EFE_state==1))/
    length(which(data1$EFE_state==0))
  
  # probability to switch from a violated state to a non violated state
  # out of all shift
  p_shift_novio1<- length(which(data1$diff==-1 & data1$EFE_state==1))/
    (29-length(which(data1$diff==0)))
  p_shift_novio1=ifelse(p_stay_violate==0, -1, p_shift_novio1)
  p_shift_novio1[is.nan(p_shift_novio1)] <- 0
  
  p_shift_novio=ifelse(p_stay_violate==0, -1, p_shift_novio)
  p_shift_novio[is.nan(p_shift_novio)] <- 0
  
  noviolation_shift_prob <- rbind(noviolation_shift_prob, p_shift_novio)
  # noviolation_shift_prob1 <- rbind(noviolation_shift_prob1, p_shift_novio1)
  # plt=ggplot(data1,aes(YearMonth,EFE_state)) + geom_line()
  # plt
  
  # <OPEN forrunning HMM>
  # hmm
  mod<-depmix(EFE_state ~1,
              nstates = 2,
              transition = ~1,
              family = binomial(),
              data=data1)

  # iterations for random start values
  best <-1.0e10
  best_model=NA

  # loop for n number of iterations
  iter<-25 # number of iterations <change as per need>
  for(i in 1:iter){
    # fitting
    fitmod<-fit(mod)
    # # summary(fitmod)

    # check for best solution
    if(AIC(fitmod)< best){
      best_model<- fitmod
      best<- AIC(fitmod)
    }

  }


  # # most probable state
  # prstates<- apply(posterior(fitmod)[,c("S1","S2")],1,which.max)
  # plot(prstates,type="b")

  # transition prob
  # s1 is violated state and s2 is non violated state

#   s1_to_s1<-best_model@trDens[1]
#   s2_to_s1<-best_model@trDens[3]
#   s1_to_s2<-best_model@trDens[2]
# 
# viol_to_viol[row] <- s1_to_s1
# noviol_to_viol[row] <- s2_to_s1
# viol_to_noviol[row] <- s1_to_s2
# 
#   viol_to_viol <- rbind(viol_to_viol, s1_to_s1)
#   noviol_to_viol <- rbind(noviol_to_viol, s2_to_s1)
  # viol_to_noviol <- rbind(viol_to_noviol, s1_to_s2)

  x<-basin[row]
  basin_sele<-rbind(basin_sele, x)
  
  rowidx<-rbind(rowidx, row)
  
  
  a<-"RUN COMPLETE FOR SITE "
  b <- print(paste(a,row))
  
  #  output_final<-data.frame("row"=rowidx,"basin_id"=basin_sele,"noVio_to_Vio"=noviol_to_viol,"Vio_to_noVio"=viol_to_noviol,
  #                           "Vio_to_Vio"= viol_to_viol,"viol_stay_prob"=violation__stay_prob)
  #  
  # write_xlsx(output_final,"C:\\Dropbox\\PB_files\\Analysis\\Data_MattisGroup\\EFE data\\HMM_RStudio\\Output_final_annual.xlsx")
  
  output_final<-data.frame("row"=rowidx,"basin_id"=basin_sele,
                           "viol_stay_prob"=violation_stay_prob,
                           "viol_shift_prob"=violation_shift_prob,
                           "noViol_shift_prob"=noviolation_shift_prob)
  
  write_xlsx(output_final,"D:\\Academic Backups\\PostDoc-Usask\\PB_files\\Analysis\\Data_paper_revision\\Upper_Lower\\HMM\\Prob_final_annual_new.xlsx")
  
  
}
# violation_prob=violation_prob[1:96]
# 
# output_final<-data.frame("row"=rowidx,"basin_id"=basin_sele,"noVio_to_Vio"=noviol_to_viol,"Vio_to_noVio"=viol_to_noviol,
#                          "Vio_to_Vio"= viol_to_viol,"viol_prob"=violation_prob)
# 
# write_xlsx(output_final,"C:\\Dropbox\\PB_files\\Analysis\\Data_MattisGroup\\EFE data\\HMM_RStudio\\Output_final362_457.xlsx")


# data1$viol_prob<-violation_prob
