## For all Clusters

# Clone git repo into home directory
# Copy the folder (Coarse, Intermediate or Fine) with required mesh size into the run directory in scratch
# cd into the folder placed in run directory

# Set : Time Step, Simulation End Time (Total iterations), Snapshot Time Interval
vim Backstep_str_config.cfg
TIME_STEP= 1e-4   # Line 118
TIME_ITER= 5000   # Line 120 : TIME_ITER = Simulation_End_Time / TIME_STEP
OUTPUT_FILES= (RESTART, PARAVIEW)  # Line 242 : No change required
OUTPUT_WRT_FREQ= 3800, 20          # Line 243 : Set iterations at which (RESTART, PARAVIEW) files are to be written
                                   # OUTPUT_WRT_FREQ = Restart_File_Time_interval * TIME_STEP, Snapshot_Time_Interval * TIME_STEP
                                   
# Domain Decomposition: SU2 modules in Compute Canada clusters are fully-parallel suites. 
# SU2_CFD can be executed in parallel using mpirun command, without making specific changes to .cfg file.

# Generate Mesh
module load CCEnv   # Required only for Niagara
module load StdEnv/2023 gcc/12.3 gmsh/4.12.2   # Load modules needed for gmsh execution
gmsh Backstep_str_mesh.geo -0    # Avoid -0 to open gmsh in GUI and then close GUI to continue.
# confirm Backstep_str_mesh.su2 in run directory

# Test job in StdEnv
module load StdEnv/2020 gcc/9.3.0 openmpi/4.0.3 su2/7.5.1   # Load modules needed for SU2 execution
salloc --nodes 1 -n 20 --time=00:30:00 --account=account-name   # Set number of nodes, total cores, time of execution and account name
# wait for nodes to be allocated
mpirun -n 20 SU2_CFD Backstep_str_config.cfg

# Main Job in StdEnv
vim '+set ff=unix' '+x' su2job_StdEnv.sh   # Setting file format to Unix
sbatch su2job_StdEnv.sh




## Exclusive in Niagara

#Download pre-compiled SU2 v8  (to be performed only once)
cd $SCRATCH
mkdir SU2_executable
cd SU2_executable   # Downloading into this directory
wget https://github.com/su2code/SU2/releases/download/v8.0.0/SU2-v8.0.0-linux64-mpi.zip
unzip SU2-v8.0.0-linux64-mpi.zip

# Clone git repo into home directory
# Copy the folder (Coarse, Intermediate or Fine) with required mesh size into the run directory in scratch
# cd into the folder placed in run directory
# Complete steps in Set : Time Step, Simulation End Time (Total iterations), Snapshot Time Interval
# Complete steps in Generate Mesh

# Test job in NiaEnv  (requires download of pre-compiled SU2 v8.)
module load NiaEnv/2019b gcc/8.3.0 intelmpi/2019u5 python/3.6.8    # Load modules needed for SU2 execution
export SU2_RUN="/scratch/SU2_executable/bin"    # Point the path containing SU2_CFD executable
export PATH=$PATH:$SU2_RUN
which SU2_CFD   # confirm the path "/scratch/SU2_executable/bin"
salloc --nodes 1 -n 20 --time=00:30:00 --account=account-name     # Set number of nodes, total cores, time of execution and account name
# wait for nodes to be allocated
mpirun -n 20 SU2_CFD Backstep_str_config.cfg

# Main Job in NiaEnv (requires download of pre-compiled SU2 v8. Check path in line 10 of su2job_NiaEnv.sh)
vim '+set ff=unix' '+x' su2job_NiaEnv.sh
sbatch su2job_NiaEnv.sh
