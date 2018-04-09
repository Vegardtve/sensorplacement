       function popup_callback(source,event,data)
%           idx = popup.Value;
%           popup_items = popup.String;
% %           This code uses dot notation to get properties.
% %           Dot notation runs in R2014b and later.
% %           For R2014a and earlier:
%           idx = get(popup,'Value');
%           popup_items = get(popup,'String');
%           data.choice = char(popup_items(idx,:));

        data.val = source.Value;
        data.maps = source.String;
        % For R2014a and earlier: 
        % val = get(source,'Value');
        % maps = get(source,'String'); 
 
       end