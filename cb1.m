function cb1(src,event,S)
%       menu=get(src,'Parent');
%     f=get(menu,'Parent');
%     uiresume(S.d);
%     val = get(src,'String'); 
%     if val == 0
%         src.UserData = 'NaN'; 
%     else
%         ser.UserData = val; 
%     end
  src.UserData = get(src, 'String');   
  
end