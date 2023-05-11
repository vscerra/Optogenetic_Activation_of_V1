% This is a testbed for functions to extract behavioral data pertaining to correct responses and reaction time. 
% This is for use with the miga data structures collected by Mike Avery for the target detection
% optogenetic experiment in macaque V1. 
clear
% Call data from the datalist
datlist
data_files = 1;
trial_type = 1;
contrast = [6, 12, 25, 50, 99];                 % These were the contrast values used in the experiment
trials = zeros(1, length(contrast));            % 4 rows correspond to : 1)target in no laser; 2)target out no laser; 3)target in laser, 4)target out no laser
correct_trials = zeros(1, length(contrast));    % 4 rows correspond to : 1)target in no laser; 2)target out no laser; 3)target in laser, 4)target out no laser

%% Proportion correct 
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
intensity = contrast;
n_trials = sum(trials);
for s = 1:length(contrast)
    response_sd(1,s) = std(correct_trials(trials(:,s)==1,s));
end

%% Reaction times
datlist
data_files = [1:7];
trial_type = 1;
contrast = [6, 12, 25, 50, 99];                 % These were the contrast values used in the experiment
rt = zeros(1, length(contrast));            % 4 rows correspond to : 1)target in no laser; 2)target out no laser; 3)target in laser, 4)target out no laser

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
                if miga.event_mat{1,j}.correct_resp == 1
                    rt(j,contrast == miga.event_mat{1,j}.target_contrast) = miga.event_mat{1,j}.saccade_onset_time - miga.event_mat{1,j}.change_time_actual;
                end
            end
        end
    end
end
n_trials = sum(rt>0);
rt_mean = sum(rt)./n_trials;
intensity = contrast;
for s = 1:length(contrast)
    rt_sd(1,s) = std(rt(rt(:,s)>0,s));
end

%% Building the fit function for PC data

% Define the Naka-Rushton function
nkrFun =  @(params,I) params(1) * (I.^params(2)) ./ (I.^params(2) + params(3).^params(2));
% Initialize parameters
I = contrast;
R = percent_correct;
initial_R_max = .9;
initial_n = 0.7;
initial_sigma = 0.1;
% Define negative log-likelihood function
nll_func = @(params) -sum(log(normpdf(R, params(1) * (I.^params(2)) ./ (I.^params(2) + params(3).^params(2)), params(3))));
initial_params = [initial_R_max, initial_n, initial_sigma]; % Initial parameter values
% Perform optimization
opts = optimset('MaxFunEvals', 100000, 'MaxIter', 100000);
estimated_params = fminsearch(nll_func, initial_params,opts);
xgrid = linspace(.00,1);
ygrid = nkrFun(estimated_params,xgrid);


