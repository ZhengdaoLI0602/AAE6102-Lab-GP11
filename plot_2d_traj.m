function plot_2d_traj(plotting_method, receiver_table, color, label)
    gnss_lon = receiver_table.Longitude;
    gnss_lat = receiver_table.Latitude;
    % truth_lon = gt_table.Longitude;
    % truth_lat = gt_table.Latitude;
    if plotting_method == "plot"
        plot(gnss_lon, gnss_lat, color, 'DisplayName', label, LineWidth=2);
    elseif plotting_method == "scatter"
        scatter(gnss_lon, gnss_lat, 12, color, 'filled', 'DisplayName', label);
    end
end