function [v] = curveXYZ(vp,R,dir)
% curvePath
% Last updated : 2019-02-04
%
% Description : This function curves the coordinates inside the variable vp
% over a cylindar according to the provided radius R. The curving always
% happend around the origin of the datum coordinate system (0,0,0) in the Z direction.
%
% Inputs:
%       vp : the planar coordinates.
%       R : the radius with which to curve the path.
%       dir : direction in which to apply the curve. 
%           0 = X
%           1 = Y
%           2 = Both direction
%       
% Outputs:
%       v : the curved coordinates.
%
% Jean-François Chauvette 2019-01-19

Rv = R*ones(size(vp,1),1); % Radius column vector

% Alpha
a = vp(:,1)./R;
a2 = vp(:,2)./R;

% X 
if dir == 0 || dir == 2
    v(:,1) = tan(a).*abs(cos(a)).*(Rv - vp(:,3));
    Xeffect = Rv - abs(cos(a)).*(Rv - vp(:,3));
elseif dir == 1
    Xeffect = 0;
    v(:,1) = vp(:,1);
end    

% Y 
if dir == 0
    v(:,2) = vp(:,2);
    Yeffect = 0;
elseif dir == 1 || dir == 2
    v(:,2) = tan(a2).*abs(cos(a2)).*(Rv - vp(:,3));
    Yeffect = Rv - abs(cos(a2)).*(Rv - vp(:,3));
end

% Z 
v(:,3) = Xeffect + Yeffect;

% Rv = R*ones(size(vp,1),1); % Radius column vector
% 
% % Alpha
% a = vp(:,1)./R;
% a2 = vp(:,2)./R;
% 
% % X 
% if dir == 0 || dir == 2
%     v(:,1) = abs(tan(a)).*abs(cos(a)).*(Rv - vp(:,2));
%     Xeffect = Rv - abs(cos(a)).*(Rv - vp(:,2));
% elseif dir == 1
%     Xeffect = 0;
%     v(:,3) = vp(:,3);
% end    
% 
% % Y 
% if dir == 0
%     v(:,3) = vp(:,3);
%     Yeffect = 0;
% elseif dir == 1 || dir == 2
%     v(:,2) = abs(tan(a2)).*abs(cos(a2)).*(Rv - vp(:,1));
%     Yeffect = Rv - abs(cos(a2)).*(Rv - vp(:,1));
% end
% 
% % X or Y
% if dir == 0
%     v(:,2) = Xeffect + Yeffect;
% elseif dir == 1
%     v(:,1) = Xeffect + Yeffect;
% end

% Z offset functions
% for i = 1:size(v,1)
% %     v(i,3) = v(i,3) + 5*sin(v(i,2)./5) + 20;
% %     v(i,3) = v(i,3) + 20*(v(i,2)./50)^2;
% %     v(i,3) = v(i,3) + sqrt(80^2 - v(i,2).^2);
% end
