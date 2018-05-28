function b = covered1(i,x,y,z,datax,datay,dataz,obsta,pan)
% Function to determine the  coverage of point i 
% in the data points array from sensor placed at (x,y,z)
% given the pan angle (pan). 

% Camera parameters (valid for all cameras)
range = 9; 
tilt = pi/6; 
fov = 45 * pi/180; 

% Point to locate 
xp = datax(i); 
yp = dataz(i); 
zp = datay(i); 
% Norm of (x,y,z),(xp,yp,zp)
L = sqrt((xp-x)^2+(zp-z)^2+(yp-y)^2);
% XY angle
xya = atan2(zp-z,xp-x);
% XZ angle
xza = atan2(yp-y,L);
% Determine if point is covered and visible from 
% current sensor config. b = 1 if covered and visible
if (L < range)
    if ((pan-fov) <= xya) && (xya <= (pan+fov))
        if ((tilt-fov) <= xza) && (xza <= (tilt+fov)) 
          % Evaluate all obstacle points to ensure that no obstacle points block
		  % the sensor coverage of point i. b = true if covered and visible
		  for jj = 1:length(obsta)
			xoi = obsta(jj,1); 
              yoi = obsta(jj,3); 
              zoi = obsta(jj,2); 
              oi_L = sqrt((xoi-x)^2+(zoi-z)^2+(yoi-y)^2);
              oi_xya = atan2(zoi-z,xoi-x);
              db = 0.25; 
              oi_xza = atan2(yoi-y,oi_L);
              if ((pan-fov) <= oi_xya) && (oi_xya <= (pan+fov))
                if(abs(xya-oi_xya) < db)
                    if((tilt-fov) <= oi_xza) && (oi_xza <= (tilt+fov))
                        if(abs(xza-oi_xza) < db)
                            if(L > oi_L)                                          
                                b = false;                                                        
                            else
                                b = true; 
                            end
                        else
                            b = true; 
                        end
                    else 
                        b = true; 
                    end
                else
                    b = true;
                end
              else
                  b = true;
              end

            end

        else
            b = false; 
        end
    else
        b = false; 
    end
else 
    b = false; 
end