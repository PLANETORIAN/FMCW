% --- Pass 1: run once with G_ADC_frontend = 1 to measure the true TVG output peak ---
clear
radar_init;              % G_ADC_frontend defaults to 1 here, since it doesn't exist yet
out = sim('Model');       % capture into "out" explicitly

% --- Pass 2: calibrate from that measurement ---
TVG_element = out.logsout.getElement('TVG_output_logged');
TVG_data = TVG_element.Values.Data;
Measured_ADC_input_peak = max(abs(TVG_data));

Headroom_Fraction = 0.8;
G_ADC_frontend = (Headroom_Fraction * V_FSR) / Measured_ADC_input_peak;

fprintf('Measured TVG peak (unity gain): %.4f\n', Measured_ADC_input_peak);
fprintf('Calibrated G_ADC_frontend: %.6f\n', G_ADC_frontend);