% Step02_main_curve
% Last updated : 2020-09-08
% 
% Description : script that runs the functions to read a Gcode file and
% curve its coordinates on a cylindrical plane. The result is a newly
% constructed Gcode file that contains the curved geometry, ready to be
% printed on a matching curved surface or supports.
%
% Note: this script can be run from an already flat Gcode file, i.e. one
% does not necessarily need to go through the script
% "Step01_main_flatten.m" if the original design is already planar.
%
% Instructions: 
%       1) Choose the printer in which the Gcode has been generated AND in
%       which the part will be printed. BOTH MUST BE THE SAME PRINTER. One
%       cannot slice with a printer's settings and print with another. The
%       datum coordinate systems are probably not the same and the curving
%       will be wrong.
%       2) Input the flat Gcode file name (processing the Gcode can take a
%       few minutes, depending on the toolpath size).
%       3) Choose if you want to continue from step 01 or not (if not, you
%       need to specify the geometry) .
% w
% Jean-François Chauvette 2019-01-19

clc; 
clear all;
close all; 

% Imports
addpath('gCodeProcess');
addpath('gMath');
addpath('gTools');

% Initialization of variables
%dist_res = 10; % point spacing for linear motion
%curve_mode = 0; % 0 = X dir, 1 = Y dir, 2 = XY dir.
print_normals = 0;
layer_ajustment = 0; % [mm] the adjustment to be done to layer 1 to take the first layer height into account (if first layer height > 100% in Simplify3D)
xMid = 0;
yMid = 0;

% User choice for printer
printerInput = validUserInput('Select the printer (Raise3D = 1, AON M2 = 2, Aerotech Gantry = 3, Aerotech Linear Stage = 4, Fanuc = 5) : ',0 ,'1','2','3','4','5');

% Opening the Gcode file
nom_fic_in = input('File name of the GCODE to open (no extension required) : ','s');
fid=fopen([nom_fic_in '.gcode']);
while fid<0
    nom_fic_in = input('File does not exist\nFile name of the GCODE to open (no extension required) : ','s');
    fid=fopen([nom_fic_in '.gcode']);
end

% User choice for radius and part dimensions
infosInput = validUserInput('Do you want to curve a Gcode toolpath by continuing from the previous flattening step (Y/N)? ',0,'Y','N');
if(strcmpi(infosInput, 'y'))
    % Reading the "infos" file
    nom_fic_r = [nom_fic_in(1:strfind(nom_fic_in,'_flatten')-1)  '.infos'];
    fid_r = fopen(nom_fic_r,'rt');
    while fid_r<0
        nom_fic_r = input('File does not exist\nType the file name of an .infos file : ','s');
        fid_r = fopen([nom_fic_r '.infos'],'rt');
    end
    R = str2double(fgetl(fid_r)); % Get radius value
    xMid = str2double(fgetl(fid_r)); % Get the middle X coord
    yMid = str2double(fgetl(fid_r)); % Get the middle Y coord
    fclose(fid_r);
    fprintf('Radius is %.2f\n',R);
else
    % Asking the user to input the values instead
    R = input('Input a radius for the curving of your toolpath (positive to curve upward, negative to curve downward) (mm) : ');
%     if strcmpi(printerInput, 'R3D') || strcmpi(printerInput, 'Fanuc')
    if strcmpi(printerInput, '1')
        xMid = input('Input your part''s dimension along the X axis (mm) : ')/2;
        yMid = input('Input your part''s dimension along the Y axis (mm) : ')/2;
    end
end
print_normals = validUserInput('Print normals (Y/N)? ',0,'Y','N');
if strcmpi(print_normals,'N')
    print_normals = 0;
else 
    print_normals = 1;
end

% Parameters for the Raise3D
DIM_RAISE3D = [280+2*25, 305, 300]; % X & Y bed dimensions [mm] for the Raise3D (25 is the X offset in Simplify3D)
OFFSET_RAISE3D_RIGHT = [DIM_RAISE3D(1)/2-xMid, DIM_RAISE3D(2)/2-yMid, 0]; % Offset for printing a curved surface to the right on the Raise3D
OFFSET_RAISE3D_LEFT = [DIM_RAISE3D(1)/2+xMid, DIM_RAISE3D(2)/2+yMid, 0]; % Offset for printing a curved surface to the left on the Raise3D

% Parameters for the AON
DIM_AON = [450, 425, 620]; % X & Y bed dimensions [mm] for the AON
OFFSET_AON = [DIM_AON(1)/2, DIM_AON(2)/2, 0];

% Parameters for the Aerotech Gantry
DIM_AEROG = [200, 200, 200]; % X & Y bed dimensions [mm] for the Aerotech Gantry AS SET UP IN SIMPLIFY 3D slicing profile
OFFSET_AEROG = [0, 0, 0]; % Offset for printing a curved surface with the Aerotech gantry

% Parameters for the Aerotech Linear Stage
DIM_AEROLS = [0, 0, 0];
OFFSET_AEROLS = [172.75, 252.25, 82.29]; % Valeur de la position centrale du G-code test de David = À REMPLACER

% Parameters for the Fanuc
DIM_FANUC = [450, 450, 600]; % X, Y & Z table dimensions [mm] for the Fanuc (ALUMINIUM BED)
% OFFSET_FANUC = [DIM_FANUC(1)/2-xMid, DIM_FANUC(2)/2-yMid, 0];%187.4380]; % Z is for the Z-offset of the fan case when needed (ALUMINIUM BED for curving Charlotte's tube)
% OFFSET_FANUC = [DIM_FANUC(1)/2, DIM_FANUC(2)/2, 0];

DIM_FANUC = [1800, 380, 0];
OFFSET_FANUC = [0, 0, 0];

% Initialisation of printers offset and dim
if strcmpi(printerInput, '1')
    sideInput = validUserInput('Will you be using the Left or Right nozzle to print? (L/R)? ',0,'L','R');
    if strcmpi(sideInput,'L')
        offset = OFFSET_RAISE3D_LEFT;
    else
        offset = OFFSET_RAISE3D_RIGHT;
    end
elseif strcmpi(printerInput, '2')
    offset = OFFSET_AON;
elseif strcmpi(printerInput, '3')
    offset = OFFSET_AEROG;
elseif strcmpi(printerInput, '4')
    offset = OFFSET_AEROLS;
elseif strcmpi(printerInput, '5')
    offset = OFFSET_FANUC;
%     print_normals = 1;
end

% User choice for curve mode
curve_mode = str2double(validUserInput('Around which axis is the curving taking place ? (Y = 0, X = 1, both = 2) : ',0 , '0', '1', '2'));

% User choice for points interpolation resolution
dist_res = validUserInput('Enter the point interpolation resolution (distance between new points for curving process -> the smaller resolution, the longer it is to compute) (mm) : ',1);

% Processing the Gcode
tic;
fprintf('Reading %s...\n', [nom_fic_in '.gcode']);
gCodeProcess(nom_fic_in,fid,dist_res,R,offset,print_normals,curve_mode,layer_ajustment);
t=toc;
fprintf('Total process time : %.2f s\n',t);