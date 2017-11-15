function [R,fd,td] = RBNR(imfile,Pswt,B)
% 
%
% Racing Bib Number Recognition function
% detects racing bib numbers (RBNs) in the input image and recognize using
% Tesseract OCR. 
% 
% 
% imfile - path to image file
% P - stroke width trandform (SWT) text detection algorithm parameters.
% B - RBNR parameters
% R - result struct, contains the detected face, tag and number (RBN) 
% R.face - face location in this format [minRow maxRow minCol maxCol]
% R.torso - torso location in this format [minRow maxRow minCol maxCol]
% R.tag - RBN tag location in this format [minRow maxRow minCol maxCol]
% R.rbn - RBN (number)
% fd - array of face detection results. format [minRow maxRow minCol maxCol]
% td - array of tag detection results. format [minRow maxRow minCol maxCol]
%
% 
% Parameter details
% -------------------
% RBNR parameters:
% faceDet_filtersXmlFile - path of OpenCV haarcascades filters. Can be
%                       downloaded from http://opencv.willowgarage.com/wiki
% faceTorso_scale - torso scaling factor. given [a b], the torso hypothesis
%                   is (a*face_hieght) X (b*face_width) 
% prepSwt_faceMaxStrkTbl - prepare swt max width parameter according to
%                          given face sizes. for given [a b] - if face dim
%                          less than a than use max stroke b (pixel units)
% prepSwt_faceMaxFontTbl - prepare swt max font parameter according to
%                          given face sizes. for given [a b] - if face dim
%                          less than a than use max font b (pixel units)
%
% prepSwt_faceSzUpscaleTbl - prepare swt max upscale parameter according to
%                          given face sizes. for given [a b] - if face dim
%                          less than a than use image upscale factor b
% tagSel_tagFaceDimensionRatio - candidate tag selection process, tag 
%                       size must be larger than (face size)/DimensionRatio
% tagSel_tagFaceDistRatio - candidate tag selection process, tag - face
%                           distance is greater than (face size)/DistRatio
% tagSel_tagTorsoWidthRatio - candidate tag selection process, tag width
%                           is less than (torso size)/WidthRatio
% tagSel_tagAspectRatio - tag aspect ratio: (height/width)<tagAspectRatio
%
% tagSel_tagMedianStrkRatio - candidate tag selection process, the median 
%                           stroke width of the digits is less than 
%                           face_width/tagMedianStrkRatio
% preProc_lowThreshold - pre procssing low binary threshold. this indicates 
%                       the allowed distance between each pixel's color in 
%                       the font image and the average color.
% preProc_lowThreshold - pre procssing high binary threshold.this indicates 
%                       the allowed distance between each pixel's color in 
%                       the font image and the average color in case of low
%                       resolution font images. usually, this threshold  
%                       is >= from lowThreshold.
% preProc_nofRowsForHighThr - indicates the maximal rows number for high 
%                           threshold. above this number, the low threshold
%                           is used.
% preProc_strokeForHighThr - indicates the maximal stroke width for high 
%                           threshold. above this width, the low threshold
%                           is used.
% preProc_maxOrientFixAngle - the maximal orientation angle for the "fixing
%                             orientation" module in the pre processing 
%                              stage. values [0-90] 
%
% ocr_confLevelDegradPerChar - ocr confidence level degradation between
%                              characters (digits) in RBN. if CL is less
%                              than confLevelDegradPerChar of the median CL
%                              values [0-1]
% ocr_confLevel - ocr average confidence level of RBN. the confidence level
%                 here is inverted (basically it should be 1/CL). Thus the
%                 lower CL is, the more accurate, however setting CL too 
%                 low may filter lot of the results. values > 0
% ocr_filterMinNum - the minimum RBN's number. use only at the end of the
%                    process to filter irrelevant numbers.
% ocr_filterMaxNum - the maximum RBN's number. use only at the end of the
%                    process to filter irrelevant numbers.                  
%
%
%

% output
R = struct('face',{},'torso',{},'tag',{},'rbn',{});
td = [];
fd = [];


if nargin < 1
    error('Missing input arguments. usage: [R,fd,td] = RBNR(imfile,swtParam,RbnParam)');
end


% SWT Parameters
if nargin < 2
    % defaults
    Pswt = struct('maxWid',-8,'varAvgRatio',0.5,'aspectRatio',10, ...
    'widthToSrokeRatio',12,'highToStrokeRatio',12, ...
    'StrokeToMaxHighRatio',0.6,'minDim',5,'maxDim',80, ...
    'condWidthToStroke',10,'allowedGradVariation',pi/2,'imresizeFactor',1);
