% ---------------------------------------------------------
% dynError
% ---------------------------------------------------------
% Dynalog Analysis Package 
% Michael Hughes 2010-2011
% ---------------------------------------------------------
% Returns matrix of differences between actual and planned 
% positions.
%
% Syntax: error = dynError(dynData)
%
% dynData: struct from dynRead
% ---------------------------------------------------------

function [err] = dynError(bankA) 
	
	err = (bankA.actualPosition - bankA.planPosition);
						
end
