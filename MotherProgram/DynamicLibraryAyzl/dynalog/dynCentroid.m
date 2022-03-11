
#--> define coordinate system
#--> check if there are gaps
#--> if there is, read in leaf number, gap size, 
#bank a and b positions 
#--> if |leafno(i)-leafno(i+1)|!=1 then we have a circle with 
#centroid 
#--> take middle value assign it to value centroid
#--> centroid has coordinate

#NEWPLAN 20170719

#Get coordinate system right - bank a and bank b are inverted. 
#multiply bank a positions by -1 to get actual position with respect to
#middle line being 0 

#CALCULATE max leaf speed for whole plan

#Read in the number of bunches(centroids)

#for next timestep, read in number of bunches

#check new centroid positions against previous timestep, 
#do this by getting max leaf speed and timsing this by 0.05 
#this is largest theoretical distance centroid could move

#fill in an array

#most basic procedures i imagine this will be not very useful on as the 
#centrepoint will be mostly in the middle most of the time

#This procedure is going to work well on an elements sytle procedure

#however there will be some limitations, a combination of a high leaf speed
#and bunches of dose being close together will (i predict) make the code
#innacurate, but for the most part i feel this will work. 

#Further work would develop the method of calculating the centroid,
#I have assumed that the dose regions will be roughly spherical so the middle
#will be half the way up and half the way across. But a more rigorous approach 
#with a weighted area calculation could be used for non spherical dose regions.

#Not included with dynAnalysis.m as more convinient to run this in 
#test directories of interest, as some non-elements type MLC files will produce
#results of little interest (can still be run though).  
#--------------------------------------------------------

#-->Make animation 

#-----------------------------------------------------
  
addpath("/Users/daltonhanaway/Desktop/RH_Summer2019/New2019/Database/DLGFiles");
addpath("/Users/daltonhanaway/Desktop/RH_Summer2019/New2019/Scripts/MotherProgram/DynamicLibraryAyzl/dynalog/");

global dynConstants;

cd /Users/daltonhanaway/Desktop/RH_Summer2019/New2019/Database/DLGFiles
listing = dir('*.dlg');
%Sort files by date
[unused, order] = sort([listing(:).datenum] , 'ascend');
sortedListing = listing(order);
numFiles = 	size(sortedListing,1);
#get filenames
bankAName = sortedListing(1).name;
bankBName = bankAName;
bankBName(1) = [];
bankBName = strcat('B', bankBName);

bankA = dynRead(bankAName);
bankB = dynRead(bankBName);

#get the actual positions set up as an array
bankApos = bankA.actualPosition;
bankBpos = bankB.actualPosition;

#get gap size
gap = dynGap(bankA, bankB);
gap = gap.actualGap;
#centroid mid position for x coordinate - we invert bankA so we have a viable

#axis to plot against 
centroidMid = (-bankApos + bankBpos)/2.0;


initialCentroids = 0

#get the total treatment time
treatTime = zeros((length(gap)),1);
for k = 1:length(gap)
  treatTime(k) = 0.05*real(k);
endfor


LeafWidth = zeros(60);

#vectorisation wuh 
w = 1:60;
if w <= 10
  LeafWidth(w) = 10.0;
elseif 10 < w < 51
  LeafWidth (w) = 5.0;
else
  LeafWidth(w) = 10.0;
endif

#using coordinate system of dynalogs where 0 is the middle
#coordinate system is inverted for each bank
#so we need to flip values for bank A to find the coordinates of the gap
#is easier to flip values once we find somewhere where gap ~= 0
bunchCountTotal = 0 ;
#bunchCountTotal is a running tally of how many cumulative dose bunches there are for each timestep

#find fastest leaf speed for each iteration
#We will use this to relate centroids from one timeslice to another timeslice
    %Remove leaves that did not move
bankAMoving = dynOnlyMoving(bankA);
bankBMoving = dynOnlyMoving(bankB);
		
%Calculate leaf speeds
leafSpeedsA = dynLeafSpeed(bankAMoving);
leafSpeedsB = dynLeafSpeed(bankBMoving);
leafSpeeds = [leafSpeedsA leafSpeedsB];
#max(matrix) returns vector of largest items for each columns
#doing max again will find fastest value 
#we use this for now as a rough estimate for valid centroid movement 
#future more accurate iterations could use max leaf speed for a particular timeslice
maxSpeed = max(max(leafSpeeds));
#set initial centroid number to be 0 outside loop
totalCentroidInitial = 0 ;
#initialise centroid array to have the timesteps, can append other centroids on
#when they appear in the MLC file
centroidArray = zeros(length(gap));

