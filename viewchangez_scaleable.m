function viewchangez(src,event,data) 
nodes=get(data.w,'Nodes');



d = dialog('Position',[300 300 250 150],'Name','RotZ');
sld = uicontrol('Parent',d,...
                     'Style', 'slider',...
                     'Position',[75 70 100 40],...
                     'Min',0,'Max',360,'Value',90,...
                     'Callback', @surfzlim); 

   % Add a text uicontrol to label the slider.
    txt = uicontrol('Parent',d,...
        'Style','text',...
        'Position',[20 80 210 40],...
        'String','Rotation');
    
    btn = uicontrol('Parent',d,...
           'Position',[89 20 70 40],...
           'String','Close',...
           'Callback','delete(gcf)');
       
       
    function surfzlim(source,event)
        val = 360 - source.Value;
        % For R2014a and earlier:
        % val = 51 - get(source,'Value')
        set(source,'Tag','val');
    end
             
    % Wait for d to close before running to completion
    uiwait(d);









nodes(1).rotation = [[0 0 1] val*180/pi]; 
end
