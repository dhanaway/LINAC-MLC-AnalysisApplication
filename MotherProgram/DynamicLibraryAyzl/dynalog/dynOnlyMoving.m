% ---------------------------------------------------------
% dynOnlyMoving
% ---------------------------------------------------------
% Dynalog Analysis Package
% Michael Hughes 2010-2011
% ---------------------------------------------------------
% Removes leaves which do not move during treatment
% from dynData struct. Use .leafNumber field to determine
% original leaf number.
%
% Syntax: dynDataMoving = dynOnlyMoving(dynData)
%
% dynDataMoving : 	output dynData struct
% dynData : 		struct from dynread
% ---------------------------------------------------------

function [onlyMoving] = dynOnlyMoving(dynData) 

	%Copy across dynData
	onlyMoving = dynData;
	leaf = 0;
	i = 0;
	%Remove non-moving leaves

	while (leaf < onlyMoving.numLeaves - 1)
      
		i = i + 1;
		leaf =leaf + 1;
        
		%check for standard deviation of < 10^-3 (checking for = 0 seems
		%to lead to spurious removals, needs investgating. Using 10^-3 seems
		%to work well.)
	
		if (std(onlyMoving.planPosition(:,i)) < 10^-3)
			onlyMoving.planPosition(:,i) = [];
			onlyMoving.actualPosition(:,i) = [];
			onlyMoving.previousPosition(:,i) = [];
			onlyMoving.nextPosition(:,i) = [];
			onlyMoving.leafNumber(:,i) = [];
			i = i -1;
		end
		
	end
	onlyMoving.numLeaves = i;
	
end
