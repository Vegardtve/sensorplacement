function callback_roi(source,event,data,S)
uiresume(S.d)
    val = source.Value; 
    if val==1 
        S.sw_x = 1;
        S.sw_z = 0; 
    elseif val==2 
        S.sw_z = 1; 
        S.sw_x = 0; 
    end
    source.UserData = [S.sw_x , S.sw_z];
end 