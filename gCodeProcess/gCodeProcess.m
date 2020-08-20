function gCodeProcess(nom_fic_in, raw_gcode_file, dist_res, R, offset, curve_mode, layer_ajustment)
% gCodeProcess
% Last updated : 2020-08-19
%
% Description : This function reads a G-code file, interpolates points
% between the coordinates following the resolution given by the variable
% dist_res then curves the toolpath using the given first layer radius R.
% The radius of each remaining layers are calculated in the script
% curveXYZ.m. Before curving the path, it is placed at the origin
% (0,0,0) of the printer using the offset variable. Once curved, the path
% is replaced to its original position when it was sliced. Afterwards, the
% complete G-code is reconstructed and output to a new G-code file.
%
% Inputs:
%       nom_fic_in : the name of the file for writing the new G-code in.
%       raw_gcode_file : the G-code file's id. Used to loop throught it.
%       dist_res : the interpolation resolution between two points.
%       R : the first layer radius used to curve the path.
%       offset : the path's offset needed for the curving operation.
%       curve_mode : (0, 1 or 2) the curving mode to use in curveXYZ().
%       layer_ajustment : the adjustment to be done to layer 1 to take the
%           first layer height into account
%
% gCodeProcess.m is a heavily modified script based on the script
% gCodeReader.m made by Tom Williamson. The original script can be found
% here : https://www.mathworks.com/matlabcentral/fileexchange/67767-gp-code-reader
%
% Jean-François Chauvette 2019-01-19

% Modes
rapid_positioning = 0;
linear_interpolation = 1;
current_mode = NaN;

% Initialize variables
current_layer = 0;
current_pos = [0,0,0];
last_linear = [];
last_curved = [];
current_extr = 0;
current_fdrt = 0;
subTotExtrLine = 0;
subTotExtrCurv = 0;
resetExtr = 0;    
firstLayerOffset = 0;
interp_pos = [];
interp_extr = [];

% Writing the new processed Gcode file
if ~contains(nom_fic_in,'_flatten')
    filename = [nom_fic_in '_r' num2str(R) '_curved.gcode'];
else
    filename = [nom_fic_in(1:strfind(nom_fic_in,'_flatten')-1) '_curved.gcode'];
end
fid_g = fopen(filename,'Wt');

