sweep_cap.startFreqMHzReq = 88;          % Start Frequency (MHz)
sweep_cap.stopFreqMHzReq = 108;          % Stop Frequency (MHz)
sweep_cap.bandwidthHz = 50000;           % Bandwidth (Hz)
sweep_cap.node_ip = '189.89.182.38';     % IP Address
sweep_cap.node_port = 9999;              % Port



[~, startFreqMHz, stopFreqMHz, numSamples, ~] = step(sweep_cap);

freqs = linspace(startFreqMHz, stopFreqMHz, numSamples);
sweepData  = zeros(numSamples, 1, 'single');
sortedData = zeros(numSamples, 1, 'single');

n = 1;
OccData = zeros(numSamples,10);
occTot  = zeros(numSamples, 1);
thresh  = zeros(1, 1, 'single');

CountTraces = 0;

fig = figure;
axes1 = subplot(2, 1, 1);
axes2 = subplot(2, 1, 2);

% Spectral data
for ii = 1:100
    sweepData(:,1) = step(sweep_cap);
    sortedData(:) = sort(sweepData);

    auxthresh = mean(sortedData(1:ceil(0.2*length(sortedData)))) + 12;
    if thresh ~= auxthresh
        thresh(:) = auxthresh;
        CountTraces = CountTraces+1;
    else
        disp(sprintf('Número de amostras da conexão: %d', CountTraces));
        CountTraces = 0;
        reset(sweep_cap);
        continue
    end

    OccData(:,n) = sweepData > thresh;

    % Plot 1: Spectral data and threshold
    plot(axes1, freqs, sweepData);
    hold on
    plot(axes1, [freqs(1) freqs(end)], [thresh thresh], 'Color', 'red');
    hold off

    n = n + 1;
    if n == 10
        occTot(:) = sum(OccData,2)/n;

        % plot of occTot X freqs
        plot(axes2, freqs, occTot);
        n = 1;            
    end
    drawnow nocallbacks

end

% Disconnect from node and unload library
reset(sweep_cap);