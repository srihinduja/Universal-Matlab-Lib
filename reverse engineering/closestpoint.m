function [ closest_points,mindist,match ] = closestpoint(P, Q, mode)
% Q target point set
% P floating point set
% For each point in P, find its closest point in Q.
% i.e. P covers a smaller area.

if nargin<3
    mode = 1;
end

switch mode
    case 1
        testresult = license('test', 'Statistics_Toolbox');
        
        if testresult == 1
            kdOBJ = KDTreeSearcher(Q);
            [match, mindist] = knnsearch(kdOBJ,P);
            closest_points = Q(match,:);
        else
            [ closest_points,mindist,match ] = match_distance(P,Q);
        end
    case 2
        [ closest_points,mindist,match ] = match_distance(P,Q);
end

function [ closest_points,distance,places] = match_distance(P,Q)
% Q target point set
% P floating point set
[M_m,N_m]=size(P);
[M_s,N_s]=size(Q);

x_surf=Q(:,1);
y_surf=Q(:,2);

if N_s==2
    z_surf=zeros(M_s,1);
else
    z_surf=Q(:,3);
end
x_meas=P(:,1);
y_meas=P(:,2);

if N_m==2
    z_meas=zeros(M_m,1);
else
    z_meas=P(:,3);
end
closest_points=zeros(M_m,N_m);
distance=zeros(M_m,1);
places=zeros(M_m,1);
b_temp_ones = ones(M_s,1);
measP = [x_meas y_meas z_meas];
for i=1:M_m
    b_temp = measP(i,:).*b_temp_ones;
    
    dist=((b_temp(:,1)-x_surf).^2+(b_temp(:,2)-y_surf).^2+(b_temp(:,3)-z_surf).^2).^0.5;
        [fval,I] = min(dist);
        closest_point=[x_surf(I) y_surf(I) z_surf(I)];
        distance(i)=fval;
        closest_points(i,:)=closest_point;
        places(i)=I;
end

function [ mD ] = CalcDistMtx ( mX )
vSsqX = sum(mX .^ 2);
mD = sqrt(bsxfun(@plus, vSsqX.', vSsqX) - (2 * (mX.' * mX)));