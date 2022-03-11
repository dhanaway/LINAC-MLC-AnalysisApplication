% ---------------------------------------------------------
% exampleSpeeds
% ---------------------------------------------------------
% Dynalog Analysis Package
% Michael Hughes December 2010
% ---------------------------------------------------------
% This is an example showing how to use various functions
% in the Dynalog analysis package, particularly those relating
% to calculating speeds of leaves.
%
% If leaf acceleration is high there may be some innacuracies
% as no interpolation is performed.
%
% It performs an automatic analysis of all dynalog file pairs
% in the current directory. Note that pairs (i.e. one file for 
% each leaf bank) must have identical file names other than bank A 
% having the prefix 'A' and bank B having the prefix 'B'.
%
% A series of plots are created, showing:
%	- leaf speed against positions
%	- leaf speed aginst dose fraction
%	- histogram of leaf speeds
%	- speeds against dose fraction plot for leaf 35
% These files have the suffix 1, 2, 3 etc, referring to the
% leaf pairs in file date/time order.
%
% A comma-separated value file ('histogram.csv') is created, with 
% columns:
%	Field/file name
%   Number of observations (leaves x dose fractions)
%   Histogram data with 1 mm bin widths from 0 to 25 mm. Data is in %.
% ---------------------------------------------------------

