clc;
clear;

%% Select dt matrix file manually
[file_dt, path_dt] = uigetfile('*.mat', 'Select dt matrix file');
if isequal(file_dt,0)
    error('No dt file selected.');
end

dt_struct = load(fullfile(path_dt, file_dt));
dt_fields = fieldnames(dt_struct);
dt = dt_struct.(dt_fields{1});   % Automatically read first variable

%% Select coordinate file manually
[file_coord, path_coord] = uigetfile('*.mat', 'Select coordinate file');
if isequal(file_coord,0)
    error('No coordinate file selected.');
end

coord_struct = load(fullfile(path_coord, file_coord));
coord_fields = fieldnames(coord_struct);

% Detect X and Y automatically
X_grid = coord_struct.(coord_fields{1});
Y_grid = coord_struct.(coord_fields{2});

%% Create output folder based on dt filename
[~, name_dt, ~] = fileparts(file_dt);
output_folder = fullfile(path_dt, name_dt);

if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

%% Plot grid
figure;
pcolor(X_grid, Y_grid, dt);
shading interp;
colorbar;
xlabel('X (m)');
ylabel('Y (m)');
title('Magnetic Data Grid');
axis equal tight;

%% Convert grid matrix to XYZ
X = X_grid(:);
Y = Y_grid(:);
Z = dt(:);

valid = ~isnan(Z);
X = X(valid);
Y = Y(valid);
Z = Z(valid);

T_export = table(X, Y, Z, 'VariableNames', {'X','Y','MAG'});

%% Save Excel inside created folder
output_file = fullfile(output_folder, [name_dt '_XYZ.xlsx']);
writetable(T_export, output_file);

disp(['XYZ file saved in folder: ', output_folder]);