function multi_digit_number=getMultipleNumber(string_to_convert)
% getMultipleNumber converts a multi-digit string into a number
%
%% Syntax
% multi_digit_number=getMultipleNumber(string_to_convert)
%
%% Description
% getMultipleNumber gets a string that might contain a multi-digit number
% and converts it to a number. This is used when converting CSVs or other
% text data to MAT arrays.
%
% Required Input.
% string_to_convert: a string that needs to be converted to a number (can
% also be empty or non-number)
% 
% Output.
% multi_digit_number: the number in the string as a double.

% checks if the string is already a number 
if (isnumeric(string_to_convert))
    
    % if so, returns the string
    multi_digit_number = string_to_convert;
    
% checks if the string is empty
elseif (isempty(string_to_convert))
    
    % if so, returns -1
    multi_digit_number=-1;
    
% converts the string to a multi-digit number 
else
    
    multi_digit_number=str2double(string_to_convert);
    
    % in case conversion fail (because this is multi digit) - go char by char
    if (isnan(multi_digit_number))
        num_of_element = length(string_to_convert);
        multi_digit_number = 0;
        for i=1:num_of_element 
            multi_digit_number = multi_digit_number + GetLetterNumber(string_to_convert(i))*10^(i-1);
        end
    end
end