#!/bin/bash
. /etc/bashrc

module load StdEnv/2023  gcc/12.3  openmpi/4.1.5 openfoam/v2306 gmsh/4.12.2
. $WM_PROJECT_DIR/bin/tools/RunFunctions

# STEP1: preparing the base case
#-------------------------------
echo "STEP1: preparing the base case"
rm -rf bfs[0-9]*	# remove directories created during the previous scaling test
mesh=bfs		# Selecting mesh. locatiom mesh/bfs.geo
case=case		# first, make the mesh in base case
gmsh mesh/$mesh.geo -3 -o mesh/$mesh.msh -format msh2
gmshToFoam mesh/$mesh.msh -case $case

#### script to modify boundary file to reflect boundary conditions#############
  sed -i '/physical/d' $case/constant/polyMesh/boundary
  sed -i "/wall_/,/startFace/{s/patch/wall/}" $case/constant/polyMesh/boundary
  sed -i "/top/,/startFace/{s/patch/symmetryPlane/}" $case/constant/polyMesh/boundary
  sed -i "/front/,/startFace/{s/patch/cyclic/}" $case/constant/polyMesh/boundary
  sed -i "/back/,/startFace/{s/patch/cyclic/}" $case/constant/polyMesh/boundary
  sed -i -e '/front/,/}/{/startFace .*/a'"\\\tneighbourPatch  back;" -e '}' $case/constant/polyMesh/boundary
  sed -i -e '/back/,/}/{/startFace .*/a'"\\\tneighbourPatch  front;" -e '}' $case/constant/polyMesh/boundary
  sed -i -e '/cyclic/,/nFaces/{/type .*/a'"\\\tinGroups        1(cyclic);" -e '}' $case/constant/polyMesh/boundary
  sed -i -e '/wall_/,/}/{/type .*/a'"\\\tinGroups        1(wall);" -e '}' $case/constant/polyMesh/boundary
#### script to modify boundary file to reflect boundary conditions#############

# STEP2: Run a case to select appropriate no. of timesteps for scaling test
#-------------------------------
echo "STEP2: Run a case to select appropriate no. of timesteps for scaling test"

case=timeStepsEval	
rm -rf $case
cp -r case $case	# copy case from the base case
cd $case
sed -i "s/bfs8/timeStepsEval/" jobscript.sh #renaming job
echo "Submitting job for timestep evaluation ..."
sbatch jobscript.sh	#when the job is done, it creates a dummy file named "completed" (last line in the jobscript.sh)
echo -n "timestep evaluation job submitted. Waiting to finish.."
started=0
while [ ! -f completed ];
  do sleep 20;
  echo -n ".";
done #check for the file "completed" to know if job is done
rm -f completed		# remove the dummy file
echo "timestep evaluation job completed."

# STEP3: Analyze log file to select number of timesteps for scaling test
#-----------------------------------------------------------------------
echo "STEP3: Analyze log file to select number of timesteps for scaling test"
#get the dt from controlDict
dt=`grep deltaT system/controlDict | cut -d " " -f 11|sed 's/;//'|sed -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/(\1*10^\2\3)/g'|sed 's/(//g'|sed 's/)//g'` #sed at the end removes trailing zeros
echo "TimeEval case deltT = $dt"

#calculate the simulation time for N timesteps. N=10,50,100,200,250
ts10=$(echo "scale=5;$dt * 10"|bc| sed '/\./ s/\.\{0,1\}0\{1,\}$//')	# scale=5 ensure 5 significant digit 
ts50=$(echo "scale=5;$dt * 50"|bc| sed '/\./ s/\.\{0,1\}0\{1,\}$//')
ts100=$(echo "scale=5;$dt * 100"|bc| sed '/\./ s/\.\{0,1\}0\{1,\}$//')
ts150=$(echo "scale=5;$dt * 150"|bc| sed '/\./ s/\.\{0,1\}0\{1,\}$//')
ts200=$(echo "scale=5;$dt * 200"|bc| sed '/\./ s/\.\{0,1\}0\{1,\}$//')
ts250=$(echo "scale=5;$dt * 250"|bc| sed '/\./ s/\.\{0,1\}0\{1,\}$//')
echo "$ts10  $ts50  $ts100 $ts150 $ts200 $ts250"

