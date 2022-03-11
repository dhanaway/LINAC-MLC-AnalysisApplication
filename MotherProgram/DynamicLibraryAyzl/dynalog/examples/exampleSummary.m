% ---------------------------------------------------------
% exampleSummary
% ---------------------------------------------------------
% Dynalog Analysis Package
% Michael Hughes December 2010
% ---------------------------------------------------------
% This is an example showing how to use various functions
% in the Dynalog analysis package.
%
% It performs an automatic analysis of all dynalog file pairs
% in the current directory. Note that pairs (i.e. one file for 
% each leaf bank) must have identical file names except bank A 
% has the prefix 'A' and bank B has the prefix 'B'.
%
% A series of gamma maps is created, showing the difference
% between planned and actual fluences for each file-pair. The 
% tolerance is intially set to 1%, 1 mm.
%
% A comma-separated value file ('result.csv') is created, with 
% columns:
%	Bank A Filename
%   Bank B Filename
%   File Date (Bank A)
%   File Time (Bank B)
%   Treatment Time Length (s)
%   Number of Beam Hold-offs
%   Bank A RMS Leaf Error (mm)
%   Bank B RMS Leaf Error (mm)
%   Gap Size RMS Error (mm)
%	Number Bank A Leaves failing (> 5% with 2 mm error)
%   Number Bank A Leaves failing (> 5% with 2 mm error)
% ---------------------------------------------------------




	%Define global constants
	dynConstants
			
	%Output CSV filename
	outfile = 'result.csv';

	%Get list of dynalog files in current directory
	listing = dir('a*.dlg');
	
	%Sort files by date
	[unused, order] = sort([listing(:).datenum] , 'descend');
	sortedListing = listing(order); 
	numFiles = 	size(sortedListing,1);
	
	%Open output file and print headers
	fid = fopen(outfile,'w');
	fprintf(fid, '\r\nDynalog Analysis\r\n');
	fprintf(fid, 'Number of File-pairs analysed: %d \r\n', numFiles);
	fprintf(fid, 'Bank A Filename,Bank B Filename,File Date,File Time, Treatment Time (s),Num. Beam Hold Offs,Bank A RMS Error (mm),Bank B RMS Error (mm) ,Gap RMS Error (mm),Bank A Fails,Bank B Fails,Gap Fails,Total Observations,Observations < 1mm ,Observations < 2mm, \r\n');
	
	%Loop through each dynalog file pair, calculate stats and write to output file.
	for i = 1:numFiles
		
		%Get name of Bank A file and work out name of bank B file
		bankAName = sortedListing(i).name;
		bankBName = bankAName;
		bankBName(1) = [];
		bankBName = strcat('B', bankBName);
		
		%Load in data from dyanlog files
		bankA = dynRead(bankAName);
		bankB = dynRead(bankBName);
	
		%Find number of beam hold-offs
		numOff = dynNumHoldOff(bankA);
		
		%Calculate treatment time
		treatTime = bankA.numFractions * 0.05;
	
		%Remove segments where beam was not on
     
		bankAOn = dynOnlyBeamOn(dynOnlyMoving(bankA));
		bankBOn = dynOnlyBeamOn(dynOnlyMoving(bankB));
					
		%Make a histogram of leaf errors.
		errorsA = abs(dynError(bankAOn));
		errorsB = abs(dynError(bankBOn));
		errorsVector = [errorsA(:); errorsB(:)];
		
		%Find RMS Errors
		RMSErrorA = dynRMSError(bankAOn);
		RMSErrorB = dynRMSError(bankBOn);
		RMSGapError = dynRMSGapError(bankBOn, bankAOn);
		
		%Find number of failing leaves
		numBankAFail = sum(dynLeafCheck(bankAOn,2,0.05));
		numBankBFail = sum(dynLeafCheck(bankBOn,2,0.05));
		numGapFail = sum(dynGapCheck(bankAOn,bankBOn,4,0.05));
		totalObservations = bankAOn.numFractions * bankBOn.numLeaves * 2;
		totalLessThan1mm = (sum(sum(errorsA <= 1)) + sum(sum(errorsB <= 1))) / totalObservations * 100;
		totalLessThan2mm = (sum(sum(errorsA <= 2)) + sum(sum(errorsB <= 2))) / totalObservations * 100;
				
		%Get date and time file was created
		[fileDate, fileTime] = strtok(sortedListing(i).date);
		
		%Write output to CSV file
		fprintf(fid, '%s,%s,%s,%s,%f,%d,%f,%f,%f,%d,%d,%d,%d,%d,%d, \r\n', bankAName, bankBName, fileDate, fileTime, treatTime, numOff, RMSErrorA, RMSErrorB, RMSGapError, numBankAFail, numBankBFail, numGapFail, totalObservations, totalLessThan1mm, totalLessThan2mm);
		
		%Generate fluence maps at 1 pixel mm with and with x4 temporal interpolation
		[mapA mapB] = dynFluence(bankA, bankB,1,4);
				
		%Print the planned fluence map to a JPEG file
		figure('visible', 'off');
		clf()
		imagesc(mapA');
		title(strcat('Planned Fluence map for files: ', bankAName,',',bankBName), 'Interpreter','none');
		xlabel('Position (mm)');
		ylabel('Position (mm)');
		set(gca,'Ydir','normal');
		colormap jet;	
		colorbar;
		axis equal;
		print (strcat('planned_fluence_', num2str(i),'.jpg'), '-djpeg');	
		
		%Print the actual fluence map to a JPEG file
		figure('visible', 'off');
		clf()
		imagesc(mapB');
		title(strcat('Planned Fluence map for files: ', bankAName,',',bankBName), 'Interpreter','none');
		xlabel('Position (mm)');
		ylabel('Position (mm)');
		set(gca,'Ydir','normal');
		colormap jet;	
		colorbar;
		axis equal;
		print (strcat('actual_fluence_', num2str(i),'.jpg'), '-djpeg');	
		
		%Generate gamma map
		[sizeX sizeY] = size(mapA);
		gammaMap = dynGammaQuick(mapA, mapB, 0.02, 2, max(mapA(:)),0.1);
		[gSizeX gSizeY] = size(gammaMap);
		%Print the gamma map to a JPEG file
		figure('visible', 'off');
		clf()
		imagesc(gammaMap',[0 1]);
		title(strcat('Gamma Map for DLG files: ', bankAName,',',bankBName), 'Interpreter','none');
		xlabel('Position (mm)');
		ylabel('Position (mm)');
		set(gca,'Ydir','normal');
		colormap jet;	
		axis equal;
		colorbar;
		print (strcat('gamma_map_', num2str(i),'.jpg'), '-djpeg');	
			
	end
	
	%Close the CSV file
	fclose(fid);	
				
	


	