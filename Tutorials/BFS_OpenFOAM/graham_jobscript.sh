#!/bin/bash
# bash script for submitting a job to the sharcnet Graham queue

#SBATCH --nodes=2                           # number of nodes to use
#SBATCH --time=00-10:00:00                  # time (DD-HH:MM:SS)
#SBATCH --job-name="bfs_DDES"    		    # job name

#SBATCH --ntasks-per-node=32                # tasks per node
#SBATCH --mem=128000M                       # memory per node
#SBATCH --output=bfs_DDES_300k%j.log        # log file
#SBATCH --error=sim-%j.err                  # error file
#SBATCH --mail-user=nlokanat@uwaterloo.ca   # who to email
#SBATCH --mail-type=FAIL                    # when to email

cd $SLURM_SUBMIT_DIR
module load StdEnv/2023  gcc/12.3  openmpi/4.1.5 openfoam/v2306 gmsh/4.12.2
. $WM_PROJECT_DIR/bin/tools/RunFunctions

#Before running this script
#---------------------------------------------------------------------------------------------------------------
# 1) Uncomment only one of the following three lines to select the mesh;
# 2) Replace 64 against "numberOfSubdomains: in 'case/system/decomposeParDict' with no.of nodes * tasks per node
# 3) Use following deltaT in 'case/system/controlDict' 
#---------------------------------------------------------------------------------------------------------------
#mesh=bfs_200k	# coarse mesh 		(deltaT: 1e-4)
#mesh=bfs_400k	# intermediate mesh (deltaT: 4e-5)
mesh=bfs_800k	# fine mesh			(deltaT: 2e-5)


case="$mesh"_DDES
if [ ! -d "$case" ]; then
  echo "creating $case"
fi

cp -r case $case										#copying from base case
gmsh mesh/$mesh.geo -3 -o mesh/$mesh.msh -format msh2	#generating mesh
gmshToFoam mesh/$mesh.msh -case $case					#converting mesh to openfoam format


#### script to modify constant/polyMesh/boundary file to reflect boundary conditions#############
  sed -i '/physical/d' $case/constant/polyMesh/boundary
  sed -i "/wall_/,/startFace/{s/patch/wall/}" $case/constant/polyMesh/boundary
  sed -i "/top/,/startFace/{s/patch/symmetryPlane/}" $case/constant/polyMesh/boundary
  sed -i "/front/,/startFace/{s/patch/cyclic/}" $case/constant/polyMesh/boundary
  sed -i "/back/,/startFace/{s/patch/cyclic/}" $case/constant/polyMesh/boundary
  sed -i -e '/front/,/}/{/startFace .*/a'"\\\tneighbourPatch  back;" -e '}' $case/constant/polyMesh/boundary
  sed -i -e '/back/,/}/{/startFace .*/a'"\\\tneighbourPatch  front;" -e '}' $case/constant/polyMesh/boundary
  sed -i -e '/cyclic/,/nFaces/{/type .*/a'"\\\tinGroups        1(cyclic);" -e '}' $case/constant/polyMesh/boundary
  sed -i -e '/wall_/,/}/{/type .*/a'"\\\tinGroups        1(wall);" -e '}' $case/constant/polyMesh/boundary
#### script to modify constant/polyMesh/boundary file to reflect boundary conditions#############


cd $case
rm -r log.* proc*
cp -r 0.orig 0

decomposePar -force > log.decomposePar
mpirun pimpleFoam -parallel > log.pimpleFoam
reconstructPar > log.reconstructPar
rm -rf processor*

