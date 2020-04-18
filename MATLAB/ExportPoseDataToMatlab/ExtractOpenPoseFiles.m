function ExtractOpenPoseFiles(data_dir, json_dir, trial_frames_dir, subjects_nums, confidence_threshold, study_name)
% ExtractOpenPoseFiles parse all the json files and export them to MATLAB
%
%% Syntax
% ExtractOpenPoseFiles(data_dir, json_dir, trial_frames_dir)
%
%% Description
% ExtractOpenPoseFiles gets a json folder with all kepoints detection from
% all participants and extract them to a MATLAB array. the function also
% gets a confidence therehold for the detection and a time-frames array to
% divide data to trials
%
% Required Input.
% data_dir: data folder to save matlab files 
% json_dir: json folder with all keypoint detecionts. JSon files are per
% frame
% trial_frames_dir: directory with all trial-frames files for participants
% (indicates which frame is which trial so function can divide to trials)
% subjects_nums: subject numbers to analyze
% confidence_threshold: confidence threshold for detection
% study_name: whether it is study 1 or study 2 (to avoid colliding IDs)

% make dir for MATLAB open pose data
mkdir(fullfile(data_dir,'OpenPoseData'));

% go over all subjects
for i=1:length(subjects_nums)
    
    % gets the subject number 
    s_num = subjects_nums(i);
    fprintf('Analyzing subject: %.0f | ',s_num);
    
    % loads the trial frames data (which frames are which trial)
    load(fullfile(trial_frames_dir,[study_name '_S#' num2str(s_num) '_TrialsFrameTimes.mat']));
    bad_frames = [];
    
    % go over all trials 
    for trial_num = 1:size(trials_frames,1)
        
        % initialize trial structure
        trial_frame_onset =  trials_frames(trial_num,1)-1;
        trial_frame_offset =  trials_frames(trial_num,2)-1;
        trial_data_x = [];
        trial_data_y = [];
        trial_face_x = [];
        trial_face_y = [];
        trial_data_conf = [];
        
        % go over all frames within the trials
        for tf=trial_frame_onset:trial_frame_offset 
            
            % gets the relevant json file and loads json data
            JSonFileName = [study_name '_S#' num2str(s_num) 'ForOpenPose_' sprintf('%012d',tf) '_keypoints.json'];
            try
            json_data=loadjson(fullfile(data_dir, json_dir, JSonFileName));
            catch ex              
                bad_frames=[bad_frames; trial_num tf -1]; % this is in case not data from that frame - continues;
                continue;
            end
            
            % convert JSON data to vector
            infant_data = GetInfantData(json_data);
            
            % if detection data failed
            if (isempty(infant_data))
                bad_frames=[bad_frames; trial_num tf 0]; % if data from the frame is not sufficient (can't even know who is the baby) - skip the frame
                continue;
            end
            
            % gets only the relevant points in the skeleton
            right_hand_data = infant_data(:,5);
            left_hand_data = infant_data(:,8);
            right_foot_data = infant_data(:,11);
            left_foot_data = infant_data(:,14); 
            face_data = infant_data(:,1); 
            
            % checks that detection passes threhold level
            if (right_hand_data(3)<confidence_threshold || ...
                left_hand_data(3)<confidence_threshold || ...
                right_foot_data(3)<confidence_threshold || ...
                left_foot_data(3)<confidence_threshold)
                bad_frames=[bad_frames; trial_num tf 1]; % if data from at least one point is missing - skip this frame
                continue;
            end
            
            % if detection is good - adds it to the trial array.
            % face detection is relevant only for anonymizing the videos
            trial_data_x = [trial_data_x; right_hand_data(1) left_hand_data(1) right_foot_data(1) left_foot_data(1)];
            trial_data_y = [trial_data_y; right_hand_data(2) left_hand_data(2) right_foot_data(2) left_foot_data(2)];
            trial_data_conf = [trial_data_conf; right_hand_data(3) left_hand_data(3) right_foot_data(3) left_foot_data(3)];
            trial_face_x = [trial_face_x; face_data(1)];
            trial_face_y = [trial_face_y; face_data(2)];
        end
        
        % adds detections to subject cell array
        s_data_x{trial_num} = trial_data_x;
        s_data_y{trial_num} = trial_data_y;
        s_data_conf{trial_num} = trial_data_conf;
        s_face_x{trial_num} = trial_face_x;
        s_face_y{trial_num} = trial_face_y;
    end
    
    % saves the subject open pose data 
   save(fullfile(data_dir,'OpenPoseData',[study_name '_S#' num2str(s_num)]),'s_data_x','s_data_y','s_data_conf','bad_frames','s_num','s_face_x','s_face_y');
   clear s_data_x s_data_y s_data_conf
end