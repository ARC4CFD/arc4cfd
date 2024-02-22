#uncomment only one of the following three lines to select the mesh
#mesh=bfs_200k	# coarse mesh
#mesh=bfs_400k	# intermediate mesh
mesh=bfs_800k	# fine mesh


case="$mesh"_DDES
if [ ! -d "$case" ]; then
  echo "creating $case"
fi

cp -r case $case
gmsh mesh/$mesh.geo -3 -o mesh/$mesh.msh -format msh2
gmshToFoam mesh/$mesh.msh -case $case
cp $case/constant/polyMesh/boundary $case/constant/polyMesh/boundary.old

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


#cp mesh/boundary $case/constant/polyMesh/
cd $case
rm -r log.* proc*
./Allrun
