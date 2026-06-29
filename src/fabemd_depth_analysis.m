%% FILE: fabemd_depth_analysis.m
function [depth_results, elbow] = fabemd_depth_analysis(imfs, base_name)

N = length(imfs)-1;
if N < 1
    error('No IMFs found.');
end

ps = zeros(N,1);

for i = 1:N
    ps(i) = mean(imfs{i}.^2,'all');
end

% --------- Automatic Elbow Detection ----------
elbow = detect_elbow(ps);
elbows = elbow;

fprintf('Automatic elbow detected at IMF %d\n', elbow);

% --------- Plot Power Spectrum ----------
hfig = figure;
plot(1:N, ps,'-o','LineWidth',2); hold on;
xline(elbow,'r--','LineWidth',2);
xlabel('IMF Index'); ylabel('Power');
title('IMF Power Spectrum (Automatic Elbow)');
grid on;

saveas(hfig,[base_name '_PowerSpectrum.jpg']);
saveas(hfig,[base_name '_PowerSpectrum.fig']);

Tps = table((1:N)', ps, 'VariableNames',{'IMF_Index','Power'});
writetable(Tps,[base_name '_PowerSpectrum.csv']);
save([base_name '_PowerSpectrum.mat'],'ps','elbow');

% --------- Build Depth Groups ----------
depth_bounds = [0 elbows N];
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

    hf = figure('Visible','off');
    imagesc(combined); axis image off;
    colormap(jet); colorbar;
    title(['Depth Layer ' num2str(d)]);
    saveas(hf,[base_name '_Depth_' num2str(d) '.jpg']);
    close(hf);

    writetable(array2table(combined),...
        [base_name '_Depth_' num2str(d) '.csv']);
    save([base_name '_Depth_' num2str(d) '.mat'],'combined');
end

end


% -------------------------------
% function elbow = detect_elbow(ps)

x = (1:length(ps))';
y = ps(:);

x_norm = (x-min(x))/(max(x)-min(x));
y_norm = (y-min(y))/(max(y)-min(y));

diff_curve = y_norm - x_norm;
[~, elbow] = max(diff_curve);

% Return elbow point for reporting
end

