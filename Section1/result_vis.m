%% Visualizing temperature contour
close all; clear all; clc;

T_final=load('39204_32.csv');
[nj,ni] = size(T_final);

Lx=linspace(0,0.06,ni);
Ly=linspace(0,0.04,nj);

figure;
set(gcf,'DefaultAxesFontsize',24);
contourf(Lx,Ly,T_final,30,'LineStyle','none')
colormap parula;
shading interp;
axis equal;
colorbar;

xlabel('$x\,(m)$','FontSize',24,'Interpreter','latex');
ylabel('$y\,(m)$','FontSize',24,'Interpreter','latex');
legend('$T(x,y)$','FontSize',24,'Interpreter','latex','location','northoutside');