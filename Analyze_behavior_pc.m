function [response, intensity, n_trials, response_sd] = TarDet_behavior_pc(data_files, trial_type)
% This is a function to extract behavioral response data for the presented intensities. 
% This is for use with the miga data structures collected by Mike Avery for the target detection
% optogenetic experiment in macaque V1. 

% Inputs:
    % data_files : 1-7 are the usable days of data, use the
        % numbers of the files (1:7) from datlist 
    % trial_type : 1-4 representing the 4 types of trials presented in the
        % experiment. 1)target in no laser; 2)target out no laser; 3)target in laser, 4)target out no laser
% Outputs: 
    % response : vector, behavioral response in proportion of correct responses
        % for the presented intensities
    % intensity : vector, of presented stimulus contrast intensity 
    % n_trials : vector, number of trials presented at each contrast
    % response_sd : vector, standard deviation of the responses for each contrast
    
    % VScerra 2023
    
% Call data from the datalist
datlist
% Initialize some variables 
contrast = [6, 12, 25, 50, 99];                 % These were the contrast values used in the experiment
trials = zeros(1, length(contrast));            
correct_trials = zeros(1, length(contrast));    

for i = 1:length(data_files)
    load(dlist(data_files(i),:))
    for j = 1:size(miga.event_mat,2)
        if ~isempty(miga.event_mat{1,j}) && any(miga.event_mat{1,j}.allevent_codes == 6003)
            location = miga.event_mat{1,j}.attendinRF(1);
            laser = miga.event_mat{1,j}.lasertrial(1);
            if location == 1 && laser == 1
                type = 3;
            elseif location == 1 && laser == 0
                type = 1;
            elseif location == 0 && laser == 1
                type = 4;
            elseif location == 0 && laser == 0
                type = 2;
            end
            if type == trial_type
                trials = [trials; contrast == miga.event_mat{1,j}.target_contrast];
                correct_trials = [correct_trials; contrast == miga.event_mat{1,j}.target_contrast.*miga.event_mat{1,j}.correct_resp];
            end
        end
    end
end
         
response = sum(correct_trials)./sum(trials);    
intensity = contrast*.01;
n_trials = sum(trials);
for s = 1:length(contrast)
    response_sd(1,s) = std(correct_trials(trials(:,s)==1,s));
end
end

