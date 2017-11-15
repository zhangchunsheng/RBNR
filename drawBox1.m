function Iout = drawBox1(Iin,x,c,BLD)
%Iin = input image
%BLD = Bold level;
%x = [minRow maxRow minCol maxCol]
%c = color RGB vector

for l = 1:size(x,1)
    minRow = fix(x(l,1)); 
    maxRow = fix(x(l,2));
    minCol = fix(x(l,3));
    maxCol = fix(x(l,4));
    
    Iin(minRow:maxRow,max(minCol-BLD,1),1) = c(1);
    Iin(minRow:maxRow,min(maxCol+BLD,end),1) = c(1);
    Iin(max(minRow-BLD,1),minCol:maxCol,1) = c(1);
    Iin(maxRow+BLD,minCol:maxCol,1) = c(1);
    Iin(minRow:maxRow,max(minCol-BLD,1),2) = c(2);
    Iin(minRow:maxRow,min(maxCol+BLD,end),2) = c(2);
    Iin(max(minRow-BLD,1),minCol:maxCol,2) = c(2);
    Iin(maxRow+BLD,minCol:maxCol,2) = c(2);
    Iin(minRow:maxRow,max(minCol-BLD,1),3) = c(3);
    Iin(minRow:maxRow,min(maxCol+BLD,end),3) = c(3);
    Iin(max(minRow-BLD,1),minCol:maxCol,3) = c(3);
    Iin(maxRow+BLD,minCol:maxCol,3) = c(3);
end
Iout = Iin;
end