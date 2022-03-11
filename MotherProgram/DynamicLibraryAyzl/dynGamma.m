% ------------------------------------------------------------
% dynGamma
% ------------------------------------------------------------
% Dyanlog Analysis Package
% Michael Hughes 2010-2011
% ------------------------------------------------------------
% Calculates gamma analysis map between two fluence maps. 
%
% For description of technique see: 
% Low, D.A. et al., Med. Phys. 25, p656(1998).
%
% Large errors will occur if distanceCriterion is comparable to the interpolated
% pixel size. Avoid this by specifying a higher interpFactor.
%
% Syntax:
% gammaMap = dynGamma(mapA, mapB, doseCriterion, distanceCriterion, normDose, threshold);
%	
% gammaMap: 			2D Array containing gamma indices
% mapA, mapB:			2D Arrays containing fluence maps
% doseCriterion:		The dose criterion to test (as a fraction of normDose)
% distanceCriterion: 	The distance criterion to test (in pixels)
% normDose: 			The fluence value which will be taken as 100%
% threshold:			Points with dose less than this fraction of normDose will not be evaluated
% interpFactor:			Maps will be interpolate by a factor of 2^interpFactor
% ------------------------------------------------------------

function [gamma] = dynGamma(mapA, mapB, doseCriterion, distanceCriterion, normDose, threshold, interpFactor) 

	%Interpolate maps
	useMapA = interp2(mapA, interpFactor);
	useMapB = interp2(mapB, interpFactor);

	%Check points out as far as 2 x distance criterion. This setting will not affect pass/fail rate but may affect values of
	%gamma indices for failing points, so set higher if requires (will increase processing time approximately with the square of the
	%multiplier)
	trialSize = distanceCriterion * 2^interpFactor * 2;
	
	%Zero cells below gamma threshold
	useMapA(useMapA < (threshold * normDose)) = 0;
	useMapB(useMapA < (threshold * normDose)) = 0;
	
	%Get size of maps
	[xSize ySize] = size(useMapA);
	
	%Create larger maps to allow the circshift to work
	testMapA = zeros(xSize + trialSize * 2, ySize + trialSize * 2);
	testMapB = zeros(xSize + trialSize * 2, ySize + trialSize * 2);
	
	%Give the larger maps big dose differences so they will never be chosen as the gamma index
	testMapA(:,:) = 10^8;
	testMapB(:,:) = -(10^8);
	
	%Copy original fluence maps onto test maps
	testMapA(trialSize + 1:trialSize + xSize,trialSize + 1:trialSize + ySize) = useMapA;
	testMapB(trialSize + 1:trialSize + xSize,trialSize + 1:trialSize + ySize) = useMapB;

	%Initialise gamma value array	
	gValue = zeros(xSize + trialSize * 2, ySize + trialSize * 2);
	gValue(:,:) = 100;
	
	%Initialise dose difference array	
	doseDifference = zeros(xSize + trialSize * 2, ySize + trialSize * 2);

	%Loop through each trial offset, calculating gamma value for each point. 
	%If the gamma value is less than any other found, use that value
	%This code is vectorised w.r.t testMapA/B rather than the trial area as this provides the biggest
	%speed increase. (i.e. it calculates the index at a certain offset for each point on the map in one go.)
	%Ideally it would be vectorised for the trial area as well but this is not trivial to set up.
	
	for x = 1: trialSize * 2 + 1
		for y = 1:trialSize * 2 + 1
			
			doseDifference = (testMapA - circshift(testMapB, [(x - trialSize - 1) (y - trialSize -1)])) ./ normDose;
			distanceDifference = sqrt((x - trialSize - 1)^2 + (y - trialSize - 1)^2);
			gValue = min(sqrt((doseDifference./doseCriterion).^2 + (distanceDifference ./ (distanceCriterion * 2^interpFactor)).^2), gValue);
				
		end
	end
	gamma = gValue(trialSize + 1:trialSize + xSize,trialSize + 1:trialSize + ySize);
	
end