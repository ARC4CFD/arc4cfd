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

for i in 1 2 4 6 8 12 16 20 24 28 32; do
    case=bfs$i
    echo "Prepare case $case..."
    cp -r case $case
    cp mesh/bfs.geo mesh/$case.geo
    nz=$(echo "scale=1;2 * $i"|bc)
    echo "no of divisions in Z direction= $nz"
    sed -i "s/Nz = 2;/Nz = $nz;/" mesh/$case.geo	#increase no. of division in z direction as many times as nproc
    gmsh mesh/$case.geo -3 -o mesh/$case.msh -format msh2
    gmshToFoam mesh/$case.msh -case $case
    cd $case
    sed -i "s/numberOfSubdomains.*/numberOfSubdomains ${i};/" system/decomposeParDict	#using right no. of procs
    sed -i "s/1 1 .*);/1 1 ${i});/" system/decomposeParDict	#divide the domain in Z direction into as many number of procs 
    if [ $i -eq 1 ]; then       #if serial, run AllrunSerial
       ./AllrunSerial
    else
       ./Allrun
    fi
    cd ..
done


# STEP2: Write test results to screen and file
#---------------------------------------------
echo "STEP2: Write test results to screen and file"
echo "# cores   Wall time (s):"
echo "------------------------"
echo "# cores   Wall time (s):"> WSTResults.dat
echo "------------------------">> WSTResults.dat
for i in 1 2 4 6 8 12 16 20 24 28 32; do
    echo $i `grep Execution bfs${i}/log.pimpleFoam | tail -n 1 | cut -d " " -f 3`
    echo $i `grep Execution bfs${i}/log.pimpleFoam | tail -n 1 | cut -d " " -f 3`>> WSTResults.dat
done
