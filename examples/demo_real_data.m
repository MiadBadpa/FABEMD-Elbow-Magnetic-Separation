%% DEMO_REAL_DATA - Example of using FABEMD-Elbow on real magnetic data
% This script demonstrates the workflow on KuhZireh field data

clc; clear; close all;

%% Load real data
load('data/real/dt_matrix.mat');  % variable 'dt' or 'image'

% Ensure variable name is 'image'
if exist('dt', 'var')
    image = dt;
    clear dt;
end

fprintf('Data size: %d x %d\n', size(image,1), size(image,2));

%% Run adaptive FABEMD-Elbow
fprintf('\n=== Running Adaptive FABEMD ===\n');
[imfs, info] = adaptive_fabemd(image, 14, 1);

%% Perform depth analysis (using regularized version based on diagnostics)
fprintf('\n=== Performing Depth Analysis ===\n');
if strcmp(info.mode, 'original_regularized')
    [depth_results, elbow] = fabemd_depth_analysis_regularized(imfs, 'real_output');
else
    [depth_results, elbow] = fabemd_depth_analysis(imfs, 'real_output');
end

%% Visualize results
figure('Position', [100, 100, 1200, 400]);

subplot(1,3,1);
imagesc(image); axis image off; colormap(jet); colorbar;
title('Original Residual TMI');

subplot(1,3,2);
imagesc(depth_results{1}); axis image off; colormap(jet); colorbar;
title(sprintf('Shallow Scale (IMFs 1-%d)', elbow));

subplot(1,3,3);
imagesc(depth_results{2}); axis image off; colormap(jet); colorbar;
title(sprintf('Deep Scale (IMFs %d-%d)', elbow+1, length(imfs)-1));

sgtitle('KuhZireh Magnetic Data - FABEMD-Elbow Results');

%% Display diagnostics
fprintf('\n=== Diagnostic Report ===\n');
fprintf('Selected method: %s\n', info.mode);
fprintf('Elbow IMF: %d\n', elbow);
fprintf('Gradient ratio: %.4f\n', info.gradient_ratio);
fprintf('Extrema density: %.4f\n', info.extrema_density);
fprintf('Noise index: %.4f\n', info.noise_index);

fprintf('\nDone!\n');