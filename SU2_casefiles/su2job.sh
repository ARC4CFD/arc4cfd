#!/bin/bash
#SBATCH --nodes=1
#SBATCH --mem=127000M
#SBATCH --ntasks-per-node=2
#SBATCH --time=3-00:00
#SBATCH --job-name ARC4CFD_BFS
#SBATCH --output=BFSstr%j.txt
#SBATCH --mail-type=FAIL
cd $SLURM_SUBMIT_DIR
module load CCEnv StdEnv
module load  gcc/9.3.0 openmpi/4.0.3
module load su2/7.5.1
mpirun -n 2 SU2_CFD Backstep_str_config.cfg
