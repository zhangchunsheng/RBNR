function [winCand,winIndex] = findBestTag(tagCand,face_W,bodyArea,imresizeFactor,medStroke,P,B,numOfCC,charsBB,charsCLR,fdFalse,ocrPreProc_enable)


% choose the best candidate tag

% defaults
% B.tagSel_tagFaceDimensionRatio = 4.5;
% B.tagSel_tagFaceDistRatio = 4;
% B.tagSel_tagTorsoWidthRatio = 0.85;
% B.tagSel_tagAspectRatio = 0.86;
% B.tagSel_tagMedianStrkRatio = 6;

ind = 1:size(tagCand,1);
%check if tag is valid
k = 1;
cand_A = [];
winCand = [];
winIndex = [];
while k <= size(tagCand,1)
    cand_W = tagCand(k,4)-tagCand(k,3);
    cand_H = tagCand(k,2)-tagCand(k,1);
    if (cand_W < face_W/B.tagSel_tagFaceDimensionRatio) || (cand_H < face_W/B.tagSel_tagFaceDimensionRatio) %if it's too small
        tagCand(k,:) = [];
        ind(k) = [];
    elseif ((tagCand(k,1) < face_W/B.tagSel_tagFaceDistRatio))% if it's close to face
        tagCand(k,:) = [];
        ind(k) = [];
    elseif (cand_W/size(bodyArea,2) > B.tagSel_tagTorsoWidthRatio)
        tagCand(k,:) = [];
        ind(k) = [];
    elseif cand_W/cand_H < B.tagSel_tagAspectRatio  %if it's aspect ratio don't fit
        tagCand(k,:) = [];
        ind(k) = [];
    elseif ~fdFalse && (face_W/medStroke(ind(k)) < B.tagSel_tagMedianStrkRatio/imresizeFactor)  %if stroke is too large
        tagCand(k,:) = [];
        ind(k) = [];
        
        
        % the following conditions are assumed to be correct in all cases
        % 
        %
        % if median stroke less than 3 (even after upscaling) - drop it
        % (unless face is really small 24p)
        % if number of SWT components is 20 or more - drop it
    elseif ~fdFalse && (face_W > 25 && medStroke(ind(k)) < 3) %if stroke is too small
        tagCand(k,:) = [];
        ind(k) = [];
    elseif numOfCC(k) > 19
        tagCand(k,:) = [];
        ind(k) = [];
        
    else
        
        
        tagImg = bodyArea(tagCand(k,1):tagCand(k,2),tagCand(k,3):tagCand(k,4),:);
        if ocrPreProc_enable
            
            % if still more than 1 candidate left
            % calculate the total confidence level of the digits as
            % extracted from Tesseract OCR. 
            % 
            % 
            [img,~] = ocrPreProc_SD(tagImg,'gray',imresizeFactor,P,B,charsBB{ind(k)},charsCLR{ind(k)},medStroke(ind(k)));
            [tmpN,cand_A(k)] = ocr_wrapper(img);
        else
            [tmpN,cand_A(k)] = ocr_wrapper(rgb2gray(tagImg));
        end
        
        tmpN(find(tmpN==' '))=[]; % in order to clear spaces
        
        cand_A(k) = cand_A(k)/length(tmpN); %average level(divide by num of chars)
        k = k + 1;
    end
end

if isempty(tagCand)
    return;
end


%choose best candidate for tag
[v,id] = min(abs(cand_A));
winCand = tagCand(id,:);
winIndex = ind(id);