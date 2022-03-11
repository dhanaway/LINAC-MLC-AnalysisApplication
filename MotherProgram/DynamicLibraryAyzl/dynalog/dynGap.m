% ---------------------------------------------------------
% dynGap
% ---------------------------------------------------------
% Dynalog Analysis Package
% Michael Hughes 2010-2011
% ---------------------------------------------------------
% Calculates the gap between leaves of two banks at all 
% dose fractions.
%
% Requires that Bank A positions < Bank B positions, 
% otherwise returned gaps will be negative.
%
% If relationship between banks is unknown, use dynGapAbs 
% which calculates the magnitude of the gap only.
%
% Syntax: gap = dynGap(dynDataA, dynDataB)
%
% dynDataA/B : Structs from dynRead for Banks A and B
%
% Returns struct of two arrays:
%	.planGap   : planned gap
%   .actualGap : actual gap
% ---------------------------------------------------------

function [gap] = dynGap(bankA, bankB) 

	planGap = bankA.planPosition + bankB.planPosition;
	actualGap = bankA.actualPosition + bankB.actualPosition;
	gap = struct('planGap', planGap, 'actualGap', actualGap);
			
end

		
