classdef Scenario
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
            % start_time
            % stop_time
        end
        
        function animationPlay(obj)
           obj.root.PlayForward();
        end
        
        function animationPause(obj)
           obj.root.Pause();
        end
        
        function animationSetCurrentTime(obj, time)
            % 将仿真跳转到指定时间
            % time 
        end
    end
    
end

