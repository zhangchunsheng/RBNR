function T = findTextLines(CCpairTbl,CCnum,BB,L,Irgb)

CCPairsCand = find(CCpairTbl)';
CClineTbl = zeros(CCnum,1);
nofLines = 0;
for p = CCPairsCand
    
    if CClineTbl(p) == 0
        
        %merge into line
        nofLines = nofLines + 1;
        pp = p;        
        while CCpairTbl(pp) ~= 0 && CClineTbl(pp)==0
            CClineTbl(pp) = nofLines;
            pp = CCpairTbl(pp);
        end
        CClineTbl(pp) = nofLines;
        
        pp = p;
        while ~isempty(find(CCpairTbl==pp))
            tmp = find(CCpairTbl==pp);
            CClineTbl(tmp(1)) = nofLines;
            pp = tmp(1);
        end
    end
        
end




minLineLength = 1;
for l = 1:line
    ind = find(CClineTbl==l)';
    if length(ind) > 2
        minLineLength = 2;
    end
end


lineCnt = 1;
maxRowInLine = inf*ones(nofLines,1);
minRowInLine = zeros(nofLines,1);
maxColInLine = inf*ones(nofLines,1);
minColInLine = zeros(nofLines,1);


for l = 1:nofLines
    ind = find(CClineTbl==l)';
    
    if length(ind) > 4 % if num of chars is 5 or more search for exeptions 

        
        dMaxRow = diff(BB(ind,2));
        dMaxRow > 2*median(dMaxRow)
        
        
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

        T.charsColor = [avgRGB(ind,:) b_avgRGB(ind,:) avgHSV(ind,:) b_avgHSV(ind,:) avgGRAY(ind,:) b_avgGRAY(ind,:)];
        %plot text frames
        T.charsBB(lineCnt,:) = [minRowInLine(l),maxRowInLine(l), ...
                minColInLine(l),maxColInLine(l)];
            lineCnt = lineCnt + 1;
            
            if (nargout > 1)
                charsCLR{lineCnt-1} = charColor;
            end
            if (nargout > 2)
                medStroke(lineCnt-1) = mean(med(ind));
            end
            if (nargout > 3)
                [cL,i] = min(minCol(ind));
                leftBottom = maxRow(ind(i));
                [cR,i] = max(maxCol(ind));
                rightBottom = maxRow(ind(i));
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


