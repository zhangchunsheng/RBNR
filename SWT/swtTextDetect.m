function [textFramesTble,charsCLR,medStroke,m,numOfChars,charsBB,charsP,charsN] = swtTextDetect(IMAGE,P,dbg)
%
%
% SWT Text Detection Algorithm
%
% Inputs
% IMAGE  - input image
% P      - parameters struct 
% dbg    - optional debug image plots
%
%
% Outputs
% T              - struct array of the detected text region
% T.boundingBox  - text region bounding box: [minRow maxRox minCol maxCol] 
% T.charsColor   - color of each char (cell)
% T.medStroke    - median stroke width of each char
% T.slope        - slope of each char
% T.numOfChars   - number of chars
% T.charsBB       - bounding box of each char
% T.charsP       - pixels of each char
% T.charsN       - pixel number of each char
% 
% SWT parameters
% ------------------
% maxWid - maximum allowed stroke width of the text
% varAvgRatio - the allowed average/variance ratio of a 'text' component
% aspectRatio - the allowed aspect ratio of text component (height/width)
% widthToSrokeRatio - the allowed fontWidth/SrokeWidth ratio of text
%                       component
% highToStrokeRatio - the allowed fontHeight/SrokeWidth ratio of text
%                       component
% StrokeToMaxHighRatio - the allowed strokeWidth/(maximum component height)
%                       ratio of text component. maximum height is achieved
%                       using rotation of the font component.
% minDim - minimum size of text component (character dimension in pixels).
% maxDim - maximum size of text component (character dimension in pixels).
% condWidthToStroke - keep default 0.
% allowedGradVariation - the allowed gradient direction variation while 
%                           searching the stroke between two edges. if 
%                           the angle between the two gradients is lower
%                           than this parameter, the stroke is valid.
% imresizeFactor - indicates the upscaling factor that is used before swt.
%             if ~= 1 than input image is resized according to this factor.


%%%%%%%%%%%%%%%%
% defualt params
%%%%%%%%%%%%%%%%
if nargin < 2
    %parameters for classification
    P = struct( 'maxWid',-14, ...
                'varAvgRatio',0.5, ...
                'aspectRatio',10, ...
                'widthToSrokeRatio',12, ...
                'highToStrokeRatio',12, ...
                'StrokeToMaxHighRatio',0.8, ...
                'minDim',5,'maxDim',80, ...
                'condWidthToStroke',0, ...
                'allowedGradVariation',pi/2, ...
                'imresizeFactor',1);
end

if nargin < 3
    dbg = 0;
end
    




%%%%%%%%%%%%%%%%
% edge detection
%%%%%%%%%%%%%%%%
Irgb = IMAGE;

%find edges
if P.imresizeFactor ~= 1
    Irgb = imresize(Irgb,P.imresizeFactor,'bilinear');
end

% use the Y component of YCbCr transform 
I = double(rgb2ycbcr(Irgb));
IM = I(:,:,1);

% canny edge detector
E = edge(IM(:,:,1),'canny');

% debug mode
if dbg, figure;imshow(E);title('1. CannyEdgeDetector'), end





%%%%%%%%%%%%%%%%%%%%%%%%
% Stroke width transform
%%%%%%%%%%%%%%%%%%%%%%%%
%calc likely stroke width
[Iy,Ix] = gradient(I(:,:,1));
[W,Wimg] = swt(E,Ix,Iy,P.maxWid);
if dbg, figure;imshow(uint8(Wimg));title('2. Stroke Width Transform'),end
textFramesTble = [];
charsCLR = [];
medStroke = [];
m = [];
numOfChars = [];
charsP = cell(1);charsN = cell(1);charsBB = cell(1);
if ~any(any(W))
    return ;
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% label connected componnets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[L,CCnum] = labelCC(W);





%%%%%%%%%%%%%%%%%%%%%%%%%
% find Latters candidates
%%%%%%%%%%%%%%%%%%%%%%%%%
[cand, BB, med, cent, avgRGB,...
    b_avgRGB,avgHSV,b_avgHSV,avgGRAY,b_avgGRAY] = findLetterCand(L,CCnum,W,Irgb,P);

%plot the candidate CCs
LL = zeros(size(L));
for cc = cand, LL = LL + (L==cc); end
if dbg,figure;imshow(LL);title('3. Letters Candidates'),end



%%%%%%%%%%%%%%%
% find CC pairs
%%%%%%%%%%%%%%%
CCpairTbl = findCCpairs(cand,CCnum,BB,med,cent,avgRGB,...
                        b_avgRGB,avgHSV,b_avgHSV);       
           
%plot the CC pairs
LL = zeros(size(L));
for cc = cand
    if CCpairTbl(cc) ~= 0
        LL = LL + (L==cc) + (L==CCpairTbl(cc));
    end        
