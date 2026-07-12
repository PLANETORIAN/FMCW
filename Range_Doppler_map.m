% 1. Retrieve the raw 1D array from Simulink (all 128 chirps)
raw_1D_signal = out.rx_digital; 

% 2. Reshape into a 2D Matrix
% Rows = N_samples (Fast-Time / Range)
% Columns = N_chirps (Slow-Time / Velocity)
% 1. Calculate the exact mathematical size your 2D matrix requires
required_elements = N_samples * N_chirps;

% 2. Extract only the valid data (taking the LAST required_elements from the array)
% This safely ignores any extra t=0 initialization frames Simulink logged
valid_1D_signal = raw_1D_signal(end - required_elements + 1 : end);

% 3. Reshape the perfectly sized array into your 2D Range-Doppler matrix
sig_matrix = reshape(valid_1D_signal, N_samples, N_chirps);

% 3. First FFT (Fast-Time / Range)
% We run a 1D FFT down every single column simultaneously
range_fft = fft(sig_matrix, N_samples, 1);

% We still only care about the positive half of the range frequencies
half_length = floor(double(N_samples) / 2);
range_fft_half = range_fft(1:half_length, :);

% 4. Second FFT (Slow-Time / Doppler)
% We run a second FFT across the rows to find the phase shift between chirps
doppler_fft = fft(range_fft_half, N_chirps, 2);

% Shift the zero-Doppler frequency to the center of the matrix
doppler_fft_shifted = fftshift(doppler_fft, 2);
RDM_magnitude = abs(doppler_fft_shifted);

% 2. Calculate the physical step sizes (Resolutions) using radar_init variables
% Velocity Resolution (m/s per bin)
v_res = lambda / (2 * N_chirps * Tc);

% Range Resolution (meters per bin)
% (If your init script calls it 'S' or 'slope', replace 'Sweep_Slope' below)
range_res = c / (2 * S * Tc);

% 3. Create the physical axis arrays
% Velocity Axis: Centered at 0, spanning from negative to positive velocity
velocity_axis = (-N_chirps/2 : N_chirps/2 - 1) * v_res;

% Range Axis: Starts at 0 and goes out to the maximum visible range
range_axis = (0 : half_length - 1) * range_res;

% 4. Plot using the physical axes instead of raw bins
figure;
% Feed the custom physical axes directly into the imagesc function
imagesc(velocity_axis, range_axis, RDM_magnitude);
colormap('jet');
colorbar;

% Label the physical units
xlabel('Velocity (m/s)');
ylabel('Range (Meters)');
title('Physical 2D Range-Doppler Map');
set(gca, 'YDir', 'normal'); % Flips the Y-axis so 0 range is at the bottom
