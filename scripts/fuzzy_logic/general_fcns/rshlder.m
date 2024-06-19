%****************************************************************************
 % A 'GENERIC' ALGORITHM IN MATLAB CODE THAT RETURNS DEFUZZIFIED Decision Applied
 
 % to MATLAB's Tipper Problem. THIS PROGRAM WAS WRITTEN BY KELLY COHEN WITHIN THE FRAMEWORK 
 
 % The SOFT COMPUTING BASED AI Class Taught at UC/CEAS
 %               -------------------------------------
 %             -  LAST UPDATE : September 14, 2019     -
 %               -------------------------------------
 %****************************************************************************
%
function mur = rshlder(x,cer,rer,ler)   %right shoulder membership function

if x>=ler & x<cer,
mur = (x-ler)/(cer-ler);
elseif x>=cer,
mur = 1;
else
mur = 0;
end

