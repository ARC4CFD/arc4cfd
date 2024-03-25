#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --time=0-00:30
#SBATCH --job-name="bfs8"          # job name
#SBATCH --output=bfs8%j.txt
#SBATCH --mail-type=FAIL

module purge
module load CCEnv StdEnv
cd $SLURM_SUBMIT_DIR
module load StdEnv/2023  gcc/12.3  openmpi/4.1.5 openfoam/v2306 gmsh/4.12.2
. $WM_PROJECT_DIR/bin/tools/RunFunctions

cp -r 0.orig 0
decomposePar -force > log.decomposePar
mpirun pimpleFoam -parallel > log.pimpleFoam
reconstructPar > log.reconstructPar
rm -rf processor*
touch completed
