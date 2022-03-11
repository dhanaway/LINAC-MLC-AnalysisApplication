% ---------------------------------------------------------
% dynNumBeamOn
% ---------------------------------------------------------
% Dynalog Analysis Package
% Michael Hughes 2010-2011
% ---------------------------------------------------------
% Returns the number of Beam-Ons which occurred.
%
% Syntax: numHoldOff = dynNumBeamOn(dynData)
%
% dynData : struct from dynRead
% ---------------------------------------------------------


function [num] = dynNumBeamOn(dynData) 
	
	num = sum(sum(dynData.beamOn(:,1) == 1));

end