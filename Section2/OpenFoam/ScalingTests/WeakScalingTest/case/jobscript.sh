#!/bin/bash
#SBATCH --ntasks=8
#SBATCH --mem-per-cpu=3g
#SBATCH --time=0-00:30
#SBATCH --job-name="bfs8"          # job name
#SBATCH --output=bfs8%j.txt
#SBATCH --mail-type=FAIL


cd $SLURM_SUBMIT_DIR
module load StdEnv/2023  gcc/12.3  openmpi/4.1.5 openfoam/v2306 gmsh/4.12.2
. $WM_PROJECT_DIR/bin/tools/RunFunctions

#### script to modify boundary file to reflect boundary conditions#############
  sed -i '/physical/d' constant/polyMesh/boundary
  sed -i "/wall_/,/startFace/{s/patch/wall/}" constant/polyMesh/boundary
  sed -i "/top/,/startFace/{s/patch/symmetryPlane/}" constant/polyMesh/boundary
  sed -i "/front/,/startFace/{s/patch/cyclic/}" constant/polyMesh/boundary
  sed -i "/back/,/startFace/{s/patch/cyclic/}" constant/polyMesh/boundary
  sed -i -e '/front/,/}/{/startFace .*/a'"\\\tneighbourPatch  back;" -e '}' constant/polyMesh/boundary
  sed -i -e '/back/,/}/{/startFace .*/a'"\\\tneighbourPatch  front;" -e '}' constant/polyMesh/boundary
  sed -i -e '/cyclic/,/nFaces/{/type .*/a'"\\\tinGroups        1(cyclic);" -e '}' constant/polyMesh/boundary
  sed -i -e '/wall_/,/}/{/type .*/a'"\\\tinGroups        1(wall);" -e '}' constant/polyMesh/boundary
#### script to modify boundary file to reflect boundary conditions#############

cp -r 0.orig 0
decomposePar -force > log.decomposePar
mpirun pimpleFoam -parallel > log.pimpleFoam
reconstructPar > log.reconstructPar
rm -rf processor*
touch completed
