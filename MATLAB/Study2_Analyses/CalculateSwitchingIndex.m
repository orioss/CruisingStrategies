function switch_index_all=CalculateSwitchingIndex(strategies_info_file)
% CalculateSwitchingIndex calculates the switching index for study 2
% analysis
%
% Syntax
% ImportCruisingDataFromCSVs(datavyu_print_csv_file_gap_handrail)
%
% Description
% ImportCruisingDataFromCSVs get a MAT file with the information about which
% strategy was used in which trial and gap size, and tests whether infants 
% switched real-time strategies in different windows of gap sizes. 
% The function tests 2-cm, 4-cm, 8-cm, 12-cm, and 16-cm windows. 
% For each infant, it computes the number of different strategies in 
% each window size, sliding along in 2-cm increments from 10 to 68 cm. 
%
% Required Input.
% strategies_info_file: MAT file with an array indicating which strategy
% was used in each trial, with the participant ID and the gap size. 
%
% Output. 
% switch_index_all: cell array including the switching indices for all
% participant per window size (2,4,8, 12, and 16).

load(strategies_info_file);
strategies_info=cell2mat(strategies_info);
subject_nums = unique(strategies_info(:,1));

% initialize array with all gap size with 2-cm increments
unique_data_gaps = 10:2:68;

% initialize counter for the window size (for output variable)
window_size_counter=1;

% go over all window sizes (0 is actually a 2cm window size)
for window=[0 4 8 12 16]
    
    % initialize the subject switching index
    s_switch_index=[]
    
    % go over all
    for s=1:length(subject_nums)
        
        num_of_strategies_per_gap = [];
        subject_num = subject_nums(s);
        
        % gets subject data
        s_data = strategies_info(strategies_info(:,1)==subject_num,2:3);
        
        % go over all gaps in 2cm increments
        for ii=1:length(unique_data_gaps)
            
            % checks if the window is larger and a regular increment
            if (window~=0)
                gap_sizes = unique_data_gaps(ii):2:unique_data_gaps(ii)+window;
            else
                gap_sizes = unique_data_gaps(ii);
            end
            
            % calculates the number of unique strategies in the gap size
           num_of_strategies = unique(s_data(ismember(s_data(:,1),gap_sizes),2));
           if (~isempty(num_of_strategies ))
                num_of_strategies_per_gap = [num_of_strategies_per_gap  length(num_of_strategies)];
           end
        end
        
        % add the averaged the number across all trials to the output structure
        s_switch_index = [s_switch_index; mean(num_of_strategies_per_gap)];         
        clear num_of_strategies_per_gap gap_size_per_joint
    end
    
    % saves the switching indices to the output structure
    switch_index_all{window_size_counter}=s_switch_index;
    window_size_counter=window_size_counter+1;
end