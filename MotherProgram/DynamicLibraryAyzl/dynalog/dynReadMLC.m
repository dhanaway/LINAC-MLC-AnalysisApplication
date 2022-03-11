% ---------------------------------------------------------
% dynReadMLC
% ---------------------------------------------------------
% Dynalog Analysis Package
% Michael Hughes 2010-2011
% ---------------------------------------------------------
% Reads in data from Varian MLC File to struct array. This
% struct is generally compatible with that produced by dynRead,
% although some operations clearly do not make physical sense
% if applied to data from MLC (for example dynError).
%
% WARNING: This function is very slow (several seconds per
% file read).
%
% Syntax: dynReadMLC(fileName, bank)
%		fileName 	= Path and filename for MLC file
%		bank 		= 'A' or 'B'
%
% Returns: Struct array with elements:
% .name : 			name of file
% .mlcfile : 		name of file data was read from
% .bank : 			MLC bank A or B
% .planTolerance : 	plan tolerance quoted in file
% .numLeaves : 		number of leaves in plan 
% .numFractions : 	number of dose segments ( 
% .planPosition : 	planned position of leaf
% .actualPosition : empty - for compataibilty with dynRead
% .previousPosition:empty - for compataibilty with dynRead
% .nextPosition :	empty - for compataibilty with dynRead
% ---------------------------------------------------------

function [ret] = dynReadMLC(fileName, bank) 

	%Assume 60 leaves per bank
	global varianNumLeaves
	if isempty(varianNumLeaves)
		varianNumLeaves = 60;
	end
		
	%Open MLC file
	fid = fopen(fileName, 'r');
		
	%Read in headers
	unKnown1 = fgets(fid);
	unKnown1 = fgets(fid);
	[str, remain] = strtok(fgets(fid),'=');
	name = remain(2:end);
	unKnown1 = fgets(fid);
	unKnown1 = fgets(fid);
	[str, remain] = strtok(fgets(fid),'=');
	maxFractions = str2double(remain(2:end));
	unKnown1 = fgets(fid);
	[str, remain] = strtok(fgets(fid),'=');
	planTolerance = str2double(remain(2:end));
	mlcFile = fileName;
	
	%Initialise counters and arrays
	planPosition = zeros(1000, numLeaves);
	actualPosition = zeros(1000, numLeaves);
	previousPosition = zeros(1000, numLeaves);
	nextPosition = zeros(1000, numLeaves);
	doseFraction = zeros(1000, numLeaves);
	DVASegment = zeros(1000, numLeaves);
	beamHoldOff = zeros(1000, numLeaves);
	beamOn = zeros(1000, numLeaves);
	previousDoseFraction = zeros(1000, numLeaves);
	nextDoseFraction = zeros(1000, numLeaves);
	leafNumber = zeros(1000, numLeaves);
	
	%Read in data for each counter
	fractionCounter = 0;
	while feof(fid) < 1 && fractionCounter < maxFractions
		
		fractionCounter = fractionCounter + 1;
		
		%Test if next block is a field, otherwise exit loop and stop reading file
		unKnown1 = fgets(fid);
		[str, remain] = strtok(fgets(fid),'=');
		if ~(strcmp(str,'Field' ))
			break;
		end
		
		%Skip header lines
		unKnown1 = fgets(fid);
		unKnown1 = fgets(fid);
		unKnown1 = fgets(fid);
		unKnown1 = fgets(fid);
	
		%Read in data for each leaf
		for leafCounter = 1:numLeaves
			[str, remain] = strtok(fgets(fid),'=');
			
			if (bank =='A')
				planPosition(fractionCounter, leafCounter) = str2double(remain(2:end)) * 10;
			end
		end
		for leafCounter = 1:numLeaves
			[str, remain] = strtok(fgets(fid),'=');
			if (bank =='B')
				planPosition(fractionCounter, leafCounter) = str2double(remain(2:end)) * 10;
			end
		end
		
		%Skip footer lines
		unKnown1 = fgets(fid);
		unKnown1 = fgets(fid);
		unKnown1 = fgets(fid);
	
	end
	numFractions  = fractionCounter
	
	%Store the number of each leaf. This is needed because some functions remove leaves from the array.
	for leafCounter = 1:numLeaves
		leafNumber(:, leafCounter) = leafCounter;
	end
		
	%Remove unwanted space from arrays
	planPosition(numFractions + 1:1000,:) = [];
	actualPosition(numFractions + 1:1000,:) = [];
	previousPosition(numFractions + 1:1000,:) = [];
	nextPosition(numFractions + 1:1000,:) = [];
	doseFraction(numFractions + 1:1000,:) = [];
	DVASegment(numFractions + 1:1000,:) = [];
	beamHoldOff(numFractions + 1:1000,:) = [];
	beamOn(numFractions + 1:1000,:) = [];
	previousDoseFraction(numFractions + 1:1000,:) = [];
	nextDoseFraction (numFractions + 1:1000,:) = [];
	leafNumber (numFractions + 1:1000,:) = [];
	
	%Return a struct array with the MLC data
	ret = struct('name', name,'mlcfile', mlcFile, 'bank', bank,'planTolerance',planTolerance, 'numLeaves', numLeaves, 'numFractions', numFractions, 'leafNumber', leafNumber, 'doseFraction', doseFraction, 'DVASegment', DVASegment, 'beamHoldOff', beamHoldOff, 'beamOn', beamOn, 'previousDoseFraction', previousDoseFraction, 'nextDoseFraction', nextDoseFraction, 'planPosition', planPosition, 'actualPosition', actualPosition,'previousPosition',previousPosition,'nextPosition',nextPosition);
	
	%Close the MLC file
	fclose(fid);
	
end

			
			
	
	
	
	
	
	
	

