% Amassing trial data to better understand the CassOpto behavioral and
% neural analyses.
% Outputs: 
    % trialTab : putting trial data into a 2D matrix with pertinent
        % information on a trial-by-trial basis. 
    % trialTab_fields : cell array indicating what the columns in trialTab
        % are tabulating
    % eventTab : this is an exploration of the time codes from the monkeylogic
        % data and how they correspond to trial events


% VScerra, September 2018

%%%%%%   set a path and choose which data files to explore %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd('C:\Users\vscerra\Documents\MATLAB\targdet_data\Opto\data\');
data_files = 4; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%call the data from datlist
datlist
dataFolder = dlist(data_files,:);
%initialize some variables
eventTab = [];
trialTab = [];
trialTab_fields = [];
contrast = [6,12,25,50,99,NaN].*.01;
file_no = 0;

        for a = 1:length(data_files)
            load(dataFolder(a,:))
            file_no = file_no+1;
            %initalize temporary variables
            trial = zeros(size(miga.event_mat,2),25);
            trial(:,[7:13 20:25])=NaN;
            for i = 1:size(miga.event_mat,2)
                if ~isempty(miga.event_mat{1,i})
                    events = miga.event_mat{1,i};
                    codes = events.allevent_codes;
                    times = events.allevent_times;
                    non_t = 0;
                    for j = 1:size(codes,1)
                        if codes(j) == 100
                            eventTab{j,i} = ('Start Eye Data');
                            trial(i,23) = times(j);         % trial 23: when did eye recording start?
                            trialTab_fields{1,23} = ('begin eye data');
                        elseif codes(j) == 101
                            eventTab{j,i} = ('End Eye Data');         
                        elseif codes(j) == 501
                            eventTab{j,i} = ('Attend OUT');
                        elseif codes(j) == 6005
                            eventTab{j,i} = ('Correct');
                            trial(i,6) = 1;                 % trial 6: was the trial correct or incorrect? (1 or 0)
                            trialTab_fields{1,6} = ('correct response');
                        elseif codes(j) == 6006
                            eventTab{j,i} = ('Incorrect');
                        elseif codes(j) == 6021
                            eventTab{j,i} = ('Catch');
                            trial(i,27)=1;
                            trialTab_fields{1,27} = ('catch trial');
                        elseif codes(j) == 502
                            eventTab{j,i} = ('Attend IN');
                            trial(i,3) = 1;                 % trial 3: was the trial attend IN (1) or OUT(0)?
                            trialTab_fields{1,3} = ('target in RF');
                            j = events.RF_x;
                            y = events.RF_y;
                        elseif codes(j) == 3060
                            eventTab{j,i} = ('Attend OUT');
                        elseif codes(j) == 3061
                            eventTab{j,i} = ('Attend IN');
                        elseif codes(j) == 8
                            eventTab{j,i} = ('Fix occurs');
                        elseif codes(j) == 35
                            eventTab{j,i} = ('Fix on');
                        elseif codes(j) == 36
                            eventTab{j,i} = ('Fix off');
                        elseif codes(j) == 4800
                            eventTab{j,i} = ('Set trialNum');
                        elseif codes(j) == 3000
                            eventTab{j,i} = ('Laser on');
                            trial(i,4) = 1;                 % trial 4: Laser trial (0 = no, 1 = yes)
                            trialTab_fields{1,4} = ('laser trial');
                            trial(i,7) = times(j);          % trial 7: laser ON time
                            trialTab_fields{1,7} = ('laser ON time');
                        elseif codes(j) == 3001
                            eventTab{j,i} = ('Laser off');
                            trial(i,20) = times(j)- trial(i,7); % trial 20: Laser duration
                            trialTab_fields{1,20} = ('laser duration');
                        elseif codes(j) == 3050
                            eventTab{j,i} = ('No Laser');
                        elseif codes(j) == 3051
                            eventTab{j,i} = ('Laser tr');
                                                    elseif codes(j) == 6001
                            eventTab{j,i} = ('Non-T on');
                            non_t = non_t+1;                % counting up non-target stimuli
                        elseif codes(j) == 6002
                            eventTab{j,i} = ('Non-T off');
                        elseif codes(j) == 6003
                            eventTab{j,i} = ('T on');                        
                            trial(i,8) = times(j);          % trial 8: Target on time
                            trialTab_fields{1,8} = ('target on time');
                            trial(i,5) = 1;                 % trial 5: Target or no target (1 or 0)
                            trialTab_fields{1,5} = ('target trial');
                            trial(i,11) = events.target_contrast*.01;   % trial 11: Target contrast
                            trialTab_fields{1,11} = ('target contrast');
                            trial(i,12) = events.prev_nontarget_contrast*.01;   % trial 12: Non-target contrast
                            trialTab_fields{1,12} = ('non-target contrast');
                            trial(i,13) = trial(i,11)-trial(i,12);  % trial 13: change in target contrast from previous non-target
                            trialTab_fields{1,13} = ('change in target contrast');
                            trial(i,16) = events.target_phase;      % trial 16: what is the target's phase?
                            trialTab_fields{1,16} = ('target phase');
                            trial(i,17) = trial(i,16) - events.prev_nontarget_phase;    % trial 17: what is the change from the previous non-target's phase
                            trialTab_fields{1,17} = ('target phase change');
                            if trial(i,4)==1
                                trial(i,22) = trial(i,7)-times(j);      % trial 22: what is the laser target offset (Ltime - Ttime)
                                trialTab_fields{1,22} = ('laser target ofset');
                            else
                                trial(i,22) = NaN;
                            end
                        elseif codes(j) == 6004
                            eventTab{j,i} = ('T off');
                            trial(i,21) = times(j)-trial(i,8);  % trial 21: Target duration
                            trialTab_fields{1,21} = ('target duration');
                        elseif codes(j) == 6023
                            eventTab{j,i} = ('Saccade Go');
                            trial(i,9) = times(j);          %trial 9: saccade time
                            trialTab_fields{1,9} = ('saccade time');
                        elseif codes(j) == 6024
                            eventTab{j,i} = ('Foil on');
                        elseif codes(j) == 6025
                            eventTab{j,i} = ('Foil off');
                        elseif codes(j) == 4600
                            eventTab{j,i} = ('Change stimulus');
                        elseif codes(j) == 150
                            eventTab{j,i} = ('Trial start');
                        elseif codes(j) == 151
                            eventTab{j,i} = ('Trial end');
                            trial(i,24) = times(j);             % trial 24: trial end time;
                            trialTab_fields{1,24} = ('trial end time');
                        elseif codes(j) > 4299 && codes(j) < 4400
                            mssg = [' A phase ',num2str(codes(j)-4300)];
                            eventTab{j,i} = mssg;
                        elseif codes(j) > 4499 && codes(j) < 4600
                            mssg = ['NA phase ',num2str(codes(j)-4500)];
                            eventTab{j,i} = mssg;
                        elseif codes(j) > 4399 && codes(j) < 4500
                            mssg = ['NA contrast ',num2str(codes(j)-4400)];
                            eventTab{j,i} = mssg;
                        elseif codes(j) > 4199 && codes(j) < 4300
                            mssg = [' A contrast ',num2str(codes(j)-4200)];
                            eventTab{j,i} = mssg;
                        elseif codes(j) > 3999 && codes(j) < 4200
                            mssg = [' Base orient ',num2str(codes(j)-4000)];
                            eventTab{j,i} = mssg;
                            trial(i,15) = codes(j)-4000;                    % trial 15: what is the baseline orientation of stimulus
                            trialTab_fields{1,15} = ('stimulus orientation');
                        elseif codes(j) > 12000
                            mssg = ['Change time ',num2str(codes(j)-12000)];
                            eventTab{j,i} = mssg;
                        else
                            eventTab{j,i} = codes(j);
                        end
                        
                        trial(i,25) = i;
                        trialTab_fields{1,25} = ('trial number');
                    end
                    if trial(i,9)>0
                        trial(i,10) = trial(i,9)-trial(i,8);   %trial 10: RT? Saccade go minus target on time
                        trialTab_fields{1,10} = ('reaction time');
                    end
                    if trial(i,6) == 1 && ~isnan(trial(i,8))
                        trial(i,18) = 1;                       % trial 18: trial code 1 = correct/target
                        trialTab_fields{1,18} = ('trial code');
                    elseif trial(i,6) == 1 && isnan(trial(i,8))
                        trial(i,18) = 2;                       % trial 18: trial code 2 = correct/catch (no target)
                    elseif trial(i,6) == 0 && trial(i,9)>0 && (events.fix_break == 1 || events.false_alarm_att ==1 || events.false_alarm_notatt == 1)
                        trial(i,18) = 3;                       % trial 18: trial code 3 = false alarm/fixation break
                    elseif trial(i,6) == 0 && trial(i,8)> 0 && events.miss_target ==1
                        trial(i,18) = 4;                       % trial 18: trial code 4 = miss (target)
                    end
                    trial(i,14) = non_t;
                    trialTab_fields{1,14} = ('non-target stimuli');
                    trialTab_fields{1,1} = ('target x');
                    trialTab_fields{1,2} = ('target y');
                    if trial(i,3) == 1
                        trial(i,1) = events.RF_x(1);
                        trial(i,2) = events.RF_y(1);
                    else
                        trial(i,1) = events.nonRF_x(1);
                        trial(i,2) = events.nonRF_y(1);
                    end
                    trial(i,26) = file_no;
                    trialTab_fields{1,26} = ('file number');
                end
            end
            trialTab = [trialTab;trial];
        end
    
   clearvars -except trialTab eventTab trialTab_fields
