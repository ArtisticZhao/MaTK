classdef Scenario < handle
    % Scenario ������

    properties
        root  % root: object of AgStkObjectRoot
        start_time % type: datetime
        stop_time  % type: datetime
        
        objsPath % <cell char> ������ȫ���Ķ��󣬰����Ӷ���
        % for AER report
        Name
        AERTimes
        Az
        El
        Range
    end

    methods
        function obj = Scenario(OM)
            % OM: object of AgStkObjectRoot
            obj.root = OM;
        end
    
        %% ��������
        function newAndConfigScenario(obj, scenarioName)
            % �رղ��½�����
            % Args:
            %   - scenarioName <char>: ��������
            obj.root.UnitPreferences.SetCurrentUnit('LatitudeUnit', 'deg');
            obj.root.UnitPreferences.SetCurrentUnit('LongitudeUnit', 'deg');
            obj.root.UnitPreferences.SetCurrentUnit('DateFormat', 'UTCG');
            % close old scenario
            obj.root.CloseScenario;
            obj.root.NewScenario(scenarioName);
            % �ر����½ǵ�����Ϣ
            obj.root.ExecuteCommand('VO * Annotation Time Show Off ShowTimeStep Off');
            obj.root.ExecuteCommand('VO * Annotation Frame Show Off');
        end
        
        function loadScenario(obj, scenarioPath)
            % ��sc�ļ��м��س���
            % Args:
            %   - scenarioPath <char>: sc�ļ���·��
            % close old scenario
            obj.root.CloseScenario;
            obj.root.LoadScenario(scenarioPath)
            % Update properties
            obj.getStartTime();
            obj.getStopTime();
            % �ر����½ǵ�����Ϣ
            obj.root.ExecuteCommand('VO * Annotation Time Show Off ShowTimeStep Off');
            obj.root.ExecuteCommand('VO * Annotation Frame Show Off');
        end
       
        function setPeriod(obj, start_time, stop_time)
            % ���÷���Ŀ�ʼ�ͽ���ʱ��
            % Args:
            %   - start_time <char>: ����Ŀ�ʼʱ�� e.g. '30 Jul 2014 16:00:05.000'
            %   - stop_time <char>:  ����Ľ���ʱ�� e.g. '31 Jul 2014 16:00:00.000'
            obj.root.CurrentScenario.SetTimePeriod(start_time, stop_time);
            obj.root.CurrentScenario.Epoch = start_time;
            obj.start_time = datetime(start_time,'InputFormat','dd MMM yyyy HH:mm:ss.SSS', 'local', 'en_US');
            obj.stop_time = datetime(stop_time,'InputFormat','dd MMM yyyy HH:mm:ss.SSS', 'local', 'en_US');
            obj.root.CurrentTime = 0;
        end
        
        function start_time=getStartTime(obj)
            start_time = obj.root.CurrentScenario.StartTime;
            obj.start_time = datetime(start_time,'InputFormat','dd MMM yyyy HH:mm:ss.SSS', 'local', 'en_US');
        end
        
        function stop_time=getStopTime(obj)
            stop_time = obj.root.CurrentScenario.StopTime;
            obj.stop_time = datetime(stop_time,'InputFormat','dd MMM yyyy HH:mm:ss.SSS', 'local', 'en_US');
        end

        %% ��������
        function animationPlay(obj)
            obj.root.PlayForward();
        end

        function animationPause(obj)
            obj.root.Pause();
        end
        
        function animationReset(obj)
            obj.root.Rewind(); 
        end
        
        function animationFaster(obj)
            obj.root.Faster();
        end
        
        function animationSlower(obj)
            obj.root.Slower();
        end

        function animationSetCurrentTime(obj, time)
            % ��������ת��ָ��ʱ��
            % Args:
            %   - time <char>: ��Ҫ��ת��ʱ������ e.g. '30 Jul 2014 16:00:05.000'
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
            % ��ȡ��ǰ����ʱ��
            % Returns:
            %   - current_time <double>: �ǵ�ǰʱ�̼�ȥobj.root.CurrentScenario.Epoch ��seconds��,
            %                            ͨ�� Epoch = StartTime
            current_time_sec = obj.root.CurrentTime;
            obj.getStartTime();
            current_time = obj.start_time + seconds(current_time_sec);
            current_time = datetime(current_time,'Format','dd MMM yyyy HH:mm:ss.SSS', 'Locale', 'en_US');
        end
        
        function zoom_to(obj, target, id)
           % ��3D��ͼ�����ŵ�ָ��Ŀ��
           % Args:
           %   - target<char>: e.g. 'Satellite/ck'
           %   - id<int>: windows id
           cmd = 'VO * View FromTo FromRegName "STK Object" FromName "%s" ToRegName "STK Object" ToName "%s" WindowID %d';
           cmd = sprintf(cmd, target, target, id);
           obj.root.ExecuteCommand(cmd);
           % X�н�  Y�н�  ���� m
           obj.root.ExecuteCommand('VO * ViewerPosition 30 0 30');
        end

        %% ���/ɾ������: Satellite Missile Sensor Facility
        function insertSatByOrbitalElements(obj, name, color, semimajor_axis_km, eccentricity, inclination_deg, RANN, argument_of_perigee_deg, ture_anomaly_deg, sensor)
            % ���ݹ���������������
            % Args:
            %   - name <char>: ����
            %   - color <int>: ��ɫ
            %   - semimajor_axis_km <double>: ����볤��/km
            %   - eccentricity <double>:  ƫ����/
            %   - inclination_deg <double>: ������/��
            %   - RANN <double>: ������ྭ/��
            %   - argument_of_perigee_deg <double>: ���ص����/��
            %   - ture_anomaly_deg <double>: ����ص��/��
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
            % ��Ӵ�����
            if nargin == 10
                % ���ݴ����������������ô�������
                [r,c]=size(sensor); % c = 3, r = ����������
                for i=1:r
                    obj.attachSensor(satellite, sprintf('Sensor%d', i), sensor(i,1), sensor(i,2), sensor(i,3));
                end
            else
                obj.attachSensor(satellite, 'Sensor', 55);
            end
        end

        function insertMissileByEFile(obj, name, color, path_of_e, modelPath, attitudePath, sensor)
            % ����e�ļ�·�����missile
            % Args:
            %   - name <char>: ����
            %   - color <int>: ��ɫ
            %   - path_of_e <char>: e�ļ�·��
            %   - [modelPath <char>]: ��ѡ��ģ��·��
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
           
            % ���÷�����ģ��
            if nargin >= 5
                model = missile.VO.Model;
                model.Visible = true; 
                model.ModelData.Filename  = modelPath;
                if nargin >= 6
                    ex = missile.Attitude.External;
                    ex.Load(attitudePath)
                end
                if nargin >= 7
                   % ���ݴ����������������ô�������
                   [r,c]=size(sensor); % c = 3, r = ����������
                   for i=1:r
                       obj.attachSensor(missile, sprintf('Sensor%d', i), sensor(i,1), sensor(i,2), sensor(i,3));
                   end
                end
            end
            if nargin <7
                % ���Ĭ�ϴ�����
                obj.attachSensor(missile, 'SA', 45, 90, 50);
                obj.attachSensor(missile, 'SB', 45, -90, 50);
            end
            
        end
        
        function missileSetAttitude(obj, missile, roll, pitch, yaw)
            % �޸�missile��̬
            % Args:
            %   - missile <IAgMissile>: STK��������
            %   - roll <double>: �����
            %   - pitch <double>: ������
            %   - yaw <double>: ��λ
            missile.SetAttitudeType('eAttitudeStandard');
            standard = missile.Attitude;
            standard.Basic.SetProfileType('eProfileFixedInAxes'); 
            interfix = standard.Basic.Profile;
            interfix.Orientation.AssignYPRAngles('eYPR', yaw, pitch, roll); 
        end
        
        function [latitude, longitude, altitude]=missileGetLLA(obj, path)
            % ��ȡ��ǰmissile�ľ�γ�Ⱥ���λ����Ϣ
            % Args:
            %   - path: STK path
            % Returns:
            %   - latitude<double>: ����
            %   - longitude<double>: γ��
            %   - altitude<double>: ���� (m)
            cmd = 'Position %s';
            cmd = sprintf(cmd, path);
            res = obj.root.ExecuteCommand(cmd);
            if res.Count == 1
               res = res.Item(cast(0, 'int32'));
            end
            C = strsplit(res, ' ');
            latitude = C(1);
            longitude = C(2);
            altitude = C(3);
        end
        
        function attachSensor(obj, father, name, coneHalfAngle, Az, El)
            % ΪĿ����Ӵ�����
            % Args:  
            %   - father <AgStkObject>: �������, ��sat��missile
            %   - name <char>:   ����
            %   - coneHalfAngle <double>: Բ׶��������׶��
            %   - [Az <double>]: ��ѡ, ������λ�ã���λ��
            %   - [El <double>]: ��ѡ, ������λ�ã��ײ��߶�
            sensor = father.Children.New('eSensor', name);
            % �����Բ׶�Ǵ�����, ��Ҫ��������:
            % Args: 
            %   - ConeAngle: Angular separation between points in a pattern  ����Ϊ��׶��
            %   - AngularResolution: Angular separation between points in a pattern. Ϊ�Ƿֱ���
            sensor.CommonTasks.SetPatternSimpleConic(coneHalfAngle, 0.1);  
            if nargin == 6
                % ���崫����ָ��
                sensor.CommonTasks.SetPointingFixedAzEl(Az,El,'eAzElAboutBoresightRotate');
                % �޸�ָ��ռ�ĳ���
                sensor.VO.SpaceProjection = 500;
            end
        end

        function insertFacilityByGeo(obj, name, color, latitude, longitude, altitude)
            % ���ݾ�γ�������ʩ
            % Args:
            %   - name <char>: ����
            %   - color <int>: ��ɫֵ
            %   - latitude <double>: ����
            %   - longitude <double>: γ��
            %   - altitude <double>: ���� (km)
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
        
        function object=getByPath(obj, path)
            % ���������path, ��ȡ��Ӧ�Ķ���
            % Args:
            %   - path <char>: STK path
            % Returns:
            %   - object <StkObject>: STK����
            scenario_objs =  obj.root.CurrentScenario.Children;
            for i = 0: scenario_objs.Count - 1
                if strcmp(scenario_objs.Item(cast(i,'int32')).Path, path)
                    object = scenario_objs.Item(cast(i,'int32'));
                    return
                end
            end
        end
        
        function dict=getAllObj(obj)
            % ���ص�ǰ�����µ�ȫ������(�������Ӷ���)
            % Returns:
            %   - dict <struct char char>: struct��keyΪ����ļ�����֣�valueΪSTKpath
            dict = struct();
            scenario_objs =  obj.root.CurrentScenario.Children;
            for i = 0: scenario_objs.Count - 1
                dict.(scenario_objs.Item(cast(i,'int32')).InstanceName) = scenario_objs.Item(cast(i,'int32')).Path;
            end
        end
        
        function list=getAllObjWithChildren(obj, father)
            % ���س����µ����ж���,�����Ӷ���
            % Args: �������Զ��ݹ����, ����������贫�Σ�
            %   - father <AgStkObject>: STK ����
            % Returns:
            %   - list <cell char>: ��ǰ�����µ�ȫ�������STKpath�������Ӷ���
            if nargin==2
                objs = father;
            else
                objs =  obj.root.CurrentScenario;
                obj.objsPath = {};
            end
            
            if ~objs.HasChildren
               return
            end
                
            for i = 0: objs.Children.Count - 1
                obj.getAllObjWithChildren(objs.Children.Item(cast(i,'int32')));
                obj.objsPath(end+1) = {objs.Children.Item(cast(i,'int32')).Path};
            end
            list = obj.objsPath;
        end
        
        function removeByPath(obj, path)
            % ����STKpathɾ��Ŀ��
            % Args: 
            %   - path: e.g.  '/Application/STK/Scenario/Scenario/Missile/FXQ'
            %                 or 'Missile/FXQ'
            scenario_objs =  obj.root.CurrentScenario.Children;
            pattern = sprintf('%s$', path);
            for i = 0: scenario_objs.Count - 1
                if strcmp(scenario_objs.Item(cast(i,'int32')).Path, path)
                    disp(sprintf('%s removed!', scenario_objs.Item(cast(i,'int32')).Path))
                    scenario_objs.Item(cast(i,'int32')).Unload();
                    return
                end
                % ��pathƥ��
                res = regexp(scenario_objs.Item(cast(i,'int32')).Path, pattern, 'match');
                if ~isempty(res)
                    disp(sprintf('%s removed!', scenario_objs.Item(cast(i,'int32')).Path))
                    scenario_objs.Item(cast(i,'int32')).Unload();
                    return
                end
            end
        end

        function removeAll(obj)
            % ɾ�������µ�ȫ������
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
        function newConstellation(obj, name, objects)
            % �������ϣ�һ���Ǵ������ļ���
            % Args: 
            %   - name: ����
            %   - objects <cell char>: (������)����STKpath�ļ��� ��ʽӦΪ nx1
            constellation = obj.root.CurrentScenario.Children.New('eConstellation', name);
            for i=1:size(objects)
                constellation.Objects.Add(char(objects(i)));
            end
            disp(['Add ' num2str(constellation.Objects.Count) ' item(s) to ' constellation.InstanceName '!'])
        end
        
        function newChain(obj, name, objects)
            % ����Chain
            % Args: 
            %   - name: ����
            %   - objects <cell char>: ����STKpath�ļ��� ��ʽӦΪ nx1
            chain = obj.root.CurrentScenario.Children.New('eChain', name);
            for i=1:size(objects)
                chain.Objects.Add(char(objects(i)));
            end
            chain.Graphics.Animation.IsDirectionVisible = true;
            disp(['Add ' num2str(chain.Objects.Count) ' item(s) to ' chain.InstanceName '!'])
        end
        
        function chain=getChain(obj, path)
            % ��ȡ��ǰ�����µ�һ����ָ�� Chain
            % Args:
            %   - [path <char>]: ��ѡ������ӦΪChain��Path
            scenario_objs =  obj.root.CurrentScenario.Children;
            chains = scenario_objs.GetElements('eChain');
            if chains.Count >= 1
                if nargin == 2
                    % ָ��path
                    for i = 0: chains.Count - 1
                       if strcmp(chains.Item(cast(i,'int32')).Path, path)
                           chain = chains.Item(cast(i,'int32'));
                           return
                       end
                    end
                    chain = nan;
                    disp('No chain found in scenario by given path!')
                else
                    % û��ָ��path, ���ȡ��һ��chain
                    chain = chains.Item(cast(0,'int32'));
                end
            else
                chain = nan;
            end
        end
        
        function [Name, AERTimes, Az, El, Range]=accessAER(obj, timeStep, filename)
            % ��ȡAER Access
            % Args:
            %   - timeStep<int>: ���沽������λ����
            %   - [filename<char>]: ��ѡ�����������ļ�������������ļ����򱣴浽ָ���ļ�
            % Returns: ���鷵��ֵindexһһ��Ӧ��Ӧһ��ѭ����
            %   - Name<cell char>: access A to B ���֣�
            %   - AERTimes<cell char>: ����ʱ��
            %   - Az<cell double>: ��λ��
            %   - El<cell double>: ������
            %   - Range<cell double>: ����
            chain = obj.getChain(); 
