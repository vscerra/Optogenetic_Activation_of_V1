% This script goes through the analysis of proportion of correct responses,
% fitting of the response curves with a Naka-Rushton function, and plotting
% those curves with the data for the target detection task with optogenetic
% activation of inhibitory cells in macaque V1.
% Scripts and functions called:
% datlist.m
% data files from 7 experimental data collection days
% TarDet_behavior_pc.m
% NakaRushton_fit.m


data_files = [1:7]; % Choose which data files to analyze, all = 1:7
trials = [2,4];    % 1 = In RF, no laser; 2 = Out of RF, no laser; 3 = In RF, laser; 4 = Out of RF, no laser
plotting = 3;       % 1 = percent correct; 2 = reaction time; 3 = both pc and rt
plot_se = 1;        % 1 = include SE bars, 0 = no error bars

% =========================================================================
% Plotting variables
trial_labels = {'in RF, no laser';'out of RF, no laser';'in RF, with laser';'out of RF, no laser'};
colors = [.1, .1, .1;       %black
    0.5, 0.5, 0.5;    %grey
    0, .7, .3;        %green
    0.3, 0.9, 0.5];   %lt green
line_styles = {'-','-.','-','-.'};
marker_styles = {'o','o','d','d'};
xgrid = linspace(.00,1);
lw = 2;
ms = 8;
pc_label_x = [.09, .04, .35, .25];
pc_label_y = [.80, .65, .50, .40];
rt_label_x = .35;
rt_label_y = [400, 385, 370, 355];
label_text = {'\bfIn RF, No laser','\bfOut RF, No Laser','\bfIn RF, with laser','\bfOut RF, with laser'};
% Pre-allocate variables
pc_params = zeros(4,3);
rt_params = zeros(4,3);
ygrid = zeros(4,length(xgrid));
%% Proportion of correct responses
if plotting == 1 || plotting == 3
    figure;
    for i = trials
        [R, I, n, SD] = TarDet_behavior_pc(data_files, i);
        [pc_params(i,:), nkrFun] = NakaRushton_fit(R, I);
        ygrid(i,:) = nkrFun(pc_params(i,:),xgrid);
        plot(I,R,marker_styles{i},'MarkerEdgeColor',colors(i,:),'MarkerSize',ms,'MarkerFaceColor',colors(i,:))
        hold on
        plot(xgrid,nkrFun(pc_params(i,:),xgrid),'Color',colors(i,:),'LineWidth',lw,'LineStyle', line_styles{i})
        set(gca,'XScale','log','TickDir','out','YTick',[0,.25,.5,.75,1])
        box off
        text(pc_label_x(i),pc_label_y(i),label_text{i},'Color',colors(i,:),'HorizontalAlignment','center')
        if plot_se == 1
            errorbar(I,R,SD./sqrt(n),marker_styles{i},'color',colors(i,:),'LineWidth',lw)
        end
    end
    if any(trials == 1) && any(trials == 3)
        plot(xgrid, abs(ygrid(1,:)-ygrid(3,:)),'m','LineStyle',':','LineWidth',lw)
        text(.06,.03,'Laser Stimulation Effect','Color','m')
    end
    xlabel('Target Contrast')
    ylabel('Proportion Correct')
    text(.1,1.03,'Laser Stimulation Shifts the Psychometric Curve','Color','b','FontSize',14,'HorizontalAlignment','center');
    text(.1,.97, 'Only When Target and Stimulation are in the RF','Color','b','Fontsize',13,'HorizontalAlignment', 'center')
    hold off
    
end

%% Reaction Time
if plotting == 2 || plotting == 3
    figure;
    for i = trials
        [R, I, n, SD] = TarDet_behavior_rt(data_files, i);
        plot(I,R,marker_styles{i},'MarkerEdgeColor',colors(i,:),'MarkerSize',ms,'MarkerFaceColor',colors(i,:))
        hold on
        set(gca,'XScale','log','TickDir','out','YTick',[250, 350, 450])
        box off
        text(rt_label_x,rt_label_y(i),label_text{i},'Color',colors(i,:))
        if plot_se == 1
            errorbar(I,R,SD./sqrt(n),marker_styles{i},'color',colors(i,:),'LineWidth',lw)
        end
    end
    xlim([.05,1])
    ylim([200, 450])
    xlabel('Target Contrast [0.05 -> 1]')
    ylabel('Reaction Time [ms]')
    text(.07,460,'Increased Target Contrast Speeds RT','Color','b','FontSize',14);
    text(.08,445, 'But Laser Stimulation has No Effect','Color','b','Fontsize',13);
    hold off
    
end