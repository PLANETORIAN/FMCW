% windowing.m - Rectangular vs Hamming vs Hann on one chirp (target at 120 m)
% FIX: the windows are written out as formulas and forced to columns. The old version called
% hamming(N), and a shadowing hamming.m on the MATLAB path (returns a row vector) turned the
% Hamming curve into the rectangular curve minus 21.9 dB. Axes also moved from 50 m to the 120 m target.
raw_signal = out.rx_digital(1:N_samples); raw_signal = raw_signal(:);
n = (0:N_samples-1)';
w_rect = ones(N_samples,1);
w_hamm = 0.54 - 0.46*cos(2*pi*n/(N_samples-1));
w_hann = 0.50 - 0.50*cos(2*pi*n/(N_samples-1));
windows = {w_rect, w_hamm, w_hann};
window_names = {'Rectangular','Hamming','Hann'};
half_length = floor(double(N_samples)/2);
fft_mag_dB_all = zeros(half_length,3);
freq_axis = (0:half_length-1)' * (fs/double(N_samples));
range_axis = (freq_axis*c)/(2*S);
figure('Name','Windowing (fixed)','Position',[100,100,1200,800]);
for i = 1:3
    X = fft(raw_signal .* windows{i}, N_samples);
    m = abs(X(1:half_length)); m(m==0) = 1e-12;
    fft_mag_dB_all(:,i) = 20*log10(m);
    subplot(2,2,i); plot(range_axis, fft_mag_dB_all(:,i), 'LineWidth',1.5);
    xlim([0 200]); ylim([0 100]); grid on;
    xlabel('Range (meters)'); ylabel('Amplitude (dB)'); title([window_names{i} ' Window']);
end
subplot(2,2,4); plot(range_axis, fft_mag_dB_all, 'LineWidth',1.5);
xlim([110 130]); ylim([0 100]); grid on; legend(window_names);
xlabel('Range (meters)'); ylabel('Amplitude (dB)'); title('Window trade-off (zoom on target)');
