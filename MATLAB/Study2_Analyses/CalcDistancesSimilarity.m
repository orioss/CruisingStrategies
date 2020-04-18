function mdist_square=CalcDistancesSimilarity(pose_data_dir, subj_nums)
% CalcDistancesSimilarity performs the similarity analysis in Study 2
%
% Syntax
% mdist_square=CalcDistancesSimilarity(pose_data_dir, subj_nums)
%
% Description
% CalcDistancesSimilarity gets the folder with all keypoint data, creates
% arm-leg MTS for each subject and each trial and returns the similarity
% between MTSs across all trials.
%
% Required Input.
% pose_data_dir: folder location for all keypoints data
% subj_nums: subject numbers to include in the analyses.
%
% Output. 
% mdist_square: The similarity matrix containing the distance between each
% pair of trials across participants and gap sizes.

% initialize general variables
study_name = 'GapHandrail'
all_paths_idx=1;

% initialize parameters for creating the MTS
downsampling_value=1;
hand_medfilt_value=1;
leg_medfilt_value=1;

%% Creates MTSs for all subjects in all trials
% go over all subjects
for s_ix=1:length(subj_nums)
   
   % loads the pose data for the subject
   s_num = subj_nums(s_ix);
   load(fullfile(pose_data_dir, ['GapHandrailS#' num2str(s_num)]))
   
   % go over all trials (gap sizes)
   for trial_ix = 1:length(s_data_x)
       
      % gets the trial data
      trial_data =  s_data_x{trial_ix};
      if (isempty(trial_data))
          continue;
      end

      % create arms and legs MTS
      hand_diff_data = trial_data(:,2)-trial_data(:,1);
      leg_diff_data = trial_data(:,4)-trial_data(:,3);
      hand_diff_data_zscore = medfilt1(downsample((zscore(hand_diff_data)),downsampling_value),hand_medfilt_value,'zeropad');
      leg_diff_data_zscore = medfilt1(downsample((zscore(leg_diff_data)),downsampling_value),leg_medfilt_value,'zeropad');
      
      % adds to all paths structure for similarity
      all_paths_for_similarity{all_paths_idx} = [hand_diff_data_zscore leg_diff_data_zscore];       
      all_paths_idx = all_paths_idx + 1;
   end %trial
end %subject   

%% calculate the similarity between each hand-leg dynamics
% initialize similarity matrix 
similarity_mat = zeros(length(all_paths_for_similarity), length(all_paths_for_similarity));

% go over all paths and compare similarity between them 
for idx1=1:length(all_paths_for_similarity)
   for idx2=1:length(all_paths_for_similarity)
       
      if (idx1==idx2)
          continue;
      end
      
      % gets the two paths and use DTW to calculate similarity
      path1 = all_paths_for_similarity{idx1}; 
      path2 = all_paths_for_similarity{idx2}; 
      [Dist,D,k,w,sub1_warped,sub2_warped]=Calculate_2D_DTW(path1, path2, 0);
      dist_length(idx1,idx2)=Dist;
      k_length(idx1,idx2)=k;
   end
end

% adds the distance to the similarity matrix
mdist_square = dist_length./k_length;
mdist_square(isnan(mdist_square))=0;

