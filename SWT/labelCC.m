function [L,CCnum] = labelCC(W)

% This function groups the non zero pixels of the stroke width image W into
% connected components. Pixels with extream value (2 times from median) are
% dropped. 
% 
% W - stroke width image
% L - labeled componenets image
% CCnum - number of connected componenets.
% 
%
%
%
%

BW = W>0;
[L,CCnum] = bwlabeln(BW);

for cc = 1:CCnum
    clear CCr CCc CCw a
    %clean CC from unusual strokes
    [CCr,CCc] = find(L==cc);
    for ii = 1:length(CCr)
        CCw(ii) = W(CCr(ii),CCc(ii));
    end
    CCmed = median(CCw);
    a = find((CCw >= 2*CCmed) | (2*CCw < CCmed));
    if ~isempty(a)
        for ii = a
            W(CCr(ii),CCc(ii)) = 0;
        end
    end
end

BW = W>0;
[L,CCnum] = bwlabeln(BW);