#get the actual clockTime taken for N timesteps from log file
#it search for the line, say, Time = 0.0003 in the log.pimpleFoam and takes the third previous line
#from the third line, it extracts the clockTime in seconds
t10=`awk -v N=3 -v pattern="Time = 0$ts10$" '{i=(1+(i%N));if (buffer[i]&& $0 ~ pattern) print buffer[i]; buffer[i]=$0;}' log.pimpleFoam|cut -d "=" -f3|cut -d" " -f 2`
t50=`awk -v N=3 -v pattern="Time = 0$ts50$" '{i=(1+(i%N));if (buffer[i]&& $0 ~ pattern) print buffer[i]; buffer[i]=$0;}' log.pimpleFoam|cut -d "=" -f3|cut -d" " -f 2`
t100=`awk -v N=3 -v pattern="Time = 0$ts100$" '{i=(1+(i%N));if (buffer[i]&& $0 ~ pattern) print buffer[i]; buffer[i]=$0;}' log.pimpleFoam|cut -d "=" -f3|cut -d" " -f 2`
t150=`awk -v N=3 -v pattern="Time = 0$ts150$" '{i=(1+(i%N));if (buffer[i]&& $0 ~ pattern) print buffer[i]; buffer[i]=$0;}' log.pimpleFoam|cut -d "=" -f3|cut -d" " -f 2`
t200=`awk -v N=3 -v pattern="Time = 0$ts200$" '{i=(1+(i%N));if (buffer[i]&& $0 ~ pattern) print buffer[i]; buffer[i]=$0;}' log.pimpleFoam|cut -d "=" -f3|cut -d" " -f 2`
t250=`awk -v N=3 -v pattern="Time = 0$ts250$" '{i=(1+(i%N));if (buffer[i]&& $0 ~ pattern) print buffer[i]; buffer[i]=$0;}' log.pimpleFoam|cut -d "=" -f3|cut -d" " -f 2`

echo "$t10  $t50  $t100 $t150 $t200 $t250"

#calculate average(normalized) clocktime for a timestep. This is to find best number of timesteps for scaling analysis
t10n=$(echo "scale=5;$t10 / 10.0"|bc)
t50n=$(echo "scale=5;$t50 / 50.0"|bc)
t100n=$(echo "scale=5;$t100 / 100.0"|bc)
t150n=$(echo "scale=5;$t150 / 150.0"|bc)
t200n=$(echo "scale=5;$t200 / 200.0"|bc)
t250n=$(echo "scale=5;$t250 / 250.0"|bc)
echo "Time for 10 timesteps: $t10 seconds. Normalized time for a timestep = $t10n" 
echo "Time for 50 timesteps: $t50 seconds. Normalized time for a timestep = $t50n" 
echo "Time for 100 timesteps: $t100 seconds. Normalized time for a timestep = $t100n" 
echo "Time for 150 timesteps: $t150 seconds. Normalized time for a timestep = $t150n" 
echo "Time for 200 timesteps: $t200 seconds. Normalized time for a timestep = $t200n" 
echo "Time for 250 timesteps: $t250 seconds. Normalized time for a timestep = $t250n" 

