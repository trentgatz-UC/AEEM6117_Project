
%****************************************************************************
 % A 'GENERIC' ALGORITHM IN MATLAB CODE THAT RETURNS DEFUZZIFIED Decision Applied
 
 % to MATLAB's Tipper Problem. THIS PROGRAM WAS WRITTEN BY KELLY COHEN WITHIN THE FRAMEWORK 
 
 % The SOFT COMPUTING BASED AI Class Taught at UC/CEAS
 %               -------------------------------------
 %             -  LAST UPDATE : September 14, 2019     -
 %               -------------------------------------
 %****************************************************************************
%
function mu = triangle(x,ce,re,le);    %TRIANGLE MEMBERSHIP FUNCTION

if x >= le & x <= ce,
   mu = (x - le)/(ce - le);
elseif x >= ce & x <= re,
   mu = (re - x)/(re - ce);
else
 mu = 0;
end

