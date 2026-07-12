% 1. Extract the digital signal for a single chirp
raw_signal = out.rx_digital(1:N_samples); 

% 2. Define the Windows in a cell array for easy looping
windows = {ones(N_samples, 1), hamming(N_samples), hann(N_samples)};
window_names = {'Rectangular', 'Hamming', 'Hann'};

% 3. Pre-allocate arrays to store results for the final comparison plot
half_length = floor(double(N_samples) / 2);
fft_mag_dB_all = zeros(half_length, 3);

% Map Range Axis (Digital Bins -> Frequency -> Range)
freq_axis = (0:half_length-1)' * (fs / double(N_samples));
range_axis = (freq_axis * c) / (2 * S); % Direct conversion to meters

% 4. Create the Figure
figure('Name', 'Windowing Analysis', 'Position', [100, 100, 1200, 800]);

% Loop through each of the 3 windows
for i = 1:3
    % Apply window in time domain
    signal_windowed = raw_signal .* windows{i};
    
    % Perform FFT
    signal_fft = fft(signal_windowed, N_samples);
    
    % Extract magnitude and convert to dB
    fft_mag = abs(signal_fft(1:half_length));
    fft_mag(fft_mag == 0) = 1e-12; % Prevent log(0)
    fft_mag_dB = 20 * log10(fft_mag);
    
    % Store for the overlay plot
    fft_mag_dB_all(:, i) = fft_mag_dB;
    
    % Plot individual window in the 2x2 grid
    subplot(2, 2, i);
    plot(range_axis, fft_mag_dB, 'LineWidth', 1.5);
    xlim([0, 100]);
    ylim([0, 90]); % Standardize Y-axis to see the floor drop
    xlabel('Range (meters)');
    ylabel('Amplitude (dB)');
    title(sprintf('%s Window', window_names{i}));
    grid on;
end

% 5. Create the 4th Subplot: The Overlay (Zoomed on the target)
subplot(2, 2, 4);
plot(range_axis, fft_mag_dB_all(:,1), 'LineWidth', 1.5, 'Color', [0 0.4470 0.7410]); hold on;
plot(range_axis, fft_mag_dB_all(:,2), 'LineWidth', 1.5, 'Color', [0.8500 0.3250 0.0980]);
plot(range_axis, fft_mag_dB_all(:,3), 'LineWidth', 1.5, 'Color', [0.9290 0.6940 0.1250]);
hold off;
xlim([40, 60]); % Zoomed in tightly around the 50m target
ylim([0, 90]);
xlabel('Range (meters)');
ylabel('Amplitude (dB)');
title('Window Trade-off: Main Lobe vs. Sidelobes');
legend(window_names);
grid on;