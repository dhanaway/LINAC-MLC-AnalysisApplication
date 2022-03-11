% ---------------------------------------------------------
% dynRMSGapError
% ---------------------------------------------------------
% Dynalog Analysis Package
% Michael Hughes 2010-2011
% ---------------------------------------------------------
% Calculates RMS of difference between actual and planned
% gap sizes for all leaves and dose fractions.
%
% Syntax: RMSGapError = dynRMSGapError(dynDataA, dynDataB)
%
% dynDataA/B : struct from dynData for banks A and B.
% ---------------------------------------------------------

function [RMS] = dynRMSGapError(bankA, bankB) 
	
	RMS = sqrt((sum(sum(dynGapError(bankA, bankB).^2) )) / (bankA.numFractions .* bankA.numLeaves));
				
end
