function CalculateStrategyPerGapBodyRelation(strategies_data_file, datavyu_file)
% CalculateStrategyPerGapBodyRelation calculates and prints differences
% between experienced and novice cruisers in terms of strategy used in
% different body-environment relation
%
% Syntax
% CalculateStrategyPerGapBodyRelation(strategies_data_file, datavyu_file)
%
% Description
% CalculateStrategyPerGapBodyRelation tests how the use of different strategies 
% changed according to changes in body-environment relations (i.e., ratio 
% between infants’ wingspan and gap size). Trials with different ratios 
% require different real-time strategies. This function calcuates A 3X3 
% matrix for novice and experienced cruisers - show that experience are 
% using when it's necessary (diagonal), and novice are using regardless.
%
% Required Input.
% strategies_data_file: MAT file with array that includes information about
% the strategy that were used in the study
% datavyu_file: CSV file with the printed data from datavyu 

% initialize the colors for the figure
colors = [247,244,249; 231,225,239; 212,185,218; 201,148,199; 223,101,176; 
          231,41,138; 206,18,86; 152,0,67; 103,0,31]./255;
new_color_mapping = [6 4 7 5 3 1 2 8];

% imports and converts datavyu data     
datavyu_data = csvimport(datavyu_file);
datavyu_data = datavyu_data(2:end,[1 6 12 14]);
datavyu_data = cell2mat(cellfun(@(elem) getNumeric(elem), datavyu_data, 'UniformOutput', false));
datavyu_data=unique(datavyu_data,'rows');
[exp_data_sorted,exp_data_ix]=sort(datavyu_data(:,2));

% loads strategy information
load(strategies_data_file);
data=cell2mat(strategies_info);
subjects = unique(data(:,1)); 
subjects = subjects(exp_data_ix);

% median split according to experience
low_experince_subjs = subjects(1:11);
high_experince_subjs = subjects(12:end);

% split the strategies according to their use in "challanging" body-gap ratio
highest_strategies = [1];
high_strategies = [1 2 3 5 8];
low_strategies = [4 7 6];



% go over two types of cruising levels - novice and experienced
for cruise_level=1:2
    
    % gets the subjects with the relevant cruising experience
    if (cruise_level==1)
        subjs = low_experince_subjs;
    else
        subjs = high_experince_subjs;
    end
    
    % initialize 3x3 matrices for figrue
    strategy_efficiency = zeros(3,3);
    strategy_counter = zeros(1,3);

    % initialize figure
    figure; 
    
    % go over all subjects with the specific experience level
    for s_ix=1:length(subjs)
        
       % gets the subject wingspan
       sub = subjs(s_ix);
       sub_wing = unique(datavyu_data(datavyu_data(:,1)==sub,4));
       if (sub_wing <0)
           continue;
       end
       
       % gets the subject data
       sub_data = data(data(:,1)==sub,2:3);
       
       % go over all trials
       for g_ix=1:size(sub_data,1)
           
           % gets the gap and calculates the challange index
           gap = sub_data(g_ix,1);
           challange_index = gap;
           
           % gets the strategy that was used in the trial
           used_strategy = new_color_mapping(sub_data(g_ix,2));

           % checks where the challange in index belongs and where the used
           % strategy belong in terms of the 3x3 matrix (see Figure 8 in
           % the paper)
           if (challange_index>0 & challange_index<34)
              challange_category = 3;
              strategy_counter(3)=strategy_counter(3)+1;
           elseif (challange_index>34 & challange_index<=50)
               challange_category = 2;
               strategy_counter(2)=strategy_counter(2)+1;
           elseif (challange_index>50)
               challange_category = 1;
               strategy_counter(1)=strategy_counter(1)+1;
           end

           % checkes what is the relevant cell for that trial
           if (ismember(used_strategy,highest_strategies))
              strategy_category = 1;
           elseif (ismember(used_strategy,high_strategies))
               strategy_category = 2;
           elseif (ismember(used_strategy,low_strategies))
               strategy_category = 3;
           end
           
           % adds the trial to the relevant cell in the 3x3 matrix
           strategy_efficiency(challange_category,strategy_category)=strategy_efficiency(challange_category,strategy_category)+1;       
       end
    end
    
    % prints the average strategy use for the specific experience level
    imagesc(strategy_efficiency./strategy_counter',[0.15 0.55]);
    colormap(colors)
end




