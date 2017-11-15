function [bd,face_W] = face2body(I,fd,tscale)

%define area to search the tag
%Defualt
%width = 7/3 * faceWidth 
%hight = 7/2 * faceHight

if nargin < 3
    tscale = [7/2 7/3]; %[height width] * face_W
end




bd = [];
face_W = [];
L = (tscale(2) - 1)/2;

for ii = 1:size(fd,1)
    face_h = fd(ii,2) - fd(ii,1);
    face_w = face_h;
    t_minRow = fix(max(fd(ii,2) + face_h/2,1));
    t_maxRow = fix(min(t_minRow + tscale(1)*face_h,size(I,1)));
    t_minCol = fix(max(fd(ii,3) - face_w*L,1));
    t_maxCol = fix(min(t_minCol + face_w*tscale(2),size(I,2)));
    bd = [bd;t_minRow t_maxRow t_minCol t_maxCol];
    face_W = [face_W;face_w];
end



if isempty(fd)
    [m,n,z] = size(I);
    t_minRow = fix(0.25*m);
    t_maxRow = fix(0.75*m);
    t_minCol = fix(0.25*n);
    t_maxCol = fix(0.75*n);
    face_W = fix((t_maxRow - t_minRow)/4.5);
    bd = [t_minRow t_maxRow t_minCol t_maxCol];
end
