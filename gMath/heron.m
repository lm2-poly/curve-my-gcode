function R = heron(pt)
% heron
% Last updated : 2019-02-19
%
% Description : This function computes the radius of the circle passing by
% 3 points. The method uses Heron's formula along with the law of sines.
%
% Inputs:
%       pt : the 3x2 matrix containing the XY coordinates of 3 points.
%       
% Outputs:
%       R : the radius of the circle.
%
% Jean-François Chauvette 2019-01-19

% Heron
a = norm(pt(2,:)-pt(1,:));
b = norm(pt(3,:)-pt(2,:));
c = norm(pt(3,:)-pt(1,:));
p = (a+b+c)/2;
S = sqrt(p*(p-a)*(p-b)*(p-c));

% Sinus law
R = (a*b*c)/(4*S);
end

