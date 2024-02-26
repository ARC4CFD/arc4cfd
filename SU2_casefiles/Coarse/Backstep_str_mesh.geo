// Gmsh project created on Mon May 29 13:48:18 2023
SetFactory("OpenCASCADE");

// x is streamwise direction
// y is wall-normal direction
// z is spanwise direction
// origin at start of backward step midplane

// Important parameters
h = 0.0096;
Li = 10.*h;
Lx = 20.*h;
Ly = 5.*h;
Lz = 4.*h;
Nxi = 50;
Nx = 100;
Ny = 50;
Nz = 40;

Point(1) = {0, 0, 0};
Point(2) = {0, h, 0};
Point(3) = {Lx, h, 0};
Point(4) = {Lx, 0, 0};
Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};
Curve Loop(1) = {4, 1, 2, 3};
Plane Surface(1) = {1};

Point(5) = {0, h+Ly, 0};
Point(6) = {Lx, h+Ly, 0};
Line(5) = {2, 5};
Line(6) = {5, 6};
Line(7) = {6, 3};
Curve Loop(2) = {5, 6, 7, -2};
Plane Surface(2) = {2};


Point(7) = {-Li, h, 0};
Point(8) = {-Li, h+Ly, 0};
Line(8) = {2, 7};
Line(9) = {7, 8};
Line(10) = {8, 5};
Curve Loop(3) = {8, 9, 10, -5};
Plane Surface(3) = {3};

Transfinite Curve {-10, 8} = Nxi Using Progression 1.08;
Transfinite Curve {6, 2, -4} = Nx Using Progression 1.04;
Transfinite Curve {9, 5, -7} = Ny*0.5 Using Progression 1.2;
Transfinite Curve {1, 3} = Ny*0.5 Using Bump 0.2;

Transfinite Surface "*";
Recombine Surface "*";

Extrude {0, 0, -Lz*0.5} {
  Surface{1, 2, 3};
  Layers{Nz*0.5};
  Recombine;
}

Extrude {0, 0, Lz*0.5} {
  Surface{1, 2, 3};
  Layers{Nz*0.5};
  Recombine;
}

Physical Surface("inlet") = {27, 14};
Physical Surface("outlet") = {24, 11, 20, 7};
Physical Surface("wall_in") = {26, 13};
Physical Surface("wall_ver") = {18, 5};
Physical Surface("wall_hor") = {17, 4};
Physical Surface("top") = {28, 15, 23, 10};
Physical Surface("back") = {12, 16, 8};
Physical Surface("front") = {29, 21, 25};
// Physical Surface("midplane") = {1, 2, 3};
Physical Volume("internal") = {1, 2, 3, 4, 5, 6};

Mesh 1; Mesh 2; Mesh 3;
Mesh.Format = 42;
Mesh.SaveAll= 0;
Save "Backstep_str_mesh.su2";