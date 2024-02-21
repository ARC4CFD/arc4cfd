mesh=bfs_300k
case=bfs_DDES_300k
gmsh mesh/$mesh.geo -3 -o mesh/$mesh.msh
gmshToFoam mesh/$mesh.msh -case $case
cp $case/constant/polyMesh/boundary $case/constant/polyMesh/boundary.bkp
cp mesh/boundary $case/constant/polyMesh/
cd $case
rm -r log.* proc*
./Allrun
