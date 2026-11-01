% extra_plots.m
% (1) Tx chirp frequency with the phase-reset spikes masked out, so the
%     0 -> 150 MHz ramps are visible.
% (2) The ADC at 4 bits, where the staircase is big enough to see.
% Run radar_init and sim('Model') first (needs "out"), and set I to the images folder.
% NOTE: careful with variable names here, a variable called c or S would
% overwrite the speed of light / sweep slope that the model reads.

% ---- (1) chirp frequency ----
tsig = out.logsout.getElement('Tx_phase').Values;
tt1  = tsig.Time(:);  ph1 = squeeze(tsig.Data); ph1 = ph1(:);
fi   = diff(ph1) ./ diff(tt1) / (2*pi);
fi(fi < -1e6) = NaN;                       % the reset at the end of every chirp
kk = 1:100:numel(fi);
fg = figure('Position',[100 100 1000 420]);
plot(tt1(kk)/1e-6, fi(kk)/1e6, 'LineWidth', 1.5); grid on;
xlabel('Time (\mus)'); ylabel('Instantaneous frequency (MHz)');
title(sprintf('Tx chirp: %d sawtooth sweeps, 0 to %.0f MHz in %.0f \\mus', N_chirps, B/1e6, Tc/1e-6));
exportgraphics(fg, fullfile(I,'23_tx_chirp_frequency.png'), 'Resolution', 200);
fprintf('max f_inst = %.2f MHz\n', max(fi)/1e6);
close(fg);

% ---- (2) 4-bit ADC staircase ----
N_bits_keep = N_bits;
N_bits = 4;  Delta_q = V_FSR / 2^N_bits;
o4 = sim('Model');
ti4 = o4.logsout.getElement('ADC_input_logged').Values;
to4 = o4.logsout.getElement('ADC_output_logged').Values;
tin = ti4.Time(:);  din = squeeze(ti4.Data); din = din(:);
tou = to4.Time(:);  dou = squeeze(to4.Data); dou = dou(:);
din_s = interp1(tin, din, tou, 'previous');
n0 = 4*N_samples + 300;  nn = n0:n0+59;
fg = figure('Position',[100 100 1000 420]);
stairs(1:numel(nn), din_s(nn), 'LineWidth', 1.2); hold on;
stairs(1:numel(nn), dou(nn),   'LineWidth', 1.5);
legend('ADC input (after gain)', 'ADC output (quantised)', 'Location', 'best'); grid on;
xlabel('ADC sample'); ylabel('Volts');
title(sprintf('Same signal at N = %d bits: \\Delta = %.3f V', N_bits, Delta_q));
exportgraphics(fg, fullfile(I,'29_adc_4bit_staircase.png'), 'Resolution', 200);
close(fg);
ee4 = dou - din_s;  ee4 = ee4(~isnan(ee4));
fprintf('4-bit: err std = %.4e, theory = %.4e\n', std(ee4), Delta_q/sqrt(12));

% put things back
N_bits = N_bits_keep;  Delta_q = V_FSR / 2^N_bits;
