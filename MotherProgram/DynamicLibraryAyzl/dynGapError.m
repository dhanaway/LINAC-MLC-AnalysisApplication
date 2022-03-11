% ---------------------------------------------------------
% dynGapError
% ---------------------------------------------------------
% Dynalog Analysis Package
% Michael Hughes 2010-2011
% ---------------------------------------------------------
% Returns a matrix of differences between planned
% and actual gap sizes.
%
% Syntax: gapError = dynGapError(dynDataA,dynDataB)
%
% dynDataA/B:   structs from dynRead for Banks A and B
% ---------------------------------------------------------

function [gapError] = dynGapError(bankA, bankB) 
	
    gapRet = dynGap(bankA, bankB);
	gapError = (gapRet.actualGap - gapRet.planGap);
					
end
