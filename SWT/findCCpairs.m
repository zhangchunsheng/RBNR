function CCpairTbl = findCCpairs(CCcand,CCnum,BB,medCC,centCC,avgRGB,b_avgRGB,avgHSV,b_avgHSV)

%
% This function finds pairs of components based on common properties
% such as stroke width, size, alignment, distance and location.
% 
%
%
%
%
%


minCCrow = BB(:,1);
maxCCrow = BB(:,2);
minCCcol = BB(:,3);
maxCCcol = BB(:,4);

CCpairTbl = zeros(CCnum,1);
for cc = CCcand
    Wcc = BB(cc,4) - BB(cc,3);
    Hcc = BB(cc,2) - BB(cc,1);
    minDp = 4*Wcc;

    %find the most distiguishing rgb/V component 
%    [val,idx] = max([b_avgRGB(cc,:) - avgRGB(cc,:),(b_avgHSV(cc,3)-avgHSV(cc,3))*255]);


    %find the closest neigbour
    for p = CCcand
        if p ~= cc

            Wp = maxCCcol(p) - minCCcol(p);
            Hp = maxCCrow(p) - minCCrow(p);
            Dp = minCCcol(p) - maxCCcol(cc);
            Dpcm = centCC(p,1) - centCC(cc,1);

            
            if centCC(p,1) > maxCCcol(cc) && ...
                    minCCcol(p) > centCC(cc) && ...    %to the right
                    maxCCcol(p) >= maxCCcol(cc) && ...
                    (maxCCrow(p)-Hp/2) > minCCrow(cc) && ...  %nearly the same line
                    (minCCrow(p)+Hp/2.2) < maxCCrow(cc) && ...
                    abs(medCC(p) - medCC(cc)) < (2+floor((medCC(p)+medCC(cc))/14)) && ...     %nearly the same stroke width
                    Hp/Hcc > 0.5 && ...     %nearly the same height
                    Hp/Hcc < 2 && ...
                    (Dpcm < 2*mean([Wcc Wp]) || ... %not far then 2 times latter width  
                    (Dpcm < 3*mean([Wcc Wp]) && (Hcc - Hp) < 2)) && ...
                    abs(median(avgHSV(cc,:) - avgHSV(p,:))) < 0.1 && ... %nearly the same colour
                    mean(abs(avgRGB(cc,:) - avgRGB(p,:))) < 50 && ...
                    mean(abs(b_avgRGB(cc,:) - b_avgRGB(p,:))) < 50
                    
                
                if Dpcm < minDp
                    CCpairTbl(cc) = p;
                    minDp = Dpcm;
                end
            end
        end
    end
end
                    