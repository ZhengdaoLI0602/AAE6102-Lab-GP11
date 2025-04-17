%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The codes are used for the lab report of the subject AAE6102
%
% Written by Zhengdao LI (zhengda0.li@connect.polyu.hk), Group 11
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clearvars
close all

para = 'snrmask';
this_folder = ['Figures\', para];
if ~isfolder(this_folder)
    mkdir(this_folder);
end


%% Load ground truth file
% Skip preambles
Nr_skipped_lines = 2;
gt_data = read_pos_data('UrbanNav_whampoa_raw.txt', Nr_skipped_lines);

% Convert minute and second to unit of degree
gt_data(:, 4) = gt_data(:, 4) + gt_data(:, 5)./60 + gt_data(:, 6)./3600;
gt_data(:, 7) = gt_data(:, 7) + gt_data(:, 8)./60 + gt_data(:, 9)./3600;
% Delete the redundant columns
gt_data(:, [5:6, 8:9]) = [];

% Create a table from the gt_data
columnNames = {'UTCTime', 'Week', 'GPSTime', 'Latitude', 'Longitude', 'H-Ell', 'VelBdyX', 'VelBdyY', 'VelBdyZ', 'AccBdyX', 'AccBdyY', 'AccBdyZ', 'Roll', 'Pitch', 'Heading', 'Q'};
gt_table = array2table(gt_data, 'VariableNames', columnNames);
gt_ecef = llh2ecef( table2array(gt_table(:,4:6)) .* [pi/180, pi/180, 1] );



%% Load positioning file (benchmark)
% Skip preambles
Nr_skipped_lines = 27;
receiver_data = read_pos_data('20210521.medium-urban.whampoa.ublox.f9p.pos', Nr_skipped_lines);
% Create a table from the receiver_data
columnNames = {'Week', 'GPSTime','Latitude', 'Longitude', 'Height', 'Q', 'ns', 'sdn', 'sde', 'sdu', 'sdne', 'sdeu', 'sdun', 'age', 'ratio'};
receiver_table = array2table(receiver_data, 'VariableNames', columnNames);
receiver_ecef = llh2ecef( table2array(receiver_table(:,3:5)) .* [pi/180, pi/180, 1] );


%
% Nr_skipped_lines = 27;
% receiver_data = read_pos_data('../20210521.medium-urban.whampoa.ublox.f9p.pos', Nr_skipped_lines);
% columnNames = {'Week', 'GPSTime','Latitude', 'Longitude', 'Height', 'Q', 'ns', 'sdn', 'sde', 'sdu', 'sdne', 'sdeu', 'sdun', 'age', 'ratio'};
% receiver_table = array2table(receiver_data, 'VariableNames', columnNames);
% 
% save snrmask_on receiver_table





%% Visualization

%--------  Figure 1: Trajectory-------- 
figure;
hold on;
plot_2d_traj("plot", gt_table, 'g', 'Ground Truth')
load("benchmark.mat")
plot_2d_traj("scatter", receiver_table, 'b', 'No SNR mask (Benchmark)')
load("snrmask_on.mat")
plot_2d_traj("scatter", receiver_table, 'r', 'With SNR mask')
set(gcf, 'Position', [100, 100, 500, 500]); % Resizes the current figure

xlabel('Longitude (degrees)');
ylabel('Latitude (degrees)');
legend('show');
grid on;
saveas(gcf, [this_folder,'\traj_2d.png']);


%--------  Figure 3: Number of satellites -------- 
figure;
hold on;
load("benchmark.mat")
[~, ~, Nr_Sat] = get_2d_err(gt_ecef, gt_table, receiver_table);
plot(Nr_Sat, 'b', 'DisplayName', 'No SNR mask (Benchmark)' , LineWidth=1);
load("snrmask_on.mat")
[~, ~, Nr_Sat] = get_2d_err(gt_ecef, gt_table, receiver_table);
plot(Nr_Sat, 'r', 'DisplayName', 'With SNR mask' , LineWidth=1);

set(gcf, 'Position', [100, 100, 1000, 300]); % Resizes the current figure
xlabel('Time (epoch)')
ylabel('Number of valid satellite signal')
ylim([0 1.35*max(Nr_Sat)])
legend('show');
grid on;
saveas(gcf, [this_folder,'\nr_sats.png']);


%-------- Figure 2: Error-------- 

% Making plot
figure; hold on
load("benchmark.mat"); [err_2d, err_2d_statis(1,:), ~] = get_2d_err(gt_ecef, gt_table, receiver_table);
plot((1:1:size(gt_ecef, 1)), err_2d, 'b-', 'LineWidth', 1.5, 'DisplayName','No SNR mask (Benchmark)')  % blue solid line with width 2
load("snrmask_on.mat"); [err_2d, err_2d_statis(2,:), ~] = get_2d_err(gt_ecef, gt_table, receiver_table);
plot((1:1:size(gt_ecef, 1)), err_2d, 'r-', 'LineWidth', 1.5, 'DisplayName','With SNR mask')  % blue solid line with width 2
set(gcf, 'Position', [100, 100, 500, 500]); % Resizes the current figure
legend('show')
xlabel('Time (epoch)')
ylabel('2D Error (meter)')
grid on
saveas(gcf, [this_folder,'\err_2d.png']);










