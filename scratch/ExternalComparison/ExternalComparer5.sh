#!/bin/bash
#

########################
##### qsub options #####
########################
#
# Any line starting with #$ is interpreted as command line option for qsub

#### Working directory
#  These options specify the directory where the job is to be executed.
#  The default is your home directory (which you don't want).
#  If you use the -wd option, you need to make sure that directory exists.
#
#$ -cwd                           # Current working directory (where you run qsub)
#                                 # MUST BE UNDER $HOME/scratch !!!!!
#
# #$ -wd /home/me/scratch/CoolStuffIsHere # Run job /home/me/scratch/CoolStuffIsHere

##### Shell that is used
#$ -S /bin/bash

#### Number of threads
#  If you have a multi-threaded application, you need to specify here how many
#  cores your process uses.
#  Note: You explicitly have to tell you program how many threads to use
#$ -pe smp 35

#### Run time limit
#  Specify maximum CPU time after which job is to be killed (format HH:MM:SS).
#$ -l h_rt=296:00:00    # in this example, we set 10 minutes

#### Memory limit
#  specifies the maximum amount of memory this job can take
#  This is per thread, so the total amount is this number times the number
#  of threads. The default value is 2g.
#$ -l h_vmem=2g  # here we choose 4g, so that overall we reserve up to 8*4g=32g total

###  # $ -l h=crunch.local

#### Email after done, -abe is abort, begin, end
#$ -m a
#$ -M collinerickson@u.northwestern.edu

#########################
##### Your commands #####
#########################

# For example, run AMPL here (with cplex threads limit to 8 to match your specification above)
#cd ~/github/DOE-code
#Rscript crunch_run_file.R
#Rscript R6load.R

date

Rscript /home/collin/scratch/SGGP/scratch/ExternalComparison/ExternalComparer5.R

date
