function [linearStartIndices, linearEndIndices, info, deltas] = findTwoLinearPortions(DE, de, threshold, Ddata, currentStripSize, window_index)
    % Initialize variables
    maxAttempts = 10;
    PLOT = 1;
    info = [];
    thresholdAttempts = 0;
    linearPortions = struct('startIndex', [], 'endIndex', [], 'deltas', []);
    deltas = [];
    colors = {'r', 'g', 'b', 'c', 'm', 'y', 'k'};

    % Iterate until two linear portions are found or threshold becomes too small
    while threshold >= 0
        % Use ischange to detect the end of the linear portion
        [TF, SI, Ic] = ischange(DE, 'linear', 'Threshold', threshold);

        % Check if any change points were detected
        if any(TF)
            changeIndices = find(TF);
            numChanges = numel(changeIndices);

            % Ensure there are at least two change points detected
            if numChanges >= 2
                % Iterate through the detected change points
                for changeIndex = 1:numChanges-1
                    % Extract the start and end indices for potential linear portions
                    startIdx = changeIndices(changeIndex);
                    endIdx = changeIndices(changeIndex + 1);

                    % Check if the indices are within bounds and form a valid linear portion
                    if endIdx > startIdx && DE(endIdx) > DE(startIdx) && (endIdx - startIdx) >= 5
                        % Process the linear portion
                        FitLine = polyfit(de(startIdx:endIdx), DE(startIdx:endIdx), 1);
                        delta = FitLine(1); % scaling parameter

                        % Store the linear portion information
                        linearPortions(end+1).startIndex = startIdx;
                        linearPortions(end).endIndex = endIdx;
                        linearPortions(end).deltas = delta; % Store delta value for this linear portion
                    end
                end
            end

            % Check if two linear portions are found
            if numel(linearPortions) >= 2
                % Update info if two linear portions are found
                info = 0;
                break; % Exit the loop once two linear portions are found
            end
        end

        % Decrease threshold if no linear portions are found
        threshold = threshold - 0.0001;

        % Increment thresholdAttempts and reset maxAttempts if needed
        thresholdAttempts = thresholdAttempts + 1;
        if thresholdAttempts == maxAttempts
            thresholdAttempts = 0;
            maxAttempts = 10;
        end
    end

    % If no suitable linear portions are found, set default values
    if isempty(linearPortions)
        linearPortions(1).startIndex = round(0.2 * length(de));
        % Find linearEndIndex by searching from linearStartIndex onwards
        for i = linearPortions(1).startIndex + 10:length(de)
            % Use ischange to detect change points from linearStartIndex
            [TF, SI, Ic] = ischange(DE, 'linear', 'Threshold', 0.008);

            % Check if any change points were detected
            if any(TF)
                changeIndices = find(TF);

                % Find the first change index
                linearPortions(1).endIndex = i + changeIndices(1) - 1;

                % Ensure the difference between linearStartIndex and linearEndIndex is greater than or equal to 5
                if (linearPortions(1).endIndex - linearPortions(1).startIndex) >= 5
                    break; % Exit the loop if a suitable linear portion is found
                end
            end
        end

        % Process the default linear portion or store relevant information
        FitLine = polyfit(de(linearPortions(1).startIndex:linearPortions(1).endIndex), ...
                          DE(linearPortions(1).startIndex:linearPortions(1).endIndex), 1);
        linearPortions(1).deltas = FitLine(1); % scaling parameter

        % Update info to '' is default values are used
        info = 1;
    end

    % Check if deltas from the third portion exceed 0.7
    if numel(linearPortions) >= 3 && linearPortions(3).deltas > 0.7
        % Take deltas from the next linear portion (fourth portion)
        linearStartIndices = linearPortions(4).startIndex;
        linearEndIndices = linearPortions(4).endIndex;
        deltas = linearPortions(4).deltas;
    else
        % Extract linear portion information for the third portion if available
        if numel(linearPortions) >= 3
            linearStartIndices = linearPortions(3).startIndex;
            linearEndIndices = linearPortions(3).endIndex;
            deltas = linearPortions(3).deltas;
        else
            % Set default values if fewer than three portions are found
            linearStartIndices = [];
            linearEndIndices = [];
            deltas = [];
        end
    end

    % Plot linear portions
    if PLOT
        figure;
        subplot(1, 2, 1);
        plot(Ddata);


        subplot(1, 2, 2);
        plot(de(3:end), DE(3:end), '+');
        hold on;
    
        % Plot the linear portion associated with saved indices and delta
        FitLine = polyfit(de(linearStartIndices:linearEndIndices), DE(linearStartIndices:linearEndIndices), 1);
        plot(de(linearStartIndices:linearEndIndices), FitLine(1) * de(linearStartIndices:linearEndIndices) + FitLine(2), 'r--', 'LineWidth', 1.5); % Plot the fit line
        scatter(de(linearStartIndices), DE(linearStartIndices), 50, 'k', 'filled', 'DisplayName', 'Start of Linear Portion');
        scatter(de(linearEndIndices), DE(linearEndIndices), 50, 'k', 'filled', 'DisplayName', 'End of Linear Portion');
    
        xlabel('log(l)'), ylabel('S(l)');
        legend(['\delta = ' num2str(sprintf('%.3f', deltas))], 'Location', 'northwest');
        title(['Linear Portions for Channel - Window Index ' num2str(window_index)]);    

        hold off 


    end
end
