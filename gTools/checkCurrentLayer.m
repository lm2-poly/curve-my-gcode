function currentLayer = checkCurrentLayer(tline)
% checkCurrentLayer
% Last updated : 2019-02-04
%
% Description : This function checks which layer is being read by the
% function gCodeProcess.
%
% Inputs:
%       tline : the line read from the G-code file.
%       
% Outputs:
%       currentLayer : 1 = layer 1, 2 = end layer, 0 = all other layers.
%
% Jean-François Chauvette 2019-01-19

currentLayer = 0;
if contains(tline,'layer 1')
    currentLayer = 1;
elseif contains(tline,'layer end')
    currentLayer = 2;
end
end

