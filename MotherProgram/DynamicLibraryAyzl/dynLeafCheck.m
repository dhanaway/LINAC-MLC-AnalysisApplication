% ---------------------------------------------------------
% dynLeafCheck
% ---------------------------------------------------------
% Dynalog Analysis Package
% Michael Hughes 2010-2011
% ---------------------------------------------------------
% Checks each leaf against a tolerance. Returns positive
% if 'fractions' of dose fractions show a leaf position
% error greater than 'tolerance'.
%
% Syntax: leafTest = dynLeafCheck(dynData, tolerance, segments)
%
% leafTest:	 vector giving with boolean value for each leaf
% dynData:   struct from dynRead
% tolerance: error tolerance
% fractions: fraction of dose fractions which are allowed
%			 to be out of tolerance
% ---------------------------------------------------------
		
function [passFail] = dynLeafCheck(bank, tolerance, fractions)

	%Calculate number of allowed tolerance breaches
	fractionsAllowed = fractions * (bank.numFractions);
	
	%Find number of fails for each leaf
	numFails = sum(abs(dynError(bank)) > tolerance);
		
	%Check if greater than allowed number of fractions
	passFail = (numFails > fractionsAllowed);
	
end
	
	