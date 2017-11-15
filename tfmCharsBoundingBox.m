function [cBB,p] = tfmCharsBoundingBox(charsP,charsN,maxSize,pad,t_mat,Xdata,Ydata,tagAreaTilt,tagArea);

% C = charsBB;
% 
r_shift = min(charsP(:,1)) - fix(pad(1));
c_shift = min(charsP(:,2)) - fix(pad(2));
charsP(:,1) = charsP(:,1) - r_shift;
charsP(:,2) = charsP(:,2) - c_shift;
% P1 = [C(:,1)-r_shift C(:,3)-c_shift ones(size(C,1),1)];
% P2 = [C(:,2)-r_shift C(:,4)-c_shift ones(size(C,1),1)];
si = 0;
for ii = 1:length(charsN)
    P = [charsP(si+1:si+charsN(ii),:) ones(charsN(ii),1)];
    Q = P*t_mat';
    minR(ii) = min(Q(:,1));
    maxR(ii) = max(Q(:,1));
    minC(ii) = min(Q(:,2));
    maxC(ii) = max(Q(:,2));   

    si = si + charsN(ii);
end
cBB = [minR'-(Ydata(1)-1) maxR'-(Ydata(1)-1) minC'-(Xdata(1)-1) maxC'-(Xdata(1)-1)];
cBB = round(cBB);
% Pt2 = P2*t_mat';

% Q1 = [C(:,1)-r_shift C(:,4)-c_shift ones(size(C,1),1)];
% Q2 = [C(:,2)-r_shift C(:,3)-c_shift ones(size(C,1),1)];
% 
% Qt1 = Q1*t_mat';
% Qt2 = Q2*t_mat';

% cBB_P = [Pt1(:,1)-(Ydata(1)-1) Pt2(:,1)-(Ydata(1)-1) Pt1(:,2)-(Xdata(1)-1) Pt2(:,2)-(Xdata(1)-1)];
% cBB_Q = [Qt1(:,1)-(Ydata(1)-1) Qt2(:,1)-(Ydata(1)-1) Qt2(:,2)-(Xdata(1)-1) Qt1(:,2)-(Xdata(1)-1)];
% cBB = (cBB_P + cBB_Q)/2;
% cBB = round(cBB);
% cBB(:,1) = fix(cBB(:,1));
% cBB(:,3) = fix(cBB(:,3));
% cBB(:,2) = ceil(cBB(:,2));
% cBB(:,4) = ceil(cBB(:,4));

for k = 1:size(cBB,1)
    cBB(k,1) = max(cBB(k,1),1);
    cBB(k,2) = min(cBB(k,2),maxSize(1));
    cBB(k,3) = max(cBB(k,3),1);
    cBB(k,4) = min(cBB(k,4),maxSize(2));
end

p = [min(cBB(:,1)) max(cBB(:,2)) min(cBB(:,3)) max(cBB(:,4))];