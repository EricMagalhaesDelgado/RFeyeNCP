% Connect to RFeye Node via NCP to get spectrum.
%
%      Copyright(c) 2017 CRFS Limited.All rights reserved.
%
%      CRFS Limited, Cambridge, England
%
%      CRFS Limited Confidential Information
%      Do not use, distribute, copy or modify without express authorisation
%      by CRFS Limited.Unauthorised use or reproduction will be prosecuted
%      and may result in civil and criminal penalties.
%
%      Filename:     ncp_sweep_data.m
%      Description : System object file to call external NCP library.
%
%      Version : see below
%
%      Author : Boon Khoo, Alex Bartolome
%
%      History :
%      1.00    BK  27 /  2 / 2017 Initial
%      1.01    AB  13 / 12 / 2018 Fix default IP and port
%
classdef ncp_sweep_data < matlab.System & matlab.system.mixin.Propagates ...
        & matlab.system.mixin.CustomIcon
    properties
        % Start Frequency (MHz)
        startFreqMHzReq = 900;
        % Stop Frequency (MHz)
        stopFreqMHzReq = 920;
        % Bandwidth (Hz)
        bandwidthHz = 200000;
        % IP Address
        node_ip = '192.0.2.0';
        % Port
        node_port = 9999;
    end
    
    properties (Nontunable)
    end
    
    properties (Access = private)
        sweepDataPtr
        startFreqMHzPtr
        startFreqmHzPtr
        bandwidthHzPtr
        numSamplesPtr
        initNumSamp
    end
    
    properties (DiscreteState)
    end
    
    methods
        % Constructor
        function obj = ncp_sweep_data(varargin)
            % Support name-value pair arguments when constructing the object.
            setProperties(obj,nargin,varargin{:});
        end
    end
    
    methods (Access = protected)
        %% Common functions
        function setupImpl(obj)
            obj.startFreqMHzReq;
            obj.stopFreqMHzReq;
            obj.bandwidthHz;
            obj.node_ip;
            obj.node_port;
            obj.sweepDataPtr;
            obj.startFreqMHzPtr;
            obj.startFreqmHzPtr;
            obj.bandwidthHzPtr;
            obj.numSamplesPtr;
        end
        
        function [sweepData,startFreqMHz,stopFreqMHz,numSamples,freqs] = stepImpl(obj)
            % Load dll file and create NCP connection
            if not(libisloaded('matlab_ncp_lib'))
                loadlibrary('matlab_ncp_lib.dll', 'matlab_ncp_lib.h');
                obj.numSamplesPtr = libpointer('int32Ptr', 0);
                numSamp = calllib('matlab_ncp_lib', 'StartSweep',...
                    obj.startFreqMHzReq,obj.stopFreqMHzReq,obj.bandwidthHz, ...
                    obj.numSamplesPtr,obj.node_ip,obj.node_port);
                obj.sweepDataPtr = libpointer('doublePtr', zeros(numSamp,1));
                obj.startFreqMHzPtr = libpointer('int32Ptr', obj.startFreqMHzReq);
                obj.startFreqmHzPtr = libpointer('int32Ptr', 0);
                obj.bandwidthHzPtr = libpointer('int32Ptr', obj.bandwidthHz);
            end
            
            % Call the function to get sweep data
            [sweepData, startFreqMHz, startFreqmHz, bwHz, numSamp] = ...
                calllib('matlab_ncp_lib', 'GetSweepData', obj.sweepDataPtr, ...
                obj.startFreqMHzPtr, obj.startFreqmHzPtr, obj.bandwidthHzPtr,obj.numSamplesPtr);
            
            % Pause for 0.2s
%             pause(0.2);
            
            % Output data
            freqs=zeros(1,obj.initNumSamp);
            sweepData = [sweepData' zeros(1,obj.initNumSamp-length(sweepData))];
            startFreqMHz = double(startFreqMHz)+double(startFreqmHz)/1000000000;
            stepFreqMHz = double(bwHz)/2000000;
            stopFreqMHz = startFreqMHz+stepFreqMHz*double(numSamp-1);
            numSamples = double(numSamp);
            freqs(1:numSamples) = startFreqMHz:stepFreqMHz:stopFreqMHz;
        end
        
        function resetImpl(obj)
            % Initialize discrete-state properties.
            if libisloaded('matlab_ncp_lib')
                calllib('matlab_ncp_lib', 'EndSweep');
                unloadlibrary('matlab_ncp_lib');
            end
        end
        
        %% Backup/restore functions
        function s = saveObjectImpl(obj)
            % Save private, protected, or state properties in a
            % structure s. This is necessary to support Simulink
            % features, such as SimState.
        end
        
        function loadObjectImpl(obj,s,wasLocked)
            % Read private, protected, or state properties from
            % the structure s and assign it to the object obj.
        end
        
        %% Simulink functions
        function z = getDiscreteStateImpl(obj)
            % Return structure of states with field names as
            % DiscreteState properties.
            z = struct([]);
        end
        
        function flag = isInputSizeLockedImpl(obj,index)
            % Set true when the input size is allowed to change while the
            % system is running.
            flag = false;
        end
        
        function [size1,size2,size3,size4,size5] = getOutputSizeImpl(obj)
            % Get numSamp. Simulink runs this at the beginning so we have
            % to call the function here first to get numSamp.
            if ~libisloaded('matlab_ncp_lib')
                loadlibrary('matlab_ncp_lib.dll', 'matlab_ncp_lib.h');
            end
            obj.numSamplesPtr = libpointer('int32Ptr', 0);
            obj.initNumSamp = calllib('matlab_ncp_lib', 'StartSweep',...
                obj.startFreqMHzReq,obj.stopFreqMHzReq,obj.bandwidthHz, ...
                obj.numSamplesPtr,obj.node_ip,obj.node_port);
            calllib('matlab_ncp_lib', 'EndSweep');
            unloadlibrary('matlab_ncp_lib');
            numSamp = 0;
            % For some reasons, system object recognised obj.initNumSamp as
            % non integer/postive value though it is an integer and positve
            % value. So, this is a work around. 
            for ii=1:obj.initNumSamp
                numSamp = numSamp + 1;
            end
            
            size1 = [1 numSamp];
            size2 = [1 1];
            size3 = [1 1];
            size4 = [1 1];
            size5 = [1 numSamp];
        end
        
        function icon = getIconImpl(obj)
            % Define a string as the icon for the System block in Simulink.
            icon = mfilename('class');
        end
        
        function num = getNumOutputsImpl(~)
            num = 5;
        end
        
        
        function [c1,c2,c3,c4,c5] = isOutputFixedSizeImpl(~)
            c1 = true;
            c2 = true;
            c3 = true;
            c4 = true;
            c5 = true;
        end
        
        function [dt1,dt2,dt3,dt4,dt5] = getOutputDataTypeImpl(obj)
            dt1 = 'double';
            dt2 = 'double';
            dt3 = 'double';
            dt4 = 'double';
            dt5 = 'double';
        end
        
        function [flag1,flag2,flag3,flag4,flag5] = isOutputComplexImpl(obj)
            flag1 = false;
            flag2 = false;
            flag3 = false;
            flag4 = false;
            flag5 = false;
        end
    end
    
    methods(Static, Access = protected)
        %% Simulink customization functions
        function header = getHeaderImpl(obj)
            % Define header for the System block dialog box.
            header = matlab.system.display.Header(mfilename('class'));
        end
        
        function group = getPropertyGroupsImpl(obj)
            % Define section for properties in System block dialog box.
            group = matlab.system.display.Section(mfilename('class'));
        end
    end
end
