% Connect to RFeye Node via NCP to stream IQ data.
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
%      Filename:     ncp_time_data.m
%      Description : System object file to call external NCP library.
%
%      Version : see below
%
%      Authors : Boon Khoo, Alex Bartolome
%
%      History :
%      1.00    BK  22 /  2 / 2017 Initial
%      1.01    AB  13 / 12 / 2018 Fix default IP and port
%
classdef ncp_time_data < matlab.System & matlab.system.mixin.Propagates ...
        & matlab.system.mixin.CustomIcon
    properties
        
    end
    
    properties (Nontunable)
        % Number of Samples
        numSamples = 10000;
        % Center Frequency (MHz)
        centerFreqMHz = 900;
        % Bandwidth (Hz)
        bandwidthHz = 500000;
        % Exact Mode
        exactMode = 1;
        % Stream Mode (1=Streaming,0=Normal)
        streaming = 0;
        % IP Address
        node_ip = '192.0.2.0';
        % Port
        node_port = 9999;
    end
    
    properties (Access = private)
        % Pointer
        bandwidthHzPtr;
        iDataPtr;
        qDataPtr;
    end
    
    properties (DiscreteState)
    end
    
    methods
        % Constructor
        function obj = ncp_time_data(varargin)
            % Support name-value pair arguments when constructing the object.
            setProperties(obj,nargin,varargin{:});
        end
    end
    
    methods (Access = protected)
        %% Common functions
        function setupImpl(obj)
            % Implement tasks that need to be performed only once,
            % such as pre-computed constants.
            obj.numSamples;
            obj.centerFreqMHz;
            obj.bandwidthHz;
            obj.exactMode;
            obj.node_ip;
            obj.node_port;            
            % Create pointer
            obj.bandwidthHzPtr = libpointer('int32Ptr', obj.bandwidthHz);
            obj.iDataPtr = libpointer('doublePtr', zeros(obj.numSamples,1));
            obj.qDataPtr = libpointer('doublePtr', zeros(obj.numSamples,1));
        end
        
        function [i_data, q_data] = stepImpl(obj)            
            % Load dll file and create NCP connection
            if not(libisloaded('matlab_ncp_lib'))
                loadlibrary('matlab_ncp_lib.dll', 'matlab_ncp_lib.h');
                calllib('matlab_ncp_lib', 'StartTimeCapture', obj.bandwidthHz, obj.exactMode, ...
                    obj.centerFreqMHz, obj.streaming, obj.numSamples, obj.node_ip, obj.node_port);
            end
                        
            % Call the function
            calllib('matlab_ncp_lib', 'GetTimeCaptureData', ...
                obj.iDataPtr, obj.qDataPtr, obj.bandwidthHzPtr, obj.numSamples);
            
            % Pause for 0.2s 
            pause(0.2);
            
            % Output data
            i_data = obj.iDataPtr.Value';
            q_data = obj.qDataPtr.Value';
            
        end
        
        function resetImpl(obj)
            % Initialize discrete-state properties.
            if libisloaded('matlab_ncp_lib')
                calllib('matlab_ncp_lib', 'EndTimeCapture');
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
        
        function [size1,size2] = getOutputSizeImpl(obj)
            % Implement if input size does not match with output size.
            size1 = [1 obj.numSamples];
            size2 = [1 obj.numSamples];
            
        end
        
        function icon = getIconImpl(obj)
            % Define a string as the icon for the System block in Simulink.
            icon = mfilename('class');
        end
        
        function num = getNumOutputsImpl(~)
            num = 2;
        end
        
        
        function [c1,c2] = isOutputFixedSizeImpl(~)
            c1 = true;
            c2 = true;
        end
        
        function [dt1,dt2] = getOutputDataTypeImpl(obj)
            dt1 = 'double';
            dt2 = 'double';
        end
        
        function [flag1, flag2] = isOutputComplexImpl(obj)
            flag1 = false;
            flag2 = false;
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
