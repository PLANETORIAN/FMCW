% plot_logged_signals.m
% Plots the signals that the Simulink model logs (logsout) so they can be
% looked at properly instead of through the scope windows.
% Needs: radar_init already run, and "out" from sim('Model') in the workspace.
% Set  I  to the folder the PNGs should be written to before running.

L = out.logsout;
get = @(n) deal(L.getElement(n).Values.Time(:), squeeze(L.getElement(n).Values.Data));
us = 1e-6;

% ---- 1. instantaneous frequency of the transmit chirp (sawtooth) ----
[t, ph] = get('Tx_phase');
ph = ph(:);
f_inst = diff(ph) ./ diff(t) / (2*pi);          % Hz
k = 1:200:numel(f_inst);                        % decimate for plotting
fig = figure('Position',[100 100 1000 420]);
plot(t(k)/us, f_inst(k)/1e6, 'LineWidth', 1.2); grid on;
xlabel('Time (\mus)'); ylabel('Instantaneous frequency (MHz)');
title(sprintf('Tx chirp: %d sawtooth sweeps of B = %.0f MHz in Tc = %.0f \\mus', N_chirps, B/1e6, Tc/us));
exportgraphics(fig, fullfile(I,'23_tx_chirp_frequency.png'), 'Resolution', 200);

% ---- 2. Tx, Rx and IF signal zoomed at the end of chirp 1 ----
[tt, tx] = get('Tx_signal_logged');
[~,  rx] = get('Rx_signal_logged');
[ti, iff] = get('IF_signal_logged');
w = tt > 9.95*us & tt < 10.00*us;
fig = figure('Position',[100 100 1000 700]);
subplot(3,1,1); plot(tt(w)/us, tx(w)); grid on; ylabel('Tx'); title('Last 50 ns of chirp 1 (the fastest part of the sweep)');
subplot(3,1,2); plot(tt(w)/us, rx(w)); grid on; ylabel('Rx');
subplot(3,1,3); plot(ti(w)/us, iff(w)); grid on; ylabel('IF = Tx \times Rx'); xlabel('Time (\mus)');
exportgraphics(fig, fullfile(I,'24_tx_rx_if_zoom.png'), 'Resolution', 200);

% ---- 3. IF signal and TVG over the full frame ----
[ttv, tvg] = get('TVG_output_logged');
fig = figure('Position',[100 100 1000 600]);
subplot(2,1,1); plot(ti(1:50:end)/us, iff(1:50:end)); grid on; ylabel('IF signal'); title('Before and after the time-varying gain (all 8 chirps)');
subplot(2,1,2); plot(ttv(1:50:end)/us, tvg(1:50:end)); grid on; ylabel('After TVG'); xlabel('Time (\mus)');
exportgraphics(fig, fullfile(I,'25_if_vs_tvg.png'), 'Resolution', 200);

% ---- 4. ADC: input vs output, a few samples of chirp 5 ----
% ADC_input_logged is on the fast model step (T_step), ADC_output_logged is on
% the ADC clock (Ts), so they have different lengths. Resample the input at
% the ADC output times before comparing them.
[ta,  adci_fast] = get('ADC_input_logged');
[tao, adco]      = get('ADC_output_logged');
adci = interp1(ta, adci_fast, tao, 'previous');
n0 = 4*N_samples + 300;  n = n0:n0+39;          % 40 ADC samples
fig = figure('Position',[100 100 1000 420]);
stairs(1:numel(n), adci(n), 'LineWidth', 1.2); hold on;
stairs(1:numel(n), adco(n), 'LineWidth', 1.2);
legend('ADC input (after gain)', 'ADC output (quantised)', 'Location','best'); grid on;
xlabel('ADC sample'); ylabel('Volts');
title(sprintf('Quantiser at N = %d bits, \\Delta = %.2e V', N_bits, Delta_q));
exportgraphics(fig, fullfile(I,'26_adc_quantisation_zoom.png'), 'Resolution', 200);

% ---- 5. Quantisation error histogram ----
e = adco(:) - adci(:);
e = e(~isnan(e));                               % interp1 gives NaN where it cannot look back
fig = figure('Position',[100 100 800 420]);
histogram(e, 60); grid on; xlabel('quantisation error (V)'); ylabel('count');
title(sprintf('ADC error, std = %.3e V  (theory \\Delta/sqrt(12) = %.3e V)', std(e), Delta_q/sqrt(12)));
exportgraphics(fig, fullfile(I,'27_adc_error_histogram.png'), 'Resolution', 200);
fprintf('quant error std = %.4e, theory = %.4e, N_bits=%d\n', std(e), Delta_q/sqrt(12), N_bits);

% ---- 6. One-chirp spectrum in dB with range axis ----
x = out.rx_digital(4*N_samples+1:5*N_samples); x = x(:);
w2 = blackmanharris(N_samples);
X = fft(x .* w2); half = floor(N_samples/2);
P = 20*log10(abs(X(1:half)) + eps);
rax = (0:half-1)' * (fs/N_samples) * c / (2*S);
fig = figure('Position',[100 100 1000 420]);
plot(rax, P, 'LineWidth', 1.2); grid on; xlim([0 375]);
xlabel('Range (m)'); ylabel('Magnitude (dB)');
[pk, ix] = max(P); hold on; plot(rax(ix), pk, 'ro');
title(sprintf('Range profile of chirp 5, Blackman-Harris window: peak at %.1f m', rax(ix)));
exportgraphics(fig, fullfile(I,'28_range_profile_chirp5_dB.png'), 'Resolution', 200);
fprintf('chirp5 peak: %.2f m, %.2f dB\n', rax(ix), pk);
