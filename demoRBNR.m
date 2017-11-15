% demoRBNR
%
%
% run RBNR demo from './Examples' directory
%
% Add SWT path
if ~exist('swtTextDetect','file')
    addpath('SWT');
end

% load image files
dir_path = './Examples';
filename = uigetfile('*.jpg','FilterSpec',dir_path);
dir_path = [dir_path,'/'];
imfile = [dir_path,filename];



% run RBNR with default params
[R,fd,td] = RBNR(imfile);


% show image & RBNs
plotResults(R,imfile);
