# Begin SGGP redTime experiment
cat("Starting SGGP_redTime_begin.R\n")

# This file will reload number_cores, d, SGGP_RDS_path, ???
source("SGGP_redTime_parameters.R")
cat("Loading SGGP_redTime_parameters.R successfully\n")

devtools::build()
cat("devtools::build() ran successfully\n")

install.packages(repos=NULL, pkgs="/home/collin/scratch/SGGP_1.0.tar.gz")
cat("SGGP installed correctly\n")

library('SGGP')
cat("SGGP loaded successfully\n")

SG <- SGGPcreate(d=d, batchsize=N0, corr=corr)
print(SG)
cat("SGGPcreate successful\n")

# Save SG, nothing evaluated yet
saveRDS(object = SG, file = paste0(SGGP_after_append_RDS_path))
cat("saveRDS successful\n")

# write params, write .sh, qsub, and prepare next R script
source("SGGP_redTime_qsub_unevaluated.R")
cat("qsub_unevaluated.R succesful\n")