while ~feof(raw_gcode_file)
    tline = fgetl(raw_gcode_file);
    
    % Check layers to start printing at layer 1
    if ~current_layer
        current_layer = checkCurrentLayer(tline);
    end
    % Check layers to stop printing after end layer
    if current_layer && checkCurrentLayer(tline) == 2
        current_layer = 0;
    end
    
    % Check if its an instruction line
    if tline(1) == 'G' && current_layer && ~contains(tline,'G92')
        tline = tline(1:end);
        splitLine = strsplit(tline,' ');
        for i = 1:length(splitLine)
            % Check what the command is (only the main ones are implemented
            % i.e. G0 - G1)
            if strcmp(splitLine{i}, 'G0')
                current_mode = rapid_positioning;
            elseif strcmp(splitLine{i}, 'G1')
                current_mode = linear_interpolation;
            else
                if splitLine{i}(1) == 'X'     % X coordinate
                    current_pos(1) = str2double(splitLine{i}(2:end));
                elseif splitLine{i}(1) == 'Y' % Y coordinate
                    current_pos(2) = str2double(splitLine{i}(2:end));
                elseif splitLine{i}(1) == 'Z' % Z coordinate
                    current_pos(3) = str2double(splitLine{i}(2:end));
                elseif splitLine{i}(1) == 'E' % Extrusion rate
                    current_extr = str2double(splitLine{i}(2:end));
                elseif splitLine{i}(1) == 'F' % Feed rate
                    current_fdrt = str2double(splitLine{i}(2:end));
                end
            end
            % If G0, G1 have no coordinates but only E or F, the
            % instruction must be printed directly in the new gcode file
            if (strcmp(splitLine{1}, 'G0') || strcmp(splitLine{1}, 'G1')) && (splitLine{2}(1) == 'E' || splitLine{2}(1) == 'F')
                current_mode = NaN;
                % If G1 is instructed with only a E, get the extrusion
                % value
                if (strcmp(splitLine{1}, 'G1') && splitLine{2}(1) == 'E')
                   last_linear(4) = str2double(splitLine{2}(2:end)); 
                   subTotExtrLine = last_linear(4);
                   subTotExtrCurv = last_linear(4);
                end
                break;
            end
        end        
        if(isnan(current_mode))
            fprintf(fid_g, '%s\n', tline);
        end
        % Check the current mode and calculate the next points along the
        % path: linear modes
        if current_mode == linear_interpolation || current_mode == rapid_positioning
            if ~isempty(last_linear)
                dist = norm(current_pos - last_linear(1:3));
                if dist > 0 % If different point, then interpolate
                    % Motion interpolation
                    dire = (current_pos - last_linear(1:3))/dist;
                    interp_pos = last_linear(1:3) + dire.*(0:dist_res:dist)';
                    interp_pos = [interp_pos(2:end,:); current_pos];
                    if size(interp_pos, 1)>1 && all(interp_pos(end,:) == interp_pos(end-1,:)) % If points are repeating themselves, remove the double
                        interp_pos = interp_pos(1:end-1,:);
                    end
                    
                    % Extrusion value
                    interp_extr = [zeros(size(interp_pos,1)-1,1); current_extr];
                    
                    % Feedrate value
                    interp_fdrt = [current_fdrt; zeros(size(interp_pos,1)-1,1)];
                end
            else
                interp_pos = current_pos;
                interp_extr = current_extr;
                interp_fdrt = current_fdrt;
            end
        end
        % G-code reconstruction 
        if ~isnan(current_mode)
            nextCoord = interp_pos;
            
            % Offsetting and curving the coordinates
            nextCoord = [nextCoord(:,1)-offset(1) nextCoord(:,2)-offset(2) nextCoord(:,3)]; % Offset flatten path to slicer origin
            curvedCoord = curveXYZ(nextCoord,R,curve_mode); 
            
            % Repositionning of the coordinates
            nextCoord = [nextCoord(:,1)+offset(1) nextCoord(:,2)+offset(2) nextCoord(:,3:end)]; % Offset flatten path to original position
            curvedCoord = [curvedCoord(:,1)+offset(1) curvedCoord(:,2)+offset(2) curvedCoord(:,3:end)]; % Offset new path to original position         
            
            % First layer adjustment if needed (firstLayerOffset = 0 by default)
            curvedCoord(:,3) = curvedCoord(:,3) + firstLayerOffset * ones(size(curvedCoord,1),1); 
                        
            % Extrusion adjustments
            nextCoord = [nextCoord, interp_extr];
            curvedCoord = [curvedCoord, interp_extr, interp_fdrt];
            if ~isempty(last_curved)
                extr = nextCoord(end,4)-last_linear(4); % Get the total delta linear extrusion amount to the next point
                if extr<0 || resetExtr % If the delta extrusion is negative, then start from zero to the next amount
                    extr = nextCoord(end,4);
                end
                % If G1 is instructed with F but no E, then reset the
                % extrusion value to 0
                if (contains(tline,'G1') && contains(tline,'F') && ~contains(tline,'E'))
                    extr = 0;
                    subTotExtrLine = 0;
                    subTotExtrCurv = 0;
                end
                distLineTot = norm(nextCoord(end,1:3)-last_linear(1:3)); % Distance of linear path between two initial points (not taking into account any interpolated points)
                nbCoord = size(curvedCoord,1); % Number of points (including existant and extrapolated) to calculate the new extrusion for
                for i = 1:1:nbCoord % For every point, calculate the new extrusion amount
                    if(i>1) % For all the points above the first position, compute with the coordinate right before
                        dDistLine = norm(nextCoord(i,1:3)-nextCoord(i-1,1:3));
                        dDistCurv = norm(curvedCoord(i,1:3)-curvedCoord(i-1,1:3));
                    else % For the point on the first position, compute with the last coordinate from the toolpath
                        dDistLine = norm(nextCoord(1,1:3)-last_linear(1:3));
                        dDistCurv = norm(curvedCoord(1,1:3)-last_curved(1:3));
                    end
                    delta = dDistLine/distLineTot * extr; % New extrusion delta value between two linear points
                    subTotExtrLine = subTotExtrLine + delta; % New subtotal at the point for linear path
                    nextCoord(i,4) = subTotExtrLine;
                    subTotExtrCurv = subTotExtrCurv + delta * dDistCurv/dDistLine; % New subtotal at the point for curved path 
                    curvedCoord(i,4) = subTotExtrCurv;
                end
                resetExtr = 0;   
            end
                        
            % Setting the last curved coordinate 
            last_curved = curvedCoord(end,:);
            
            % Reset values for computation 
            last_linear = nextCoord(end,:);
            current_extr = 0;
            current_fdrt = 0;
            
            % gcode reconstruction
            for i=1:1:size(curvedCoord,1)
                % Construction of gcode line and appending to gcode cell set
                gline = splitLine{1}; % G0, G1, ...
                gline = [gline ' X' sprintf('%.4f',curvedCoord(i,1))];%-offset(1))]; % X
                gline = [gline ' Y' sprintf('%.4f',curvedCoord(i,2))];%-offset(2))]; % Y
                gline = [gline ' Z' sprintf('%.4f',curvedCoord(i,3))];%+offset(3))]; % Z
                if curvedCoord(i,4)>0
                    gline = [gline ' E' sprintf('%.4f',curvedCoord(i,4))]; % E
                end
                if curvedCoord(i,5)>0
                    gline = [gline ' F' sprintf('%.0f',curvedCoord(i,5))]; % F
                end
                fprintf(fid_g, '%s\n', gline); % Prints the line into the new G-code file
            end
        end
    else
        % If tline captures an outer/inner perimeter or solid layer, reset
        % the subtotal of the extrusion interpolation
        if(contains(tline,'G92') || contains(tline,'outer perimeter') || contains(tline,'inner perimeter') || contains(tline,'solid layer') || contains(tline,'infill') || contains(tline,'support'))
            subTotExtrLine = 0;
            subTotExtrCurv = 0;
            resetExtr = 1;
        end
        
        % If tline contains no instructions, then print directly into the new gcode file
        if(contains(tline,'; layer') && contains(tline,','))
            layerNum = tline(3:strfind(tline,',')-1);
            fprintf('Reading %s\n',layerNum);
        end
        
        % Layer 1 offset : in the rare occasion that the layer is distanced
        % from the others following the curvature
        if contains(tline,'; layer 1,')    
            firstLayerOffset = layer_ajustment;
        elseif contains(tline,'; layer 2,') 
            firstLayerOffset = 0;
        end
        
        fprintf(fid_g, '%s\n', tline);
    end
    current_mode = NaN;
end

% Closing the files
fclose(raw_gcode_file);
fclose(fid_g);
end