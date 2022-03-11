% ---------------------------------------------------------
% dynRMSError
% ---------------------------------------------------------
% Dynalog Analysis Package
% Michael Hughes 2010-2011
% ---------------------------------------------------------
% Calculates RMS of difference between actual and planned
% positions for all leaves and dose fractions.
%
% Syntax: RMSError = dynRMSError(dynDataA, dynDataB)
%
% dynDataA/B : struct from dynData for banks A and B.
% ---------------------------------------------------------

function [RMS] = dynRMSError(bankA) 
	
	RMS = sqrt((sum(sum(dynError(bankA).^2) )) / (bankA.numFractions .* bankA.numLeaves));
				
end
