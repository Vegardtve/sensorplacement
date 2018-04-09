function addlinefunc(src,event,data)
% Callback function for "Add Lines" (eh2_lines_add)

% Resume - Respond to uiwait in while loop
uiresume(data.f)
% Open Dialog Box
S.d = dialog('Position',[200 50 1000 600],'Name','Add Lines',...
    'WindowStyle','normal');

% Initialize table values
tab_data = {false, 0, 0, -6 , -6, 0, 24;...
            false, 0, 18, -6 , -6, 0, 0;
            false, 0, 14.5, -6 , -6, 24, 2.5;
            false, 1, 1, 1 , 1, 1, 1;
            false, 1, 1, 1 , 1, 1, 1};
                             
t = uitable(S.d,'Data',tab_data,'Position',[50 50 700 500]);   
t.ColumnName = {'Accepted','X Start','X  End',...
                'Y  Start','Y  End',...
                'Z  Start','Z  End'};
t.ColumnEditable = true;        % Make table elements editable

   
           
%%%%%% BUTTONS - USER OBJECTS           
btn = uicontrol('Parent',S.d,...
               'Position',[600 20 70 25],...
               'String','Close',...
               'Callback',{@my_exit_functions,S}); 

% Figure with the problem space displayed in 3D
figure('Name', 'Figure For Adding Lines','NumberTitle','off');
data.tp = vrifs2patch(data.w.layout.children.geometry);
data.tp.FaceColor = 'red';
rotate3d on
camorbit(0, -90);
bOK = true;
% While loop to allow continuous use
while(bOK)
% Wait for UI response
uiwait(S.d)

% Store data as UserData in the object
S.tabledata = t.Data; 
src.UserData = S.tabledata; 

% Close Callback
 if ~isempty(btn.UserData)
      bOK=false;
 end
   
end
% Close dialog box
close(S.d);   

end