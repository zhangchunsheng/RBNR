function P = prepSwtParam(face_W,Pin,faceSzUpscaleTbl, faceMaxStrkTbl, faceMaxFontTbl)


P = Pin;

% defaults
if nargin < 3
    faceMaxStrkTbl = [75 -11; 97 -12; 120 -14; 150 -18];
    faceMaxFontTbl = [150 120];
    faceSzUpscaleTbl = [70 2];
end



% upscaling swt input image
for kk = 1:size(faceSzUpscaleTbl,1)
    if face_W < faceSzUpscaleTbl(kk,1)
        P.imresizeFactor = faceSzUpscaleTbl(kk,2);
    end
end


% set max stroke
for kk = 1:size(faceMaxStrkTbl,1)
    
    if face_W*P.imresizeFactor > faceMaxStrkTbl(kk,1)
        P.maxWid = faceMaxStrkTbl(kk,2);
    end
    
end


% set max font size
for kk = 1:size(faceMaxFontTbl,1)
    
    if face_W*P.imresizeFactor > faceMaxFontTbl(kk,1)
        P.maxDim = faceMaxFontTbl(kk,2);
    end
    
end