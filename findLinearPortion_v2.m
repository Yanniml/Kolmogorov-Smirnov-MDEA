function [linearStartIndex, linearEndIndex, deltas] = findLinearPortion_v2(DE, de, threshold, Ddata, currentStripSize, window_index)
%Sabrina Sullivan
% Ioannis Schizas, Scott Kerick, Sabrina Sullivan 
%DE, de: log-log Entropy
%threshold: detection of discontinuities (smaller threshold, greater
%sensitivity)
%Ddata: Normalized data divided by stripesize 
%currentStripSize: Stripesize from that window


%Output
%linearStartIndex: start of fit region for scaling indices 
%linearEndIndex: end of fit region for scaling indices 

% Initialize variables
maxAttempts = 10;
PLOT = 1;
thresholdAttempts = 0;


    % Iterate until a change point is found or threshold becomes too small
    while threshold >= 0
        % Use ischange to detect the end of the linear portion
        [TF, ~, ~] = ischange(DE, 'linear', 'Threshold', threshold);

        % Check if any change points were detected
        if any(TF)
            changeIndices = find(TF);

            for changeIndex = 1:numel(changeIndices)-1
                % Set the initial attempt count to 1
                attemptCount = 1;

                while attemptCount <= maxAttempts
                    % Use the detected change points as the start and end of the linear portion
                    linearStartIndex = changeIndices(changeIndex);
                    linearEndIndex = changeIndices(changeIndex + 1);

                    % Skip the first 4 data points
                    linearStartIndex = max(4, linearStartIndex); 

                    % Ensure that linearStartIndex is within the valid range
                    %While less than or greater than 30% of entropy
                    while linearStartIndex <= round(0.1 * length(de)) || linearStartIndex >= round(0.3 * length(de)) 
                        thresholdAttempts = thresholdAttempts + 1;
                        threshold = threshold - 0.0001;

                        if threshold < 0
                            break;
                        end 

                        % Use ischange again with the adjusted threshold to detect the linear portion
                        [TF, ~, ~] = ischange(DE, 'linear', 'Threshold', threshold);
                        
                        % Check if any change points were detected with the adjusted threshold
                        if any(TF)
                            % Find the change indices with the adjusted threshold
                            changeIndices = find(TF);
                        end

                        % Update linearStartIndex and linearEndIndex with the adjusted threshold
                        linearStartIndex = changeIndices(changeIndex);
                        linearEndIndex = changeIndices(changeIndex + 1);

                        linearStartIndex = max(4, linearStartIndex);
                    end 

                    % Check if linearEndIndex is greater than linearStartIndex in the x and y direction
                    if linearEndIndex > linearStartIndex && DE(linearEndIndex) > DE(linearStartIndex)
                        % Check if the linear portion has a minimum length of 10 data points
                        if (linearEndIndex - linearStartIndex) >= 10
                            % Process the linear portion or store relevant information
                            FitLine = polyfit(de(linearStartIndex:linearEndIndex), DE(linearStartIndex:linearEndIndex), 1);
                            deltas = FitLine(1); % this parameter is the scaling

                            % Plot the linear portion using the FitLine coefficients
                            if PLOT

%                                 fprintf('---------------------------------------------\n');
%                                 fprintf('ST: %d\n', linearStartIndex);
%                                 fprintf('EN: %d\n', linearEndIndex);
%                                 fprintf('delta: %d\n', deltas);
% 
%                                 figure;
%                                 subplot(1, 2, 1)
%                                 plot(Ddata)
%                                 title('Raw Signal');
% 
%                                 subplot(1, 2, 2)
%                                 plot(de(3:end), DE(3:end), '+', de(linearStartIndex:linearEndIndex), FitLine(1) * de(linearStartIndex:linearEndIndex) + FitLine(2), 'r--', 'LineWidth', 1.5);
%                                 hold on;
% 
%                                 % Mark the start and end of the linear portion with black dots
%                                 scatter(de(linearStartIndex), DE(linearStartIndex), 50, 'k', 'filled', 'DisplayName', 'Start of Linear Portion');
%                                 scatter(de(linearEndIndex), DE(linearEndIndex), 50, 'k', 'filled', 'DisplayName', 'End of Linear Portion');
% 
%                                 xlabel('log(l)'), ylabel('S(l)');
%                                 legend(['\delta = ' num2str(sprintf('%.3f', deltas))], 'Location', 'northwest');
%                                 title('Non-Linear');
% 
%                                 hold off
                            end

                            return; % Exit the function after processing the nonlinear portion
                        end
                    end

                    % Increment the attempt count
                    attemptCount = attemptCount + 1;
                end
            end
        end

        % If maxAttempts reached, decrease threshold
        if maxAttempts == 10
            threshold = threshold - 0.0001;
            % fprintf('new threshold after 10 attempts %.4f\n', threshold)
            maxAttempts = 10; % Reset maxAttempts for the next threshold value
        end
    end
    
    % If no suitable linear portion is found, set default values
    linearStartIndex = round(0.2 * length(de));
    
    % Find linearEndIndex by searching from linearStartIndex onwards
    for i = linearStartIndex+10:length(de)
        % Use ischange to detect change points from linearStartIndex
        [TF, SI, Ic] = ischange(DE, 'linear', 'Threshold', 0.001);
        
        % Check if any change points were detected
        if any(TF)
            changeIndices = find(TF);
            
            % Find the first change index
            linearEndIndex = i + changeIndices(1) - 1;
            
            if (linearEndIndex - linearStartIndex) >= 10 && linearEndIndex < 47
                break; % Exit the loop if a suitable linear portion is found
            end
        end
    end
    
    % Process the default linear portion or store relevant information
    FitLine = polyfit(de(linearStartIndex:linearEndIndex), DE(linearStartIndex:linearEndIndex), 1);
    deltas = FitLine(1); % this parameter is the scaling

%     fprintf('---------------------------------------------\n');
%     fprintf('ST: %d\n', linearStartIndex);
%     fprintf('EN: %d\n', linearEndIndex);
%     fprintf('delta: %d\n', deltas);
    

    % Plot default linear portion
    if PLOT
%         figure;
%         subplot(1, 2, 1)
%         plot(Ddata)
%         title('Raw Signal');
% 
%         subplot(1, 2, 2)
%         plot(de(3:end), DE(3:end), '+', de(linearStartIndex:linearEndIndex), FitLine(1) * de(linearStartIndex:linearEndIndex) + FitLine(2), 'r--', 'LineWidth', 1.5);
%         hold on;
% 
%         % Mark the start and end of the linear portion with black dots
%         scatter(de(linearStartIndex), DE(linearStartIndex), 50, 'k', 'filled', 'DisplayName', 'Start of Linear Portion');
%         scatter(de(linearEndIndex), DE(linearEndIndex), 50, 'k', 'filled', 'DisplayName', 'End of Linear Portion');
% 
%         xlabel('log(l)'), ylabel('S(l)');
%         legend(['\delta = ' num2str(sprintf('%.3f', deltas))], 'Location', 'northwest');
%         title('Linear');
% 
%         hold off
    end
end
