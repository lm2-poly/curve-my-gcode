% Step01_main_flatten
% Last updated : 2019-02-19
% 
% Description : script that runs the functions to read a STL file and
% flatten its geometry then plots the results in a Matlab 3D graph.
%
% Instructions: 
%       1) Input the STL file name.
%       2) Assess the plotted result.
% 
% TO-DO : Extract first layer radius from STL shape
%
% N.B. : Scripts from the 'stl_tools' library were taken from the
% Polytechnique Montreal's course MEC1301 Ti en génie mécanique and are the
% work of their respective author.
%
% Jean-François Chauvette 2019-01-19

clc; 
clear all;
close all;

% Imports
addpath('stl_tools');
addpath('gMath');

% Reading the STL file
nom_fic_in = input('File name of the STL to open (no extension required) : ','s');
fid=fopen([nom_fic_in '.stl']);
while fid<0
    nom_fic_in = input('File does not exist\nFile name of the STL to open (no extension required) : ','s');
    fid=fopen([nom_fic_in '.stl']);
end
tic;
fprintf('Reading %s...\n', [nom_fic_in '.stl']);
[f,v,n] = lire_STL(fid,false);

t=toc;
fprintf('Total process time : %.2f s\n',t);

% Finding the radius of the first layer
obj = triangulation(f,v);
idA = nearestNeighbor(obj,[min(v(:,1)) 0 0]);
idB = nearestNeighbor(obj,[(min(v(:,1)) + max(v(:,1)))/2 0 0]);
idC = nearestNeighbor(obj,[max(v(:,1)) 0 0]);
pt = [v(idA,1),v(idA,3); v(idB,1),v(idB,3); v(idC,1),v(idC,3)];
R = heron(pt);
fprintf('Radius is %.2f mm\n', R);

% Flattening
% R = input('Specify the radius of the first layer (same unit as STL) : ');
[vp,np] = flattenXYZ(v,n,R);
tic;

% Writting the new STL file
ecrire_STL([nom_fic_in '_flatten.stl'], f, vp, np, false);

% Plotting the flatten mesh
disp('Plotting mesh...');
obj = triangulation(f,vp);
trisurf(obj);
xlabel('X');
ylabel('Y');
zlabel('Z');
axis equal;

% Getting the middle X & Y coordinate for Step02
xMin = abs(min(vp(:,1)));
xMax = abs(max(vp(:,1)));
yMin = abs(min(vp(:,2)));
yMax = abs(max(vp(:,2)));
xMid= mean([xMin xMax]);
yMid = mean([yMin yMax]);

% Writing the infos file for Step02
disp(['Writing ' nom_fic_in '.infos...']);
nom_fic_r = [nom_fic_in '.infos'];
fid_r = fopen(nom_fic_r,'wt');
fprintf(fid_r, '%.2f\n', R);
fprintf(fid_r, '%.2f\n', xMid);
fprintf(fid_r, '%.2f\n', yMid);
fclose(fid_r);

t=toc;
fprintf('Total process time : %.2f s\n',t);