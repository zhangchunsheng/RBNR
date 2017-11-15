function fd = faceDetector(image_file,filters_xml_file)

% OpenCV face detection algorithm
%
% 
% run faceDetector.exe
% store results in temporary file


if nargin < 2
    filters_xml_file = 'C:/OpenCV2.2/data/haarcascades/haarcascade_frontalface_alt.xml';
end




fd = [];
%Front face detection
dos(['faceDetector.exe ','"',image_file,'" ',filters_xml_file]);
[s,w] = dos('more out.txt');
fdp = str2num(w);

%replace 0 with first line (probably bug in the face detector code)
fdp(fdp==0) = 1;
% %profile face detection
% dos(['faceDetector.exe ','"',image_file,'" ','C:/OpenCV2.2/data/haarcascades/haarcascade_profileface.xml']);
% [s,w] = dos('more out.txt');
% fdp = [fdp;str2num(w)];
if ~isempty(fdp)
    fd = [fdp(1:2:end,2) fdp(2:2:end,2) fdp(1:2:end,1) fdp(2:2:end,1)];
end
