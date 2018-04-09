function val = choosedialog

    d = dialog('Position',[300 300 250 150],'Name','RotX');
    
    sld = uicontrol('Parent',d,...
                     'Style', 'slider',...
                     'Position',[75 70 100 40],...
                     'Min',1,'Max',50,'Value',41,...
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
        val = 51 - source.Value;
        % For R2014a and earlier:
        % val = 51 - get(source,'Value')
        set(source,'Tag','val');
    end
             
    % Wait for d to close before running to completion
    uiwait(d);
   

end