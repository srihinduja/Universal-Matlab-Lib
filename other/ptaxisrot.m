function R = ptaxisrot (varargin)
%PTAXISROT calculates a homogeneous transformation matrix for a rotation in
% 3D about a given axis by a specified angle.
%
% R = ptaxisrot (V, A) calculates a homogeneous transformation matrix R
% through angle A about an axis in the direction of V. A is in radians.
%
% R = ptaxisrot (V, P, A) The axis of rotation is defined by the direction
% of V and a point P.
%
% R = ptaxisrot (...,'Degree') accepts A in degrees.
%
% R = ptaxisrot (..., 'NonHom') returns a non-homogeneous matrix. If used
% when P is defined, translation is not integrated in the matrix.
%
% ================
% Example: 
% Rotate a 3D point set P by 90 degrees about a line defined by direction 
% vector [0.5774 0.5774 0.5774] and a point [5 5 5].
%
% R = ptaxisrot([0.5774 0.5774 0.5774], [5 5 5], pi); 
% P_transformed = [P ones(size(P,1),1)] * R;
% ================ 
%
% required file: VECROTMAT
%
% by Zhengyi Jiang, University of Manchester, 2017

if nargin < 2
    error('Not enough input arguments.');
end

if nargin > 5
    error('Too many input arguments.');
end

v = varargin{1}; 

if nargin == 2 || ~isnumeric(varargin{3})
    % P is not supplied
    p = [0 0 0];
    a = varargin{2};
else
    p = varargin{2};
    a = varargin{3};
end

isHom = true;

if nargin >= 3
    for i = 3:nargin
        if ~ischar(varargin{i})
            continue;
        end
        
        if strcmp(varargin{i}, 'Degree')
            a = a*pi/180;
        elseif strcmp(varargin{i}, 'NonHom')
            isHom = false;
        else
            error('Invalid parameter ''%s''. The only valid parameter is ''Degree''.', s);
        end
    end
end

% normalise the direction vector in case it hasn't been done yet
v = v(:)/norm(v);
p = p(:);

% Rodrigues' rotation formula
% calculate K
K = [0 -v(3) v(2); v(3) 0 -v(1); -v(2) v(1) 0];
R = eye(3) + sin(a) * K + (1-cos(a)) * K^2;

if isHom
    R = tmat2hom(R);
    % calculate translation
    T = eye(4); T(4,1:3) = -p;
    R = T*R*T^-1; 
end

% below is preserved for reference only
% similar to the derivation of Rodrigues's rotation.
% % transform axis to x-axis
% r = vecrotmat(p, v+p, [0 0 0], [1 0 0]);
% 
% % rotation matrix about x
% rx = [1 0 0 0; 0 cos(a) sin(a) 0; 0 -sin(a) cos(a) 0; 0 0 0 1];
% 
% R = r * rx * r^-1; 