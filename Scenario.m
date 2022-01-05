classdef Scenario < handle
    % Scenario 控制类

    properties
        root  % root: object of AgStkObjectRoot
        start_time % type: datetime
        stop_time  % type: datetime
        
        objsPath % <cell char> 场景中全部的对象，包括子对象
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
    
        %% 场景设置
        function newAndConfigScenario(obj, scenarioName)
            % 关闭并新建场景
            % Args:
            %   - scenarioName <char>: 场景名字
            obj.root.UnitPreferences.SetCurrentUnit('LatitudeUnit', 'deg');
            obj.root.UnitPreferences.SetCurrentUnit('LongitudeUnit', 'deg');
            obj.root.UnitPreferences.SetCurrentUnit('DateFormat', 'UTCG');
            % close old scenario
            obj.root.CloseScenario;
            obj.root.NewScenario(scenarioName);
            % 关闭左下角调试信息
            obj.root.ExecuteCommand('VO * Annotation Time Show Off ShowTimeStep Off');
            obj.root.ExecuteCommand('VO * Annotation Frame Show Off');
        end
        
        function loadScenario(obj, scenarioPath)
            % 从sc文件中加载场景
            % Args:
            %   - scenarioPath <char>: sc文件的路径
            % close old scenario
            obj.root.CloseScenario;
            obj.root.LoadScenario(scenarioPath)
            % Update properties
            obj.getStartTime();
            obj.getStopTime();
            % 关闭左下角调试信息
            obj.root.ExecuteCommand('VO * Annotation Time Show Off ShowTimeStep Off');
            obj.root.ExecuteCommand('VO * Annotation Frame Show Off');
        end
       
        function setPeriod(obj, start_time, stop_time)
            % 设置仿真的开始和结束时间
            % Args:
            %   - start_time <char>: 仿真的开始时间 e.g. '30 Jul 2014 16:00:05.000'
            %   - stop_time <char>:  仿真的结束时间 e.g. '31 Jul 2014 16:00:00.000'
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

        %% 动画设置
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
            % 将仿真跳转到指定时间
            % Args:
            %   - time <char>: 想要跳转的时间日期 e.g. '30 Jul 2014 16:00:05.000'
            target_time = datetime(time,'InputFormat','dd MMM yyyy HH:mm:ss.SSS', 'local', 'en_US');
            d_time = seconds(target_time - obj.start_time);
            obj.root.CurrentTime = d_time;
        end

        function animationJumpForward1day(obj)
            % 将仿真向前快进1天
            ctime = obj.root.CurrentTime;
            obj.root.CurrentTime = ctime + 24*3600;
        end
        
        function current_time=getCurrentTime(obj)
            % 获取当前动画时间
            % Returns:
            %   - current_time <double>: 是当前时刻减去obj.root.CurrentScenario.Epoch 的seconds数,
            %                            通常 Epoch = StartTime
            current_time_sec = obj.root.CurrentTime;
            obj.getStartTime();
            current_time = obj.start_time + seconds(current_time_sec);
            current_time = datetime(current_time,'Format','dd MMM yyyy HH:mm:ss.SSS', 'Locale', 'en_US');
        end
        
        function zoom_to(obj, target, id)
           % 在3D视图中缩放到指定目标
           % Args:
           %   - target<char>: e.g. 'Satellite/ck'
           %   - id<int>: windows id
           cmd = 'VO * View FromTo FromRegName "STK Object" FromName "%s" ToRegName "STK Object" ToName "%s" WindowID %d';
           cmd = sprintf(cmd, target, target, id);
           obj.root.ExecuteCommand(cmd);
           % X夹角  Y夹角  距离 m
           obj.root.ExecuteCommand('VO * ViewerPosition 30 0 30');
        end

        %% 添加/删除对象: Satellite Missile Sensor Facility
        function insertSatByOrbitalElements(obj, name, color, semimajor_axis_km, eccentricity, inclination_deg, RANN, argument_of_perigee_deg, ture_anomaly_deg, sensor)
            % 根据轨道六根数添加卫星
            % Args:
            %   - name <char>: 名字
            %   - color <int>: 颜色
            %   - semimajor_axis_km <double>: 轨道半长轴/km
            %   - eccentricity <double>:  偏心率/
            %   - inclination_deg <double>: 轨道倾角/°
            %   - RANN <double>: 升交点赤经/°
            %   - argument_of_perigee_deg <double>: 近地点幅角/°
            %   - ture_anomaly_deg <double>: 真近地点角/°
            satellite = obj.root.CurrentScenario.Children.New('eSatellite', name);
            % 设置轨道颜色
            graphics = satellite.Graphics;
            graphics.SetAttributesType('eAttributesBasic');
            attributes = graphics.Attributes;
            attributes.Color = color;
            % 根据六根数设置轨道
            keplerian = satellite.Propagator.InitialState.Representation.ConvertTo('eOrbitStateClassical');   % 使用开普勒系
            keplerian.SizeShapeType = 'eSizeShapeSemimajorAxis';   % 半长轴+偏心率型
            keplerian.LocationType = 'eLocationTrueAnomaly'; % Makes sure True Anomaly is being used
            keplerian.Orientation.AscNodeType = 'eAscNodeRAAN';
            % 输入六根数
            keplerian.SizeShape.SemiMajorAxis = semimajor_axis_km;
            keplerian.SizeShape.Eccentricity = eccentricity;
            keplerian.Orientation.Inclination = inclination_deg;         % deg
            keplerian.Orientation.ArgOfPerigee = argument_of_perigee_deg;        % deg
            keplerian.Orientation.AscNode.Value = RANN;       % deg
            keplerian.Location.Value = ture_anomaly_deg;                 % deg
            % Apply the changes made to the satellite's state and propagate:
            satellite.Propagator.InitialState.Representation.Assign(keplerian);
            satellite.Propagator.Propagate;
            % 以下两行隐藏了3D图中的地面轨道投影
            satellite.VO.Pass.TrackData.PassData.GroundTrack.SetLeadDataType('eDataNone');
            satellite.VO.Pass.TrackData.PassData.GroundTrack.SetTrailDataType('eDataNone');
            % 添加传感器
            if nargin == 10
                % 根据传感器参数矩阵设置传感器组
                [r,c]=size(sensor); % c = 3, r = 传感器个数
                for i=1:r
                    obj.attachSensor(satellite, sprintf('Sensor%d', i), sensor(i,1), sensor(i,2), sensor(i,3));
                end
            else
                obj.attachSensor(satellite, 'Sensor', 55);
            end
        end

        function insertMissileByEFile(obj, name, color, path_of_e, modelPath, attitudePath, sensor)
            % 根据e文件路径添加missile
            % Args:
            %   - name <char>: 名字
            %   - color <int>: 颜色
            %   - path_of_e <char>: e文件路径
            %   - [modelPath <char>]: 可选，模型路径
            missile = obj.root.CurrentScenario.Children.New('eMissile',name);
            missile.SetTrajectoryType('ePropagatorStkExternal');   % 设置外部文件
            % 设置轨道颜色
            graphics = missile.Graphics;
            graphics.SetAttributesType('eAttributesBasic');
            attributes = graphics.Attributes;
            attributes.Color = color;
            % 从外部文件导入轨道信息
            trajectory = missile.Trajectory;
            trajectory.Filename = path_of_e;
            trajectory.Propagate;
            % 以下两行隐藏了3D图中的地面轨道投影
            missile.VO.Trajectory.TrackData.PassData.GroundTrack.SetLeadDataType('eDataNone');
            missile.VO.Trajectory.TrackData.PassData.GroundTrack.SetTrailDataType('eDataNone');
           
            % 设置飞行器模型
            if nargin >= 5
                model = missile.VO.Model;
                model.Visible = true; 
                model.ModelData.Filename  = modelPath;
                if nargin >= 6
                    ex = missile.Attitude.External;
                    ex.Load(attitudePath)
                end
                if nargin >= 7
                   % 根据传感器参数矩阵设置传感器组
                   [r,c]=size(sensor); % c = 3, r = 传感器个数
                   for i=1:r
                       obj.attachSensor(missile, sprintf('Sensor%d', i), sensor(i,1), sensor(i,2), sensor(i,3));
                   end
                end
            end
            if nargin <7
                % 添加默认传感器
                obj.attachSensor(missile, 'SA', 45, 90, 50);
                obj.attachSensor(missile, 'SB', 45, -90, 50);
            end
            
        end
        
        function missileSetAttitude(obj, missile, roll, pitch, yaw)
            % 修改missile姿态
            % Args:
            %   - missile <IAgMissile>: STK导弹对象
            %   - roll <double>: 横滚角
            %   - pitch <double>: 俯仰角
            %   - yaw <double>: 方位
            missile.SetAttitudeType('eAttitudeStandard');
            standard = missile.Attitude;
            standard.Basic.SetProfileType('eProfileFixedInAxes'); 
            interfix = standard.Basic.Profile;
            interfix.Orientation.AssignYPRAngles('eYPR', yaw, pitch, roll); 
        end
        
        function [latitude, longitude, altitude]=missileGetLLA(obj, path)
            % 获取当前missile的经纬度海拔位置信息
            % Args:
            %   - path: STK path
            % Returns:
            %   - latitude<double>: 精度
            %   - longitude<double>: 纬度
            %   - altitude<double>: 海拔 (m)
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
            % 为目标添加传感器
            % Args:  
            %   - father <AgStkObject>: 父类对象, 如sat或missile
            %   - name <char>:   名称
            %   - coneHalfAngle <double>: 圆锥传感器半锥角
            %   - [Az <double>]: 可选, 传感器位置，方位角
            %   - [El <double>]: 可选, 传感器位置，底部高度
            sensor = father.Children.New('eSensor', name);
            % 定义简单圆锥角传感器, 需要两个参数:
            % Args: 
            %   - ConeAngle: Angular separation between points in a pattern  参数为半锥角
            %   - AngularResolution: Angular separation between points in a pattern. 为角分辨率
            sensor.CommonTasks.SetPatternSimpleConic(coneHalfAngle, 0.1);  
            if nargin == 6
                % 定义传感器指向
                sensor.CommonTasks.SetPointingFixedAzEl(Az,El,'eAzElAboutBoresightRotate');
                % 修改指向空间的长度
                sensor.VO.SpaceProjection = 500;
            end
        end

        function insertFacilityByGeo(obj, name, color, latitude, longitude, altitude)
            % 根据经纬度添加设施
            % Args:
            %   - name <char>: 名字
            %   - color <int>: 颜色值
            %   - latitude <double>: 经度
            %   - longitude <double>: 纬度
            %   - altitude <double>: 海拔 (km)
            facility = obj.root.CurrentScenario.Children.New('eFacility', name);
            % 设置颜色
            graphics = facility.Graphics;
            graphics.LabelColor = color;
            % IAgFacility facility: Facility Object
            facility.Position.AssignGeodetic(latitude, longitude, altitude);
            % Set altitude to height of terrain
            facility.UseTerrain = true;
            % Set altitude to a distance above the ground
            facility.HeightAboveGround = 0;   % km
            % 设置地面设施上空范围示意区域
