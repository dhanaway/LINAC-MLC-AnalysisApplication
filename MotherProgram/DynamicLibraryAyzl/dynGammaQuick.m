% ------------------------------------------------------------
% dynGammaQuick
% ------------------------------------------------------------
% Dyanlog Analysis Package
% Michael Hughes 2010-2011
% ------------------------------------------------------------
% Estimates a gamma analysis map between two fluence maps. 
% This function is much quicker than dynGamma but is only
% an approximation. It becomes more accurate for distributions
% in which the second differential of the dose gradient
% is small relative to the first differential.
%
% For description of gamma analysis principles see: 
% Daniel, A.L. et al., Med. Phys. 25, p656 (1998).
%
% For a description and evalution of this approximation, see:
% Bakai, A. et al., Phys. Med. Biol. 48 p3543 (2003).
%
% Syntax:
% gammaMap = dynGammaQuick(mapA, mapB, doseCriterion, distanceCriterion, normDose, threshold);
%	
% gammaMap: 			2D Array containing gamma indices
% mapA, mapB:			2D Arrays containing fluence maps
% doseCriterion:		The dose criterion to test (as a fraction of normDose)
% distanceCriterion: 	The distance criterion to test (in pixels)
% normDose: 			The fluence value which will be taken as 100%
% threshold:			Points with dose less than this fraction of normDose will not be evaluated
% ------------------------------------------------------------

function [gammaMap] = dynGammaQuick(mapA, mapB, doseCriterion, distanceCriterion, normDose, threshold)
	
	%Define Gradient Operator
	gradOperator = [-0.5 0 0.5];
	
	%Calculate gradient Map
	gradientXMap = conv2(mapA,gradOperator,'same');
	gradientYMap = conv2(mapB,gradOperator','same');
	gradientMap = sqrt(gradientXMap.^2 + gradientYMap.^2) / normDose;
	
	%Calculate Gamma Index
	gammaMap = abs(mapA - mapB) ./ (normDose * sqrt((doseCriterion^2 + distanceCriterion^2 * (gradientMap).^2)))  ;

	%Remove points below threshold
	gammaMap(mapA < threshold * normDose) = 0;
	
end