% ---------------------------------------------------------
% dynNumHoldOff
% ---------------------------------------------------------
% Dynalog Analysis Package
% Michael Hughes 2010-2011
% ---------------------------------------------------------
% Returns the number of Beam Hold Offs which occurred.
%
% Syntax: numHoldOff = dynNumHoldOff(dynData)
%
% dynData : struct from dynRead
% ---------------------------------------------------------

function [num] = dynNumHoldOff(dynData) 
	
	num = sum(sum(dynData.beamHoldOff(:,1) == 1));
		
end
