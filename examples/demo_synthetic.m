%% DEMO_SYNTHETIC - Example of using FABEMD-Elbow on synthetic data
% This script demonstrates the complete workflow on synthetic Model 1

clc; clear; close all;

%% Load synthetic data
load('data/synthetic/dt_001.mat');  % variable 'dt' or 'image'

% Ensure variable name is 'image'
if exist('dt', 'var')
    image = dt;
    clear dt;
end

fprintf('Data size: %d x %d\n', size(image,1), size(image,2));

%% Run adaptive FABEMD-Elbow
fprintf('\n=== Running Adaptive FABEMD ===\n');
[imfs, info] = adaptive_fabemd(image, 20, 1);

%% Perform depth analysis
fprintf('\n=== Performing Depth Analysis ===\n');
[depth_results, elbow] = fabemd_depth_analysis(imfs, 'demo_output');

%% Visualize results
figure('Position', [100, 100, 1200, 400]);

subplot(1,3,1);
imagesc(image); axis image off; colormap(jet); colorbar;
title('Original Data');

subplot(1,3,2);
imagesc(depth_results{1}); axis image off; colormap(jet); colorbar;
title(sprintf('Depth 1 (Short-scale, IMFs 1-%d)', elbow));

subplot(1,3,3);
imagesc(depth_results{2}); axis image off; colormap(jet); colorbar;
title(sprintf('Depth 2 (Long-scale, IMFs %d-%d)', elbow+1, length(imfs)-1));

sgtitle('FABEMD-Elbow Decomposition Results');

%% Display diagnostics
fprintf('\n=== Diagnostic Report ===\n');
fprintf('Selected method: %s\n', info.mode);
fprintf('Elbow IMF: %d\n', elbow);
fprintf('Gradient ratio: %.4f\n', info.gradient_ratio);
fprintf('Extrema density: %.4f\n', info.extrema_density);
fprintf('Noise index: %.4f\n', info.noise_index);

fprintf('\nDone!\n');