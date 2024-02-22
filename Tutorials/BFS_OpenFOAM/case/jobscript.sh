#!/bin/bash
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=40
#SBATCH --time=23:00:00
#SBATCH --job-name mpi_job
#SBATCH --output=sphereDrag%j.txt
#SBATCH --mail-type=ALL

cd $SLURM_SUBMIT_DIR 
module load gcc/8.3.0 openmpi/4.0.1 openfoam/20.12

. $WM_PROJECT_DIR/bin/tools/RunFunctions
rm *.txt
#blockMesh > log.blockMesh
restore0Dir
decomposePar -force > log.decompose
mpirun pimpleFoam -parallel > log.pimple
reconstructPar > log.reconstruct
rm -rf processor*
