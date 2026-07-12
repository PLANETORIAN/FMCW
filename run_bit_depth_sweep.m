% NOTE: do NOT run "clear" before this script — it depends on G_ADC_frontend
% already being calibrated and sitting in the workspace from calibrate_adc_gain.m

radar_init;   % re-runs setup, but G_ADC_frontend now already exists, so the
              % placeholder branch is skipped and your calibrated value is kept

N_bits_list = [4, 6, 8, 10, 12, 14, 16];
SNR_measured = zeros(size(N_bits_list));

win_fast = blackmanharris(N_samples);

for i = 1:length(N_bits_list)
    N_bits = N_bits_list(i);
    Delta_q = V_FSR / (2^N_bits);

    simOut = sim('Model');
    adc_element = simOut.logsout.getElement('ADC_output_logged');

    % Extract chirp 5 to bypass filter startup transients
    chirp_idx = 5;
    start_idx = (chirp_idx - 1) * N_samples + 1;
    end_idx = chirp_idx * N_samples;
    chirp_data = adc_element.Values.Data(start_idx:end_idx);
    chirp_data = chirp_data(:);

    chirp_windowed = chirp_data .* win_fast;
    X = fft(chirp_windowed);
    X_mag = abs(X(1:floor(N_samples/2)));
    P = X_mag.^2;

    % Blank DC/near-DC bins
    P(1:5) = 0;

    [peak_power, peak_idx] = max(P);

    % Wide guard band, confirmed necessary for Blackman-Harris main lobe
    guard = 20;
    noise_bins = P;
    noise_bins(max(1,peak_idx-guard):min(length(P),peak_idx+guard)) = NaN;
    noise_floor = mean(noise_bins, 'omitnan');

    SNR_measured(i) = 10*log10(peak_power / noise_floor);

    fprintf('N_bits=%2d -> SNR=%.4f dB\n', N_bits, SNR_measured(i));
end

p = polyfit(N_bits_list, SNR_measured, 1);
slope = p(1);

figure;
plot(N_bits_list, SNR_measured, 'o-', 'LineWidth', 1.5); hold on;
plot(N_bits_list, polyval(p, N_bits_list), '--');
xlabel('ADC bit depth (N)');
ylabel('Measured SNR (dB)');
title(sprintf('SNR vs bit depth — measured slope = %.3f dB/bit (theory: 6.02)', slope));
legend('Measured', 'Linear fit', 'Location', 'northwest');
grid on;