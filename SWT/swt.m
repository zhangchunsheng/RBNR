function [W,Wimg] = swt(E,Ix,Iy,Wmax)

%keep original image size and pad with zeros
[rows,cols] = size(E);
Npad = abs(Wmax) + 2;
PAD1 = zeros(size(E,1),Npad);
PAD2 = zeros(Npad,size(E,2));
E = [PAD1,E,PAD1];
PAD2 = zeros(Npad,size(E,2));
E = [PAD2;E;PAD2];

%normalized magnitude gradient 
Ixn = [PAD2;[PAD1,(Ix)./sqrt(Ix.^2 + Iy.^2 + eps),PAD1];PAD2] ;
Iyn = [PAD2;[PAD1,(Iy)./sqrt(Ix.^2 + Iy.^2 + eps),PAD1];PAD2]; 
Ip = [PAD2;[PAD1,atan2(Iy,Ix),PAD1];PAD2]; 

%stroke width possible values
n_vals = sign(Wmax)*(1:abs(Wmax));

%calc stroke width
W = 255*ones(size(E));
Wimg = 255*ones(size(E)); 

for ii = Npad + (1:rows) %lines
    for jj = Npad + (1:cols) %colomns

        if E(ii,jj)
            for n = n_vals
                s1 = round(ii + Ixn(ii,jj)*n);
                s2 = round(jj + Iyn(ii,jj)*n);
                
                %if Edge is found
                if E(s1,s2) || ((abs(n)>3) && (E(s1+1,s2) || E(s1,s2+1) || E(s1-1,s2)))
                    
                    %if opposite gradient is found
                    if (E(s1,s2) && abs(pi - abs(Ip(s1,s2) - Ip(ii,jj)))<pi/2) || ...
                       (E(s1+1,s2) && abs(pi - abs(Ip(s1+1,s2) - Ip(ii,jj)))<pi/2) || ...
                       (E(s1,s2+1) && abs(pi - abs(Ip(s1,s2+1) - Ip(ii,jj)))<pi/2) || ...
                       (E(s1-1,s2) && abs(pi - abs(Ip(s1-1,s2) - Ip(ii,jj)))<pi/2)
                        for nn = sign(n)*(0:abs(n))
                            s1 = round(ii + Ixn(ii,jj)*nn);
                            s2 = round(jj + Iyn(ii,jj)*nn);

                            %if there's no lower width
                            if W(s1,s2) >= abs(n)
                                W(s1,s2) = abs(n);
                                Wimg(s1,s2) = abs(n)*10;
                            end
                        end
                    end
                    break;
                end

            end
        end
    end
end

% second pass to set higher strok widths to median 
rayWvals = [];
for ii = Npad + (1:rows) %lines
    for jj = Npad + (1:cols) %colomns

        if E(ii,jj)
            for n = n_vals
                s1 = round(ii + Ixn(ii,jj)*n);
                s2 = round(jj + Iyn(ii,jj)*n);
                rayWvals(abs(n)) = W(s1,s2);
                
                %if Edge is found
                if E(s1,s2) || ((abs(n)>3) && (E(s1+1,s2) || E(s1,s2+1) || E(s1-1,s2)))
                    %if opposite gradient is found
                    if (E(s1,s2) && abs(pi - abs(Ip(s1,s2) - Ip(ii,jj)))<pi/2) || ...
                       (E(s1+1,s2) && abs(pi - abs(Ip(s1+1,s2) - Ip(ii,jj)))<pi/2) || ...
                       (E(s1,s2+1) && abs(pi - abs(Ip(s1,s2+1) - Ip(ii,jj)))<pi/2) || ...
                       (E(s1-1,s2) && abs(pi - abs(Ip(s1-1,s2) - Ip(ii,jj)))<pi/2)                       
                        medRayWvals = median(rayWvals);
                        for nn = sign(n)*(0:abs(n))
                            s1 = round(ii + Ixn(ii,jj)*nn);
                            s2 = round(jj + Iyn(ii,jj)*nn);

                            %if there's no significient lower width
                            if W(s1,s2) >= medRayWvals
                                W(s1,s2) = floor(medRayWvals);
                                Wimg(s1,s2) = floor(medRayWvals)*10;
                            end
                        end
                    end
                    break;
                end

            end
        end
    end
end

%return to original size
W([1:Npad,end-Npad+1:end],:) = [];
W(:,[1:Npad,end-Npad+1:end]) = [];
W = W.*(W ~= 255);
Wimg([1:Npad,end-Npad+1:end],:) = [];
Wimg(:,[1:Npad,end-Npad+1:end]) = [];