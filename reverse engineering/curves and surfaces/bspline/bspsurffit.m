function [varargout]=bspsurffit(P,u,w,ncpu,ncpw,ku,kw,nnpu,nnpw)
% P is a set of surface points in a 3D Cartesian coordinate system
% u is parameters in u-direction;
% w is parameters in w-direction;
% ncp is number of control points in u direction
% ncpw is number of control points in w direction
% nnpu is number of fitted points in u direction
% nnpw is number of fitted points in w direction

QX = P(:,1);
QY = P(:,2);
QZ = P(:,3);
npoints = numel(QX);

%% U direction
nosu = ncpu-ku+1; % number of segments

% make sure the last u value equals the number of segments
umax = max(u);
if umax ~= nosu
    u = u / umax * nosu;
end

knotVu = bspknot(ncpu, ku);
U = bspbasis(u, ncpu, ku, knotVu);

%% W direction
nosw = ncpw-kw+1; % number of segments

% make sure the last w value equals the number of segments
wmax = max(w);
if wmax ~= nosw
    w = w / wmax * nosw;
end

[knotVw] = bspknot(ncpw, kw);
W = bspbasis(w, ncpw, kw, knotVw);
W = W';

%% Control points
% repeat each U value by number of control points in w in dim2
UU = kron(U,ones(1,ncpw));
% repeat each W value by number of control poitns in w in dim1
WW = repmat(W,ncpu,1)';

UW = UU.*WW;

% Calculate the control points
CX=UW\QX;
CY=UW\QY;
CZ=UW\QZ;

% Rearrange the control points into matrix form
CXX = reshape(CX,ncpw,ncpu)';
CYY = reshape(CY,ncpw,ncpu)';
CZZ = reshape(CZ,ncpw,ncpu)';

%% Generate new points and output
if nargout == 2
    % generate uniform u,w for fitting.
    ufit = linspace(0,nosu,nnpu);
    wfit = linspace(0,nosw,nnpw);

    Ufit = bspbasis(ufit, ncpu, ku, knotVu);
    Wfit = bspbasis(wfit, ncpw, kw, knotVw);

    FX = Ufit*CXX*Wfit';
    FY = Ufit*CYY*Wfit';
    FZ = Ufit*CZZ*Wfit';

    varargout{1} = [FX(:), FY(:), FZ(:)];
    bsp.x = FX; bsp.y = FY; bsp.z = FZ;
    bsp.cx = CXX; bsp.cy = CYY; bsp.cz = CZZ;
    bsp.knotu = knotVu; bsp.knotw = knotVw;
    varargout{2} = bsp;
else
    bsp.cx = CXX; bsp.cy = CYY; bsp.cz = CZZ;
    bsp.knotu = knotVu; bsp.knotw = knotVw;
    varargout{1} = bsp;
end