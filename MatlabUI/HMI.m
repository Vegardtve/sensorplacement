%%% Author: Vegard Tveit
%%% Date: 19.05.2018
%%% Version: 3.0
%%% Comment: Added minor functionalities
%%% TODO:
%%%       - Add Built-in Genetic Algorithm                                                      
%%%       - Improve Visualization
%%%       - Fig bugs and minimize delay

% Initialize
clc; 
clear;
close all;
c_cam = 0; 
c_roi = 0; 


% Setup GUI Figure to fit screen
figure_setup;

% Open the VRML world and display in a canvas
vrml_setup;

% Set up toolbar (Left side)
gui_tools_setup; 

% Define GUI drop-down menus
definemenus;    


bOK=true;

while(bOK)
    % Wait for response from GUI
    uiwait(data.f);         

    eh1_boolean = str2num(get(eh1_file,'Tag'));

% Save coordinates for floor and add to vr world
    if eh1_boolean == 1
        data.floorpatch = guidata(eh1_file); 
        X_v = data.floorpatch{1}; 
        Y_v = data.floorpatch{2}; 
        Z_v = data.floorpatch{3};
        data.P = patch(X_v,Y_v,Z_v,'k'); 
        vrpatch2ifs(data.P,data.w); 
        corners = [X_v; Y_v; Z_v];
        save('corners.mat','corners'); 
    end 

% Add specified camera data to camera matrix
    data.bool_camera = str2num(get(eh2_camera_add,'Tag')); 
    if data.bool_camera == 1
        c_cam = c_cam + 1; 
        data.cam(c_cam,1:3) = eh2_camera_add.UserData;
        cam = data.cam(1:end,1:3); 
        save('added_camera.mat','cam'); 
        set(eh2_camera_add,'Tag','0'); 
        data.bool_camera = 0; 
    end
    
%     if ~isempty(eh2_camera_add.UserData)
%         data.cam(c_cam,1:3) = eh2_camera_add.UserData;
%         data.bool_camera = 0; 
%         cam = data.cam(2:end,1:3); 
%         save('added_camera.mat','cam'); 
%     end
    data.bool_roi = str2num(get(eh2_roi_add_1,'Tag')); 
    if data.bool_roi == 1
        c_roi = c_roi + 1; 
        roi{c_roi} = eh2_roi_add_1.UserData
%         roi(c_roi).roipatch = eh2_roi_add_1.UserData.roi
        save('roi.mat','roi')
        set(eh2_roi_add_1,'Tag','0'); 
        data.bool_roi = 0; 
        cubes = getappdata(eh2_roi_add_1,'cubes'); 
        c = cell2mat(cubes); 
        save('fishnet.mat','c'); 
    end
    
    
% Add accepted lines for camera placement    
    if ~isempty(eh2_lines_add.UserData)
        data.lines = eh2_lines_add.UserData;
        n = size(data.lines); 
        c = 0; 
        for i = 1:n(1)
            if data.lines{i,1} == 1
                c = c + 1; 
                data.accepted_lines(c,:) = data.lines(i,:);
                save_lines = data.accepted_lines; 
                save('lines.mat','save_lines');
            end
        end
    end
    
    % Visualize Lines Callback
    eh2vis_boolean = str2num(get(eh2_lines_vis,'Tag'));
    if eh2vis_boolean == 1
        data.lines_flip = eh2_lines_vis.UserData;    
    end
    
    if ~isempty(eh2_roi_define)
        roidata = eh2_roi_define.UserData;
        save('roi_setup.mat','roidata')
    end
    
    % Optimization Setup
    optsetp_bool = str2num(get(eh_optim,'Tag')); 
    if optsetp_bool == 1
        optsetup = eh_optim.UserData; 
        save('Optimsetup.mat','optsetup'); 
        set(eh_optim,'Tag','0'); 
        optsetp_bool = 0; 
    end
    % Data Points Annotations
    json_bool = str2num(get(eh0_optim,'Tag'));
    if json_bool == 1
        cam_ad = load('added_camera.mat');
        optim = eh0_optim.UserData;
        % Optim:    Column 1: Annotations
        %           Column 2: Camera points x
        %           Column 3: Camera points z
        %           Column 4: Data Points x
        %           Column 5: Data points y
        %           Column 6: Data points z
        %           Column 7: Camera points y
        optim{8} = cam_ad.cam;
        savejson('',optim,'full_0705.json');
        set(eh0_optim,'Tag','0'); 
        json_bool = 0; 
    end
        
% Check if menu callbacks are correct. Display menu names if clicked
%    callback_functions; 
    

% Exit Callback
    if eh2_f.UserData == 1
      bOK=false;
    end
    
   
    pause(0.05)
end



% close(data.f);

