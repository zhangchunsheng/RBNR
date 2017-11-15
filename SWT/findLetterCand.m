function [CCcand,BB,medCC,centCC,avgRGB,b_avgRGB,avgHSV,b_avgHSV,avgGRAY,b_avgGRAY] = findLetterCand(L,CCnum,W,Irgb,P,mode)

% This function finds the connected components in the binary 
% image L which are likely characters.
% We apply the following checks:
% Dimensions (P.minDim, P.maxDim)
% Small Variance (P.varAvgRatio)
% Aspect ratio (P.aspectRatio)
% Stroke-Dimensions ratio (P.StrokeToMaxHighRatio)
% vertical orientation 
%
% Some properties are extracted from the letter candidates for matching use
%
%
%
%

dontDrop = 0;
if nargin > 5
    if mode == 1
        dontDrop = 1;
    end
end       

Ir = Irgb(:,:,1);Ib = Irgb(:,:,2);Ig = Irgb(:,:,3);
Ihsv = rgb2hsv(Irgb); Ih = Ihsv(:,:,1);Is = Ihsv(:,:,2);Iv = Ihsv(:,:,3);
Igray = rgb2gray(Irgb);

Lcand = ones(CCnum,1);
CCavg = zeros(CCnum,1);
CCvar = zeros(CCnum,1);
avgRGB = zeros(CCnum,3);
b_avgRGB = zeros(CCnum,3);
avgHSV = zeros(CCnum,3);
b_avgHSV = zeros(CCnum,3);
avgGRAY = zeros(CCnum,1);
b_avgGRAY = zeros(CCnum,1);
centCC = zeros(CCnum,2);
for cc = 1:CCnum
    
    %reject CC with small/large dimensions
    if Lcand(cc)
        clear CCr CCc CCw        
        [CCr,CCc] = find(L==cc);
        CCw = W(L==cc)';
        maxCCc = max(CCc);
        minCCc = min(CCc);
        maxCCr = max(CCr);
        minCCr = min(CCr);
        CCmed = median(CCw);

        if max(maxCCc-minCCc,maxCCr-minCCr)<P.minDim ||  ...
                max(maxCCc-minCCc,maxCCr-minCCr)>P.maxDim
            Lcand(cc) = 0;

        end
    end
    
    
    %reject CC with large variance
    if Lcand(cc)
        CCavg(cc) = mean2(CCw);
        CCvar(cc) = std2(CCw);

        if CCvar(cc)/(CCavg(cc)+eps) > P.varAvgRatio
            Lcand(cc) = 0;
        end
    end

    % reject CC with large aspect ratio, large stroke to high ratio and
    % tend-to-vertical orieantation 
    if Lcand(cc)
        
        bbP1 = regionprops((L==cc),'MajorAxisLength');
        bbP2 = regionprops((L==cc),'MinorAxisLength');
        bbP3 = regionprops((L==cc),'Orientation');
        
        if bbP1.MajorAxisLength/bbP2.MinorAxisLength > P.aspectRatio
           Lcand(cc) = 0 | dontDrop;
        end
        
        if CCmed/bbP1.MajorAxisLength > P.StrokeToMaxHighRatio
           Lcand(cc) = 0 | dontDrop;
        end
        
        if (abs(bbP3.Orientation) < 40) && bbP1.MajorAxisLength/bbP2.MinorAxisLength > 2
           Lcand(cc) = 0 | dontDrop;
        end

    end
    

    

    maxCCcol(cc) = maxCCc;
    minCCcol(cc) = minCCc;
    maxCCrow(cc) = maxCCr;
    minCCrow(cc) = minCCr;
    medCC(cc) = CCmed;
    
    % calculate centroid of cc
    if Lcand(cc)
        bbP4 = regionprops((L==cc),'Centroid');
        centCC(cc,:) = round(bbP4.Centroid);
    end

    
    if Lcand(cc)
        avgRGB(cc,:) = [mean(Ir(L==cc)),mean(Ig(L==cc)),mean(Ib(L==cc))];
        avgHSV(cc,:) = [mean(Ih(L==cc)),mean(Is(L==cc)),mean(Iv(L==cc))];
        avgGRAY(cc,:) = mean(Igray(L==cc));

        B = L==cc;
        B(minCCrow(cc):maxCCrow(cc),max(minCCcol(cc)-1,1):min(maxCCcol(cc)+1,size(B,2))) = 1;
        B = B & ~(L==cc);
        if any(any(B))
            b_avgRGB(cc,:) = [mean(Ir(B)),mean(Ig(B)),mean(Ib(B))];
            b_avgHSV(cc,:) = [mean(Ih(B)),mean(Is(B)),mean(Iv(B))];
            b_avgGRAY(cc,:) = mean(Igray(B));
        else
            b_avgRGB(cc,:) = avgRGB(cc,:);
            b_avgHSV(cc,:) = avgHSV(cc,:);
            b_avgGRAY(cc,:) =   avgGRAY(cc,:);
        end
    end
end

BB = [minCCrow' maxCCrow' minCCcol' maxCCcol'];
CCcand = find(Lcand)';