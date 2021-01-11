% Load ncp_sweep_data object
sweep_cap = ncp_sweep_data;

% Parameters:
sweep_cap.startFreqMHzReq = 118;          % Start Frequency (MHz)
sweep_cap.stopFreqMHzReq  = 137;          % Stop Frequency (MHz)
sweep_cap.bandwidthHz = 2500;           % Bandwidth (Hz)
sweep_cap.node_ip = '187.44.203.199';    % IP Address
sweep_cap.node_port = 9999;              % Port

% Pre-allocation:
[~, startFreqMHz, stopFreqMHz, numSamples, ~] = step(sweep_cap);

freqs = linspace(startFreqMHz, stopFreqMHz, numSamples);
sweepData  = zeros(numSamples, 1, 'single');
sortedData = zeros(numSamples, 1, 'single');

n = 1;
OccCount = 100;

OccData = zeros(numSamples, 2);
occTot  = zeros(numSamples, 1);
thresh  = zeros(1, 1, 'single');

% StepWidth
StepWidth = round(1e+3*(stopFreqMHz - startFreqMHz)/(numSamples-1), 1); % in kHz

% Plot properties
figure('Position', [1, 1, 1000, 562], 'Color', [1,1,1]);

axes2 = subplot(2,1,2);
axes1 = subplot(2,1,1);

% axes1.Position = [0.075 0.1 0.875 0.775];
set(axes2,  'FontName', 'Calibri', 'FontSize', 9, ...
            'XGrid',    'on', 'XMinorGrid',  'on', ...
            'YGrid',    'on', 'YMinorGrid',  'on', ...
            'Box',      'on',                      ...
            'XLim',  [freqs(1), freqs(end)], ...
            'XTick', [freqs(1), freqs(end)], ...
            'XTickLabel', [freqs(1), freqs(end)], ... 
            'YLim', [-5, 105], ...
            'YTick', round(linspace(0,100,5)), ...
            'YTickLabel', round(linspace(0,100,5)));

set(axes1, 'TitleHorizontalAlignment', 'left',   ...
            'FontName', 'Calibri', 'FontSize', 9, ...
            'XGrid',    'on', 'XMinorGrid',  'on', ...
            'YGrid',    'on', 'YMinorGrid',  'on', ...
            'Box',      'on',                      ...
            'XLim',  [freqs(1), freqs(end)], ...
            'XTick', [freqs(1), freqs(end)], ...
            'XTickLabel', [freqs(1), freqs(end)], ... 
            'YLim', [-120, -20], ...
            'YTick', round(linspace(-120,-20,5)), ...
            'YTickLabel', round(linspace(-120,-20,5)));

str1  = ['RFeye Site view. ' sweep_cap.node_ip ' (NCP).'];  
str2 = {['SweepPoints: '  num2str(numSamples) '. '     ...
         'StepWidth: '     num2str(StepWidth) ' kHz.']};
     
[strTitle, strSubtitle] = title(str1, str2);
strTitle.FontSize     = 11;
strSubtitle.FontAngle = 'italic';

% xlabel('Frequency (MHz)', 'FontName', 'Calibri', 'FontSize', 10, 'FontWeight', 'bold')
% ylabel('Level (dBm)', 'FontName', 'Calibri', 'FontSize', 10, 'FontWeight', 'bold')
hold on

% Spectral data
while true
    sweepData(:,1) = step(sweep_cap);
    
    sortedData(:)  = sort(sweepData);
    thresh = mean(sortedData(1:ceil(0.2*length(sortedData)))) + 20;
    occTot(:) = double(sweepData > thresh);
    
    if n ~= 1
        OccData(:,2) = occTot;
        OccData(:,1) = ((OccCount-1)*OccData(:,1) + OccData(:,2))/OccCount;
    else
        OccData(:,1) = occTot;
    end
    n=n+1;
    
    cla(axes1)
    line(axes1, freqs, sweepData);
    hold on
    line(axes1, [freqs(1) freqs(end)], [thresh thresh], 'Color', 'red');
    
    plot(axes2, freqs, 100*OccData(:,1));
    drawnow nocallbacks
    linkaxes([axes1, axes2], 'x')

end

% while true
%     sweepData(:,1) = step(sweep_cap);
%     
%     sortedData(:)  = sort(sweepData);
%     thresh = mean(sortedData(1:ceil(0.2*length(sortedData)))) + 20;
%     
%     OccData(:,n) = sweepData > thresh;
%     
%     cla(axes1)
%     line(axes1, freqs, sweepData);
%     hold on
%     line(axes1, [freqs(1) freqs(end)], [thresh thresh], 'Color', 'red');
%     
%     n = n + 1;
%     if n == 100
%         occTot(:) = 100 * sum(OccData,2)/n;
% 
%         plot(axes2, freqs, occTot);
%         n = 1;
%     end
%     drawnow limitrate
% 
% end
% Disconnect from node and unload library
reset(sweep_cap);