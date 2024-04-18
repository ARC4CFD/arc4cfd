#!/bin/bash

#SBATCH --job-name=isleap      ## Name of the job
#SBATCH --output=isleap.out    ## Output file
#SBATCH -e isleap.err          ## Error file
#SBATCH --time=10:00           ## Job Duration
#SBATCH --nodes=1              ## Number of nodes
#SBATCH --ntasks=1             ## Number of processors
#SBATCH --mem-per-cpu=100M     ## Memory per CPU required by the job.

## Execute the python script and pass the input '2024'
srun python isleap.py 2024