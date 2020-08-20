function compareCurves(A,B)
% compareCurves
% Last updated : 2019-02-04
%
% Description : This function Compares two paths given as a vector and 3D
% plots them for debugging purposes.
%
% Inputs:
%       A : the first path.
%       B : the second path.
%       
% Outputs:
%       none.
%
% Jean-François Chauvette 2019-01-19

plot3(A(:,1),A(:,2),A(:,3),'r-*');
hold on; 
plot3(B(:,1),B(:,2),B(:,3),'b-*');
axis equal;
end

