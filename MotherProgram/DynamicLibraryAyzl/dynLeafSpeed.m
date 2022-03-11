% ---------------------------------------------------------
% dynLeafSpeed
% ---------------------------------------------------------
% Dynalog Analysis Package
% Michael Hughes 2010-2011
% ---------------------------------------------------------
% Calculates speed of each leaf during each dose fraction.
% If delivery time (totalTime) is specified, time increment
% between records is calculated, otherwise it is assumed to 
% be 50 us. In general, the total time should be specified 
% for data extracted from MLC files (where record increment
% time is variable) but not specified for data extracted 
% from dynalog files (where it fixed).
%
% Syntax:	leafSpeed = dynLeafSpeed(dynDataA, [totalTime])
%	
%	leafSpeed: 	2D Array of size (dynData.numFractions - 1) x 
%			    (dynData.numLeaves) containing leaf speeds in 
%			    mm/s for all fractions. 
%	dynDataA:	struct from dynRead.
%  	totalTime:  Optional - total time for field delivery 
% ------------------------------------------------------------

function leafSpeed = dynLeafSpeed(dynData, varargin)
	
	global recordSpacing
	if length(varargin) ~= 0
		%If user specifies time of treatment, calculate time between records
		totalTime = varargin{1};
		recordIncrement = totalTime / dynData.numFractions;
	else
		%If user does not specific treatment time, and time between records has not been set as a constant, set it to
		%a default of 50 us
		if isempty(recordSpacing)
			recordIncrement = 0.05;		
		else
			recordIncrement = recordSpacing;
		end
	end

	%Calculate leaf speeds
	for f = 1:dynData.numFractions - 1
		leafSpeed(f,:) = abs(dynData.actualPosition(f,:) - dynData.actualPosition(f + 1,:)) / recordIncrement;
	end
			
end

	