end
if dbg,figure;imshow(LL);title('4. Letter candidate pairs'),end
          



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% merge CC pairs to text lines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CCPairsCand = find(CCpairTbl)';
CClineTbl = zeros(CCnum,1);
line = 0;
for p = CCPairsCand
    
    if CClineTbl(p) == 0
        
        %merge into line
        line = line + 1;
        pp = p;        
        while CCpairTbl(pp) ~= 0 && CClineTbl(pp)==0
            CClineTbl(pp) = line;
            pp = CCpairTbl(pp);
        end
        CClineTbl(pp) = line;
        
        pp = p;
        while ~isempty(find(CCpairTbl==pp))
            tmp = find(CCpairTbl==pp);
            CClineTbl(tmp(1)) = line;
            pp = tmp(1);
        end
    end
        
end
textFramesTble = [];
%frame text lines in the image
% if line == 1
%     minLineLength = 1;
% else
%     minLineLength = 2;
% end
minLineLength = 1;
for l = 1:line
    ind = find(CClineTbl==l)';
    if length(ind) > 2
        minLineLength = 2;
    end
end
lineCnt = 1;
for l = 1:line
    ind = find(CClineTbl==l)';
    if length(ind) > minLineLength

        maxRowInLine(l) = 0;
        minRowInLine(l) = inf;
        maxColInLine(l) = 0;
        minColInLine(l) = inf;
        charBoundBox = [];
        charsPixs = [];
        charsSize = [];
        charColor = [];
        for ii = ind
            maxRowInLine(l) = max(maxRowInLine(l),BB(ii,2));
            minRowInLine(l) = min(minRowInLine(l),BB(ii,1));
            maxColInLine(l) = max(maxColInLine(l),BB(ii,4));
            minColInLine(l) = min(minColInLine(l),BB(ii,3));  
            [CCr,CCc] = find(L==ii);
            charsPixs = [charsPixs;[CCr CCc]];
            charsSize = [charsSize;size(CCr,1)];
        end
        charBoundBox = BB(ind,:);

        charColor = [avgRGB(ind,:) b_avgRGB(ind,:) avgHSV(ind,:) b_avgHSV(ind,:) avgGRAY(ind,:) b_avgGRAY(ind,:)];
        %plot text frames
        if (nargout == 0)
            BLD = 0:1;
            if (minColInLine(l)-BLD)>0 & (maxColInLine(l)+BLD)<size(Irgb,2) & ...
                    (minRowInLine(l)-BLD)>0 & (maxRowInLine(l)+BLD)<size(Irgb,1)
                Irgb(minRowInLine(l):maxRowInLine(l),minColInLine(l)-BLD,2:3) = 0;
                Irgb(minRowInLine(l):maxRowInLine(l),maxColInLine(l)+BLD,2:3) = 0;
                Irgb(minRowInLine(l)-BLD,minColInLine(l):maxColInLine(l),2:3) = 0;
                Irgb(maxRowInLine(l)+BLD,minColInLine(l):maxColInLine(l),2:3) = 0;
                Irgb(minRowInLine(l):maxRowInLine(l),minColInLine(l)-BLD,1) = 255;
                Irgb(minRowInLine(l):maxRowInLine(l),maxColInLine(l)+BLD,1) = 255;
                Irgb(minRowInLine(l)-BLD,minColInLine(l):maxColInLine(l),1) = 255;
                Irgb(maxRowInLine(l)+BLD,minColInLine(l):maxColInLine(l),1) = 255;
            end
            figure;imshow(Irgb)

        else
            textFramesTble(lineCnt,:) = [minRowInLine(l),maxRowInLine(l), ...
                minColInLine(l),maxColInLine(l)];
            lineCnt = lineCnt + 1;
            
            if (nargout > 1)
                charsCLR{lineCnt-1} = charColor;
            end
            if (nargout > 2)
                medStroke(lineCnt-1) = mean(med(ind));
            end
            if (nargout > 3)
                [cL,i] = min(BB(ind,3)); % min of chars minCol
                leftBottom = BB(ind(i),2); % maxRow of the lef char 
                [cR,i] = max(BB(ind,4)); % max of maxCol
                rightBottom = BB(ind(i),2); %maxRow of right char
                m(lineCnt-1) = (rightBottom - leftBottom)/(cR - cL);
            end
            if (nargout > 4)
                numOfChars(lineCnt-1) = length(ind);
            end
            if (nargout > 5)
                charsBB{lineCnt-1} = round(charBoundBox/P.imresizeFactor);
                charsP{lineCnt-1} = round(charsPixs/P.imresizeFactor);
                charsN{lineCnt-1} = charsSize;
            end


        end
    end
end

if P.imresizeFactor ~= 1
    textFramesTble = round(textFramesTble/P.imresizeFactor);
end

% if (nargout == 2)
%     imLL = LL;
% end