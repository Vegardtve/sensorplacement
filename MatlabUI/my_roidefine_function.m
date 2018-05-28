function my_roidefine_function(src,event,data)

uiresume(data.f)
A = load('corners.mat'); 
S.corners = A.corners; 
S.d = dialog('Position',[300 50 300 200],'Name',...
    'Setup Region of Interest',...
    'WindowStyle','normal');

txt = uicontrol('Parent',S.d,...
        'Style','text',...
        'Position',[50 100 200 50],...
        'String','Choose axis to swipe along');
    
popup = uicontrol('Parent',S.d,...
           'Style','popup',...
           'Position',[50 80 200 50],...
           'String',{'Swipe along vertical', 'Swipe along horizontal'},...
           'Callback',{@callback_roi,data,S});

 btn = uicontrol('Parent',S.d,...
               'Position',[200 20 70 25],...
               'String','Close',...
               'Callback',{@my_exit_functions,S});  

bOK = true; 
while(bOK)
    uiwait(S.d)
    if ~isempty(popup.UserData)
        F.sw_dir = popup.UserData; 
        F.corners = S.corners;        
    end

src.UserData = F; 
%  Close Callback
 if btn.UserData == 1
      bOK=false;
 end
end
% Close dialog box
close(S.d)
end

    

          
           