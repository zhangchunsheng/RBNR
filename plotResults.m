function plotResults(R,imfile)

Iface = imread(imfile);

for ii=1:length(R)
    
    fd = R(ii).face;
    bd = R(ii).torso;
    tg = [R(ii).tag(1:2) + [-2 2] R(ii).tag(3:4) + [-3 3]];
    
    
    %draw face & body
    if ~isempty(fd), Iface = drawBox1(Iface,fd,[255 0 0],-1:1);end
    Iface = drawBox1(Iface,bd,[0 255 0],-1:1);
    Iface = drawBox1(Iface,tg,[0 0 255],-1:1);
    
end
 
imshow(Iface,'Border', 'tight');
hold on

for ii=1:length(R)
    NUM = R(ii).rbn;
    bd = R(ii).torso;
    face_W = fd(2) - fd(1);

    s = max(8,min(12,round(face_W/5)));
    if (size(NUM,2) > 2)
        text(bd(3)+3,bd(1)+3,NUM,'FontSize',s,'color','k','BackgroundColor','g','VerticalAlignment','top','HorizontalAlignment','left');
    end
end
hold off
%title('RED - face detection, GREEN - body estimation, BLUE - digits detection by swt')
set(gcf,'Name',imfile)
pause(1)
