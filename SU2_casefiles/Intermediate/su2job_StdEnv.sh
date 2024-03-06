#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --time=0-23:00
#SBATCH --job-name ARC4CFD_BFS
#SBATCH --output=BFSstr%j.txt
#SBATCH --mail-type=FAIL
cd $SLURM_SUBMIT_DIR
module load StdEnv/2020 gcc/9.3.0 openmpi/4.0.3 su2/7.5.1
mpirun -n 10 SU2_CFD Backstep_str_config.cfg
