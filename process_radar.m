% 1. Extract the digital signal from the Simulink workspace variable
% Note: Depending on your Simulink version, the array might just be named 'rx_digital'
signal = out.rx_digital; 

% 2. Perform the Fast Fourier Transform (FFT)
% We use N_samples (from your init script) to define the length of our FFT
signal_fft = fft(signal, N_samples);

% 3. Calculate the frequency axis
% The standard FFT mirrors itself, so we only look at the first half (positive frequencies)
half_length = floor(double(N_samples) / 2);
fft_mag = abs(signal_fft(1:half_length)); 

% Map the digital bins to actual frequencies in Hz
freq_axis = (0:half_length-1)' * (fs / double(N_samples));

% 4. Find the dominant beat frequency (f_beat)
[~, max_idx] = max(fft_mag);
f_beat = freq_axis(max_idx);

% 5. Apply the extraction formula we just derived
Calculated_Range = (f_beat * c) / (2 * S);

% 6. Plot the FFT and display the final result
plot(freq_axis / 1e6, fft_mag, 'LineWidth', 1.5);
xlabel('Frequency (MHz)');
ylabel('Amplitude');
title('Digital Signal Processing: FFT');
grid on;

fprintf('Detected Beat Frequency: %.2f MHz\n', f_beat / 1e6);
fprintf('Calculated Target Range: %.2f meters\n', Calculated_Range);