function printStatistics(C,rbnList)

detRate = zeros(size(C,2),1);
fDetRate = zeros(size(C,2),1);
tDetRate = zeros(size(C,2),1); 
detRateMiss1 = zeros(size(C,2),1);
fNumTot = zeros(size(C,2),1);
nofTruePlusFalse = zeros(size(C,2),1);
detNumVec = [];

for ii = 1:length(C)
    
    detRate(ii) = C(ii).numDet;
    fDetRate(ii) = C(ii).faceDet;
    tDetRate(ii) = C(ii).tagDet;
    detRateMiss1(ii) = C(ii).miss1;
    fNumTot(ii) = C(ii).nofRefFaces;
    nofTruePlusFalse(ii) = C(ii).nofGuesses;
    for kk = 1:length(rbnList{ii})
        detNumVec = [detNumVec;[ii rbnList{ii}(kk)]];
        
        % check if detected RBN already found (to avoid counting twice the
        % same tag)
        if kk>1
         if length(find(rbnList{ii}(kk) == rbnList{ii}(1:kk-1))>0)
             detRate(ii) = detRate(ii)-1;
             nofTruePlusFalse(ii) = nofTruePlusFalse(ii)-1;
         end   
        end

    end


 
end

fprintf(['Precision                            : %0.4g\n'],sum(detRate)/sum(nofTruePlusFalse));
fprintf(['Recall (0 missed digit allowed)      : %0.4g\n'],sum(detRate)/sum(fNumTot));
fprintf(['Recall (1 missed digit allowed)      : %0.4g\n'],(sum(detRateMiss1.*~detRate)+sum(detRate))/sum(fNumTot));
fprintf(['Faces Detection Rate                 : %0.4g\n'],sum(fDetRate)/sum(fNumTot));
fprintf(['Tags Detection Rate                  : %0.4g\n'],sum(tDetRate)/sum(fNumTot));




