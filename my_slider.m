function my_slider()
hfig = figure();
setappdata(hfig,'slidervalue',0);
setappdata(hfig,'difference',1);

slider = uicontrol('Parent', hfig,'Style','slider',...
         'Units','normalized',...
         'Position',[0.3 0.5 0.4 0.1],...
         'Tag','slider1',...
         'Callback',@slider_callback);
     
button = uicontrol('Parent', hfig,'Style','pushbutton',...
         'Units','normalized',...
         'Position',[0.4 0.3 0.2 0.1],...
         'String','Display Values',...
         'Callback',@button_callback);
end

function slider_callback(hObject,eventdata)
	diffMax = hObject.Max - hObject.Value;
	setappdata(hObject.Parent,'slidervalue',hObject.Value);
	setappdata(hObject.Parent,'difference',diffMax);
	% For R2014a and earlier: 
	% maxval = get(hObject,'Max');  
	% currval = get(hObject,'Value');  
	% diffMax = maxval - currval;   
	% parentfig = get(hObject,'Parent');  
	% setappdata(parentfig,'slidervalue',currval); 
	% setappdata(parentfig,'difference',diffMax); 
end

function button_callback(hObject,eventdata)
	currentval = getappdata(hObject.Parent,'slidervalue');
	diffval = getappdata(hObject.Parent,'difference');
	% For R2014a and earlier:
	% parentfig = get(hObject,'Parent');
	% currentval = getappdata(parentfig,'slidervalue');
	% diffval = getappdata(parentfig,'difference');

	display([currentval diffval]);
end