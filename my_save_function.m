function my_save_function(src,event,data) 
    menu=get(src,'Parent');
    f=get(menu,'Parent');
    uiresume(f);
    src.UserData = 1;
end