%% Table Handler 
clear; 
clc; 
load IRC5_table.mat; 
A = IRC5DualCabinetpoints; 
Col1 = A.VarName1; 
Col2 = A.VarName2; 
Col3 = A.VarName3; 
Col4 = A.VarName4; 

N = 5398; 
str1 = zeros(N,3);

for i = 1:N
%     Col1{i}
    str1(i,1:3) = str2num(Col1{i}); 
    str2(i,1:3) = str2num(Col2{i}); 
    str3(i,1:3) = str2num(Col3{i}); 
    str4(i,1:3) = str2num(Col4{i}); 
end

x = [str1(:,1); str2(:,1); str3(:,1); str4(:,1)]; 
y = [str1(:,2); str2(:,2); str3(:,2); str4(:,2)]; 
z = [str1(:,3); str2(:,3); str3(:,3); str4(:,3)]; 


figure
scatter3(x,y,z)


