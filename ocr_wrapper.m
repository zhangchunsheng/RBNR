function [num,cl] = ocr_wrapper(IM)


if size(IM,1) < 10 | size(IM,2) < 10
    num = num2str(0);
    cl = 0;
    return;
end

imwrite(IM,'tmp.tif','tif','compression','none');

%apply OCR (Tesseract OCR)
%    dos('tesseract tmp.tif tmp');
dos('tesseract.exe tmp.tif tmp nobatch digits');

%display text
[s,w] = dos('more tmp.txt');
if ~isempty(w)
    if length(w) > 1
        w(end-1:end) = [];
    end
end

num = w;

if nargout > 1
    %extract confidence level
    [s1,w1] = dos('more out1.txt');
    cl = str2num(w1);
end
