#!/bin/bash
#This script assumes that you've 
#1)resourse allocated via commands:
#       debugjob --clean (niagara)
#       salloc -n 32 --time=1:00:0 --mem-per-cpu=3g (graham, narval ...)
#2)loaded the modules:
#       module load CCEnv StdEnv/2023  gcc/12.3  openmpi/4.1.5 openfoam/v2306 gmsh/4.12.2 (niagara)
#       module load StdEnv/2023  gcc/12.3  openmpi/4.1.5 openfoam/v2306 gmsh/4.12.2 (graham, narval ...)

# STEP1: preparing the base case
#-------------------------------
echo "STEP1: preparing the base case"
gmsh mesh/bfs.geo -3 -o mesh/bfs.msh -format msh2
gmshToFoam mesh/bfs.msh -case case
#### script to modify boundary file to reflect boundary conditions#############
  sed -i '/physical/d' case/constant/polyMesh/boundary
  sed -i "/wall_/,/startFace/{s/patch/wall/}" case/constant/polyMesh/boundary
  sed -i "/top/,/startFace/{s/patch/symmetryPlane/}" case/constant/polyMesh/boundary
  sed -i "/front/,/startFace/{s/patch/cyclic/}" case/constant/polyMesh/boundary
  sed -i "/back/,/startFace/{s/patch/cyclic/}" case/constant/polyMesh/boundary
  sed -i -e '/front/,/}/{/startFace .*/a'"\\\tneighbourPatch  back;" -e '}' case/constant/polyMesh/boundary
  sed -i -e '/back/,/}/{/startFace .*/a'"\\\tneighbourPatch  front;" -e '}' case/constant/polyMesh/boundary
  sed -i -e '/cyclic/,/nFaces/{/type .*/a'"\\\tinGroups        1(cyclic);" -e '}' case/constant/polyMesh/boundary
  sed -i -e '/wall_/,/}/{/type .*/a'"\\\tinGroups        1(wall);" -e '}' case/constant/polyMesh/boundary
#### script to modify boundary file to reflect boundary conditions#############
# STEP2: Prepare cases and run scaling test jobs 
#-----------------------------------------------
echo " STEP2: Prepare cases and run scaling test jobs "
for i in 1 2 4 6 8 12 16 20 24 28 32; do
    case=bfs$i
    echo "Prepare case $case..."
    cp -r case $case
    cd $case
    sed -i "s/numberOfSubdomains.*/numberOfSubdomains ${i};/" system/decomposeParDict   #using right no. of procs
    if [ $i -eq 1 ]; then       #if serial, run AllrunSerial 
       ./AllrunSerial
    else
       ./Allrun
    fi
    cd ..
done

# STEP3: Write test results to screen and file
#---------------------------------------------
echo "STEP3: Write test results to screen and file"
echo "# cores   Wall time (s):"
echo "------------------------"
echo "# cores   Wall time (s):"> SSTResults.dat
echo "------------------------">> SSTResults.dat
for i in 1 2 4 6 8 12 16 20 24 28 32; do
#for i in 1 2 4; do
    echo $i `grep Execution bfs${i}/log.pimpleFoam | tail -n 1 | cut -d " " -f 3`
    echo $i `grep Execution bfs${i}/log.pimpleFoam | tail -n 1 | cut -d " " -f 3`>> SSTResults.dat
done
