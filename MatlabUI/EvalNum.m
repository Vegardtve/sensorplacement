function [panx,camx] = EvalNum(npans,i)
% function to translate the combinations indices 
% to the indices of the camera position and pan arrays

ic = i - 1; 
pc = floor(ic/npans);
panx = i - pc*npans;
camx = pc + 1;