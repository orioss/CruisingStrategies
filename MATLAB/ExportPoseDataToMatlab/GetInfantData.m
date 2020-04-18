function infant_data = GetInfantData(json_data)
% GetInfantData gets a json structure, and returns infant data as a vector
%
%% Syntax
% infant_data = GetInfantData(json_data)
%
%% Description
% GetInfantData is used for exporting the pose information to MATLAB. It
% gets a json structure as input, parse it, identifies the infant and returns the body
% keypoint as a vector. The meaning of each colums can be found in OpenPose
% documentation: https://github.com/ArtificialShane/OpenPose/blob/master/doc/output.md
% Please note there are 2 versions of openpose. the old version is
% commented but can be used.
%
% Required Input.
% json_data: json structure to parse

% gets the part of json that includes people key point
people_data = json_data.people;

% initialize arrays for analysis 
all_pose_data = [];
num_of_zeros_in_data = [];

% go over each detected body
for p_idx=1:length(people_data)
    
   % gets key points 
   person_data =  people_data{p_idx};
   
   % tranlate it to 2d keypoints
   pose_data = person_data.pose_keypoints_2d; % new version 
   %pose_data = cell2mat(person_data.pose_keypoints); % old version 
   
   % checks how many kekypoints were not detected
   num_of_zeros_in_data = [num_of_zeros_in_data; length(pose_data(pose_data==0))];
   
   % get the pose data
   all_pose_data = [all_pose_data; pose_data];
end

% infant is the person with the maximal information in the frame
infant_data = all_pose_data((num_of_zeros_in_data==min(num_of_zeros_in_data)),:);

% insert the pose data as a vector to others
if (size(infant_data,1)==1)
    infant_data = reshape(infant_data,3,18);
else
    infant_data = [];
end 