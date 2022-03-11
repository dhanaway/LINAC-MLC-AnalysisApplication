% ---------------------------------------------------------
% dynGapCheck
% ---------------------------------------------------------
% Dynalog Analysis Package
% Michael Hughes 2010-2011
% ---------------------------------------------------------
% For each leaf, checks gap size error at each dose fraction 
% against a tolerance. 
%
% Returns a vector, true for leaves which have fraction 
% 'fractions' of dose fractions with an error greater than 
% or equal to 'tolerance'.
%
% Syntax: 
% gapCheck = dynGapCheck(dynDataA, dynDataB, tolerance, segments)
%
% gapCheck   : vector of booleans (1 to .numLeaves)
% dynDataA/B : structs from dynRead for Banks A and B
% tolerance  : error tolerance
% fractions  : fraction of dose fractions which are allowed
%			    to be out of tolerance for each leaf.
% ---------------------------------------------------------
		
function [passFail] = dynGapCheck(bankA, bankB, tolerance, fractions)
	
	%Find number of fails for each leaf
	numFails = sum(abs(dynGapError(bankA, bankB)) > tolerance);
		
	%Check if greater than allowed number of fractions
	allowedFractions = fractions * bankA.numFractions;
	passFail = (numFails >= allowedFractions);
	
end
	
	