function out_number=getNumeric(number_as_string)
% getNumeric converts a string to a number
%
%% Syntax
% out_number=getNumeric(number_as_string)
%
%% Description
% getNumeric converts a string to a number. This function is mainly used when 
% a cell array is converted from a string to a number and if there is an
% empty string in the cell array or a non-number
%
% Required Input.
% number_as_string: a string that needs to be converted to a number (can
% also be empty or non-number)
% 
% Output.
% out_number: the number in the string as a double.

% checks if the string is a actually a number
if (isnumeric(number_as_string))
    
    % if so, returns the string
    out_number = number_as_string;
    
% checks if the string is empty 
elseif (isempty(number_as_string))
    
    % if so, returns -1
    out_number=-1;
    
% converts the string to a number
else
    out_number=str2double(number_as_string);
end