function elbow = detect_elbow(ps)
% DETECT_ELBOW Automatic elbow-point detection using curvature method
%
% Input:
%   ps - power spectrum vector
% Output:
%   elbow - index of elbow point

x = (1:length(ps))';
y = ps(:);

% Normalize
x_norm = (x - min(x)) / (max(x) - min(x));
y_norm = (y - min(y)) / (max(y) - min(y));

% Curvature-based detection
diff_curve = y_norm - x_norm;
[~, elbow] = max(diff_curve);

% Ensure elbow is within valid range
elbow = max(2, min(elbow, length(ps)-1));

end