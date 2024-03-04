#!/bin/bash
. /etc/bashrc

module load StdEnv/2023  gcc/12.3  openmpi/4.1.5 openfoam/v2306 gmsh/4.12.2
. $WM_PROJECT_DIR/bin/tools/RunFunctions

# STEP1: preparing the base case
#-------------------------------
echo "STEP1: preparing the base case"
rm -rf bfs[0-9]*	# remove directories created during the previous scaling test
rm -rf mesh/bfs[1-9]*	#remove old gmsh and mesh files

for i in 1 2 4 6 8 12 16 20 24 28 32; do
#for i in 1 2 3 4 5 6 7 8; do
#for i in 1 2 4 8; do #less no. of cases for quick testing
    case=bfs$i
    echo "Prepare case $case..."
    cp -r case $case
    cp mesh/bfs.geo mesh/$case.geo
    nz=$(echo "scale=1;2 * $i"|bc)
    echo "no of divisions in Z direction= $nz"
    sed -i "s/Nz = 2;/Nz = $nz;/" mesh/$case.geo	#increase no. of division in z direction to keep same load per proc
    cd $case
    sed -i "s/numberOfSubdomains.*/numberOfSubdomains ${i};/" system/decomposeParDict	#using right no. of procs
    sed -i "s/1 1 .*);/1 1 ${i});/" system/decomposeParDict	#using right no. of procs
    sed -i "s/bfs8/bfs$i/" jobscript.sh	#renaming job
    sed -i "s/ntasks=8/ntasks=$i/" jobscript.sh	#request right no. of procs
    if [ $i -eq 1 ]; then			#if serial, remove commands to 
       sed -i '/decompose/d' jobscript.sh	#decompose, reconstruct from jobscript and perform serial run
       sed -i '/processor/d' jobscript.sh
       sed -i '/reconstruct/d' jobscript.sh
       sed -i 's/mpirun.*>/pimpleFoam>/' jobscript.sh
    fi
    cd ..
    gmsh mesh/$case.geo -3 -o mesh/$case.msh -format msh2
    gmshToFoam mesh/$case.msh -case $case
    cd $case
    echo "Submitting job for bfs$i: sbatch jobscript.sh"
    sbatch jobscript.sh #comment, if needed, for testing
    cd ..
done

#Next we wait for all jobs to finish. We detect completion as usual by checking for "completed" file
dirs=`ls -d bfs[0-9]*|wc -l` #gives how many scaling test cases we plan
#following line wait for all jobs to finish, displays status while wait
while [ `find ./bfs* -iname completed|wc -l` -lt $dirs ]; do sleep 60;echo `find ./bfs* -iname completed|wc -l` out of $dirs jobs completed; done


# STEP2: Write test results to screen and file
#---------------------------------------------
echo "STEP5: Write test results to screen and file"
echo "# cores   Wall time (s):"
echo "------------------------"
echo "# cores   Wall time (s):"> WSTResults.dat
echo "------------------------">> WSTResults.dat
for i in 1 2 4 6 8 12 16 20 24 28 32; do
#for i in 1 2 3 4 5 6 7 8; do
#for i in 1 2 4 8; do
    echo $i `grep Execution bfs${i}/log.pimpleFoam | tail -n 1 | cut -d " " -f 3`
    echo $i `grep Execution bfs${i}/log.pimpleFoam | tail -n 1 | cut -d " " -f 3`>> WSTResults.dat
done
