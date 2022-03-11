% ---------------------------------------------------------
% dynGapAbs
% ---------------------------------------------------------
% Dynalog Analysis Package
% Michael Hughes 2010-2011
% ---------------------------------------------------------
% Calculates magnitude of gap between leaves of two banks at 
% all dose fractions.
%
% To determine sign of gap (which should be +ve unless there
% is an error) use dynGap.
%
% Syntax: gapAbs = dynGapAbs(dynDataA, dynDataB)
%
% dynDataA/B : Structs from dynRead for Banks A and B
%
% Returns struct of two arrays:
%	.planGap   : planned gap
%   .actualGap : actual gap
% ---------------------------------------------------------

function [gap] = dynGapAbs(bankA, bankB) 

	planGap = abs(bankA.planPosition - bankB.planPosition);
	actualGap = abs(bankA.actualPosition - bankB.actualPosition);
	gap = struct('planGap', planGap, 'actualGap', actualGap);
		
end
