function my_exit_functions(src,event,S) 
%     menu=get(src,'Parent');
%     f=get(menu,'Parent');
    uiresume(S.d);
    src.UserData = 1;
end