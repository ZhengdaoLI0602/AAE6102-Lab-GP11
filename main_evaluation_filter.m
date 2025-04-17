%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The codes are used for the lab report of the subject AAE6102
%
% Written by Zhengdao LI (zhengda0.li@connect.polyu.hk), Group 11
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clearvars
close all

para = 'filter';
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

% save benchmark receiver_table





%% Visualization

%--------  Figure 1: Trajectory-------- 
figure;
hold on;
plot_2d_traj("plot", gt_table, 'g', 'Ground Truth')
load("benchmark.mat")
plot_2d_traj("scatter", receiver_table, 'b', 'Forward (Benchmark)')
load("filter_backward.mat")
plot_2d_traj("scatter", receiver_table, 'cyan', 'Backward')
load("filter_combined.mat")
plot_2d_traj("scatter", receiver_table, 'r', 'Combined')
set(gcf, 'Position', [100, 100, 500, 500]); % Resizes the current figure

% gnss_lon = receiver_table.Longitude;
% gnss_lat = receiver_table.Latitude;
% truth_lon = gt_table.Longitude;
% truth_lat = gt_table.Latitude;
% plot(truth_lon, truth_lat, 'g', 'DisplayName', 'Ground Truth', LineWidth=2);
% scatter(gnss_lon, gnss_lat, 15, 'b', 'filled', 'DisplayName', 'GNSS Positions');
xlabel('Longitude (degrees)');
ylabel('Latitude (degrees)');
% title('2D Trajectories');
legend('show');
grid on;
saveas(gcf, [this_folder,'\traj_2d.png']);


%--------  Figure 3: Number of satellites -------- 
figure;
hold on;
load("benchmark.mat")
% Nr_Sat = receiver_table.ns;
[~, ~, Nr_Sat] = get_2d_err(gt_ecef, gt_table, receiver_table);
plot(Nr_Sat, 'b', 'DisplayName', 'Forward (Benchmark)' , LineWidth=1);
load("filter_backward.mat")
% Nr_Sat = receiver_table.ns;
[~, ~, Nr_Sat] = get_2d_err(gt_ecef, gt_table, receiver_table);
plot(Nr_Sat, 'cyan', 'DisplayName', 'Backward' , LineWidth=1);
load("filter_combined.mat")
% Nr_Sat = receiver_table.ns;
[~, ~, Nr_Sat] = get_2d_err(gt_ecef, gt_table, receiver_table);
plot(Nr_Sat, 'r', 'DisplayName', 'Combined' , LineWidth=1);

set(gcf, 'Position', [100, 100, 1000, 300]); % Resizes the current figure
xlabel('Time (epoch)')
ylabel('Number of valid satellite signal')
ylim([0 1.35*max(Nr_Sat)])
legend('show');
grid on;
saveas(gcf, [this_folder,'\nr_sats.png']);


%-------- Figure 2: Error-------- 

% % initialize error matrix
% err_enu = zeros(size(gt_ecef, 1), 3);
% for i = 1: size(err_enu , 1)
%     cur_time = gt_table.GPSTime(i);
% 
%     cur_receiver_idx  = find(round(receiver_table.GPSTime) == cur_time);
%     if size(cur_receiver_idx, 1) ~= 0
%         err_enu(i, :) = ecef2enu( receiver_ecef(cur_receiver_idx,:), gt_ecef(i,:) );
%     else
%         err_enu(i, :) = [nan, nan, nan];
%     end
% end
% err_2d = vecnorm(err_enu(:, 1:2), 2, 2); % 2-norm; dim=2



% Making plot
err_2d_statis = [];
figure; hold on
load("benchmark.mat"); [err_2d, err_2d_statis(1,:), ~] = get_2d_err(gt_ecef, gt_table, receiver_table);
plot((1:1:size(gt_ecef, 1)), err_2d, 'b-', 'LineWidth', 1.5, 'DisplayName','Forward (Benchmark)')  % blue solid line with width 2
load("filter_backward.mat"); [err_2d, err_2d_statis(2,:), ~] = get_2d_err(gt_ecef, gt_table, receiver_table);
plot((1:1:size(gt_ecef, 1)), err_2d, 'cyan-', 'LineWidth', 1.5, 'DisplayName','Backward')  % blue solid line with width 2
load("filter_combined.mat"); [err_2d, err_2d_statis(3,:), ~] = get_2d_err(gt_ecef, gt_table, receiver_table);
plot((1:1:size(gt_ecef, 1)), err_2d, 'r-', 'LineWidth', 1.5, 'DisplayName','Combined')  % blue solid line with width 2
set(gcf, 'Position', [100, 100, 500, 500]); % Resizes the current figure
legend('show')
xlabel('Time (epoch)')
ylabel('2D Error (meter)')
grid on
saveas(gcf, [this_folder,'\err_2d.png']);

% % Filter out non-NaN epoch and display statistics 
% valid_idx = ~isnan(err_enu(:,1));
% ave_2de = mean(err_2d(valid_idx));
% std_2de =rms(err_2d(valid_idx));
% disp(['Received epochs / Ground truth epochs: ', num2str(sum(valid_idx)), ' / ' num2str(length(gt_ecef))])
% disp(['2D Error (mean | std): ', num2str(ave_2de),'  |  ', num2str(std_2de)])












