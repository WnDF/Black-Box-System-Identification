clearvars; clc; close all;

here = fileparts(mfilename('fullpath'));
addpath(here);
addpath(fullfile(here, 'tools'));

% Identifier seed for random data generation
SYSTEM_ID = 6427340;
rng(SYSTEM_ID);

%% Part 1: Experiment Design and Data Pre-Processing

%% Step response experiment: determine a suitable sampling frequency
fs_test = 100;
T_test  = 20;
N_test  = T_test * fs_test;

u_test = ones(N_test,1);
t_test = (0:N_test-1)'/fs_test;

y_test = exciteSystem(SYSTEM_ID, u_test, fs_test);
y_test_clean = remove_spikes_mad(y_test, t_test);

figure('Position', [100 100 600 250]);
plot(t_test, y_test_clean, 'LineWidth', 1);
title('Step Response Output (After Spike Removal)');
xlabel('Time (s)'); ylabel('y(t)'); grid on;
save_figure('step_response_sampling_freq.png');

% From the settling time (~3-4 s) and the 10x-bandwidth rule of thumb,
% fs >= 2.2 Hz is required; 10 Hz was chosen as a safe, practical margin.
fs = 10;
Ts = 1/fs;

%% Persistently exciting staircase input for training
Texp   = 100;
xMax   = 10;    % max magnitude
nSteps = 50;    % number of stairs

[u_train, t_train] = excitation_input(Texp, fs, xMax, nSteps);

figure('Position', [100 100 800 250]);
plot(t_train, u_train, 'LineWidth', 1.2); grid on;
xlabel('Time (s)'); ylabel('u(t)');
title('Persistently Exciting Staircase Input (Random Levels)');
save_figure('staircase_input_signal.png');

%% Persistency of excitation check
sMax = 180;
rankH = persistency_of_excitation(u_train, sMax);

figure('Position', [100 100 800 250]);
plot(1:sMax, rankH, 'o-', 'LineWidth', 1.5);
grid on; xlabel('Order s'); ylabel('rank(U_s)');
title('Persistency of Excitation Test (Hankel Rank)');
save_figure('persistency_of_excitation.png');

%% Generate training data and remove spikes
y_train_raw = exciteSystem(SYSTEM_ID, u_train, fs);
y_train_clean = remove_spikes_mad(y_train_raw, t_train);

figure('Position', [100 100 800 500]);
subplot(2,1,1)
plot(t_train, y_train_raw, 'LineWidth', 1.1); grid on;
xlabel('Time (s)'); ylabel('y(t)');
title('Noisy Output Signal Corresponding to Staircase Input');
subplot(2,1,2)
plot(t_train, y_train_clean, 'LineWidth', 0.9); grid on;
xlabel('Time (s)'); ylabel('y(t)');
title('Spike Removed Output Signal for Training');
save_figure('output_before_after_spike_removal.png');

%% Time delay estimation and compensation
[nk, Td, r, lags] = estimate_time_delay(u_train, y_train_clean, fs);
[u_train, y_train_shifted, t_train] = apply_time_shift(u_train, y_train_clean, nk, fs);

figure('Position', [100 100 800 750]);
subplot(3,1,1)
plot(lags/fs, r, 'LineWidth', 1.1); grid on;
xlabel('Lag (s)'); ylabel('Normalized cross-correlation');
title('Cross-correlation between Cleaned Output Signal and Staircase Input Signal');
xline(Td, '--', sprintf('Td = %.3f s', Td));
subplot(3,1,2)
plot(t_train, u_train, 'LineWidth', 1.0); grid on;
xlabel('Time (s)'); ylabel('u(t)');
title('Input Signal for Training After Delay Compensation');
subplot(3,1,3)
plot(t_train, y_train_shifted, 'LineWidth', 1.0); grid on;
xlabel('Time (s)'); ylabel('y(t)');
title('Output Signal for Training After Delay Compensation');
save_figure('delay_estimation_crosscorr_and_shift.png');

%% DC offset removal
[y_train, y_train_dc] = remove_dc_offset(y_train_shifted);

figure('Position', [100 100 800 500]);
subplot(2,1,1)
plot(t_train, y_train_shifted, 'LineWidth', 1.0); grid on;
xlabel('Time (s)'); ylabel('y(t)');
title('Output Signal Before DC Offset Removal');
subplot(2,1,2)
plot(t_train, y_train, 'LineWidth', 1.0); grid on;
xlabel('Time (s)'); ylabel('y(t)');
title('Output Signal After DC Offset Removal');
save_figure('dc_offset_before_after.png');

%% Linearity check via step responses at two amplitudes
A1 = 1; A2 = 2;
u1_test = A1 * ones(N_test,1);
u2_test = A2 * ones(N_test,1);

