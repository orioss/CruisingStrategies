function variability_measure_array=CalcArmsAndLegVariability(subj_nums, pose_data_dir, datavyu_data_file)
% CalcCoordinationPattern performs the arm and leg variability analysis for study 1
%
%% Syntax
% variability_measure_array=CalcArmsAndLegVariability(subj_nums, pose_data_dir, datavyu_data_file)
%
%% Description
% CalcArmsAndLegVariability assess variability in step durations based on 
% the phase changes in the arm- and leg-MTS. For each trial, it calculates
% variability in phase change in the MTS for each pair of limbs independently. 
%
% Required Input.
% subj_nums: the infants IDs to analyze
% pose_data_dir: folder with all the pose data from all participants
% datavyu_data_file: location of MAT file with all the data from datavyu (trial
% information, subjects, etc.)

% loads the data from datavyu
load(datavyu_data_file);

% sets the smoothing parameters 
leg_medfilt_value = 1;
hand_medfilt_value = 1;
downsampling_value = 1;

% initialize results array 
study_name = 'ContinuousHandrail';
all_paths_subj_and_trial=[];
all_paths_idx=1;
variability_measure_array = [];
measures_trial_level = [];

% go over all the subjects
for s_ix=1:length(subj_nums)
   
   % gets information about infant - age, experience, etc.
   s_num = subj_nums(s_ix)
   s_experience = unique(baseline_data(baseline_data(:,1)==s_num,2));
   s_time = (mean(baseline_data(baseline_data(:,1)==s_num,7)-baseline_data(baseline_data(:,1)==s_num,6)))/1000;
   
   % loads the pose data
   load(fullfile(pose_data_dir, [study_name 'S#' num2str(s_num)]))
   
   % initialize arrays for movement variability
   leg_const_measure = [];
   hand_const_measure = [];
   leg_length_measure = [];
   hand_length_measure = [];
   
   % go over all trials
   for trial_ix = 1:length(s_data_x)
      
      % gets the trial data
      trial_data =  s_data_x{trial_ix};
      if (isempty(trial_data))
          continue;
      end

      % creates legs and hands MTS (including zscore and smoothing
      hand_diff_data = trial_data(:,2)-trial_data(:,1);
      leg_diff_data = trial_data(:,4)-trial_data(:,3);
      hand_diff_data_zscore = medfilt1(downsample((zscore(hand_diff_data)),downsampling_value),hand_medfilt_value,'zeropad');
      leg_diff_data_zscore = medfilt1(downsample((zscore(leg_diff_data)),downsampling_value),leg_medfilt_value,'zeropad');
      
      % calculates variability measures in arms and legs movements (see
      % paper for full details)
      hand_constancy = std(diff(find(diff(angle(hand_diff_data_zscore))~=0)));
      leg_constancy = std(diff(find(diff(angle(leg_diff_data_zscore))~=0)));
      hand_sz = mean(diff(find(diff(angle(hand_diff_data_zscore))~=0)));
      leg_sz = mean(diff(find(diff(angle(leg_diff_data_zscore))~=0)));
      
      % add to the measure array
      leg_const_measure = [leg_const_measure; leg_constancy];
      hand_const_measure = [hand_const_measure; hand_constancy];
      leg_length_measure = [leg_length_measure; leg_sz];
      hand_length_measure = [hand_length_measure; hand_sz];
      measures_trial_level = [measures_trial_level; leg_constancy hand_constancy];
   end %trial
   
   variability_measure_array = [variability_measure_array; s_experience s_time mean(leg_const_measure) mean(hand_const_measure) ...
                        mean(leg_length_measure) mean(hand_length_measure) std(hand_length_measure) std(leg_length_measure)];
   close all;
end %subject   