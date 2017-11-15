function [num,CL] = ocr_wrapper_SD(IM,B)

if nargin < 2
    B.ocr_confLevelDegradPerChar = 0.7;
    B.ocr_confLevel = 180;
    B.ocr_filterMinNum = 99;
    B.ocr_filterMaxNum = 9999;
end

num = '';
digC = cell(1,size(IM,2));
filterFlag = 1;

for cc = 1:size(IM,2)
    
    [digC{cc},cl(cc)] = ocr_wrapper(IM{cc});
    if digC{cc} == 10, digC{cc} = '1';filterFlag=0;  end %due to bug in OCR - sometimes recognizes '1' as '\n'
    
end


medCL = median(cl);
for cc = 1:size(IM,2)
    if (median(cl)/cl(cc) > B.ocr_confLevelDegradPerChar) || ~filterFlag
        dig = digC{cc};
        num(end+1:end+size(dig,2)) = dig(1,:);
    end
end


% in order to clear spaces
num(find(num==' '))=[];

% average confidence level
CL=mean(cl);


% get rid of 1 digit numbers. not supported by this system and probably
% are false detections
% 
if (size(num,2) < 2)
    num = [];
    return;
end

% drop small images (3 pixels image size is not supported by OCR)
% 
if (length(IM) < 3)
    num = [];
    return;
end


% allowable confidence level (In Tesseract OCR, confidence level is the 
% distance from protoype. lower is better)
if (CL > B.ocr_confLevel)
    num = [];
    return;
end
    

% Filter illegal numbers
% number is greater than minimum
if (str2num(num) < B.ocr_filterMinNum)
    num = [];
    return;
end

% number is less than maximum
if (str2num(num) > B.ocr_filterMaxNum)
    num = [];
    return;
end






