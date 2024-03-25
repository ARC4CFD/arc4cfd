#!/bin/bash
#SBATCH --job-name="bfs_DDES"      # job name

#SBATCH --ntasks=64                # number of processors
#SBATCH --nodes=2-8                # number of nodes
#SBATCH --mem-per-cpu=3g           # memory per cpu

#SBATCH --time=0-20:00             # walltime dd-hh-mm
#SBATCH --output=bfs%j.txt         # output file
#SBATCH --mail-type=FAIL           


cd $SLURM_SUBMIT_DIR
module load StdEnv/2023  gcc/12.3  openmpi/4.1.5 openfoam/v2306 gmsh/4.12.2
. $WM_PROJECT_DIR/bin/tools/RunFunctions

#Before running this script
#---------------------------------------------------------------------------------------------------------------
# 1) Uncomment only one of the three lines under MESH to select the mesh;
# 2) Replace 64 against "numberOfSubdomains: in 'system/decomposeParDict' of base_case with no.of tasks (= nodes * tasks per node)
# 3) Use following deltaT in 'system/controlDict' in your base_case (You might want to change the writing interval too)
#---------------------------------------------------------------------------------------------------------------


#------------ USER INPUT START ------------------------------------------------------

# BASE CASE
base_case=case		# Provide name of the base case with your preferred settings. 
			# prepare your base case from  the supplied "case" folder

#   MESH
mesh=bfs_200k   # coarse mesh                   (deltaT: 1e-4)
#mesh=bfs_400k  # intermediate mesh             (deltaT: 4e-5)
#mesh=bfs_800k  # fine mesh                     (deltaT: 2e-5)

#------------ USER INPUT END ------------------------------------------------------





case="$mesh"_DDES
if [ ! -d "$case" ]; then # This checks if a directory exists with the same case name. Helps for restarting a job
  echo "creating $case"
  cp -r $base_case $case                                  #copying from base case
  gmsh mesh/$mesh.geo -3 -o mesh/$mesh.msh -format msh2   #generating mesh
  gmshToFoam mesh/$mesh.msh -case $case                   #converting mesh to openfoam format
  
  
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
  cd ..
fi

cd $case
mpirun pimpleFoam -parallel > log.pimpleFoam
reconstructPar > log.reconstructPar
#rm -rf processor*

