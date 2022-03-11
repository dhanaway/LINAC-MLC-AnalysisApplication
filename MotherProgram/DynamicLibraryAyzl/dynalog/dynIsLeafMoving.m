% ---------------------------------------------------------
% dynIsLeafMoving
% ---------------------------------------------------------
% Dynalog Analysis Package
% Michael Hughes 2010-2011
% ---------------------------------------------------------
% Checks if leaf was planned to move at any point during field.
% Returns 1 if moving, 0 if not moving.
%
% Syntax: isMoving = dynIsLeafMoving(dynData, leaf)
%
% dynData : struct from dysRead
% leaf : 	leaf number to check (refers to position in array,
%			not .leafNumber field). Can be a vector.
% ---------------------------------------------------------

function [isMoving] = dynIsLeafMoving(dynData, leaf) 

	isMoving = (std(dynData.planPosition(:,leaf)) > 10^-3);
		
end
