function receiver_data = read_pos_data(file_path, Nr_skipped_lines)
    % file_path = '20210521.medium-urban.whampoa.ublox.f9p.txt';
    fid = fopen(file_path, 'r');
    % Skip the first xxx lines
    for i = 1:Nr_skipped_lines
        fgets(fid);
    end
    % Initialize variables
    receiver_data = [];
    % Read line by line and extract receiver_data
    while ~feof(fid)
        line = fgets(fid);
        if isempty(line) || line(1) == '%'
            continue;
        end
        % Split the line into columns
        columns = strsplit(line);
        % Convert columns to numeric values
        values = str2double(columns);
        % Append to receiver_data array
        receiver_data = [receiver_data; values];
    end
    % Close the file
    fclose(fid);

    % delete the NaN column
    receiver_data(:, end) = [];
    
    % % Create a table from the receiver_data
    % columnNames = {'Week', 'GPSTime','Latitude', 'Longitude', 'Height', 'Q', 'ns', 'sdn', 'sde', 'sdu', 'sdne', 'sdeu', 'sdun', 'age', 'ratio'};
    % receiver_table = array2table(receiver_data, 'VariableNames', columnNames);
end