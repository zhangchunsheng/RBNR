function [C rbnList] = checkResults(fd,td,R,reffile)


% results struct
C = struct('numDet',0,'faceDet',0,'tagDet',0,'miss1',0,'miss2',0,'miss3',0,'nofRefFaces',0,'nofGuesses',0);


% load reference file
load(reffile);
numList = number;
faceList = facep;
tagList = tagp;
rbnList = [];



for kk = 1:length(R)
    
    num1 = R(kk).rbn;
    face1 = R(kk).face;
    tag1 = R(kk).tag;
    
    [n,f,t,ms1,ms2,ms3,~,~,~,~] = checkResult1(num1,numList,face1,faceList,tag1,tagList);
    
    if n && (C.numDet<=size(facep,1)) , C.numDet = C.numDet+1;end
 %   if f && (C.faceDet<=size(facep,1)) , C.faceDet = C.faceDet+1;end
 %   if t && (C.tagDet<=size(facep,1)) , C.tagDet = C.tagDet+1;end

    if ms1 && (C.miss1<=size(facep,1)), C.miss1 = C.miss1+1;end
    if ms2 && (C.miss2<=size(facep,1)), C.miss2 = C.miss2+1;end
    if ms3 && (C.miss3<=size(facep,1)), C.miss3 = C.miss3+1;end
    
    rbnList = [rbnList;str2num(num1)];
    
    
end




for kk = 1:size(fd,1)
    if (C.faceDet<=size(faceList,1)),
        C.faceDet = C.faceDet + checkResult(faceList,fd(kk,:));
    end;
end

for kk = 1:size(td,1)
    if (C.tagDet<=size(tagList,1)),
        C.tagDet = C.tagDet + checkResult(tagList,td(kk,:));
    end;
end

C.nofRefFaces = size(facep,1);
C.nofGuesses = length(rbnList);
