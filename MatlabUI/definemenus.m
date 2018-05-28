% Drop Down Menu - File 
mh_f = uimenu(data.f,'Label','File'); % Drop Down Menu
% Drop Down Items
eh2_f = uimenu(mh_f,'Label','Exit','Callback',{@my_exit_function,data}); 

% Drop Down Menu - Edit 
mh_file = uimenu(data.f,'Label','Edit'); % Drop Down Menu

eh0_file = uimenu(mh_file,'Label','Edit VRML','Callback','vredit(data.A)');

eh1_file_floor = uimenu(mh_file,'Label','Floor');
eh1_file = uimenu(eh1_file_floor,'Label','Add Floor',...
    'Callback',{@addbackground,data}); 

% Dropw down (Edit -> Camera)
eh2_camera = uimenu(mh_file,'Label','Camera'); 
eh2_camera_add = uimenu(eh2_camera,'Label','Add Camera',...
    'Callback',{@my_cameradd_function,data}); 
eh2_camera_visu = uimenu(eh2_camera,'Label','List of Added Cameras',...
    'Callback',{@my_cameralist_function,data}); 
eh2_lines_add = uimenu(eh2_camera,'Label','Add Lines',...
    'Callback',{@addlinefunc,data}); 
eh2_lines_vis = uimenu(eh2_camera,'Label','Visualize Lines',...
    'Callback',{@my_visulines_func,data}); 

% Drop down (Edit -> Region Of Interest)
eh2_roi = uimenu(mh_file,'Label','Region Of Interest'); 
eh2_roi_define = uimenu(eh2_roi,'Label','Setup Region Of Interest',...
    'Callback',{@my_roidefine_function,data});
eh2_roi_add_1 = uimenu(eh2_roi,'Label','Add Region Of Interest',...
    'Callback',{@my_roiadd_function,data}); 
eh2_roi_visu = uimenu(eh2_roi,'Label','Visualize Region Of Interest',...
    'Callback',{@my_roivisu_function,data}); 

% Drop Down Menu - Optimization 
mh_optim = uimenu(data.f,'Label','Optimization'); % Drop Down Menu
eh_optim = uimenu(mh_optim,'Label','Define Parameters',...
    'Callback',{@my_definepara_function,data}); 
eh0_optim = uimenu(mh_optim,'Label','Generate JSON',...
    'Callback',{@my_setuppara_function,data});

% Drop Down Menu - Visualization 
mh_visual = uimenu(data.f,'Label','Visualization'); % Drop Down Menu

eh0_visual = uimenu(mh_visual,'Label','Load Optimization Results',...
    'Callback',{@my_visuresult_function,data});

% Drop Down Menu - Resources 
mh_resources = uimenu(data.f,'Label','Resources'); % Drop Down Menu

eh0_resources = uimenu(mh_resources,'Label','About',...
    'Callback',{@my_about_function,data});
eh1_resources = uimenu(mh_resources,'Label','Help',...
    'Callback',{@my_help_function,data});

