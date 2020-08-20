function [vp,np] = flattenSTL(v,n,R)
% flattenSTL
% Last updated : 2019-02-04
%
% Description : This function flattens the coordinates inside the variable
% v and the normals of the vertices inside the variable v over a plane
% according to the provided radius R. The flattening always happend around
% the origin of the datum coordinate system (0,0,0).
%
% Inputs:
%       v : the curved coordinates.
%       n : the normal of the vertices formed by the coordinates.
%       R : the radius from which to flatten the path.
%       
% Outputs:
%       vp : the planar coordinates.
%       np : the normals corresponding the the planar coordinates.
%
% Jean-François Chauvette 2019-01-19

Rv = R*ones(size(v,1),1); % Radius column vector for the vertices
Rn = R*ones(size(n,1),1); % Radius column vector for the normals

% Y PRIME
vp(:,2) = v(:,2);
np(:,2) = n(:,2);

% Alpha
av = atan(v(:,1)./abs(Rv - v(:,3)));
an = atan(n(:,1)./abs(Rn - n(:,3)));

% X PRIME
vp(:,1) = R*av;
np(:,1) = R*an;

% Z PRIME
vp(:,3) = Rv - sqrt(v(:,1).^2 + (Rv - v(:,3)).^2);
np(:,3) = Rn - sqrt(n(:,1).^2 + (Rn - n(:,3)).^2);
