SetFactory("OpenCASCADE");

upstream   = 200;   // upstream distance from cylinder
downstream = 500;   // downstream distance from cylinder
height     = 100;  //  height from cylinder
width      = 50;   // width of computational domain 
radius     =10;   // radius of cylinder

dx        = 0.25;    // size of mesh near cylinder
BL        = 1.2;  // Approximate boundary layer thickness
dxfar     = 10.0;  // size of mesh far field
nBL       = 11;  //  grid points in BL
nCirc     = 25;  // grids in circumference
nZ        = 5;    // grid points in the z-direction

// Generate domain point-by-point
Point(1) = { 0,  0, 0, dx};     
Point(2) = { radius,  0, 0, dx};     
Point(3) = { 0,  radius, 0, dx};    
Point(4) = {-radius,  0, 0, dx};      
Point(5) = { 0, -radius, 0, dx};     

Point(6) = { BL*radius,  0, 0, dx};   
Point(7) = { 0,  BL*radius, 0, dx};   
Point(8) = {-BL*radius,  0, 0, dx};    
Point(9) = { 0, -BL*radius, 0, dx};   

// Create cylinder and region around the cylinder BL
Circle(10) = {2, 1, 3};
Circle(11) = {3, 1, 4}; 
Circle(12) = {4, 1, 5};
Circle(13) = {5, 1, 2};

Circle(14) = {6, 1, 7};
Circle(15) = {7, 1, 8}; 
Circle(16) = {8, 1, 9};
Circle(17) = {9, 1, 6};

Line(18) = {2, 6};
Line(19) = {7, 3};
Line(20) = {4, 8};
Line(21) = {9, 5};

//- Create vertices and surfaces
Line Loop(22) = {10, 18, 14, 19};
Line Loop(23) = {19, 11, 15, 20};
Line Loop(24) = {20, 12, 16, 21};
Line Loop(25) = {21, 13, 17, 18};

Plane Surface(26) = {22};
Plane Surface(27) = {23};
Plane Surface(28) = {24};
Plane Surface(29) = {25};

//--Create bounding domain
Point(30) = { downstream, 0, 0, dxfar};
Point(31) = { downstream, height, 0, dxfar};
Point(32) = { 0, height, 0, dxfar};
Line(33) = {6, 30};
Line(34) = {30, 31};
Line(35) = {31, 32};
Line(36) = {32, 7};
Line Loop(37) = {33, 34, 35, 36, 14};
Plane Surface(38) = {37};

Point(39) = { downstream, -height, 0, dxfar};
Point(40) = { 0, -height, 0, dxfar};
Line(41) = {9, 40};
Line(42) = {40, 39};
Line(43) = {39, 30};
Line Loop(44) = {41, 42, 43, 33, 17};
Plane Surface(45) = {44};

Point(46) = { -upstream, height, 0, dxfar};
Point(47) = { -upstream, 0, 0, dxfar};
Line(48) = {32, 46};
Line(49) = {46, 47};
Line(50) = {47, 8};
Line Loop(51) = {15, 36, 48, 49, 50};
Plane Surface(52) = {51};

Point(53) = { -upstream, -height, 0, dxfar};
Line(54) = {47, 53};
Line(55) = {53, 40};
Line Loop(56) = {16, 50, 54, 55, 41};
Plane Surface(57) = {56};


Transfinite Line{18, 19} = nBL;
Transfinite Line{10, 14} = nCirc;
Transfinite Surface{26}; 
Recombine Surface{26};

Transfinite Line{19, 20} = nBL;
Transfinite Line{11, 15} = nCirc;
Transfinite Surface{27};
Recombine Surface{27};

Transfinite Line{20, 21} = nBL;
Transfinite Line{12, 16} = nCirc;
Transfinite Surface{28};
Recombine Surface{28};

Transfinite Line{21, 18} = nBL;
Transfinite Line{13, 17} = nCirc;
Transfinite Surface{29};
Recombine Surface{29};


Recombine Surface{38};

Recombine Surface{45};

Recombine Surface{52};

Recombine Surface{57};

num[]=Extrude {0,0,-width} {Surface{26, 27, 28, 29, 38, 45, 52, 57}; Layers{nZ}; Recombine;};

Coherence Mesh;



