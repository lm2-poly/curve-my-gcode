function gCodeReader(filePath)
%gCodeReader  Function that takes a G-Code file and plots the tool path 
% Tom Williamson
% 18/06/2018

raw_gcode_file = fopen(filePath);
while raw_gcode_file<0
    filePath = input('File does not exist\nFile name (with extension) : ','s');
    raw_gcode_file=fopen(filePath);
end
fprintf('Reading %s...\n', filePath);
% Initialize variables
current_pos = [0,0,0];
toolPath = [];
current_layer = 0;

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
    if tline(1) == 'G' && current_layer
        tline = tline(1:end);
        splitLine = strsplit(tline,' ');
        for i = 1:length(splitLine)
            if splitLine{i}(1) == 'X'
                current_pos(1) = str2num(splitLine{i}(2:end));
            elseif splitLine{i}(1) == 'Y'
                current_pos(2) = str2num(splitLine{i}(2:end));
            elseif splitLine{i}(1) == 'Z'
                current_pos(3) = str2num(splitLine{i}(2:end));
            end
        end
        toolPath = [toolPath;current_pos(1) current_pos(2) current_pos(3)];
    else
        if(contains(tline,'; layer') && contains(tline,','))
            fprintf('Reading %s\n',tline(3:strfind(tline,',')-1));
        end
    end
end

% Plot & close file
plot3(toolPath(:,1),toolPath(:,2),toolPath(:,3),'r-');
xlabel('X');
ylabel('Y');
zlabel('Z');
axis equal;
fclose(raw_gcode_file);
end