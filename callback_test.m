function callback_test(source,event,data)
    data.vv = source.Value; 
       
    if data.vv==1 
        data.c.NavMode = 'Walk';
    elseif data.vv==2 
        data.c.NavMode = 'Examine'; 
    elseif data.vv==3 
        data.c.NavMode = 'Fly'; 
    end
end 
          
    