for j = 1:length(gap)
	disp(j)
  #cycling through the whole length of the treatment in 0.05s time slices
  
  #This is the current array size
  ArrayEnd = 1;
  
  bunchCount = 0; #tracks number of centroids at each timestep 
  holdArray = zeros(61,2);
  #2 columns for gap / 2 (in new system) == centroid_X position 
  #this method where we use a 60x2 array will make it easier
  #to spot bunches of gaps and define a centroid for each of
  #then
  
  #-----------------------------
  #find the dose areas  
  #-----------------------------
  for k = 1:60
    if gap(j,k) > 0.5 
      #fill holidng array with all the leaves with a gap (all dose areas)
      #leaf number == centroid y position 
      holdArray(k,1) = k;
      #gap == centroid x position in new system
      holdArray(k,2) = centroidMid(j,k);
    endif 
  endfor
  
  #--------------------------------
  #find the midpoint of the dose areas
  #--------------------------------
  
  i=1;
  while i <= 60
    if holdArray(i,1) ~= 0
      #find the leaf where the dose bunch starts
      
      StartLeaf = i;
      if holdArray(i+1,1) == 0
        #if it's just a 1 leaf bunch then set the mid to
        #leaf + half the width of the leaf
        midX = centroidMid(j,i);
        midLeaf = StartLeaf;
        midY=0;
        #this will be an inverted plot in y as leaf number goes up in the -ve y direction
        #optional to fix later
        for i=1:StartLeaf
          midY = midY + LeafWidth(i);
        endfor
        i = i + 1;
      elseif holdArray(i+1,1) ~= 0
        endLeaf = 0;
        while holdArray(i+1,1) ~=0
          i = i+1;
          #counter counts how many leaves in the bunch
          endLeaf = i + StartLeaf;
          #we use i again here so that the loop doesn't have to go through the other leaves again
          #will just start off from the next leaf without a gap
        endwhile
        #record endleaf to start outer loop from 
        midLeaf = ((StartLeaf + endLeaf)/2.0);
        
    
        if floor(midLeaf)-midLeaf == 0
          #if midLeaf is an integer then the bunch has a middle leaf (odd number of leaves bunch)
          midY=0;
          # get the middle value in terms of mm instead of leaf number
          for k=1:midLeaf
            midY = midY + LeafWidth(k);
          endfor
          midX = centroidMid(j,midLeaf);
        else
          #if midLeaf is not an integer then there are 2 leaves in the middle
          #find the max value between the two mid leaves and use that leaf for centroid position 
          if gap(j,(midLeaf + 0.5)) > gap(j,(midLeaf - 0.5))
            midLeaf = midLeaf + 0.5;
            for k=1:midLeaf
              midY = midY + LeafWidth(k);
            endfor
            midX = centroidMid(j,midLeaf);
          else
            #if the other gap is bigger then set midleaf to the lower value 
            #then proceed from there
            midLeaf = midLeaf - 0.5;
            for k=1:midLeaf
              midY = midY + LeafWidth(k);
            endfor
            midX = centroidMid(j,midLeaf);
          endif
          
        endif
        
      endif
      bunchCount = bunchCount + 1;
      bunchCountTotal = bunchCountTotal + 1;
    else 
      i = i+1;
    endif
    
    #--------------------------------
    #Input Centroid position(s) into final centroid array 
    #--------------------------------
    
    #timestep is always appeneded at end of j loop to the first column
    #this will help us plot easier / animate 
    
    
    #Program works by filling array at first centroid then comparing others to that one 
    
     
    if bunchCountTotal >= 1 && j == 1
      #record new end of array 
      ArrayEnd = ArrayEnd + 2;
      NewArray = zeros(length(gap),2);
      centroidArray = [centroidArray, NewArray];
      #each time we iterate through the inner i=1:60 loop midX and midY will change
      centroidArray(j,ArrayEnd-1) = midX;
      centroidArray(j,ArrayEnd) = midY;
      
       
    #now compare others to this 
    elseif bunchCountTotal ~=1 && bunchCountTotal ~= 0 
                
      #now need to relate the centroid array to each at the previous timestep 
      #if none of them are in range, then we have a new centroid, and we make a new
      #column in the array 
      
      #check the circle of the new centroid. 
      
      
      #loop through centroids until a viable position is found for centroid
      #then put into that array position 
      
      
      centroidFound = false;
      #width of Array == ArrayEnd 
      for f=2:2:ArrayEnd 
        #we take maxSpeed to be the radius of the circle around which the previous centroid could pheasably be at the next timestep
        if sqrt((midX-centroidArray(j-1,f))**2 + (midY-centroidArray(j-1,f+1))**2) < maxSpeed;
          centroidArray(j,f) = midX;
          centroidArray(j,f+1) = midY;
          centroidFound = true;
          break
        endif
        
      endfor
      #if a centroid position still has not been found then make a new column
      if centroidFound == false
        ArrayEnd = ArrayEnd + 2;
        NewArray = zeros(length(gap),2);
        centroidArray = [centroidArray, NewArray];
        #each time we come through the loop midX and midY will change
        centroidArray(j,ArrayEnd-1) = midX;
        centroidArray(j,ArrayEnd) = midY;
        
      endif 
      
      
    endif
  
  endwhile

#need timestamp for every timeslice, centroid or neigh 
centroidArray(j,1) = j*0.05;  
  
  
#perhaps append to csv for each timestep and 
#for bunch count and relevant bunch number 

endfor


centroidArray 