#idea is to find %change of normalised time and take the timestep where change is less than 4.5%
r1=$(echo "scale=3;$t10n / $t50n" | bc)
r2=$(echo "scale=3;$t50n / $t100n" | bc)
r3=$(echo "scale=3;$t100n / $t150n" | bc)
r4=$(echo "scale=3;$t150n / $t200n" | bc)
r5=$(echo "scale=3;$t200n / $t250n" | bc)
r1=$(echo "$r1 * 1000" | bc| sed '/\./ s/\.\{0,1\}0\{1,\}$//')	# * 1000 because only integer allowed inside if [... ]
r2=$(echo "$r2 * 1000" | bc| sed '/\./ s/\.\{0,1\}0\{1,\}$//') 
r3=$(echo "$r3 * 1000" | bc| sed '/\./ s/\.\{0,1\}0\{1,\}$//')
r4=$(echo "$r4 * 1000" | bc| sed '/\./ s/\.\{0,1\}0\{1,\}$//')
r5=$(echo "$r5 * 1000" | bc| sed '/\./ s/\.\{0,1\}0\{1,\}$//')
tStep=250
echo "$r1  $r2  $r3 $r4 $r5 "
if [ $r1 -lt 1045 ]; then
   tStep=10 
elif [ $r2 -lt 1045 ]; then
   tStep=50 
elif [ $r3 -lt 1045 ]; then
   tStep=100 
elif [ $r4 -lt 1045 ]; then
   tStep=150 
elif [ $r5 -lt 1045 ]; then
   tStep=200
else
   tStep=250
fi

echo "Selecting timestep $tStep"
cd ..
endTime=0$(echo "scale=5;$dt * $tStep"|bc| sed '/\./ s/\.\{0,1\}0\{1,\}$//')	#calculating endTime. endTime=dt * tStep


# STEP4: Prepare cases and run scaling test jobs 
#-----------------------------------------------
echo " STEP4: Prepare cases and run scaling test jobs "
for i in 1 2 4 6 8 12 16 20 24 28 32; do
#for i in 1 2 4; do #less no. of cases for quick testing
    case=bfs$i
    echo "Prepare case $case..."
    cp -r case $case
    cd $case
    sed -i "s/endTime .*/endTime         ${endTime};/" system/controlDict    #updating endTime in controlDict
    sed -i "s/method.*/method scotch;/" system/decomposeParDict	#ensure using scotch
    sed -i "s/numberOfSubdomains.*/numberOfSubdomains ${i};/" system/decomposeParDict	#using right no. of procs
    sed -i "s/bfs8/bfs$i/" jobscript.sh	#renaming job
    sed -i "s/ntasks=8/ntasks=$i/" jobscript.sh	#request right no. of procs
    if [ $i -eq 1 ]; then			#if serial, remove commands to 
       sed -i '/decompose/d' jobscript.sh	#decompose, reconstruct from jobscript and perform serial run
       sed -i '/processor/d' jobscript.sh
       sed -i '/reconstruct/d' jobscript.sh
       sed -i 's/mpirun.*>/pimpleFoam>/' jobscript.sh
    fi
    echo "Submitting job for bfs$i: sbatch jobscript.sh"
    sbatch jobscript.sh #comment, if needed, for testing
    cd ..
done
#Next we wait for all jobs to finish. We detect completion as usual by checking for "completed" file
dirs=`ls -d bfs[0-9]*|wc -l` #gives how many scaling test cases we plan
#following line wait for all jobs to finish, displays status while wait
while [ `find ./bfs* -iname completed|wc -l` -lt $dirs ]; do sleep 60;echo `find ./bfs* -iname completed|wc -l` out of $dirs jobs completed; done

# STEP5: Write test results to screen and file
#---------------------------------------------
echo "STEP5: Write test results to screen and file"
echo "# cores   Wall time (s):"
echo "------------------------"
echo "# cores   Wall time (s):"> SSTResults.dat
echo "------------------------">> SSTResults.dat
for i in 1 2 4 6 8 12 16 20 24 28 32; do
#for i in 1 2 4; do
    echo $i `grep Execution bfs${i}/log.pimpleFoam | tail -n 1 | cut -d " " -f 3`
    echo $i `grep Execution bfs${i}/log.pimpleFoam | tail -n 1 | cut -d " " -f 3`>> SSTResults.dat
done
