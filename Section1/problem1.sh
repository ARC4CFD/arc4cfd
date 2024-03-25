#!/bin/bash
#SBATCH --job-name=problem1    ## Name of the job
#SBATCH --time=08:00:00        ## Job Duration hh:mm:ss
#SBATCH --nodes=2              ## Number of nodes
#SBATCH --ntasks=64            ## Number of processors

module load python/3.9.6

srun python problem1.py