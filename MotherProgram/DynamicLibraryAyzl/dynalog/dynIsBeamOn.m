% ---------------------------------------------------------
% dynIsBeamOn
% ---------------------------------------------------------
% Dyanlog Analysis Package
% Michael Hughes 2010-2011
% ---------------------------------------------------------
% Checks if beam was on for specified dose fraction.
%
% Returns 1 if Beam On, 0 if Beam Off
%
% Syntax: isBeamOn = dynIsBeamOn(dynData, fraction)
%
% dynData :  struct from dynRead
% fraction : dose fraction to check
% ---------------------------------------------------------

function [isOn] = dynIsBeamOn(dynData, fraction) 

	isOn = (dynData.beamOn(fraction,1) ~= 0);
		
end
