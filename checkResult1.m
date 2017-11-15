function [numDet,faceDet,tagDet,nm1,nm2,nm3,nm1_7,nm5_6,cdig,fdig] = checkResult1(num1,numr,face1,facer,tag1,tagr)

numDet = 0;
faceDet = 0;
tagDet = 0;
isMatch = 0;
tagInd = 0;
nm1=0;nm2=0;nm3=0;nm1_7=0;nm5_6=0;
cdig = 0;
fdig = length(num1);

for ii = 1:size(tagr,1)
    tag2 = tagr(ii,:);
    %calc intersection of boxes
    A = ~(tag1(1)>tag2(2) || tag1(2)<tag2(1) || ...
        tag1(3)>tag2(4) || tag1(4)<tag2(3))*...
        (min(tag1(2),tag2(2))-max(tag1(1),tag2(1)))*...
        (min(tag1(4),tag2(4))-max(tag1(3),tag2(3)));
    %calc union of boxes
    U = (tag1(2)-tag1(1))*(tag1(4)-tag1(3)) + ...
        (tag2(2)-tag2(1))*(tag2(4)-tag2(3)) - A;
    
    if A/U > 0.5
        tagDet=1;
        tagInd=ii;
    end
end


for ii = 1:size(facer,1)
    face2 = facer(ii,:);
    %calc intersection of boxes
    A = ~(face1(1)>face2(2) || face1(2)<face2(1) || ...
        face1(3)>face2(4) || face1(4)<face2(3))*...
        (min(face1(2),face2(2))-max(face1(1),face2(1)))*...
        (min(face1(4),face2(4))-max(face1(3),face2(3)));
    %calc union of boxes
    U = (face1(2)-face1(1))*(face1(4)-face1(3)) + ...
        (face2(2)-face2(1))*(face2(4)-face2(3)) - A;
    
    if A/U > 0.5
        faceDet=1;
    end
end


if tagInd == 0
    return;
end
    

num2 = numr(tagInd);    
    
if str2num(num1) == num2
    numDet = 1;
    cdig = length(num1);fdig = 0;
    return;
end

n1 = num1;n2 = num2str(num2);
nm1=0;nm2=0;nm3=0;nm1_7=0;nm5_6=0;
numBadDigits = length(n2);
num1to7swaps=0;
num5to6swaps=0;
if (size(n1,1) == 1) && (size(n2,1) == 1)
    if length(n1) == length(n2)
        numBadDigits = length(n1)-length(find(n1==n2));
        cdig = length(n1) - numBadDigits;fdig = numBadDigits;
        if numBadDigits > 0
            idx = find(n1~=n2);
            for d = idx
                if (n1(d)=='7'&n2(d)=='1') | (n2(d)=='7'&n1(d)=='1')
                    nm1_7 = nm1_7 + 1;
                end
                if (n1(d)=='5'&n2(d)=='6') | (n2(d)=='5'&n1(d)=='6')
                    nm5_6 = nm5_6 + 1;                    
                end
            end
        end
        
    end

    if (length(n1) - length(n2)) == 1
        tmp1 = length(n1(2:end))-length(find(n1(2:end)==n2));
        tmp2 = length(n1(1:end-1))-length(find(n1(1:end-1)==n2));
        numBadDigits = min(tmp1,tmp2) + 1;
        cdig = length(n2) - numBadDigits + 1;fdig = numBadDigits;
    end

    if (length(n2) - length(n1)) == 1
        tmp1 = length(n2(2:end))-length(find(n1==n2(2:end)));
        tmp2 = length(n2(1:end-1))-length(find(n1==n2(1:end-1)));
        numBadDigits = min(tmp1,tmp2) + 1;
        cdig = length(n1) - numBadDigits + 1;fdig = numBadDigits - 1;
    end

    if (length(n1) - length(n2)) == 2
        tmp1 = length(n1(3:end))-length(find(n1(3:end)==n2));
        tmp2 = length(n1(1:end-2))-length(find(n1(1:end-2)==n2));
        numBadDigits = min(tmp1,tmp2) + 2;
        cdig = length(n2) - numBadDigits + 2;fdig = numBadDigits;
    end

    if (length(n2) - length(n1)) == 2
        tmp1 = length(n2(3:end))-length(find(n1==n2(3:end)));
        tmp2 = length(n2(1:end-2))-length(find(n1==n2(1:end-2)));
        numBadDigits = min(tmp1,tmp2) + 2;
        cdig = length(n1) - numBadDigits + 2;fdig = numBadDigits - 2;
    end
    if(numBadDigits==1),nm1=1;end
    if(numBadDigits==2),nm2=1;end
    if(numBadDigits==3),nm3=1;end


end
