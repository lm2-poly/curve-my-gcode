function tot = normTot(A)
% normTot
% Last updated : 2019-02-04
%
% Description : This function calculates the norm of a path 'A' by adding
% the norm of every segment it contains, one by one. This make the
% calculation of the length of an curved path, approximated by segments,
% possible.
%
% Inputs:
%       A : the path of unknown length.
%       
% Outputs:
%       tot : the total path length.
%
% Jean-François Chauvette 2019-01-19

tot = 0;
for i = 2:1:size(A,1)
    tot = tot + norm(A(i,1:3)-A(i-1,1:3));
end
end