end


if nargin < 3
    % defaults
    B = struct('swtDbg',0,...
        'faceDet_filtersXmlFile','C:/OpenCV2.2/data/haarcascades/haarcascade_frontalface_alt.xml',...
        'faceTorso_scale', [7/2 7/3],...
        'prepSwt_faceMaxStrkTbl', [75 -11; 97 -12; 120 -14; 150 -18],...
        'prepSwt_faceMaxFontTbl', [150 120],...
        'prepSwt_faceSzUpscaleTbl', [70 2],...
        'tagSel_tagFaceDimensionRatio', 4.5,...
        'tagSel_tagFaceDistRatio', 4,...
        'tagSel_tagTorsoWidthRatio', 0.85,...
        'tagSel_tagAspectRatio', 0.86,...
        'tagSel_tagMedianStrkRatio', 6,...
        'preProc_lowThreshold', 50,...
        'preProc_highThreshold', 70,...
        'preProc_nofRowsForHighThr', 20,...
        'preProc_strokeForHighThr', 4,...
        'preProc_maxOrientFixAngle', 10,...
        'ocr_confLevelDegradPerChar', 0.7,...
        'ocr_confLevel', 180,...
        'ocr_filterMinNum', 99,...
        'ocr_filterMaxNum', 99999);
    
    
    
end    
    

% defaults
ocrPreProc_enable = 1;    
binaryThrType = 'rgb';



%imfile 
I = imread(imfile);

%faceDetector,
%fd = [minRow maxRow minCol maxCol]
fd = faceDetector(imfile,B.faceDet_filtersXmlFile);


%define area to search the tag (torso)
fdFalse = isempty(fd);
[bd,face_W] = face2body(I,fd,B.faceTorso_scale);


%loop all face candidates
resInd = 1;
for ii = 1:size(bd,1)
    rows = max(1,bd(ii,1)):min(size(I,1),bd(ii,2));
    cols = max(1,bd(ii,3)):min(size(I,2),bd(ii,4));
    
    
    bodyArea = I(rows,cols,:);
    if isempty(bodyArea)
        continue;
    end
    
    %sanity check if torso size is valid
    body_W = cols(end) - cols(1);
    body_H = rows(end) - rows(1);
    if (body_W < face_W(ii)/2) || (body_H < face_W(ii)/2) %  too small
        continue;
    end
    
    
    %SWT to find digits tag candidates
    %adjust swt parameter according to face scale
    P = prepSwtParams(face_W(ii),Pswt,B.prepSwt_faceSzUpscaleTbl, B.prepSwt_faceMaxStrkTbl, B.prepSwt_faceMaxFontTbl);
    
    %apply swt detector
    [tagCand,charsCLR,medStroke,slope,numOfCC,charsBB,charsP,charsN] = swtTextDetect(bodyArea,P,B.swtDbg);
    if isempty(tagCand)
        continue;
    end
    
    
    %choose best candidate for tag
    [winCand,winIndex] = findBestTag(tagCand,face_W(ii),bodyArea,P.imresizeFactor,medStroke,P,B,numOfCC,charsBB,charsCLR,fdFalse,ocrPreProc_enable);
    if isempty(winCand)
        continue;
    end
    
    
    % prepare the plate (RBN) image, tilt/rotation
    [IM2OCR_RGB,charsBB_tilt] = prepTagImage(I,rows,cols,bodyArea,winCand,charsP,charsN,slope,winIndex);
    
    
    
    % OCR pre-processing 
    [IM2OCR,BW_N] = ocrPreProc_SD(IM2OCR_RGB,binaryThrType,P.imresizeFactor,P,B,charsBB_tilt,charsCLR{winIndex},medStroke(winIndex));

    % drop if binary conversion failed     
    if isempty(IM2OCR)
        continue;
    end
    
    
    
    %apply OCR
    [num,cl] = ocr_wrapper_SD(IM2OCR,B);
    
    %drop if OCR failed
    if isempty(num)
        continue;
    end

    
    
    %results        
    td = [td;[winCand(1:2)+rows(1),winCand(3:4)+cols(1)]]; %keep tag detection results
    if isempty(fd), fd = [1 2 1 2]; end             % face detection results
    R(resInd) = struct('face',fd(ii,:),'torso',bd(ii,:),'tag',[winCand(1:2)+rows(1),winCand(3:4)+cols(1)],'rbn',num);
    resInd = resInd + 1; 
    
end

    
    
    