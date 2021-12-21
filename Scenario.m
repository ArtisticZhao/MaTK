classdef Scenario < handle
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
        start_time % type: datetime
        stop_time  % type: datetime
    end

    methods
        function obj = Scenario(OM)
            % OM: object of AgStkObjectRoot
            obj.root = OM;
        end
    
        %% ��������
        function newAndConfigScenario(obj, scenarioName)
            % scenarioName: name of new scenario
            obj.root.UnitPreferences.SetCurrentUnit('LatitudeUnit', 'deg');
            obj.root.UnitPreferences.SetCurrentUnit('LongitudeUnit', 'deg');
            obj.root.UnitPreferences.SetCurrentUnit('DateFormat', 'UTCG');
            % close old scenario
            obj.root.CloseScenario;
            obj.root.NewScenario(scenarioName);
        end
        
        function loadScenario(obj, scenarioPath)
            % close old scenario
            obj.root.CloseScenario;
            obj.root.LoadScenario(scenarioPath)
        end
       
        function setPeriod(obj, start_time, stop_time)
            % ���÷���Ŀ�ʼ�ͽ���ʱ��
            % start_time  e.g. '30 Jul 2014 16:00:05.000'
            % stop_time   e.g. '31 Jul 2014 16:00:00.000'
            obj.root.CurrentScenario.SetTimePeriod(start_time, stop_time);
            obj.root.CurrentScenario.Epoch = start_time;
            obj.start_time = datetime(start_time,'InputFormat','dd MMM yyyy HH:mm:ss.SSS', 'local', 'en_US');
            obj.stop_time = datetime(stop_time,'InputFormat','dd MMM yyyy HH:mm:ss.SSS', 'local', 'en_US');
            obj.root.CurrentTime = 0;
        end
        
        function start_time=getStartTime(obj)
           start_time = obj.root.CurrentScenario.StartTime;
        end
        
        function stop_time=getStopTime(obj)
           stop_time = obj.root.CurrentScenario.StopTime;
        end

        %% ��������
        function animationPlay(obj)
           obj.root.PlayForward();
        end

        function animationPause(obj)
           obj.root.Pause();
        end

        function animationSetCurrentTime(obj, time)
            % ��������ת��ָ��ʱ��
            % time: e.g. '30 Jul 2014 16:00:05.000'
            target_time = datetime(time,'InputFormat','dd MMM yyyy HH:mm:ss.SSS', 'local', 'en_US');
            d_time = seconds(target_time - obj.start_time);
            obj.root.CurrentTime = d_time;
        end

        function animationJumpForward1day(obj)
             % ��������ǰ���1��
             ctime = obj.root.CurrentTime;
             obj.root.CurrentTime = ctime + 24*3600;
        end
        
        function current_time=getCurrentTime(obj)
            % current_time �ǵ�ǰʱ�̼�ȥobj.root.CurrentScenario.Epoch ��seconds��,
            % ͨ�� Epoch = StartTime
            current_time = obj.root.CurrentTime;
        end

        %% ���/ɾ������
        function insertSatByOrbitalElements(obj, name, color, semimajor_axis_km, eccentricity, inclination_deg, RANN, argument_of_perigee_deg, ture_anomaly_deg)
            % args:
            %       color: <int>
            satellite = obj.root.CurrentScenario.Children.New('eSatellite', name);
            % ���ù����ɫ
            graphics = satellite.Graphics;
            graphics.SetAttributesType('eAttributesBasic');
            attributes = graphics.Attributes;
            attributes.Color = color;
            % �������������ù��
            keplerian = satellite.Propagator.InitialState.Representation.ConvertTo('eOrbitStateClassical');   % ʹ�ÿ�����ϵ
            keplerian.SizeShapeType = 'eSizeShapeSemimajorAxis';   % �볤��+ƫ������
            keplerian.LocationType = 'eLocationTrueAnomaly'; % Makes sure True Anomaly is being used
            keplerian.Orientation.AscNodeType = 'eAscNodeRAAN';
            % ����������
            keplerian.SizeShape.SemiMajorAxis = semimajor_axis_km;
            keplerian.SizeShape.Eccentricity = eccentricity;
            keplerian.Orientation.Inclination = inclination_deg;         % deg
            keplerian.Orientation.ArgOfPerigee = argument_of_perigee_deg;        % deg
            keplerian.Orientation.AscNode.Value = RANN;       % deg
            keplerian.Location.Value = ture_anomaly_deg;                 % deg
            % Apply the changes made to the satellite's state and propagate:
            satellite.Propagator.InitialState.Representation.Assign(keplerian);
            satellite.Propagator.Propagate;
            % ��������������3Dͼ�еĵ�����ͶӰ
            satellite.VO.Pass.TrackData.PassData.GroundTrack.SetLeadDataType('eDataNone');
            satellite.VO.Pass.TrackData.PassData.GroundTrack.SetTrailDataType('eDataNone');
        end

        function insertMissileByEFile(obj, name, color, path_of_e)
            missile = obj.root.CurrentScenario.Children.New('eMissile',name);
            missile.SetTrajectoryType('ePropagatorStkExternal');   % �����ⲿ�ļ�
            % ���ù����ɫ
            graphics = missile.Graphics;
            graphics.SetAttributesType('eAttributesBasic');
            attributes = graphics.Attributes;
            attributes.Color = color;
            % ���ⲿ�ļ���������Ϣ
            trajectory = missile.Trajectory;
            trajectory.Filename = path_of_e;
            trajectory.Propagate;
            % ��������������3Dͼ�еĵ�����ͶӰ
            missile.VO.Trajectory.TrackData.PassData.GroundTrack.SetLeadDataType('eDataNone');
            missile.VO.Trajectory.TrackData.PassData.GroundTrack.SetTrailDataType('eDataNone');
        end

        function insertFacilityByGeo(obj, name, color, latitude, longitude, altitude)
            facility = obj.root.CurrentScenario.Children.New('eFacility', name);
            % ������ɫ
            graphics = facility.Graphics;
            graphics.LabelColor = color;
            % IAgFacility facility: Facility Object
            facility.Position.AssignGeodetic(latitude, longitude, altitude);
            % Set altitude to height of terrain
            facility.UseTerrain = true;
            % Set altitude to a distance above the ground
            facility.HeightAboveGround = 0;   % km
            % ���õ�����ʩ�Ͽշ�Χʾ������
