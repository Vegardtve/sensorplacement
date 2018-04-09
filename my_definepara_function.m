function my_definepara_function(src,event,data)
uiresume(data.f)

prompt = {'Floor Height','Top Height:', 'Vertical Data Points',...
    'Placement Lines Accuracy'};
dlg_title = 'Specify Optimization Parameters';
num_lines = 1;
defaultans = {'0','-6','10','2'};
options.Resize = 'on'; 
options.WindowStyle = 'normal'; 
answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);

fh = str2double(answer{1}); 
th = str2double(answer{2}); 
vdp = str2double(answer{3}); 
pla = str2double(answer{4}); 

src.UserData = [fh th vdp pla]; 
set(src,'Tag','1'); 
end