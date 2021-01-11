% Include library
addpath('../');

% Load ncp_time_cap object
time_cap = ncp_time_data;

% Parameters
time_cap.numSamples = 10000;        % Number of Samples
time_cap.centerFreqMHz = 900;       % Center Frequncy (MHz)
time_cap.bandwidthHz = 500000;      % Bandwidth (Hz)
time_cap.exactMode = 1;             % Exact Mode
time_cap.streaming = 0;             % Streaming Mode
time_cap.node_ip = '192.0.2.0';     % IP Address
time_cap.node_port = 9999;          % Port

% Capture time data
[i_data,q_data]= step(time_cap);

% Unload library
reset(time_cap);

% Plot I/Q data
plot(1:length(i_data),i_data(1:length(i_data)),1:length(q_data),q_data(1:length(q_data)));
title('I/Q Data');
xlim([0 length(i_data)]);
ylabel('Voltage \muV');
xlabel('Sample');
