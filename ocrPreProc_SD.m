function [IM,BW_N] = ocrPreProc_SD(IM_RGB,binaryThrType,resizeFactor,P,RBNparam,charsBB_tilt,charsCLR,medStroke)


% separate the digits
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

% upscale
if resizeFactor > 1
    IM_RGB = imresize(IM_RGB,resizeFactor,'bilinear');
    charsBB_tilt = charsBB_tilt*2;
end

% hsv transform
if strcmp(binaryThrType,'hsv')
    IM_HSV = rgb2hsv(IM_RGB);
end

% gray level trasform
fullTagProc = 0;
if strcmp(binaryThrType,'gray')
    IM_GRAY = rgb2gray(IM_RGB);
    fullTagProc = 1;
end


%keep only the digits bounding box
minR = min(charsBB_tilt(:,1));
minC = min(charsBB_tilt(:,3));
charsBB_tilt(:,1) = min(charsBB_tilt(:,1) - minR + 1,size(IM_RGB,1));
charsBB_tilt(:,2) = min(charsBB_tilt(:,2) - minR + 2,size(IM_RGB,1));
charsBB_tilt(:,3) = min(charsBB_tilt(:,3) - minC + 1,size(IM_RGB,2));
charsBB_tilt(:,4) = min(charsBB_tilt(:,4) - minC + 2,size(IM_RGB,2));

%min/max row & col of each char (digit)
minRow = charsBB_tilt(:,1);
maxRow = charsBB_tilt(:,2);
minCol = charsBB_tilt(:,3);
maxCol = charsBB_tilt(:,4);

% average RGB color of each char as taken from swt analysis
avgRGB = charsCLR(:,1:3);
b_avgRGB = charsCLR(:,4:6);

% average HSV 
avgHSV = charsCLR(:,7:9);
b_avgHSV = charsCLR(:,10:12);

% average gray level as taken from swt analysis
avgGRAY = charsCLR(:,13);
b_avgGRAY = charsCLR(:,14);



% loop all of the extracted components from SWT 
[r,c,z] = size(IM_RGB);
BW = zeros(r,c);
BW_new = [];
N = size(charsBB_tilt,1);

for cc = 1:N
    
    %ignore "noise" objects (small components)
    % if height is less than 1/2 of the plate
    % or narrow component at the edge of the tag
    if (maxRow(cc) < size(BW,1)/2) || ...
            minRow(cc) > size(BW,1)/1.8 || ...
            minCol(cc) > size(BW,2) - RBNparam.preProc_strokeForHighThr - 1 || ...
            maxCol(cc) < RBNparam.preProc_strokeForHighThr + 1

        continue;
    end
    
    %initial separation according to swt components
    %mark the most right coloumn of the char
   if cc == N
       maxcol = size(IM_RGB,2);
   else
       maxcol = minCol(cc+1)-1;
   end
   
   %extract the rows & cols of the char  
    cols = minCol(cc):maxcol; rows = 1:size(IM_RGB,1);

%     %back ground average color
%     b_avgRGB(cc,1) = mean2(IM_RGB(rows,cols,1));
%     b_avgRGB(cc,2) = mean2(IM_RGB(rows,cols,2));
%     b_avgRGB(cc,3) = mean2(IM_RGB(rows,cols,3));
  

    
    if strcmp(binaryThrType,'rgb')

        IM_R = IM_RGB(rows,cols,1);
        IM_G = IM_RGB(rows,cols,2);
        IM_B = IM_RGB(rows,cols,3);
        
        %low binary threshold - distance from average color         
        t = RBNparam.preProc_lowThreshold;
        
        % for small/thin components we allow higher threshold (higher 
        % distance from average) since the calculated average color is not
        % accurate enough 
        if length(rows)/resizeFactor < RBNparam.preProc_nofRowsForHighThr && medStroke < RBNparam.preProc_strokeForHighThr
            t = RBNparam.preProc_highThreshold;
        end
                

        % for each pixel:
        % 1 if pixel's color close enough to the average color
        % 0 otherwise
        BW_new(rows,cols) = (abs(IM_G - avgRGB(cc,2)) + abs(IM_R - avgRGB(cc,1)) + abs(IM_B - avgRGB(cc,3))) < t ;

    end

    

    


% 2 more options for binary conv.
% here we use one color for binary conversion. we set threshold to half
% distance between background and foreground color. darker pixels are
% marked as 1.
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


BW_N = BW_new;


    
% if binary image empty, return RGB 
if isempty(BW_new)
    IM = IM_RGB;
    return;
end

% clean rows with less than 10% white pixels
if ~fullTagProc
    for rr=1:size(BW_new,1)
        if size(BW_new,2) - sum(BW_new(rr,:)) < round(size(BW_new,2)/10)
            BW_new(rr,:) = 0;
        end
    end
end

% connected components
maxH = 0;
BW = BW_new;
[L,CCnum] = bwlabeln(BW);

% clear noise components
for cc = 1:CCnum

    % remove small components at the edge of the image
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


if fullTagProc
    IM = BW;
    return;
end

% orientation alighnment
[L,CCnum] = bwlabeln(BW);
IM = cell(0);
if CCnum > 0
    
        for cc = 1:CCnum
            IM{cc} = (L==cc);
        end
        
        
        % orientation alighnment
        
        % if small/thin components we do not preform orientation fix since
        % result image can be blurred or twisted.
            if size(BW,1)/resizeFactor < RBNparam.preProc_nofRowsForHighThr || medStroke <= RBNparam.preProc_strokeForHighThr
   
                

        
            else
    
        for cc = 1:CCnum
            
            % find orientation according to eclipse second order approx.
            aa = regionprops((L==cc),'Orientation');
            a(cc) = aa.Orientation;
            B = (L==cc);
            bb = regionprops((L==cc),'BoundingBox'); 
            b = round(bb.BoundingBox);
            BB = B(b(2):b(2)+b(4)-1,b(1):b(1)+b(3)-1);
            
            % we limit rotation fix to small angles (~10-20 deg.); larger 
            % angles are likely to be errors.
            % we also limit it to digits wider than twice stroke size - 
            % orientation of thiner digits may not be estimated well, for 
            % example the digit 1 can be problematic in this case.
            % 
            if abs(90-abs(a(cc))) < RBNparam.preProc_maxOrientFixAngle && size(BB,2) >= 2*medStroke
                IM{cc} = imrotate(BB,sign(a(cc))*(90-abs(a(cc))),'bilinear');
            else
%                IM{cc} = BB;
            end
        end
        
            end

else
    IM{1} = BW;
end
