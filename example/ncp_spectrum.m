% Include library
addpath('../');

% Number of captures
numCapture = 1000;

% Load ncp_sweep_data object
sweep_cap = ncp_sweep_data;

% Parameters
sweep_cap.startFreqMHzReq = 770;         % Start Frequency (MHz)
sweep_cap.stopFreqMHzReq = 810;          % Stop Frequency (MHz)
sweep_cap.bandwidthHz = 10000;           % Bandwidth (Hz)
sweep_cap.node_ip = '187.44.203.199';    % IP Address
sweep_cap.node_port = 9999;              % Port

[~, ~, ~, ~, freqs] = step(sweep_cap);

figure
axes1 = subplot(1,1,1);

set(axes1,'Color','k')
title(['Spectrum ' num2str(sweep_cap.startFreqMHzReq) '-' num2str(sweep_cap.stopFreqMHzReq) ' MHz '...
    '(' num2str(sweep_cap.bandwidthHz) ' Hz resolution BW)']);
xlim([freqs(1) freqs(end)])
xlabel('Frequency (MHz)');
ylabel('Power (dBm)');

hold on

for ii= 1:numCapture
    sweepData = step(sweep_cap);
    
    % Plot spectrum
    cla
    line(freqs,sweepData);
    drawnow nocallbacks
    
end

% Disconnect from node and unload library
reset(sweep_cap);