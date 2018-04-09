function my_exit_function(src,event,data) 
    menu=get(src,'Parent');
    f=get(menu,'Parent');
    uiresume(data.f);
    src.UserData = 1;
end