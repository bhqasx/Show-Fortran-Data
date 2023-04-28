% Create a figure window and set the mouse callback function
figure;
set(gcf, 'WindowButtonDownFcn', @mouse_callback);

% Initialize a counter and set the plot to update every 0.1 seconds
counter = 0;
dt = 0.1;

% Set up an infinite loop to continuously update the plot
while true
    % Increment the counter and compute the sine wave
    counter = counter + dt;
    y = sin(counter);
    
    % Plot the sine wave and pause for dt seconds
    plot(counter, y, '.');
    pause(dt);
    
    % Check if the left mouse button was clicked, and if so, pause the plot
    if getappdata(gcf, 'is_paused')
        pause;
    end
end

% Define the mouse callback function
function mouse_callback(src, event)
    % Check if the left mouse button was clicked
    if strcmp(get(src, 'SelectionType'), 'normal')
        % Set the 'is_paused' application data to true
        setappdata(src, 'is_paused', true);
    end
end
