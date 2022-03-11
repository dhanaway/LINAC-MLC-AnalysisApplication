% ---------------------------------------------------------
% Dynalog Analysis Package
% Michael Hughes December 2010
% --------------------------------------------------------
% Edited by Tobias Conner June 2017 for directory purposes,
% perhaps further editing to come to interlink DataBaseFiling.py
% ---------------------------------------------------------
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
#it works!!
#(ish)

#currently outputs 8 gamma maps should only print 4
#an edited form of exampleSummary using the graphics toolkit gnuplot so the 
#file doesn't crash, and sorting the array system so only the file pairs are analysed

#This program requires a path to the Dynalog Analysis package to be manually input
#within the code. The current directory also needs to be the directory where the 
#dynalog files are kept. 

#File moving and directory changing with inputs are a nightmare in octave/matlab so doing
#that within DataBaseFiling.py 



toolkit = graphics_toolkit ();

unwind_protect
   if (ispc ())
     graphics_toolkit ("gnuplot")
   endif
  
  addpath("/Users/daltonhanaway/Desktop/RH_Summer2019/New2019/Database/DLGFiles");
  addpath("/Users/daltonhanaway/Desktop/RH_Summer2019/New2019/Scripts/MotherProgram/DynamicLibraryAyzl/dynalog/");
  
  disp("we are running");
  %Define global constants
	global dynConstants;
		
	%Output CSV filename
	outfile = 'resultDLG.csv';
  
	%Get list of dynalog files in current directory
    cd /Users/daltonhanaway/Desktop/RH_Summer2019/New2019/Database/DLGFiles
	listing = dir('*.dlg');
	
	%Sort files by date
	[unused, order] = sort([listing(:).datenum] , 'ascend');
  holdArray = [];
	sortedListinginit = listing(order);
  HalfLength = length(sortedListinginit) / 2;
  AArray = cell(1,HalfLength);
  SortedAArray = cell(1,HalfLength);
  
  for k = 1:length(sortedListinginit)
    
    if sortedListinginit(k).name(1)=='A'
      AArray{k} = sortedListinginit(k).name;
      dlgName = sortedListinginit(k).name;
      dlgName(1) = [];
      for m=1:length(dlgName)
        
        if dlgName(m) == '_'
          dlgName = dlgName(1:m-1);
          
          holdArray = [holdArray; str2num(dlgName)];
          break
        endif
      endfor
    endif
  endfor

  format long    ;
  sortedNums = sort(holdArray,'ascend');

  for j = 1:HalfLength
    for k = 1:length(AArray)
      a = int2str(sortedNums(j));
      if findstr(a,AArray{k}) == 2
        SortedAArray{j} = AArray{k};
      endif
    endfor
  endfor 
  
  numFiles = 	size(sortedListinginit,1);
  #numFiles != numPairs
  numPairs = numFiles / 2;
  
	%Open output file and print headers
	fid = fopen(outfile,'w');
	fprintf(fid, '\r\nDynalog Analysis\r\n');
	fprintf(fid, 'Number of File-pairs analysed: %d \r\n', numPairs);
	fprintf(fid, 'Bank A Filename,Bank B Filename,File Date,File Time, Treatment Time (s),Num. Beam Hold Offs,Bank A RMS Error (mm),Bank B RMS Error (mm) ,Gap RMS Error (mm),Bank A Fails,Bank B Fails,Gap Fails,Total Observations,Observations < 1mm ,Observations < 2mm, \r\n');
 	disp("Entering the Loop")
	%Loop through each dynalog file pair, calculate stats and write to output file.
	for i = 1:numPairs
		disp(i)
		outfile2 = ['resultArea',num2str(i),'.csv'];
		%Get name of Bank A file and Bank B file. 
		bankAName = SortedAArray{i};
        disp(strcat('Analyzing .dlg for file ', bankAName));
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
		#[fileDate, fileTime] = strtok(sortedListing(i).date);
		
		%Write output to CSV file
		fprintf(fid, '%s,%s,%f,%d,%f,%f,%f,%d,%d,%d,%d,%d,%d, \r\n', bankAName, bankBName, treatTime, numOff, RMSErrorA, RMSErrorB, RMSGapError, numBankAFail, numBankBFail, numGapFail, totalObservations, totalLessThan1mm, totalLessThan2mm);
		
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
		disp('first print')
		print (strcat('planned_fluence_', num2str(i),'.jpg'), '-djpeg');	
		close all
		disp('after print')
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
   
    #getting total area
    
    gap = (dynGap(bankA,bankB).actualGap)*0.1;
    TotalArea = zeros(length(gap),1);
    for j = 1:length(gap)
      for k = 1:60
          Area = gap(j,k);
          TotalArea(j) = TotalArea(j) + Area;
      end
    end
    
    #correctig total area, mid 40 leaves are 5mm wide
    for l = 1:length(TotalArea)
      if 11 <= l <= 50
        TotalArea(l)=TotalArea(l)*0.5;
      endif
    end
    
    A=max(TotalArea);
    h = 0.05;
    #RateofChange = diff(TotalArea)/h; approx area 
    RateofChange2 = gradient(TotalArea)*20;
    M = max(RateofChange2)+0.25;
    
    treatTime = zeros((length(gap)),1);
    
    for k = 1:length(gap)
      treatTime(k) = 0.05*real(k);
    end
    
    graph1 = plot(treatTime,RateofChange2);
    title(strcat('Rate of change of Area for files: ', bankAName,',',bankBName), 'Interpreter','none');
    xlabel('treatment duration (s)');
    ylabel('Rate of change of Area (cm^2s^-1)');
    axis([0 treatTime(length(gap)) -M M]);
    saveas(graph1,(strcat('RoCoA (cm^2s^-1)',num2str(i),'.jpg')));
    
    graph2 = plot(treatTime, TotalArea);
    title(strcat('Total Area for files: ', bankAName,',',bankBName), 'Interpreter','none');
    xlabel('treatment duration (s)');
    ylabel('Beam Area (cm^2)');
    saveas(graph2, (strcat('Area (cm^2)',num2str(i),'.jpg')));
    
    fid2 = fopen(outfile2,'w');
	  fprintf(fid2, '\r\nDynalog Analysis for Area and RoCoA for files %s and %s  (increments of 0.05s startinng from 0) \r\n', bankAName, bankBName);
	  fprintf(fid2, 'Total Area (cm^2),Rate of Change of Area (cm^2s^-1)\r\n');
    
    
    for j = 1:length(TotalArea)
      fprintf(fid2, '%d,%d \r\n', TotalArea(j), RateofChange2(j));
	  end
    fclose(fid2)
  end
	  %Close the CSV file
    
	fclose(fid);	
                
unwind_protect_cleanup
  graphics_toolkit (toolkit);
end_unwind_protect



