function IM = ocrPreProc(IM_RGB,binaryThrType,resizeFactor,P,RBNparam,charsBB_tilt,charsCLR)


% convert to binary


% clean non-digits components
%
%
% Defaults:
% RBNparam.preProc_lowThreshold = 50;
% RBNparam.preProc_highThreshold = 70;
% RBNparam.preProc_nofRowsForHighThr = 20;
% RBNparam.preProc_strokeForHighThr = 4;
% RBNparam.preProc_maxOrientFixAngle = 10;

if resizeFactor > 1
    IM_RGB = imresize(IM_RGB,resizeFactor,'bilinear');
    charsBB_tilt = charsBB_tilt*2;
end

if strcmp(binaryThrType,'hsv')
    IM_HSV = rgb2hsv(IM_RGB);
end

if strcmp(binaryThrType,'gray')
    IM_GRAY = rgb2gray(IM_RGB);
end


%keep only the digits bounding box
minR = min(charsBB_tilt(:,1));
minC = min(charsBB_tilt(:,3));
charsBB_tilt(:,1) = min(charsBB_tilt(:,1) - minR + 1,size(IM_RGB,1));
charsBB_tilt(:,2) = min(charsBB_tilt(:,2) - minR + 2,size(IM_RGB,1));
charsBB_tilt(:,3) = min(charsBB_tilt(:,3) - minC + 1,size(IM_RGB,2));
charsBB_tilt(:,4) = min(charsBB_tilt(:,4) - minC + 2,size(IM_RGB,2));

minRow = charsBB_tilt(:,1);
maxRow = charsBB_tilt(:,2);
minCol = charsBB_tilt(:,3);
maxCol = charsBB_tilt(:,4);
avgRGB = charsCLR(:,1:3);
b_avgRGB = charsCLR(:,4:6);
avgHSV = charsCLR(:,7:9);
b_avgHSV = charsCLR(:,10:12);
avgGRAY = charsCLR(:,13);
b_avgGRAY = charsCLR(:,14);



%remove all objects exept the digits
[r,c,z] = size(IM_RGB);
BW = zeros(r,c);
BW_new = [];
%BW_new = zeros(r,c);
N = size(charsBB_tilt,1);

for cc = 1:N
    if (maxRow(cc) < size(BW,1)/2) || ...
            minRow(cc) > size(BW,1)/1.8 || ...
            minCol(cc) > size(BW,2) - RBNparam.preProc_strokeForHighThr - 1 || ...
            maxCol(cc) < RBNparam.preProc_strokeForHighThr + 1


        continue;
    end
    
   if cc == N
       maxcol = size(IM_RGB,2);
   else
       maxcol = minCol(cc+1)-1;
   end
    cols = minCol(cc):maxcol; rows = 1:size(IM_RGB,1);

%     b_avgRGB(cc,1) = mean2(IM_RGB(rows,cols,1));
%     b_avgRGB(cc,2) = mean2(IM_RGB(rows,cols,2));
%     b_avgRGB(cc,3) = mean2(IM_RGB(rows,cols,3));
    
    if strcmp(binaryThrType,'rgb')
%         IM_RGB = im2double(IM_RGB);
        IM_R = IM_RGB(rows,cols,1);
        IM_G = IM_RGB(rows,cols,2);
        IM_B = IM_RGB(rows,cols,3);
        
        %apply binary threshold
        t = 100;
        BW_new(rows,cols) = (abs(IM_G - avgRGB(cc,2)) + abs(IM_R - avgRGB(cc,1)) + abs(IM_B - avgRGB(cc,3))) < t ;
                            %(abs(IM_G - b_avgRGB(cc,2)) + abs(IM_R - b_avgRGB(cc,1)) + abs(IM_B - b_avgRGB(cc,3))) > t/50;
    end


    

    if strcmp(binaryThrType,'hsv')
        idx=3;
        
        %calculate threshold
        t = avgHSV(cc,idx) + (b_avgHSV(cc,idx) - avgHSV(cc,idx))/2;

        %apply binary threshold
        BW_new(rows,cols) = IM_HSV(rows,cols,idx) < t;    
    end

    
    if strcmp(binaryThrType,'gray')
        idx = 1;
        
        %calculate threshold
        t = avgGRAY(cc,idx) + (b_avgGRAY(cc,idx) - avgGRAY(cc,idx))/2;

        %apply binary threshold
        BW_new(rows,cols) = IM_GRAY(rows,cols,idx) < t;    
    end
    
end





    
% if binary image empty, return RGB 
if isempty(BW_new)
    IM = IM_RGB;
    return;
end

% connected components
maxH = 0;
BW = BW_new;
[L,CCnum] = bwlabeln(BW);
for cc = 1:CCnum
    [CCr,CCc] = find(L==cc);
    if (max(CCr) < size(BW,1)/2) || ...
            min(CCr) > size(BW,1)/2 || ...
            min(CCc) > size(BW,2) - RBNparam.preProc_strokeForHighThr - 1 || ...
            max(CCc) < RBNparam.preProc_strokeForHighThr + 1
        
        BW(L==cc) = 0;
    else
        maxH = max(maxH,max(CCr)-min(CCr));
    end
    clear CCr CCc
end

% remove components with half hieght of the maximum
for cc = 1:CCnum
    [CCr,CCc] = find(L==cc);
    if maxH/2 >= (max(CCr)-min(CCr))
        BW(L==cc) = 0;
    end
    clear CCr CCc
end


    IM = BW;

