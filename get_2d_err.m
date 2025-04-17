function [err_2d, err_2d_statis, nr_sat] = get_2d_err(gt_ecef, gt_table, receiver_table)
    receiver_ecef = llh2ecef( table2array(receiver_table(:,3:5)) .* [pi/180, pi/180, 1] );

    err_enu = zeros(size(gt_ecef, 1), 3);
    nr_sat = zeros(size(gt_ecef, 1), 1);
    for i = 1: size(err_enu , 1)
        cur_time = gt_table.GPSTime(i);
        
        cur_receiver_idx  = find(round(receiver_table.GPSTime) == cur_time);
        if size(cur_receiver_idx, 1) ~= 0
            err_enu(i, :) = ecef2enu( receiver_ecef(cur_receiver_idx,:), gt_ecef(i,:) );
            nr_sat(i) = receiver_table.ns(cur_receiver_idx);
        else
            err_enu(i, :) = [nan, nan, nan];
            nr_sat(i) = nan;
        end
    end
    err_2d = vecnorm(err_enu(:, 1:2), 2, 2); % 2-norm; dim=2
    
    % Report
    valid_idx = ~isnan(err_enu(:,1));
    rmse_2de = rms(err_2d(valid_idx));
    std_2de  = std(err_2d(valid_idx));
    err_2d_statis = [round(rmse_2de,2), round(std_2de,2)];
    disp(['Received epochs / Ground truth epochs: ', num2str(sum(valid_idx)), ' / ' num2str(length(gt_ecef))])
    disp(['2D Error (mean | std): ', num2str(rmse_2de),'  |  ', num2str(std_2de)])
end