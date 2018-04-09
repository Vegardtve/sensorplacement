f = figure;
f.MenuBar = 'none';    % Hide standard menu bar menus.
mh = uimenu(f,'Label','My menu');
eh1 = uimenu(mh,'Label','Item 1');
eh2 = uimenu(mh,'Label','Item 2','Checked','on');