y1_test = exciteSystem(SYSTEM_ID, u1_test, fs_test);
y2_test = exciteSystem(SYSTEM_ID, u2_test, fs_test);

y1_test_clean = remove_spikes_mad(y1_test, t_test);
y2_test_clean = remove_spikes_mad(y2_test, t_test);

figure('Position', [100 100 800 250]);
plot(t_test, y1_test_clean, 'b', 'LineWidth',1.2); hold on;
plot(t_test, y2_test_clean, 'r', 'LineWidth',1.2);
plot(t_test, 2*y1_test_clean, ':', 'LineWidth',1.5);
xlabel('Time (s)'); ylabel('y(t)');
title('Linearity check using step responses with different amplitudes');
legend('y_1 (A=1)','y_2 (A=2)','2\cdoty_1','Location','best');
grid on;
save_figure('linearity_check.png');

%% Independent validation dataset
[u_val, t_val] = excitation_input(Texp, fs, xMax, nSteps);

y_val_raw = exciteSystem(SYSTEM_ID, u_val, fs);
y_val_clean = remove_spikes_mad(y_val_raw, t_val);

[u_val, y_val_shift, t_val] = apply_time_shift(u_val, y_val_clean, nk, fs);
y_val = remove_dc_offset(y_val_shift);

figure('Position', [100 100 800 500]);
subplot(2,1,1)
plot(t_val, u_val, 'LineWidth', 1.0); grid on;
xlabel('Time [s]'); ylabel('u');
title('Staircase Input Signal for Validation');
subplot(2,1,2)
plot(t_val, y_val, 'LineWidth', 1.0); grid on;
xlabel('Time [s]'); ylabel('y');
title('Output Signal for Validation');
save_figure('validation_dataset.png');

%% Part 2: Identification

%% Step 1: PO-MOESP subspace identification (deterministic model + order)
%   Pick model n = 3
[A, B, C, D, x0] = pomoesp(u_train, y_train, sMax);

[yhat_train_pomoesp, xhat_train_pomoesp] = simulate_pomoesp(A, B, C, D, x0, u_train);
vaf_train_pomoesp  = VAF(y_train, yhat_train_pomoesp);
rmse_train_pomoesp = RMSE(y_train, yhat_train_pomoesp);
plot_results_train(y_train, yhat_train_pomoesp, vaf_train_pomoesp, rmse_train_pomoesp, 'PO-MOESP');

%% Step 2: PEM refinement with an ARMAX model
T = obsv(A, C);
A_c  = T * A / T;
B_c  = T * B;
C_c  = C / T;
x0_c = T * x0;
K0 = zeros(3,1);

theta0 = [A_c(end,:).'; B_c; K0; x0_c];

lambda  = 0.1;
maxiter = 300;

[Ahat, Bhat, Chat, Dhat, Khat, x0hat] = pem(theta0, y_train, u_train, lambda, maxiter);

[yhat_train_pem, xhat_train_pem, ehat_train] = simulate_pem(Ahat, Bhat, Chat, Dhat, Khat, x0hat, u_train, y_train);
vaf_train_pem  = VAF(y_train, yhat_train_pem);
rmse_train_pem = RMSE(y_train, yhat_train_pem);
plot_results_train(y_train, yhat_train_pem, vaf_train_pem, rmse_train_pem, 'PEM');

%% Part 3: Validation

%% Simulate the identified model on unseen validation data
[yhat_val_pem, xhat_val_pem, ehat_val_pem] = simulate_pem(Ahat, Bhat, Chat, Dhat, Khat, x0hat, u_val, y_val);
vaf_val_pem  = VAF(y_val, yhat_val_pem);
rmse_val_pem = RMSE(y_val, yhat_val_pem);
plot_results_val(y_val, yhat_val_pem, vaf_val_pem, rmse_val_pem, 'PEM');
animate_pem_validation(y_val, yhat_val_pem, vaf_val_pem, rmse_val_pem, 'PEM');

%% Residual whiteness: auto-correlation and cross-correlation with input
e = y_val(:) - yhat_val_pem(:);
u = u_val(:);

[r_ee, lags_ee, maxCorr_ee, conf_ee] = residual_autocorrelation(e);
[r_eu, lags_eu, maxCorr_eu, conf_eu] = residual_crosscorrelation(e, u);

fprintf('Validation VAF = %.2f%%, RMSE = %.2f\n', vaf_val_pem, rmse_val_pem);
fprintf('max |R_ee(tau!=0)| = %.3f (conf = %.3f)\n', maxCorr_ee, conf_ee);
fprintf('max |R_eu(tau)|    = %.3f (conf = %.3f)\n', maxCorr_eu, conf_eu);
