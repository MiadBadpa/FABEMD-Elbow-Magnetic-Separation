function [depth_results, elbow] = fabemd_depth_analysis_regularized(imfs, base_name)
% FABEMD_DEPTH_ANALYSIS_REGULARIZED
%
% This is your ORIGINAL regularized depth analysis
% with added elbow output for reporting.
%
% NO algorithm changes have been made.
%
% Author: Miad Badpa
% Date: 2026

N = length(imfs)-1;

if N < 2
    error('Not enough IMFs found.');
end

%% -------- Power spectrum --------

ps = zeros(N,1);

for i = 1:N
    
    ps(i) = mean(imfs{i}.^2,'all');
    
end

%% -------- ORIGINAL elbow detection (unchanged) --------

logps = log(ps + eps);

d1 = diff(logps);

d2 = diff(d1);

[~, elbow] = max(abs(d2));

elbow = elbow + 1;

if elbow < 2
    elbow = 2;
end

fprintf('Improved elbow detected at IMF %d\n', elbow);

%% -------- Plot and save spectrum --------

hfig = figure;

plot(1:N, ps,'-o','LineWidth',2);

hold on;

xline(elbow,'r--','LineWidth',2);

xlabel('IMF Index');

ylabel('Power');

title('IMF Power Spectrum');

grid on;

saveas(hfig,[base_name '_PowerSpectrum.jpg']);

saveas(hfig,[base_name '_PowerSpectrum.fig']);

save([base_name '_PowerSpectrum.mat'],'ps','elbow');

close(hfig);

%% -------- Build depth layers --------

depth_bounds = [0 elbow N];

num_depths = length(depth_bounds)-1;

depth_results = cell(num_depths,1);

for d = 1:num_depths
    
    low_imf  = depth_bounds(d)+1;
    
    high_imf = depth_bounds(d+1);
    
    combined = zeros(size(imfs{1}));
    
    for k = low_imf:high_imf
        
        combined = combined + imfs{k};
        
    end
    
    depth_results{d} = combined;
    
    % Save MAT
    save([base_name '_Depth_' num2str(d) '.mat'],'combined');
    
    % Save image
    hf = figure('Visible','off');
    
    imagesc(combined);
    
    axis image off;
    
    colormap(jet);
    
    colorbar;
    
    title(['Depth Layer ' num2str(d)]);
    
    saveas(hf,[base_name '_Depth_' num2str(d) '.jpg']);
    
    close(hf);
    
end

end