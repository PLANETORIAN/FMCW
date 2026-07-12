% radar_init.m - FMCW Radar Physical Parameters
c = 3e8;                % Speed of light (m/s)
f0 = 0;                 % Baseband Carrier frequency
B = 150e6;              % Bandwidth (150 MHz)
Tc = 10e-6;             % Chirp duration (10 microseconds)
S = B / Tc;             % Sweep slope (Hz/s)
T_step = 1 / (10*B);
R_max = 150;            % Maximum design range in meters

% Target Parameters (N = 1 target currently active)
R_target = [120];       % Array of distances (m)
v_target = [20];        % Array of velocities (m/s)
RCS = [10];             % Array of RCS values (m^2)
N_targets = length(R_target);   % Automatically scales

% Target Physics
fc = 77e9;              % Actual Carrier Frequency for Physics (77 GHz)
lambda = c / fc;
G_tx = 100;             % linear gain
G_rx = 100;             % linear gain

% --- Calculated Path Variables ---
t_d = (2 * R_target) / c;
Prx_Ptx_ratio = (G_tx * G_rx * lambda^2 .* RCS) ./ ((4*pi)^3 .* R_target.^4);
K_target = sqrt(Prx_Ptx_ratio);   % sqrt applies element-wise

% --- Dynamic Filter Parameters ---
t_d_max = (2 * R_max) / c;
f_beat_max = S * t_d_max;
f_cutoff = f_beat_max * 1.2;      % 20% safety margin
w_c = 2 * pi * f_cutoff;

% --- Dynamic Time-Varying Gain (TVG) Parameters ---
Max_Gain = 1e6;
C_TVG = Max_Gain / (t_d_max^2);

% --- Digital constraints (Your ADC) ---
Oversampling_Factor = 2;
Ideal_fs = (2 * f_cutoff) * Oversampling_Factor;
Ideal_Ts = 1 / Ideal_fs;

if ~exist('G_ADC_frontend', 'var')
    G_ADC_frontend = 1;
end

% --- Hardware Clock Divider Fix ---
Tc_steps = round(Tc / T_step);
Ideal_Clock_Divider = Ideal_Ts / T_step;

divisors = divisors_of(Tc_steps);
valid_divisors = divisors(divisors <= Ideal_Clock_Divider);
Clock_Divider = max(valid_divisors);

Ts = Clock_Divider * T_step;
fs = 1 / Ts;
N_samples = Tc_steps / Clock_Divider;

N_chirps = 8;

% --- Discretize the anti-alias filter (manual Tustin/bilinear transform,
%     no Control System Toolbox required) ---
% Continuous filter: H(s) = wc / (s + wc)
% Tustin substitution: s = (2/Ts) * (1-z^-1)/(1+z^-1)
a = w_c * Ts;              % dimensionless: wc * sample time
num_d = [a/(2+a), a/(2+a)];
den_d = [1, (a-2)/(2+a)];

% --- Dynamic Digital Limits ---
T_frame = N_chirps * Tc;
R_max_dynamic = R_max + (max(abs(v_target)) * T_frame);
D_max_samples = ceil((2 * R_max_dynamic / c) / T_step);

% --- ADC quantizer parameters ---
V_FSR = 2;
N_bits = 12;
Delta_q = V_FSR / (2^N_bits);

% --- Local functions must go at the very end of a script file ---
function d = divisors_of(n)
    d = find(mod(n, 1:n) == 0);
end