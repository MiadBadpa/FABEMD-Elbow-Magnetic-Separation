function noise_index = estimate_noise_index(image)
% ESTIMATE_NOISE_INDEX using gradient energy method
%
% This method is physically meaningful for geophysical data.

image = double(image);

% Compute gradients
[dx, dy] = gradient(image);

% RMS values
rms_signal = rms(image(:));

rms_gradient = sqrt(mean(dx(:).^2 + dy(:).^2));

% Noise index definition
noise_index = rms_gradient / rms_signal;

end