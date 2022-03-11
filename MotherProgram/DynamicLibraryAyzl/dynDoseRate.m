% ---------------------------------------------------------
% dynDoseRate
% ---------------------------------------------------------
% Dynalog Analysis Package
% Michael Hughes 2010-2011
% ---------------------------------------------------------
% Calculates the dose rate at all dose fractions. Returns
% a vector of length 'numFractions - 1'.
%
% Results is expressed in units of fraction of total MU per 
% minute.
%
% For example a result of 0.5, would mean a dose rate of
% 50 MU/min if the total MU was 100.
%
% Syntax: dynDoseRate = dynDoseRate(dynData)
%
% dynData : 	Struct from dynRead 
%
% ---------------------------------------------------------

function [doseRate] = dynDoseRate(dynData) 
	
	%If time between records has not been set as a constant, set it to
	%a default of 50 us.
	global recordSpacing;
	if isempty(recordSpacing)
		recordIncrement = 0.05;		
	else
	
	for i = 1:dynData.numFractions - 1
		doseRate(i) = (dynData.doseFraction(i+1,1) - dynData.doseFraction(i,1)) * 60 / recordIncrement;
	end
				
end

		