function exampleSpeeds

	%Define global constants
	dynConstants

	%Get list of dynalog files in current directory
	listing = dir('a*.dlg');
	
	%Sort files by date
	[unused, order] = sort([listing(:).datenum]);
	sortedListing = listing(order); 
	numFiles = 	size(sortedListing,1);
	fid = fopen('histogram.csv','w');
	
	%Print headers for text file
	fprintf(fid, '\r\nDynalog Analysis - Leaf Speed Histogram\r\n');
	fprintf(fid, 'Number of File-pairs analysed: %d \r\n', numFiles);
	fprintf(fid, 'Field, Num. Observations, Histogram Data (1 mm bin widths 0-25 mm) \r\n');
	
	for i = 1:numFiles
		
		%Work out file names of dynalog pair
		bankAName = sortedListing(i).name;
		bankBName = bankAName;
		bankBName(1) = [];
		bankBName = strcat('B', bankBName);
		
		%Get date and time file was created
		[fileDate, fileTime] = strtok(sortedListing(i).date);
		
		%Read in dynalog files
		bankA = dynRead(bankAName);
		bankB = dynRead(bankBName);
	
		%Remove leaves that did not move
		bankAMoving = dynOnlyMoving(bankA);
		bankBMoving = dynOnlyMoving(bankB);
					
		%Calculate leaf speeds
		leafSpeedsA = dynLeafSpeed(bankAMoving);
		leafSpeedsB = dynLeafSpeed(bankBMoving);
		leafSpeeds = [leafSpeedsA leafSpeedsB];
		totalObservations = bankAMoving.numFractions * bankBMoving.numLeaves * 2 - 2;
		
		%Make a histogram of speeds
		leafSpeeds = leafSpeeds(:);
		spacer = 0:1:25;
		for x=1:bankAMoving.numLeaves
			leafLabel(x) = bankAMoving.leafNumber(1,x);
		end
		speedHistogram = histc(leafSpeeds, spacer) / totalObservations * 100;
				
		%Write output to CSV file
		fprintf(fid, 'Field %d,%d',  i, totalObservations);
		for x = 1:25
			fprintf(fid,'%f,',speedHistogram(x));
		end
		fprintf(fid, '\r\n');		
		
				
		%***********Generate plot of Leaf Speeds against Dose Fraction *********************
		figure('visible', 'off');
		clf;
		%Bank A
		subplot(1,2,1);
		imagesc(leafSpeedsA);
		title(strcat('Leaf Speeds (mm/s): ', bankAName), 'Interpreter','none');
		xlabel('Leaf No.');
		ylabel('Dose fraction (%)');
		set(gca,'XTick',1:bankA.numLeaves);
		set(gca,'XTickLabel',leafLabel);
		set(gca,'YTick',1:bankA.numFractions/20:bankA.numFractions);
		set(gca,'YTickLabel',0:5:100);
		set(gca,'Ydir','normal');
		colormap (jet(256));		
		c = colorbar;
		labels = {};
		for v=get(c,'ytick'), labels{end+1} = sprintf('%.0f mm/s',v); end
		set(c,'yticklabel',labels);		
		
		%Bank B
		subplot(1,2,2);
		imagesc(leafSpeedsB);
		title(strcat('Leaf Speeds (mm/s): ', bankBName), 'Interpreter','none');
		xlabel('Leaf No.');
		ylabel('Dose fraction (%)');
		set(gca,'XTick',1:bankB.numLeaves);
		set(gca,'XTickLabel',leafLabel);
		set(gca,'YTick',1:bankB.numFractions/20:bankB.numFractions);
		set(gca,'YTickLabel',0:5:100);
		set(gca,'Ydir','normal');
		colormap (jet(256));		
		c = colorbar;
		labels = {};
		for v=get(c,'ytick'), labels{end+1} = sprintf('%.0f mm/s',v); end
		set(c,'yticklabel',labels);		
		
		%Print plot
		print (strcat('speed_v_fraction_map', num2str(i),'.jpg'), '-djpeg');
			
		%***********Generate plot of Leaf Speeds against Position *********************		
		minA = -60;
		minB = -60;
		maxA = 60;
		maxB = 60;
		
		bankAMoving.actualPosition(1:bankAMoving.numFractions-1,13);
		for x = 1:bankAMoving.numLeaves
            [xConA yConA] = consolidator(bankAMoving.actualPosition(1:bankAMoving.numFractions-1,x), leafSpeedsA(:,x));
            [xConB yConB] = consolidator(bankBMoving.actualPosition(1:bankBMoving.numFractions-1,x), leafSpeedsB(:,x));
            speedPosA(:,x) = interp1(xConA,yConA,minA:0.2:maxA,'linear');
			speedPosB(:,x) = interp1(xConB,yConB,minB:0.2:maxB,'linear');
		end
		figure('visible', 'off');
		clf;
		subplot(1,2,1);
		imagesc(speedPosA);
		title(strcat('Leaf Speeds (mm/s): ', bankAName), 'Interpreter','none');
		xlabel('Leaf No.');
		ylabel('Leaf Position (mm)');
		set(gca,'XTick',1:bankA.numLeaves);
		set(gca,'XTickLabel',leafLabel);
		set(gca,'YTick',0:25:(maxA - minA) * 5);
		set(gca,'YTickLabel',minA:5:maxA);
		set(gca,'Ydir','normal');
		colormap (jet(256));	
		c = colorbar;
		labels = {};
		for v=get(c,'ytick'), labels{end+1} = sprintf('%.0f mm/s',v); end
		set(c,'yticklabel',labels);		
		
	
    	subplot(1,2,2);
		imagesc(speedPosB);
		title(strcat('Leaf Speeds (mm/s): ', bankBName), 'Interpreter','none');
		xlabel('Leaf No.');
		ylabel('Leaf Position (mm)');
		set(gca,'XTick',1:bankB.numLeaves);
		set(gca,'XTickLabel',leafLabel);
		set(gca,'YTick',0:25:(maxB - minB) * 5);
		set(gca,'YTickLabel',minB:5:maxB);
		colormap (jet(256));		
		c = colorbar;
		labels = {};
		for v=get(c,'ytick'), labels{end+1} = sprintf('%.0f mm/s',v); end
		set(c,'yticklabel',labels);		
		print (strcat('speed_v_position_map', num2str(i),'.jpg'), '-djpeg');		
						
		%***********Generate velocity plot for leaf 35*********************
		figure('visible', 'off');
		plot(leafSpeedsA(:,14));
		title(strcat('Leaf Speeds (mm/s) for Bank A Leaf 35 from file: ', bankBName), 'Interpreter','none');
		xlabel('Dose Fraction (%)');
		ylabel('Leaf Speed (mm/s)');
		set(gca,'XTick',1:bankA.numFractions / 10:bankA.numFractions);
		set(gca,'XTickLabel',0:10:100);
		print (strcat('leaf35A_speed_v_fraction_plot', num2str(i),'.jpg'), '-djpeg');
								
		%***********Generate leaf speed histgoram *********************
		xLab = {'0-1','2-3','4-5','6-7','8-9','10-11','12-13','14-15','16-17','18-19','20-21','22-23','24-25'};
		figure ('visible', 'off');
		clf;
		bar(spacer,speedHistogram);
		axis([-1 26 0 50]);
		title(strcat('Leaf Speed Histogram : ', bankAName, ',', bankBName), 'Interpreter','none');
		xlabel('Leaf Speed (mm/s)');
		ylabel('Percentage of Observations');
		set(gca, 'XTick', 0:2:25);
		set(gca, 'XTickLabel', xLab);
		for x=1:25
			text(spacer(x), speedHistogram(x) + 2, num2str(round(speedHistogram(x))),'HorizontalAlignment','center');
		end
		print (strcat('Leaf_Speeds_', num2str(i),'.jpg'), '-djpeg');

		
	end

	fclose(fid);	
		
end

	