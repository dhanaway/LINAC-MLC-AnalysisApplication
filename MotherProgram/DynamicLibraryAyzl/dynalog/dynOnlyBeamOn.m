% ---------------------------------------------------------
% dynOnlyBeamOn
% ---------------------------------------------------------
% Dynalog Analysis Package
% Michael Hughes 2010-2011
% ---------------------------------------------------------
% Removes fractions in which beam was planned to be off
% from dynData struct.
%
% Does NOT remove beam hold-offs (i.e. unplanned beam offs).
%
% Syntax: dynDataBeamOn = dynOnlyBeamOn(dynData)
%
% dynDataBeamOn : 	output dynData struct
% dynData : 		struct from dynRead
% ---------------------------------------------------------

function [onlyOn] = dynOnlyBeamOn(dynData) 

	onlyOn = dynData;
	i = 0;
	while (i < onlyOn.numFractions)
        
		i = i + 1;
		%If beam is not on delete these fractions from the struct array
		if (onlyOn.beamOn(i,1) == 0)
		
			onlyOn.doseFraction(i,:) = [];
			onlyOn.DVASegment(i,:) = [];
			onlyOn.beamHoldOff(i,:) = [];
			onlyOn.beamOn(i,:) = [];
			onlyOn.previousSegment(i,:) = [];
			onlyOn.nextSegment(i,:) = [];
			onlyOn.gantryRotation(i,:) = [];
			onlyOn.collimatorRotation(i,:) = [];
			onlyOn.y1JawPosition(i,:) = [];
			onlyOn.y2JawPosition(i,:) = [];
			onlyOn.x1JawPosition(i,:) = [];
			onlyOn.x2JawPosition(i,:) = [];
			onlyOn.carriagePlanPosition(i,:) = [];    
			onlyOn.carriageActualPosition (i,:) = [];
			onlyOn.planPosition(i,:) = [];
			onlyOn.actualPosition(i,:) = [];
			onlyOn.previousPosition(i,:) = [];
			onlyOn.nextPosition(i,:) = [];
			onlyOn.leafNumber(i,:) =[];			
			onlyOn.numFractions = onlyOn.numFractions - 1;
			i = i - 1;
		else
			
		end
	end
		
end
