%% COMPUTE_DEPTH_CORRELATION
% This script computes quantitative comparison between:
%   - Ground truth depth data
%   - Calculated depth data (from FABEMD or Adaptive FABEMD)
%
% Metrics computed:
%   - Pearson correlation coefficient
%   - RMSE (Root Mean Square Error)
%   - Relative Error
%
% Outputs:
%   - Printed report
%   - Saved TXT report
%   - Saved MAT file with results
%
% Author: Your Name
% Date: 2026

clc;
clear;
close all;

fprintf('\n========================================\n');
fprintf('Depth-wise Correlation Analysis\n');
fprintf('========================================\n');

%% -------------------- Select TRUE file --------------------

[true_file,true_path] = uigetfile('*.mat','Select TRUE depth file');

if isequal(true_file,0)
    return;
end

true_data_struct = load(fullfile(true_path,true_file));

true_vars = fieldnames(true_data_struct);

true_data = [];

for i=1:length(true_vars)
    
    val = true_data_struct.(true_vars{i});
    
    if isnumeric(val) && ismatrix(val)
        
        true_data = double(val);
        true_name = true_vars{i};
        break;
        
    end
    
end

if isempty(true_data)
    
    error('No valid matrix found in TRUE file');
    
end

fprintf('\nTRUE file loaded: %s\n', true_file);

%% -------------------- Select CALCULATED file --------------------

[calc_file,calc_path] = uigetfile('*.mat','Select CALCULATED depth file');

if isequal(calc_file,0)
    return;
end

calc_data_struct = load(fullfile(calc_path,calc_file));

calc_vars = fieldnames(calc_data_struct);

calc_data = [];

for i=1:length(calc_vars)
    
    val = calc_data_struct.(calc_vars{i});
    
    if isnumeric(val) && ismatrix(val)
        
        calc_data = double(val);
        calc_name = calc_vars{i};
        break;
        
    end
    
end

if isempty(calc_data)
    
    error('No valid matrix found in CALCULATED file');
    
end

fprintf('CALCULATED file loaded: %s\n', calc_file);

%% -------------------- Size check --------------------

if ~isequal(size(true_data), size(calc_data))
    
    error('Size mismatch between TRUE and CALCULATED data');
    
end

%% -------------------- Flatten data --------------------

true_vec = true_data(:);
calc_vec = calc_data(:);

%% -------------------- Correlation --------------------

R = corrcoef(true_vec, calc_vec);

correlation = R(1,2);

%% -------------------- RMSE --------------------

rmse = sqrt(mean((true_vec - calc_vec).^2));

%% -------------------- Relative Error --------------------

relative_error = norm(true_vec - calc_vec) / norm(true_vec);

%% -------------------- Print results --------------------

fprintf('\nResults:\n');

fprintf('Correlation: %.6f\n', correlation);

fprintf('RMSE: %.6f\n', rmse);

fprintf('Relative Error: %.6f\n', relative_error);

%% -------------------- Save report --------------------

report_folder = calc_path;

report_file = fullfile(report_folder,'Correlation_Report.txt');

fid = fopen(report_file,'a');

fprintf(fid,'\n========================================\n');

fprintf(fid,'Date: %s\n', datestr(now));

fprintf(fid,'TRUE file: %s\n', true_file);

fprintf(fid,'CALCULATED file: %s\n', calc_file);

fprintf(fid,'Correlation: %.6f\n', correlation);

fprintf(fid,'RMSE: %.6f\n', rmse);

fprintf(fid,'Relative Error: %.6f\n', relative_error);

fprintf(fid,'========================================\n');

fclose(fid);

%% -------------------- Save MAT results --------------------

results.correlation = correlation;
results.rmse = rmse;
results.relative_error = relative_error;
results.true_file = true_file;
results.calc_file = calc_file;

save(fullfile(report_folder,'Correlation_Result.mat'),'results');

%% -------------------- Plot comparison --------------------

figure;

subplot(1,2,1)
imagesc(true_data)
axis image off
colormap(jet)
colorbar
title('TRUE Depth')

subplot(1,2,2)
imagesc(calc_data)
axis image off
colormap(jet)
colorbar
title('Calculated Depth')

fprintf('\nReport saved to:\n%s\n', report_file);

fprintf('\nAnalysis completed successfully.\n');