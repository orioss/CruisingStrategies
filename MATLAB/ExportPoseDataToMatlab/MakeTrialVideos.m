function MakeTrialVideos(data_dir, datavyu_csv_dir, study_name)
% MakeTrialVideos creates videos per subject only with the relevant frames
%
%% Syntax
% MakeTrialVideos(data_dir, datavyu_csv_dir)
%
%% Description
% MakeTrialVideos gets a datavyu csv file with the times of each trial and
% creates one video per subject that includes only the frames that are
% relevant for pose detection. The function also saved trial_frames file
% with details about which frames are relevant to which trial. 
%
% Required Input.
% data_dir: data folder to save matlab files 
% datavyu_csv_dir: directory with all datavyu_csv print files that include 
% the onset and offset of trials. must end with the suffix "DigitizingFrames.csv"
% study_name: the study name 

% Define params
output_dir = fullfile(data_dir, 'OutputVideo');
mkdir(output_dir);
vid_dir = fullfile(data_dir, 'Video');
mkdir(vid_dir);

% checks directories exist
if all(input_dir==0) || all(output_dir==0) || all(vid_dir==0)
    clear input_dir output_dir vid_dir;
    error('Missing directory!');
end

Start = @(x) fprintf('%s...',x);
Finish = @() disp('done.');

% Import
% The first step is to import the data and organize it into a struct array
% We do this so that we have to load a video only once.  We can construct
% all digitizing videos for each subject in one pass.
fprintf('Importing data...\n');
file = subdir(fullfile(datavyu_csv_dir,'*DigitizingFrames.csv'));
data = importdata(file.name);
subject_numbers =  cellfun(@str2double,data.textdata(2:end,2));
sub_number_unique = unique(subject_numbers);
times = data.data;
      
% go over all subjects
for s=1:length(sub_number_unique)
   subject_number = sub_number_unique(s);
   ['now constructing: ' num2str(subject_number)]
   relevant_times = times(subject_numbers==subject_number,:);
   if (size(relevant_times~=2))
       relevant_times=relevant_times(:,2:3);
   end
   
    % Instantiate video reader.
    Start('Initializing video for read');
    if (subject_number<10)
        mp4path = dir(fullfile(vid_dir,[study_name 'S#0' num2str(subject_number) '*']));
    else
        mp4path = dir(fullfile(vid_dir,[study_name 'S#' num2str(subject_number) '*']));
    end
        
    % createsa video reader 
    vr = VideoReader(fullfile(vid_dir,mp4path.name));
    mp4 = mp4path.name;

    tic;
    
    % gets the onsets and offsets
    fprintf('Constructing videos\n');
    onsets = relevant_times(:,1);
    onsets = onsets ./ 1000;
    offsets = relevant_times(:,2);
    offsets = offsets ./ 1000;    
    
    % for old standardization
    if (subject_number<10)
        
    % Initialize video writer
    vw = VideoWriter(fullfile(output_dir,[study_name 'S#0' num2str(subject_number) ...
                                          '_Digitizing.mp4']),'MPEG-4');
    else
        vw = VideoWriter(fullfile(output_dir,[study_name 'S#' num2str(subject_number) ...
                                          '_Digitizing.mp4']),'MPEG-4');
    end
    
    % writes the frame to the new video
    vw.FrameRate = 30;
    vw.open;
    trials_frames = [];
    trial_frame_counter=1;
    
    % Write each frame.
    for k = 1:numel(onsets)
        trial_start_frame = trial_frame_counter; 
        for k_frame=onsets(k):0.075:offsets(k)
            vr.CurrentTime = k_frame;
            vw.writeVideo(vr.readFrame());
            trial_frame_counter = trial_frame_counter+1;
        end
        trials_frames = [trials_frames; trial_start_frame trial_frame_counter-1];
    end

    % Finalize.
    vw.close;
    
    % saves the mapping between trials and frames
    save(fullfile(output_dir,[study_name 'S#' num2str(subject_number) '_TrialsFrameTimes.mat']),'trials_frames');    
end