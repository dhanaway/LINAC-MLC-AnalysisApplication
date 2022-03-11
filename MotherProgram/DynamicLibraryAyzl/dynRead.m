% ---------------------------------------------------------
% dynRead
% ---------------------------------------------------------
% Dynalog Analysis Package
% Michael Hughes 2010-2011
% ---------------------------------------------------------
% With thanks to Ted Fisher who made a number of improvements
% to this function.
% ---------------------------------------------------------
% Reads in data from Varian Dyanlog File to struct array
%
% Syntax: dynRead(fileName)
%
% Returns Struct array with elements:
% .mlcfile: 		name of file data was read from
% .version: 		Version number of file
% .planTolerance: 	plan tolerance quoted in file
% .numLeaves: 		number of leaves in plan 
% .numFractions: 	number of dose fractions (essentially field
%					treatment time / 50 us).
% .planPosition: 	planned position of leaf
% .actualPosition:  position leaf was actually at
% .y1JawPosition:	y1 jaw position in mm
% .y2JawPosition:	y2 jaw position in mm 	
% .x1JawPosition:	x1 jaw position in mm    
% .x2JawPosition:	x2 jaw position in mm         	
% .carriagePlanPosition: 	carriage planned  position in mm	
% .carriageActualPosition:	carriage actual position in mm
% .gantryRotation:			gantry rotation in degrees
% .collimatorRotation:		collimator rotation in degrees   
% ---------------------------------------------------------

function [ret] = dynRead(fileName) 

	%This adjusts the actual leaf positions to equivalent distances at the 
	%isocenter - it may vary between systems. If a value is defined in dynConstants
	%that is used, otherwise a default is set here.
	global leafScaleFactor;
	if isempty(leafScaleFactor)
		scaleFactor = 1.96614;
	else
		scaleFactor = leafScaleFactor;
	end
	
	%Open dynalog file
	fid = fopen(fileName, 'r');
		
	%Read in headers
	version = fgetl(fid);
	name = fgetl(fid);
	mlcFile = fscanf(fid, '%s \n',1);
	planTolerance = fscanf(fid, '%s \n',1);
	numLeaves = str2num(fscanf(fid, '%s \n',1));
	clinacScale = fscanf(fid, '%s \n',1);
	
	%Read in CSV data		
	leafData = csvread(fileName, 6,0);
	
	%Extract CSV data into separate arrays
	doseFraction 			= leafData(:,1) / 25000;
	DVASegment 				= leafData(:,2);
	beamHoldOff 			= leafData(:,3);
	beamOn 					= leafData(:,4);
	previousSegment 		= leafData(:,5);
	nextSegment 			= leafData(:,6);
	gantryRotation			= leafData(:,7) / 10;
	collimatorRotation		= leafData(:,8) / 10;
	y1JawPosition			= leafData(:,9) / 10;
    y2JawPosition 			= leafData(:,10) / 10;
    x1JawPosition          	= leafData(:,11) / 10;
    x2JawPosition          	= leafData(:,12) / 10;
	carriagePlanPosition	= leafData(:,13) / 100;     
    carriageActualPosition 	= leafData(:,14) / 100;    
	planPosition    		= leafData(:,15:4:end)/ 100 * scaleFactor;
    actualPosition  		= leafData(:,16:4:end)/ 100 * scaleFactor;
    previousPosition		= leafData(:,17:4:end)/ 100 * scaleFactor;
    nextPosition    		= leafData(:,18:4:end)/ 100 * scaleFactor;
	
	%Find number of fractions
	numFractions = size(doseFraction,1);
		
	%Store the number of each leaf. This is needed because some functions remove leaves from the array.
	for leafCounter = 1:numLeaves
		leafNumber(1:numFractions, leafCounter) = leafCounter;
	end
		
	%Return a struct array with the dynalog data
	ret = struct('name', name, ...
		'mlcfile', mlcFile, ...
		'version', version, ...
		'planTolerance',planTolerance,  ...
		'numLeaves', numLeaves, ...
		'numFractions', numFractions, ...
		'leafNumber', leafNumber, ...
		'doseFraction', doseFraction, ...
		'DVASegment', DVASegment, ...
		'beamHoldOff', beamHoldOff, ...
		'beamOn', beamOn, ...
		'previousSegment', previousSegment, ...
		'nextSegment', nextSegment, ...
		'gantryRotation', gantryRotation, ...		
		'collimatorRotation', collimatorRotation, ...		
		'y1JawPosition',  y1JawPosition, 'y2JawPosition',  y2JawPosition, ...
        'x1JawPosition',  x1JawPosition, 'x2JawPosition',  x2JawPosition, ...            
		'carriagePlanPosition', carriagePlanPosition,  ...
        'carriageActualPosition', carriageActualPosition,  ...
		'planPosition', planPosition, ...
		'actualPosition', actualPosition, ...
		'previousPosition',previousPosition, ...
		'nextPosition',nextPosition); 
	
	%Close the dynalog file
	fclose(fid);
	
end

			
			
	
	
	
	
	
	
	

