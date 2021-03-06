% ------------------------------------------------------------
% dynFluence
% ------------------------------------------------------------
% Dyanlog Analysis Package
% Michael Hughes 2010-2011
% ------------------------------------------------------------
% Generates a fluence map from two dynData structs. Fluence values
% are scaled essentially arbitrarily and cannot be directly 
% compared with other fluence maps.
%
% Syntax:
% [mapPlanned mapActual] = dynFluence(dynDataA, dynDataB)
%
% mapPlanned : 	Fluence map which was planned
% mapActual : 	Fluence map which was generated
% dynDataA/B : 	Structs from dynRead for banks A and B
% scaleFactor:  Pixels per mm in Fluence map
% timeInterval: Interpolation factor (1 for no interpolation,
%				> 1 for interpolation (slower).
% ------------------------------------------------------------

function [mapPlanned mapActual] = dynFluence(bankA, bankB, scaleFactor, timeInterval) 
	%If user has not called a function to define the leaf widths, use some default values:
	global varianNumLeaves;
	global varianLeafWidth;
	if isempty(varianNumLeaves)
		numLeaves = 60;
	else
		numLeaves = varianNumLeaves;
	end
	
	if isempty(varianLeafWidth) || (length(varianLeafWidth) < varianNumLeaves)
		leafWidth(1:10) = 10;
		leafWidth(11:50) = 5;
		leafWidth(51:60) = 10;
	else
		leafWidth = varianLeafWidth;
	end


	%Allow a border around calculations of fluence in case of rounding errors.
	safetyMargin = 10;
		
	%The max size of the field, depends on leaf size and max travel distance
	fieldWidth = scaleFactor * 2 * round(max(max([ abs(bankA.actualPosition(:)) abs(bankB.actualPosition(:)) abs(bankA.planPosition(:)) abs(bankB.planPosition(:))]))) + 2 * safetyMargin;
	fieldHeight = scaleFactor * sum(leafWidth(bankA.leafNumber(1,:))) + safetyMargin;
	centrePosX = fieldWidth / 2;
	centrePosY = fieldHeight / 2;

	mapPlanned = zeros(fieldWidth, fieldHeight);
	mapActual = zeros(fieldWidth, fieldHeight);
	
	%Calculate planned fluence map by adding the fluence generated by each dose fraction
	for leaf = 1:bankA.numLeaves
       
		APos = bankA.planPosition(:,leaf)';
		BPos = bankB.planPosition(:,leaf)';
		
		planPositionA(:,leaf) = interp1(1:bankA.numFractions, bankA.planPosition(:,leaf)', 1:1/timeInterval:bankA.numFractions);
		planPositionB(:,leaf) = interp1(1:bankB.numFractions, bankB.planPosition(:,leaf)', 1:1/timeInterval:bankB.numFractions);
		actualPositionA(:,leaf) = interp1(1:bankA.numFractions, bankA.actualPosition(:,leaf), 1:1/timeInterval:bankA.numFractions);
		actualPositionB(:,leaf) = interp1(1:bankB.numFractions, bankB.actualPosition(:,leaf)', 1:1/timeInterval:bankB.numFractions);
    end
    disp(bankA.numFractions*timeInterval)
	for timeFraction = 1:bankA.numFractions * timeInterval 

		fraction = max(round(timeFraction / timeInterval),1);
		%Calculate interpolate leaf positions
				
		%Only if beam is on and beam hold off is off:-
		if (bankA.beamOn(fraction, 1) && not(bankA.beamHoldOff(fraction, 1)))
		
			%Calculate physical position of left-most leaf. Allow a ten pixel margin to prevent rounding errors.
			leafPos = centrePosY - fieldHeight / 2 + safetyMargin;
		
			%Work out current dose-rate
			if (fraction > 1)
				doseRate = bankA.doseFraction(fraction,1) - bankA.doseFraction(fraction - 1,1);
			else
				doseRate = bankA.doseFraction(fraction,1);
			end
  
			for leaf = 1:bankA.numLeaves
                                    
				startExposePlanned = centrePosX - round(scaleFactor *(planPositionA(timeFraction,leaf)));
				endExposePlanned = centrePosX + round(scaleFactor * (planPositionB(timeFraction,leaf)));
							
				startExposeActual =  centrePosX - round(scaleFactor *(actualPositionA(timeFraction,leaf)));
				endExposeActual = centrePosX + round(scaleFactor * (actualPositionB(timeFraction,leaf)));
							
				%Work out physical co-ordinate from leaf number
				startLeaf = round(leafPos);
				endLeaf = round(leafPos + (leafWidth(bankA.leafNumber(1,leaf)) * scaleFactor)) - 1;
				leafPos = leafPos + leafWidth(bankA.leafNumber(1,leaf)) * scaleFactor;
				
				%Add fluence to map from this dose fraction
                mapPlanned(fieldWidth - endExposePlanned:fieldWidth - startExposePlanned,startLeaf:endLeaf) = mapPlanned(fieldWidth - endExposePlanned:fieldWidth - startExposePlanned, startLeaf:endLeaf) + doseRate;
				mapActual(fieldWidth - endExposeActual:fieldWidth - startExposeActual,startLeaf:endLeaf) = mapActual(fieldWidth - endExposeActual:fieldWidth - startExposeActual, startLeaf:endLeaf) + doseRate;
			end
		end
	end	
	
			
end

		
