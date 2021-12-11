classdef Scenario < handle
    % Scenario 控制类
    % functions: 
    %   - Scenario
    %   - newAndConfigScenario
    %   - setPeriod
    %   - animationPlay
    %   - animationPause
    %   - animationSetCurrentTime
    
    properties
        root  % root: object of AgStkObjectRoot
        start_time % type: datetime
        stop_time  % type: datetime
    end
    
    methods
        function obj = Scenario(OM)
            % OM: object of AgStkObjectRoot
            obj.root = OM;
        end
        
        function newAndConfigScenario(obj, scenarioName)
            % scenarioName: name of new scenario
            obj.root.UnitPreferences.SetCurrentUnit('LatitudeUnit', 'deg');
            obj.root.UnitPreferences.SetCurrentUnit('LongitudeUnit', 'deg');
            obj.root.UnitPreferences.SetCurrentUnit('DateFormat', 'UTCG');
            % close old scenario
            obj.root.CloseScenario;
            obj.root.NewScenario(scenarioName);
        end
        
        function setPeriod(obj, start_time, stop_time)
            % 设置仿真的开始和结束时间
            % start_time  e.g. '30 Jul 2014 16:00:05.000'
            % stop_time   e.g. '31 Jul 2014 16:00:00.000'
            obj.root.CurrentScenario.SetTimePeriod(start_time, stop_time);
            obj.root.CurrentScenario.Epoch = start_time;
            obj.start_time = datetime(start_time,'InputFormat','dd MMM yyyy HH:mm:ss.SSS', 'local', 'en_US');
            obj.stop_time = datetime(stop_time,'InputFormat','dd MMM yyyy HH:mm:ss.SSS', 'local', 'en_US');
            obj.root.CurrentTime = 0;
        end
        
        function animationPlay(obj)
           obj.root.PlayForward();
        end
        
        function animationPause(obj)
           obj.root.Pause();
        end
        
        function animationSetCurrentTime(obj, time)
            % 将仿真跳转到指定时间
            % time: e.g. '30 Jul 2014 16:00:05.000'
            target_time = datetime(time,'InputFormat','dd MMM yyyy HH:mm:ss.SSS', 'local', 'en_US');
            d_time = seconds(target_time - obj.start_time);
            obj.root.CurrentTime = d_time;
        end
        
        function animationJumpForward1day(obj)
             % 将仿真向前快进1天
             ctime = obj.root.CurrentTime;
             obj.root.CurrentTime = ctime + 24*3600;
        end
    end
    
end

