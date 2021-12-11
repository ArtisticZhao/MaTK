classdef Scenario
    % Scenario ������
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
            % ���÷���Ŀ�ʼ�ͽ���ʱ��
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
            % ��������ת��ָ��ʱ��
            % time 
        end
    end
    
end

