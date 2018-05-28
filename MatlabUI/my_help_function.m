function my_help_function(src,event,data) 
    menu=get(src,'Parent');
    f=get(menu,'Parent');
    uiresume(data.f);
    open('UserManual.pdf');
    src.UserData = 1;
end