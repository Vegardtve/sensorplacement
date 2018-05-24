function addbackground(src,event,data) 
% Callback function for "Add Floor" (eh1_file)

% Resume - Respond to uiwait in while loop
    uiresume(data.f);
% Open the vr world and set up as a patch object in a figure
    open(data.w)
    figure('Name', 'Figure For Adding Floor','NumberTitle','off');
    data.tp = vrifs2patch(data.w.layout.children.geometry);
    data.tp.FaceColor = 'red';
    axs = gca;
    axs.XGrid = 'on';
    axs.YGrid = 'on';
    axs.ZGrid = 'on';
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    ylim([-10 0])
    camorbit(0, -90);
    units = 'centimeters';
    rotate3d on
    
    % Create input dialog box
    prompt = {'X Corner Coordinates',...
              'Y Corner Coordinates',...
              'Z Corner Coordinates'}; 
    num_lines = 2; 
    dlg_title = 'Create Floor'; 
    defaultans = {'0 18.01 18 14.51 0.01',...
                  '0 0 0 0 0',...
                  '0 0 5 2.5 24'}; 
    options.Resize = 'on'; 
    options.WindowStyle = 'normal'; 
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
    X_Val = str2num(answer{1}); 
    Y_Val = str2num(answer{2});
    Z_Val  = str2num(answer{3}); 

    % Convert values to patch object
    P = patch(X_Val,Y_Val,Z_Val,'k');
    
    % Store patch data in guidata
    data.P = {X_Val,Y_Val,Z_Val}; 
    set(src,'Tag','1')
    guidata(src,data.P)
end
