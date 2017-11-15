function [IM2OCR_RGB,charsBB_tilt] = prepTagImage(I,rows,cols,bodyArea,winCand,charsP,charsN,slope,winIndex)




% prepare the plate (RBN) image
winCand(1) = max(winCand(1),1);
winCand(2) = min(winCand(2),size(bodyArea,1));
winCand(3) = max(winCand(3),1);
winCand(4) = min(winCand(4),size(bodyArea,2));
tagImg = bodyArea(winCand(1):winCand(2),winCand(3):winCand(4),:);


cand_W = winCand(4)-winCand(3);
cand_H = winCand(2)-winCand(1);
wC = [winCand(1:2)+rows(1),winCand(3:4)+cols(1)];
rows2 = max(1,wC(1)-fix(cand_H/4)):min(size(I,1),wC(2)+fix(cand_H/4));
cols2 = max(1,wC(3)-fix(cand_W/4)):min(size(I,2),wC(4)+fix(cand_W/4));
tagArea = I(rows2,cols2,:);


% tilt/rotation correction
if (abs(slope(winIndex)) > 0.04)
    ang = atan(slope(winIndex));
    t_mat = [cos(ang) -sin(ang) 0;sin(ang) cos(ang) 0;0 0 1];
    tfm=fliptform(maketform('affine', t_mat'));
    [tagAreaTilt, Xdata, Ydata]=imtransform(tagArea, tfm, 'bilinear');
    [charsBB_tilt,p] = tfmCharsBoundingBox(charsP{winIndex},charsN{winIndex},size(tagAreaTilt),[cand_H/4 cand_W/4],t_mat,Xdata,Ydata,tagAreaTilt,tagArea);
    IM2OCR_RGB = tagAreaTilt(p(1):p(2),p(3):p(4),:);
else
    [charsBB_tilt,p] = tfmCharsBoundingBox(charsP{winIndex},charsN{winIndex},size(tagImg),[0 0],eye(3),[1 1],[1 1]);
    IM2OCR_RGB = tagImg;
end