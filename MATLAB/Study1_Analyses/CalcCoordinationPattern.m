function CalcCoordinationPattern(subj_nums, pose_data_dir, datavyu_data_file)
% CalcCoordinationPattern performs coordination-pattern analysis for study 1
%
%% Syntax
% CalcCoordinationPattern(subj_nums, pose_data_dir, study_name)
%
%% Description
% CalcCoordinationPattern get the pose data, creates MTSs, and calculates
% the relations between arm-MTS to leg-MTS. This is the base for study 1
% analyses.
%
% Required Input.
% subj_nums: list of subject to analyze
% pose_data_dir: location of all pose detection data
% datavyu_data_file: location of MAT file with all the data from datavyu (trial
% information, subjects, etc.)


load(datavyu_data_file);

% sets the smoothing parameters 
leg_medfilt_value = 1;
hand_medfilt_value = 1;
downsampling_value = 1;

% initialize results array 
study_name = 'ContinuousHandrail';
all_paths_subj_and_trial=[];
all_paths_idx=1;
sync_measures_all = [];

% go over all the subjects
for s_ix=1:length(subj_nums)
    f= figure;
    
    % gets information about infant - age, experience, etc.
    s_num = subj_nums(s_ix)
    s_experience = unique(datavyu_data(datavyu_data(:,1)==s_num,2));
    s_speed = (mean(datavyu_data(datavyu_data(:,1)==s_num,7)-datavyu_data(datavyu_data(:,1)==s_num,6)))/1000;
    if (s_experience==-1)
       continue;
    end
    
    % loads pose data
    load(fullfile(pose_data_dir, [study_name 'S#' num2str(s_num)]))
    
    % initialize arrays for coordination measures
    corr_measure = [];
    dtw_measure = [];
    plv_measure=[];
    
    % gets the duration of trials for measures calculation 
    trial_durations = (datavyu_data(datavyu_data(:,1)==s_num,7)-datavyu_data(datavyu_data(:,1)==s_num,6))/1000;
    for trial_ix =1:length(s_data_x) 
        
        % gets the trial data
        trial_data =  s_data_x{trial_ix};
        if (isempty(trial_data))
          continue;
        end
        
        % creates the arms and legs MTS (including zscore and smoothing
        hand_diff_data = trial_data(:,2)-trial_data(:,1);
        leg_diff_data = trial_data(:,4)-trial_data(:,3);
        frame_freq=length(hand_diff_data)/trial_durations(trial_ix);
        hand_diff_data_zscore = medfilt1(downsample((zscore(hand_diff_data)),downsampling_value),hand_medfilt_value,'zeropad');
        leg_diff_data_zscore = medfilt1(downsample((zscore(leg_diff_data)),downsampling_value),leg_medfilt_value,'zeropad');

        % calculates pearson measure
        [r,p] = corrcoef(hand_diff_data_zscore,leg_diff_data_zscore);
        
        % calculates dtw measure
        [Dist,~,k,w,~,~]=dtw_mat(hand_diff_data_zscore,leg_diff_data_zscore,0);

        % calculates PLV measure
        Hilbert_A=hilbert(leg_diff_data_zscore);
        Hilbert_B=hilbert(hand_diff_data_zscore);
        PhaseAng_B=angle(Hilbert_B);
        PhaseAng_A=angle(Hilbert_A);
        plv = abs(sum(exp(1i * (PhaseAng_B - PhaseAng_A))) / length(leg_diff_data_zscore));

        % adds measures to subject array
        corr_measure  = [corr_measure; r(2)];
        dtw_measure = [dtw_measure; 1./Dist];
        plv_measure = [plv_measure; plv];
    end %trial

    % adding subject to array 
    sync_measures_all = [sync_measures_all; s_experience s_speed mean(corr_measure) mean(dtw_measure) mean(plv_measure)];
    
    % prints subject's MTSs
    title_str = ['subject' num2str(s_num) '.cruising experience=' num2str(s_experience) '.speed=' num2str(s_speed)];
    title(title_str);
    print(f, fullfile([title_str '.png']   ),'-dpng');
    print(f, fullfile([title_str '.eps']),'-depsc');
    close all;
end 


x=sync_measures_all(:,1);
y=sync_measures_all(:,4);
[r,p]=corrcoef(x,y)
Fit = polyfit(x,y,1); %1 = order of the polynomial i.e a straight line 
scatter(x,y,'linewidth',10,'MarkerFaceColor',[1 0 0],'MarkerEdgeColor',[1 0 0]);
hold on
plot(polyval(Fit,1:103),'Color',[1 0 0],'linewidth',1);%
hold on


