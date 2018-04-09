function my_visulines_func(src,event,data) 
% Callback function for "Visualize Lines" (eh2_lines_vis)
uiresume(data.f)
% Open new dialog window
S.d = dialog('Position',[200 200 1000 500],'Name','Add Line',...
    'WindowStyle','normal');

% Load created lines file
 A = load('lines.mat');  
 % Determine how many lines are specified
 n = size(A.save_lines); 
 % Set first column to false
 for i = 1:n(1)
     A.save_lines{i,1} = false; 
 end
% Make UI table to display the placement lines from the .mat file. 
t = uitable(S.d,'Data',A.save_lines,'Position',[50 50 700 400]);   
t.ColumnName = {'Flip','X Start','X  End',...
                'Y  Start','Y  End',...
                'Z  Start','Z  End',};
% Make table editable
t.ColumnEditable = true;



% Set tag value to 1 (for use in main code)
set(src,'Tag','1')
% src.UserData = t.Data; 
S.lines = t.Data; 

btn_vis = uicontrol('Parent',S.d,...
               'Position',[200 20 70 25],...
               'String','Visualize',...
               'Callback',{@my_visualize_function,S,data});       
btn = uicontrol('Parent',S.d,...
               'Position',[600 20 70 25],...
               'String','Close',...
               'Callback',{@my_exit_functions,S});            
           
           
              

% guidata(src,data.accepted_lines); 

bOK = true; 
while(bOK)
    uiwait(S.d)
    src.UserData = btn_vis.UserData; 
    if btn.UserData == 1
        bOK = false; 
    end
end
close(S.d)