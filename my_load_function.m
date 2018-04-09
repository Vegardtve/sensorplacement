function my_load_function(src,event,data) 
    menu=get(src,'Parent');
    f=get(menu,'Parent');
    uiresume(f);
    src.UserData = 1;
end