%             azelMask = facility.Graphics.AzElMask;
%             azelMask.RangeVisible = true;
%             azelMask.NumberOfRangeSteps = 10;
%             azelMask.DisplayRangeMinimum = 0;   % km
%             azelMask.DisplayRangeMaximum = 100;  % km
%             azelMask.RangeColorVisible = true;
%             azelMask.RangeColor = color; % cyan
        end

        function removeAll(obj)
           scenario_objs =  obj.root.CurrentScenario.Children;
           for i = 0: scenario_objs.Count - 1
               % ���Զ���һ ����һֱɾ��index=0����
               scenario_objs.Item(cast(0,'int32')).Unload();
           end
        end
        
        %% ¼����Ƶ���
        function startRecordToFile(obj, file_name)
            recording = obj.root.CurrentScenario.SceneManager.Scenes.Item(cast(0,'int32')).Camera.VideoRecording;
            recording.StartRecording(file_name, 5000, 30);
        end
        
        function stopRecordToFile(obj)
            recording = obj.root.CurrentScenario.SceneManager.Scenes.Item(cast(0,'int32')).Camera.VideoRecording;
            recording.StopRecording();
        end
        
        %% Chains ���
        function chain=getChain(obj)
           scenario_objs =  obj.root.CurrentScenario.Children;
           chains = scenario_objs.GetElements('eChain');
           if chains.Count == 1
               chain = chains.Item(cast(0,'int32'));
           end
           % TODO: û�д���շ���ֵ!
        end
        
        function [Name, AERTimes, Az, El, Range]=accessAER(obj, timeStep, filename)
           chain = obj.getChain(); 
           chain.ClearAccess();
           chain.ComputeAccess();
           accessAER = chain.DataProviders.Item('Access AER Data').Exec(obj.root.CurrentScenario.StartTime, obj.root.CurrentScenario.StopTime,timeStep);
           % Ϊ��ƴ��,�ȵ���ͷ
           Name = cell2mat(accessAER.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Strand Name').GetValues);
           AERTimes = cell2mat(accessAER.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues);
           Az = cell2mat(accessAER.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues);
           El = cell2mat(accessAER.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Elevation').GetValues);
           Range = cell2mat(accessAER.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Range').GetValues);
           for i = 1:1:accessAER.Interval.Count-1
               Name = [Name; cell2mat(accessAER.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Strand Name').GetValues)];
               AERTimes = [AERTimes; cell2mat(accessAER.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues)];
               Az = [Az; cell2mat(accessAER.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues)];
               El = [El; cell2mat(accessAER.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Elevation').GetValues)];
               Range = [Range; cell2mat(accessAER.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Range').GetValues)];
           end
           % save to file
           if nargin == 3
               T = table(Name,AERTimes,Az,El,Range);
               writetable(T,filename)
           end
        end
    end

end