%             azelMask = facility.Graphics.AzElMask;
%             azelMask.RangeVisible = true;
%             azelMask.NumberOfRangeSteps = 10;
%             azelMask.DisplayRangeMinimum = 0;   % km
%             azelMask.DisplayRangeMaximum = 100;  % km
%             azelMask.RangeColorVisible = true;
%             azelMask.RangeColor = color; % cyan
        end
        
        function object=getByPath(obj, path)
            % 根据输入的path, 获取相应的对象
            % Args:
            %   - path <char>: STK path
            % Returns:
            %   - object <StkObject>: STK对象
            scenario_objs =  obj.root.CurrentScenario.Children;
            for i = 0: scenario_objs.Count - 1
                if strcmp(scenario_objs.Item(cast(i,'int32')).Path, path)
                    object = scenario_objs.Item(cast(i,'int32'));
                    return
                end
            end
        end
        
        function dict=getAllObj(obj)
            % 返回当前场景下的全部对象(不包括子对象)
            % Returns:
            %   - dict <struct char char>: struct的key为对象的简称名字，value为STKpath
            dict = struct();
            scenario_objs =  obj.root.CurrentScenario.Children;
            for i = 0: scenario_objs.Count - 1
                dict.(scenario_objs.Item(cast(i,'int32')).InstanceName) = scenario_objs.Item(cast(i,'int32')).Path;
            end
        end
        
        function list=getAllObjWithChildren(obj, father)
            % 返回场景下的所有对象,包括子对象
            % Args: 函数会自动递归调用, 顶层调用无需传参！
            %   - father <AgStkObject>: STK 对象
            % Returns:
            %   - list <cell char>: 当前场景下的全部对象的STKpath，包括子对象
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
            % 根据STKpath删除目标
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
                % 短path匹配
                res = regexp(scenario_objs.Item(cast(i,'int32')).Path, pattern, 'match');
                if ~isempty(res)
                    disp(sprintf('%s removed!', scenario_objs.Item(cast(i,'int32')).Path))
                    scenario_objs.Item(cast(i,'int32')).Unload();
                    return
                end
            end
        end

        function removeAll(obj)
            % 删除场景下的全部对象
            scenario_objs =  obj.root.CurrentScenario.Children;
            for i = 0: scenario_objs.Count - 1
                % 会自动减一 所以一直删除index=0即可
                scenario_objs.Item(cast(0,'int32')).Unload();
            end
        end
        
        %% 录制视频相关
        function startRecordToFile(obj, file_name)
            recording = obj.root.CurrentScenario.SceneManager.Scenes.Item(cast(0,'int32')).Camera.VideoRecording;
            recording.StartRecording(file_name, 5000, 30);
        end
        
        function stopRecordToFile(obj)
            recording = obj.root.CurrentScenario.SceneManager.Scenes.Item(cast(0,'int32')).Camera.VideoRecording;
            recording.StopRecording();
        end
        
        %% Chains 相关
        function newConstellation(obj, name, objects)
            % 创建集合，一般是传感器的集合
            % Args: 
            %   - name: 名字
            %   - objects <cell char>: (传感器)对象STKpath的集合 形式应为 nx1
            constellation = obj.root.CurrentScenario.Children.New('eConstellation', name);
            for i=1:size(objects)
                constellation.Objects.Add(char(objects(i)));
            end
            disp(['Add ' num2str(constellation.Objects.Count) ' item(s) to ' constellation.InstanceName '!'])
        end
        
        function newChain(obj, name, objects)
            % 创建Chain
            % Args: 
            %   - name: 名字
            %   - objects <cell char>: 对象STKpath的集合 形式应为 nx1
            chain = obj.root.CurrentScenario.Children.New('eChain', name);
            for i=1:size(objects)
                chain.Objects.Add(char(objects(i)));
            end
            chain.Graphics.Animation.IsDirectionVisible = true;
            disp(['Add ' num2str(chain.Objects.Count) ' item(s) to ' chain.InstanceName '!'])
        end
        
        function chain=getChain(obj, path)
            % 获取当前场景下第一个或指定 Chain
            % Args:
            %   - [path <char>]: 可选参数，应为Chain的Path
            scenario_objs =  obj.root.CurrentScenario.Children;
            chains = scenario_objs.GetElements('eChain');
            if chains.Count >= 1
                if nargin == 2
                    % 指定path
                    for i = 0: chains.Count - 1
                       if strcmp(chains.Item(cast(i,'int32')).Path, path)
                           chain = chains.Item(cast(i,'int32'));
                           return
                       end
                    end
                    chain = nan;
                    disp('No chain found in scenario by given path!')
                else
                    % 没有指定path, 则获取第一个chain
                    chain = chains.Item(cast(0,'int32'));
                end
            else
                chain = nan;
            end
        end
        
        function [Name, AERTimes, Az, El, Range]=accessAER(obj, timeStep, filename)
            % 获取AER Access
            % Args:
            %   - timeStep<int>: 仿真步长，单位：秒
            %   - [filename<char>]: 可选参数，保存文件名，如果传入文件名则保存到指定文件
            % Returns: 五组返回值index一一对应，应一起循环！
            %   - Name<cell char>: access A to B 名字，
            %   - AERTimes<cell char>: 访问时间
            %   - Az<cell double>: 方位角
            %   - El<cell double>: 俯仰角
            %   - Range<cell double>: 距离
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
            % 为了拼接,先得有头
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

