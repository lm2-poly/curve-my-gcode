function userInput = validUserInput(sentence,type,varargin)
% validUserInput
% Last updated : 2020-06-05
%
% Description : This function ask the user a choice of answer related to
% the sentenced passed in the parameter sentence. The valid choices can be
% multiple or single and are contained in the vararagin cell. The function
% keeps asking the input if it is invalid.
%
% Inputs:
%       sentence : the question asked to the user.
%       type     : validation type
%                   0 : choice of answers (strings)
%                   1 : positive numeric
%       varargin : the choices of valid answers.
%       
% Outputs:
%       userInput : the valid user input.
%
% Author: Jean-François Chauvette
% Date: 2019-01-19

userInput = input(sentence,'s');

if type == 0
    while ~any(strcmpi(varargin,userInput))
        userInput = input(['Invalid choice\n' sentence],'s');
    end
elseif type == 1
    temp = str2num(userInput); %#ok<ST2NM>
    while any(isnan(temp) | temp<0)
        userInput = input(['Input must be positive numeric\n' sentence],'s');
        temp = str2num(userInput); %#ok<ST2NM>
    end 
    userInput = temp;
end

end