%             if isnan(chain)
%                 disp('No chain found in scenario!')
%                 return 
%             end
            chain.ClearAccess();
            chain.ComputeAccess();
            accessAER = chain.DataProviders.Item('Access AER Data').Exec(obj.root.CurrentScenario.StartTime, obj.root.CurrentScenario.StopTime,timeStep);
            if accessAER.Interval.Count == 0
               return 
            end
            % Ϊ��ƴ��,�ȵ���ͷ
            Name = accessAER.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Strand Name').GetValues;
            AERTimes = cell2mat(accessAER.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues);
            Az = cell2mat(accessAER.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues);
            El = cell2mat(accessAER.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Elevation').GetValues);
            Range = cell2mat(accessAER.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Range').GetValues);
            for i = 1:1:accessAER.Interval.Count-1
                tempName = accessAER.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Strand Name').GetValues;
                Name = [Name; tempName];
                AERTimes = [AERTimes; cell2mat(accessAER.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues)];
                Az = [Az; cell2mat(accessAER.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues)];
                El = [El; cell2mat(accessAER.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Elevation').GetValues)];
                Range = [Range; cell2mat(accessAER.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Range').GetValues)];
            end
            obj.Name = Name;
            obj.AERTimes = AERTimes;
            obj.Az = Az;
            obj.El = El;
            % save to file
            if nargin == 3
                T = table(Name,AERTimes,Az,El,Range);
                writetable(T,filename)
            end
        end
    end
end

