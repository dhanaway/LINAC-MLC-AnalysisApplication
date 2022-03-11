addpath("C:\\Users\\BRMC\\Desktop\\SEPnet Project 2017\\dynalog-0.2")

	%Define global constants
	dynConstants
			
	%Output CSV filename
	outfile = 'result3.csv';

	%Get list of dynalog files in current directory
	listing = dir('*.dlg');
	
	%Sort files by date
	[unused, order] = sort([listing(:).datenum] , 'ascend');
	sortedListing = listing(order);
  numFiles = 	size(sortedListing,1);
  #numFiles != numPairs
  numPairs = numFiles / 2;
  
  #this is to make the sorting easier, using 2i and 2i-1 as counters we get
  #every A bank to be 2i-1 counter and every equivalent B bank to be 2i. 
  #This requires halfing the number of loops
  %{
	%Open output file and print headers
	fid = fopen(outfile,'w');
	fprintf(fid, '\r\nDynalog Analysis\r\n');
	fprintf(fid, 'Number of File-pairs analysed: %d \r\n', numPairs);
	fprintf(fid, 'Bank A Filename,Bank B Filename,File Date,File Time, Treatment Time (s),Num. Beam Hold Offs,Bank A RMS Error (mm),Bank B RMS Error (mm) ,Gap RMS Error (mm),Bank A Fails,Bank B Fails,Gap Fails,Total Observations,Observations < 1mm ,Observations < 2mm, \r\n');
	%}
  
  %Loop through each dynalog file pair, calculate stats and write to output file.
	#for i = 1:numPairs
		
		%Get name of Bank A file and Bank B file. 
	bankAName = sortedListing(1).name;
	bankBName = bankAName;
	bankBName(1) = [];
	bankBName = strcat('B', bankBName);
    
		%Load in data from dyanlog files
	bankA = dynRead(bankAName);
	bankB = dynRead(bankBName);
	
		%Find number of beam hold-offs
	numOff = dynNumHoldOff(bankA);
		
		%Calculate treatment time
    
  #area is just summing up all the array elements
  #row by row 
	
  gap = (dynGap(bankA,bankB).planGap);
  TotalArea = zeros(length(gap),1);
  for j = 1:length(gap)
    for i = 1:60
      if 1 <= i <= 10 
        #leaves 1-10 are 10mm wide 
        Area = 10*gap(j,i);
        TotalArea(j) = TotalArea(j) + Area; 
      elseif 11 <= i <= 50
        #leaves 11-40 are 5mm wide
        Area = 5*gap(j,i);
        TotalArea(j) = TotalArea(j) + Area;
      elseif 51 <= i <= 60
        #leaves 51-60 are 10mm wide 
        Area = 10*gap(j,i);
        TotalArea(j) = TotalArea(j) + Area
      endif
    end
  end
  
  TotalArea;
  h = 0.05;
  RateofChange = diff(TotalArea)/h;
  RateofChange2 = gradient(TotalArea);
  
  treatTime = zeros((length(gap)),1);
  for i = 1:length(gap)
    treatTime(i) = 0.05*real(i);
  end
  
  
  graph = plot(treatTime,RateofChange2);
  title('Rate of change of Areas over treatment duration (CIRCLED2)');
  xlabel('treatment duration (s)');
  ylabel('Rate of change of Area (mm^2)');
  #saveas needs changing
  saveas(graph, strcat(pwd(), '\RoCoA{i}'));
  
  
  #rate of change of area 
  
 # end 