function ImportCruisingDataFromCSVs(datavyu_print_csv_file_gap_handrail)
% ImportCruisingDataFromCSVs imports study2 data from datavyu csv file (Can
% be used for study 1 as well)
%
%% Syntax
% ImportCruisingDataFromCSVs(datavyu_print_csv_file_gap_handrail)
%
%% Description
% ImportCruisingDataFromCSVs gets a CSV file as input that is printing from
% datavyu. The csv contains information about subject, trials, and gap
% size, times, etc. The function converts the CSV file to a MAT arrays that are
% used by other functions. The function is designed to Study2 but can be
% used for study 1 as well.
%
% Required Input.
% datavyu_print_csv_file_gap_handrail: CSV file that contains datavyu
% coding

% imports datavyu print and save information about trials
file_data = csvimport(datavyu_print_csv_file_gap_handrail);
trials_info = file_data(2:end, [1 9 10 11 7 8]);
trials_info(cell2mat(cellfun(@(elem) strcmp(elem, 's'), trials_info, 'UniformOutput', false))) = {1};
trials_info(cell2mat(cellfun(@(elem) strcmp(elem, 'f'), trials_info, 'UniformOutput', false))) = {2};
trials_info(cell2mat(cellfun(@(elem) strcmp(elem, 'r'), trials_info, 'UniformOutput', false))) = {3};
trials_info=cell2mat(trials_info);
save('trials_info.mat','trials_info');

% imports datavyu print and save information about gaps
file_data = csvimport(datavyu_print_csv_file_gap_handrail);
gaps_info = file_data(2:end, [1 19 20 29 30]);
gaps_info(cell2mat(cellfun(@(elem) strcmp(elem, 'n'), gaps_info, 'UniformOutput', false))) = {1};
gaps_info(cell2mat(cellfun(@(elem) strcmp(elem, 'y'), gaps_info, 'UniformOutput', false))) = {2};
gaps_info(cell2mat(cellfun(@(elem) strcmp(elem, '.'), gaps_info, 'UniformOutput', false))) = {0};
gaps_info(cell2mat(cellfun(@(elem) strcmp(elem, 's'), gaps_info, 'UniformOutput', false))) = {1};
gaps_info(cell2mat(cellfun(@(elem) strcmp(elem, 'f'), gaps_info, 'UniformOutput', false))) = {2};
gaps_info(cell2mat(cellfun(@(elem) strcmp(elem, 'r'), gaps_info, 'UniformOutput', false))) = {3};
gaps_info(cell2mat(cellfun(@(elem) strcmp(elem, 'l'), gaps_info, 'UniformOutput', false))) = {2};
gaps_info(cell2mat(cellfun(@(elem) isempty(elem), gaps_info, 'UniformOutput', false))) = {-1};
gaps_info= cell2mat(cellfun(@(elem) getMultipleNumber(elem), gaps_info, 'UniformOutput', false));
save('gaps_info.mat','gaps_info');
gaps_info=cell2mat(gaps_info);