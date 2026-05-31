clear;
close all;
clc;

%%% the programme below are mixture of TCSTInterface() and activeX
%%% framework
%%% maximum of element allowed == 3

RTD = 180/pi;

%------------add-on module control pannel--------------------%
PlanewaveSet = 1; 
FieldMointorSet = 1;
AccerelationSet = 1;
OptmizationParameterSet = 0;


%------------function add-on control pannel -----------------%
HistoryEnable = 1;%dont set it 0!!
PhiAngSimulate = 0;%[0 45 90 135 180 225 270 315];%0;%
Repeatednumber = 1;%length(PhiAngSimulate);%1;%
RepeatEnable = 0; 


RunJobID = 1;%this is the job count, incase there is the same history name appear, dont change this 

%%%%--- control center command/ configuration setting 
   
    addpath(genpath('C:\Users\40210776\OneDrive - Queen''s University Belfast\PHD research\Matlab_\MTC testing\CST-MATLAB-API-master\cst api V2 modified'));
    
fprintf('[%s] Initializeing... \n', datestr(now,'HH:MM:SS'));
fprintf('[%s] opening CST... \n', datestr(now,'HH:MM:SS'));
%%%%%%%%%%---------Read the phase from plane wave-----%%%%%%%%%%
for ModleRepeated = 1:Repeatednumber
   
   if Repeatednumber > 1
    FileSaveDirectirity ='E:\DELL_ECIT80589_SSD\Cass_TripletV2\';
    FileNameRecordPath = [FileSaveDirectirity 'Filename_Record_For_DataCollect_W.txt'];
    InitialfileName = ['CASS_TripletV2_R_' num2str(ModleRepeated) 'of_' num2str(Repeatednumber) '.cst']; 
    FilePath = [FileSaveDirectirity InitialfileName];
   end

cst = actxserver("CSTStudio.application.2023");%('CSTStudio.application.2020');
pause(1);
mws = cst.invoke('NewMWS');
pause(0.1);


%### setting configuration ####%
Geometry = 'mm';
Frequency = 'GHz';
Time = 'ns';
TemperatureUnit = 'Kelvin';
Voltage = 'V';
Current = 'A';
Resistance = 'Ohm';
Conductance  = 'S';
Capacitance = 'PikoF';
Inductance = 'NanoH';

%### setting 2 ####%
 CstDefineUnits(mws,Geometry, Frequency, Time, TemperatureUnit, Voltage, Current, Resistance, Conductance, Capacitance, Inductance)
 CstMeshInitiator(mws)
 CstDefineFrequencyRange(mws,2.3,2.5)



%%% structure setting %%%%%
    %%%##### Special structure setting pannel #######%%%
        UnitcellGNDEnable = 1;%%on off switch-----This is for perodic GND
        MiddleElementEliminateEnable = 1;%%on off switch----For installing Pole structre
        MiddleCirculeElementEliminateEnable = 1;%%on off switch----For elimilate mutual coulping, nearby 4 element will me disappear 
                                                %MiddleCirculeElementEliminateEnable
                                                %has to be on with
                                                %MiddleElementEliminateEnable
                                                %at the same time 
        CableAddOnEnable = 0;  
        SupportAddOnEnable = 0;
        DirectorSet = 0;
        ChangeGNDIslandShape = 0;
        IsolationBladeEnable = 0;
        TripletTriangle = 0;
        %RealisticSimulation = 0;

   %%casseopeia setting
        f =2.45e9;
        c=3e11;
        WL=c/f;
        gap = 1; % for large structure the gap cant smaller than 1
        
        
        LN = 1; %24
        LS = 100; %% the negative sign is to controll the structure direction
        invoke(mws,'StoreParameter','LS',LS); 

        UN = 1;%13%<------- warining for even, odd number!!!
        TLUN = UN;
        invoke(mws,'StoreParameter','UN',UN);
        USpa = 100; %% same here, you can just add '- sign to controll the direction' 
        invoke(mws,'StoreParameter','USpa',USpa);
        UCSpac = WL/8/cosd(30);

        EN = 1;
        ENL = 26.5;
        
        GNDx = 80;%*UN;
        GNDy = 120;
        GNDz = 20;
        invoke(mws,'StoreParameter','GNDx',GNDx);
        invoke(mws,'StoreParameter','GNDy',GNDy);
        invoke(mws,'StoreParameter','GNDz',GNDz);

 %% element setting 
 fprintf('[%s] Creating element ... \n', datestr(now,'HH:MM:SS'));
    %##---set ground plane
        Name = 'Groundplane';
        component = 'GND';
         RunJobID = CstPLAlossy(mws,HistoryEnable,RunJobID)
%         RunJobID = CstCopperPureLossy(mws,HistoryEnable,RunJobID);
%         material = "Copper (pure)";
        material = 'PEC';%'PLA (lossy)';%
%        RunJobID = CstBoroFloat33(mws,HistoryEnable,RunJobID);
%        material = 'Schott BOROFLOAT 33';
        if  UnitcellGNDEnable == 1;
            Xrange = ["-GNDx/2" "GNDx/2"];%[-WL/4 WL/4];
            Yrange = ["-GNDy/2" "GNDy/2"];%[-WL/4 WL/4];
            Zrange = ["-GNDz/2" "GNDz/2"];%[0 0];%[0 1];
            RunJobID = Cstbrick(mws, Name, component, material, Xrange, Yrange, Zrange,HistoryEnable,RunJobID);
            GNDNaming(1,:) = string('Groundplane');
            StrGNDNaming(1,:) =string('GND:Groundplane');
        
        else
            Xrange = ["-USpa" "GNDx"];
            Yrange = ["-GNDy" "USpa"];
            Zrange = ["-GNDz/2" "GNDz/2"];%[0 1];
            RunJobID = Cstbrick(mws, Name, component, material, Xrange, Yrange, Zrange,HistoryEnable,RunJobID);
            GNDName = string([component ':' Name]);
        end

    %##---set MS line 
        Name = 'MS_line';
        component = 'Layer';
       material = 'PEC';
       invoke(mws,'StoreParameter','MTLx',1.5);
       invoke(mws,'StoreParameter','MSz',2);
       invoke(mws,'StoreParameter','Slotdepth',3.96);
       %invoke(mws,'StoreParameter','Msgap',1);
        Xrange = ["-MTLx/2" "MTLx/2"];
        Yrange = [0 0];
        Zrange = ["-MSz-(GNDz/2)-Slotdepth-3" "3.5"];%[0 1];

        RunJobID = Cstbrick(mws, Name, component, material, Xrange, Yrange, Zrange,HistoryEnable,RunJobID);
   %## ---  set MS WL/2 line 
  
   RunJobID = CstPickFace(mws,"Layer:MS_line",3,HistoryEnable,RunJobID);
   RunJobID = CstPickEdge(mws,"Layer:MS_line",2,HistoryEnable,RunJobID)
   mws.invoke('AddToHistory', ['AlignWCSWithEdgeandLocation_' num2str(RunJobID)],[sprintf('WCS.AlignWCSWithSelected "EdgeAndFace"')]);
    invoke(mws,'StoreParameterWithDescription','XwidthMS',6,'half wavelength matching line in Xdirection');
    invoke(mws,'StoreParameterWithDescription','ZHeightMS1st',1,'half wavelength matching line in Zdirection first stage');
    invoke(mws,'StoreParameterWithDescription','ZHeightMS2nd',3.8,'half wavelength matching line in Zdirection second stage');
    invoke(mws,'StoreParameterWithDescription','ZHeightMS3rd',6.6,'half wavelength matching line in Zdirection third stage');
    invoke(mws,'StoreParameterWithDescription','ZHeightMS4th',9.4,'half wavelength matching line in Zdirection 4 stage');
    invoke(mws,'StoreParameterWithDescription','ZHeightMS5th',15.4,'half wavelength matching line in Zdirection 5 stage');
   TestCo1= [ "0"   "0"   "-XwidthMS" "-XwidthMS" "XwidthMS" "XwidthMS" "-XwidthMS" "-XwidthMS" "0" "0";
              "0"   "-ZHeightMS1st"  "-ZHeightMS1st"  "-ZHeightMS2nd"  "-ZHeightMS2nd"  "-ZHeightMS3rd"  "-ZHeightMS3rd"   "-ZHeightMS4th"   "-ZHeightMS4th"  "-ZHeightMS5th"  ];
             %[  0     0     -6       -6      6      6      -6     -6      0    0;
             %  0    -1    -1     -3.8     -3.8   -6.6   -6.6   -9.4  -9.4 -15.4]; %(U,V)
              RunJobID = CstDefine2DCurve(mws, "Curve","Curve 1", TestCo1(1,:), TestCo1(2,:),HistoryEnable,RunJobID);
             
             
              Name = 'Strip';
              component = 'Support Structure';
              material = 'PEC';
              Curve ='Curve 1';
              %Extrude the 2D pattern(length of L channel!)
             RunJobID = CstTraceFromCurve(mws, Name,"Layer", Curve,"PEC", 0,"MTLx",HistoryEnable,RunJobID)
    RunJobID = CstActivateLocalWCS(mws,[0 0 1],[0 0 0],[1 0 0],0,HistoryEnable,RunJobID);

    %##---set upper Front patch  
        Name = 'Patch';
        component = 'Layer';
       invoke(mws,'StoreParameter','PLx',20);
       invoke(mws,'StoreParameter','PLz',33);
       invoke(mws,'StoreParameterWithDescription','PLO',4.2,char(["patchLength toward feed optmise"]));
       Xrange = ["-PLx/2" "PLx/2"];
       Yrange = [0 0];
       Zrange = ["MSz+(GNDz/2)+PLO" "MSz+PLz+(GNDz/2)"];%[0 1];
       RunJobID = Cstbrick(mws, Name, component, material, Xrange, Yrange, Zrange,HistoryEnable,RunJobID);

    %##---set lower front patch  
        Name = 'Patch';
        component = 'Layer';
        RunJobID = CstRotate(mws,"Layer:Patch",[0 0 0],[180 0 0],"true",1,HistoryEnable,RunJobID);
        

      %##---set upper Back patch  
        Name = 'BackPatch';
        component = 'Layer';
        invoke(mws,'StoreParameter','Dx',20);
        invoke(mws,'StoreParameter','Dy',0.6);
        invoke(mws,'StoreParameter','Dz',"MSz+Plz+(GNDz/2)");
        Xrange = ["-PLx/2" "PLx/2"];
        Yrange = ["-Dy" "-Dy"];
        Zrange = ["22" "45"];%[0 1];
        RunJobID = Cstbrick(mws, Name, component, material, Xrange, Yrange, Zrange,HistoryEnable,RunJobID);

    %##---set lower back patch  
        RunJobID = CstRotate(mws,"Layer:BackPatch",[0 0 0],[0 180 0],"true",1,HistoryEnable,RunJobID);
       

    %##---set Dielectric 
        %RunJobID = CstFR4lossfree(mws,HistoryEnable,RunJobID);
         RunJobID = CstFR4lossy(mws,HistoryEnable,RunJobID);
         material = 'FR-4 (lossy)';%'FR-4 (loss free)';
%        RunJobID = CstBoroFloat33(mws,HistoryEnable,RunJobID);
%        material = 'Schott BOROFLOAT 33';
         Name = 'DiEle';
         component = 'Dielectric';
       
         Xrange = ["-Dx/2" "Dx/2"];
         Yrange = ["-Dy" 0];
         Zrange = ["-Dz" "Dz"];%[0 1];
         RunJobID = Cstbrick(mws, Name, component, material, Xrange, Yrange, Zrange,HistoryEnable,RunJobID);
        
     %##---set Background GND 
        Name = 'BackGND';
%       material = "Copper (pure)";
        material = "PEC";
        component = 'Layer';
        invoke(mws,'StoreParameter','BGz',2.6);
        Xrange = ["-Dx/2" "Dx/2"];
        Yrange = ["-Dy" "-Dy"];
        Zrange = ["-16-BGz" "16+BGz"];%[0 1];
        RunJobID = Cstbrick(mws, Name, component, material, Xrange, Yrange, Zrange,HistoryEnable,RunJobID);

      %##---set Matching  Tub 
        Name = 'Matchsub';
%       material = "Copper (pure)";
        material = "PEC";
        component = 'Layer';
        invoke(mws,'StoreParameter','Balx',3);
        invoke(mws,'StoreParameter','Balz',3.64);
        Xrange = ["-Balx" "Balx"];
        Yrange = ["0" "0"];
        Zrange = ["-6" "-Balz-6"];%[0 1];
        RunJobID = Cstbrick(mws, Name, component, material, Xrange, Yrange, Zrange,HistoryEnable,RunJobID);


     %##---addon-module set director    
        if DirectorSet == 1
            Name = 'Director1';
            component = 'Director';
            OuterRadius = 2;
            invoke(mws,'StoreParameter','OuterRadius',OuterRadius);
            FD = 20;
            BD =20 ;
            invoke(mws,'StoreParameterWithDescription','FD',FD,'Front Director length');
            invoke(mws,'StoreParameterWithDescription','BD',BD,'Back Director length');
            InnerRadius = 0;
            Xcenter = 0;
            Ycenter = 50;
            Zrange = [ "(GNDz/2)" "(GNDz/2)+FD"];
            RunJobID = Cstcylinder(mws, Name, component, material, 'Z', "OuterRadius", InnerRadius, Xcenter, Ycenter, Zrange,HistoryEnable,RunJobID);
            
            Name = 'Director2';
            Xcenter = 0;
            Ycenter = 50;
            Zrange = [ "-(GNDz/2)" "-(GNDz/2)-FD"];
            RunJobID = Cstcylinder(mws, Name, component, material, 'Z', "OuterRadius", InnerRadius, Xcenter, Ycenter, Zrange,HistoryEnable,RunJobID);
            
            Name = 'Director3';
            Xcenter = 0;
            Ycenter = -50;
            Zrange = [ "-(GNDz/2)" "-(GNDz/2)-BD"];
            RunJobID = Cstcylinder(mws, Name, component, material, 'Z', "OuterRadius", InnerRadius, Xcenter, Ycenter, Zrange,HistoryEnable,RunJobID);
            
            Name = 'Director4';
            Xcenter = 0;
            Ycenter = -50;
            Zrange = [ "(GNDz/2)" "(GNDz/2)+BD"];
            RunJobID = Cstcylinder(mws, Name, component, material, 'Z', "OuterRadius", InnerRadius, Xcenter, Ycenter, Zrange,HistoryEnable,RunJobID);
        end

    

     if DirectorSet == 1
%        component1 = 'GND:Groundplane'
         component1 = 'Director:Director1';
         component2 = 'Director:Director2';
         RunJobID = CstAdd(mws,component1,component2,HistoryEnable,RunJobID);
         
%        JobID = CstAdd(mws,component1,component2,HistoryEnable,RunJobID)
         component2 = 'Director:Director3';
         RunJobID = CstAdd(mws,component1,component2,HistoryEnable,RunJobID);
         component2 = 'Director:Director4';
         RunJobID = CstAdd(mws,component1,component2,HistoryEnable,RunJobID);
%         
     end

     %hole in ground plane setting
      Name = 'hole';
      component = 'subtract';
      material = 'PEC';%'FR-4 (loss free)';
      invoke(mws,'StoreParameter','HoleGapx',2);
      invoke(mws,'StoreParameter','HoleGapy',2);
      Xrange = ["-(Dx+HoleGapx)/2" "(Dx+HoleGapx)/2"];
      Yrange = ["-Dy-(HoleGapy/2)" "(HoleGapy/2)"];
      Zrange = ["-(GNDz/2)" "(GNDz/2)"];
      RunJobID = Cstbrick(mws, Name, component, material, Xrange, Yrange, Zrange,HistoryEnable,RunJobID);

     %specialise patch dipole setting ---setting slot

      Name = 'Slot';
      component = 'subtract';
      invoke(mws,'StoreParameterWithDescription','slotdepthInPatch',3.9,'The slot depth which go inside patch');
      material = 'PEC';%'FR-4 (loss free)';
      Xrange = ["-4.8" "4.8"];
      Yrange = ["0" "0"];
      Zrange = ["-15-slotdepthInPatch" "-15"];
      RunJobID =  Cstbrick(mws, Name, component, material, Xrange, Yrange, Zrange,HistoryEnable,RunJobID);

       RunJobID = CstRotate(mws,"subtract:Slot",[0 0 0],[180 0 0],"true",1,HistoryEnable,RunJobID);
       component1 = 'subtract:Slot';
       component2 = 'subtract:Slot_1';
      

       RunJobID  = CstSubtract(mws,"Layer:Patch_1","subtract:Slot",HistoryEnable,RunJobID);
       RunJobID  = CstSubtract(mws,"Layer:Patch","subtract:Slot_1",HistoryEnable,RunJobID);

     %specialise patch dipole setting---- Set triangle
        RunJobID = CstPickFace(mws, "Dielectric:DiEle", "5" ,HistoryEnable,RunJobID);
        RunJobID = CstAlignWCSwithFace(mws,HistoryEnable,RunJobID)

      TestCo1= [  -10     7    -10       -10     ;
                   45    45   22.5      45  ]; %(U,V)
              RunJobID = CstDefine2DCurve(mws, "Curve","Curve 1", TestCo1(1,:), TestCo1(2,:),HistoryEnable,RunJobID);
             
             
  %Draw a line in a plane
              Name = 'subtractTriangle ';
              component = 'subtract';
              material = 'PEC';
              Curve ='Curve 1';
              thickness = 'Dy';
              Twistangle = 0;
              Taperangle =0 ;
              
              %Extrude the 2D pattern(length of L channel!)
              RunJobID = CstExtrudeProfile(mws, Name, component, material, thickness, Twistangle, Taperangle,Curve,HistoryEnable,RunJobID);
  
   RunJobID = CstRotate(mws,"subtract:subtractTriangle",[0 0 0],[0 0 180],"true",1,HistoryEnable,RunJobID);
   
  %Subtract everything related in Patch 
     
      Subtract_1 = "Dielectric:DiEle";
      Subtract_2 = "subtract:subtractTriangle";
      Subtract_3 = "Layer:BackPatch_1";
      Subtract_4 = "Layer:BackPatch";
      Subtract_5 = "subtract:subtractTriangle_1";
      
      mws.invoke('AddToHistory', ['DeleteCommand_' num2str(RunJobID)],[...
            sprintf('With Solid \n')...
            sprintf('.Version 10 \n')...
            sprintf('.Insert "%s" ,"%s"\n',Subtract_1,Subtract_2)...
            sprintf('.Insert "%s","%s" \n',Subtract_1,Subtract_5)...
            sprintf('.Insert "%s","%s" \n',Subtract_3,Subtract_2)...
            sprintf('.Insert "%s" ,"%s"\n',Subtract_4,Subtract_5)...
            sprintf('.Version 1 \n')...
            sprintf('End With')
            ]);
      RunJobID  = CstSubtract(mws,"Layer:Patch_1","subtract:subtractTriangle",HistoryEnable,RunJobID);
      RunJobID  = CstSubtract(mws,"Layer:Patch","subtract:subtractTriangle_1",HistoryEnable,RunJobID);
      
      

   % plane reset
   RunJobID = CstActivateLocalWCS(mws,[0 0 1],[0 0 0],[1 0 0],0,HistoryEnable,RunJobID);

     %##---group all element together expect dielectric
     component1 = 'Layer:Patch';
    component2 = 'Layer:Patch_1';
    component3 = 'Layer:BackGND';
    component4 = 'Layer:MS_line';
    component5 = 'Layer:BackPatch';
    component6 = 'Layer:BackPatch_1';
    component7 = 'Layer:Matchsub';
    component8 = 'Layer:Strip';
    RunJobID = CstAdd(mws,component1,component2,HistoryEnable,RunJobID);
    RunJobID = CstAdd(mws,component1,component3,HistoryEnable,RunJobID);
    RunJobID = CstAdd(mws,component1,component4,HistoryEnable,RunJobID);
    RunJobID = CstAdd(mws,component1,component5,HistoryEnable,RunJobID);
    RunJobID = CstAdd(mws,component1,component6,HistoryEnable,RunJobID);
    RunJobID = CstAdd(mws,component1,component7,HistoryEnable,RunJobID);
    RunJobID = CstAdd(mws,component1,component8,HistoryEnable,RunJobID);

    %port setting
    %##---set port
        PortNumber = 1;
        SetP1 = [0 "-Dy" 0];
        SetP2 = [0 0 0];
        impedance = 50;
        RunJobID = CstDiscretePort(mws,PortNumber,SetP1,SetP2,impedance,HistoryEnable,RunJobID);

    %add-on module--Cable
    if CableAddOnEnable == 1
          %##---Create Connector
            Name = 'Connector';
            component = 'ExternalMaterial';
            OuterRadius = 2;
            invoke(mws,'StoreParameter','OuterRadius',OuterRadius);
            InnerRadius = 0;
            Xcenter = 0;
            Zcenter = string(strcat('GNDz/2+',num2str(9)));
            Yrange =  ["-Dy" "-Dy-10"];
            RunJobID = Cstcylinder(mws, Name, component, material, 'Y', "OuterRadius", InnerRadius, Xcenter, Zcenter, Yrange,HistoryEnable,RunJobID);
            
            %##---Change local WCS plane
                component1 = string([component ':' Name]);
                RunJobID = CstPickCircleCenterPoint(mws,component1,1,HistoryEnable,RunJobID);
                RunJobID = CstAlignWCSwithPoint(mws,HistoryEnable,RunJobID);
                    
          %##---Create cable
            Name = 'Cable';
            component = 'ExternalMaterial';
            InnerRadius = 0;
            Xcenter = 0;
            Zcenter = 0;%string(strcat('GNDz/2+',num2str(9)));
            Yrange =  ["0" "-10"];
            RunJobID = Cstcylinder(mws, Name, component, material, 'Y', "OuterRadius-1", InnerRadius, Xcenter, Zcenter, Yrange,HistoryEnable,RunJobID);

            %##---Change local WCS plane
                component1 = string([component ':' Name]);
                RunJobID = CstPickCircleCenterPoint(mws,component1,1,HistoryEnable,RunJobID);
                RunJobID = CstAlignWCSwithPoint(mws,HistoryEnable,RunJobID);

            %##---Create 90 degree turn cable
            Name = 'DownTurn';
            component = 'ExternalMaterial';
            InnerRadius = 0;
            Xcenter = 0;
            Zcenter = 0;%string(strcat('GNDz/2+',num2str(9)));
            Yrange =  ["0" "-5"];
            RunJobID = Cstcylinder(mws, Name, component, material, 'Y', "OuterRadius-1", InnerRadius, Xcenter, Zcenter, Yrange,HistoryEnable,RunJobID);
            
            %##---Benting
            component1 = string([component ':' Name]);
            RunJobID = CstRotateWCS(mws,"w","270",HistoryEnable,RunJobID);
            RunJobID = CstRotateWCS(mws,"u","180",HistoryEnable,RunJobID);
            RunJobID = CstCylinderBending(mws,component1,"90",HistoryEnable,RunJobID);

             %##---Change local WCS plane
             RunJobID = CstPickCircleCenterPoint(mws,component1,1,HistoryEnable,RunJobID);
             RunJobID = CstAlignWCSwithPoint(mws,HistoryEnable,RunJobID);
             
             %##---Mirror the half part
             RunJobID = CstMirror(mws,component1,"True",1,HistoryEnable,RunJobID);
             RunJobID = CstRotate(mws,string([char(component1) '_1']),[0 0 0],[0 0 180],"False",1,HistoryEnable,RunJobID);

             %##---Change local WCS plane
             RunJobID = CstPickCircleCenterPoint(mws,string([char(component1) '_1']),2,HistoryEnable,RunJobID);
             RunJobID = CstAlignWCSwithPoint(mws,HistoryEnable,RunJobID);

             %##---Create cable
             Name = 'Cable2';
             component = 'ExternalMaterial';
             InnerRadius = 0;
             Xcenter = 0;
             Zcenter = 0;%string(strcat('GNDz/2+',num2str(9)));
            Yrange =  ["0" "40"];
            RunJobID = Cstcylinder(mws, Name, component, material, 'X', "OuterRadius-1", InnerRadius, Xcenter, Zcenter, Yrange,HistoryEnable,RunJobID);

            %##---Change local WCS plane
            component1 = string([component ':' Name]);
             RunJobID = CstPickCircleCenterPoint(mws,component1,2,HistoryEnable,RunJobID);
             RunJobID = CstAlignWCSwithPoint(mws,HistoryEnable,RunJobID);

             %##---Create 180 degree turn cable
            Name = 'DownTurn2';
            component = 'ExternalMaterial';
            InnerRadius = 0;
            Xcenter = 0;
            Zcenter = 0;%string(strcat('GNDz/2+',num2str(9)));
            Yrange =  ["0" "10"];
            RunJobID = Cstcylinder(mws, Name, component, material, 'X', "OuterRadius-1", InnerRadius, Xcenter, Zcenter, Yrange,HistoryEnable,RunJobID);

             %##---Benting
           component1 = string([component ':' Name]);
           RunJobID = CstCylinderBending(mws,component1,"180",HistoryEnable,RunJobID);

            %##---Change local WCS plane
             RunJobID = CstPickCircleCenterPoint(mws,component1,2,HistoryEnable,RunJobID);
             RunJobID = CstAlignWCSwithPoint(mws,HistoryEnable,RunJobID);

           %##---hole
            Name = 'HoleForCable';
            component = 'ExternalMaterial';
            InnerRadius = 0;
            Xcenter = 0;
            Zcenter = 0;%string(strcat('GNDz/2+',num2str(9)));
            Yrange =  ["0" "-40"];
            RunJobID = Cstcylinder(mws, Name, component, material, 'X', "OuterRadius", InnerRadius, Xcenter, Zcenter, Yrange,HistoryEnable,RunJobID);
            
            component1 = string([component ':' Name]);
            RunJobID  = CstSubtract(mws,StrGNDNaming, component1,HistoryEnable,RunJobID);

            %##---cable 3 
             Name = 'Cable3';
             component = 'ExternalMaterial';
             InnerRadius = 0;
             Xcenter = 0;
             Zcenter = 0;%string(strcat('GNDz/2+',num2str(9)));
            Yrange =  ["0" "-40"];
            RunJobID = Cstcylinder(mws, Name, component, material, 'X', "OuterRadius-1", InnerRadius, Xcenter, Zcenter, Yrange,HistoryEnable,RunJobID);
             
            %##---Reset WCS
            RunJobID = CstActivateLocalWCS(mws,[0 0 1],[0 0 0],[1 0 0],0,HistoryEnable,RunJobID)
            
            %##---adding everything together
            component1 = "ExternalMaterial:Cable";
            component2 = "ExternalMaterial:Cable2";
            component3 = "ExternalMaterial:Cable3"; 
            component4 = "ExternalMaterial:Connector";
            component5 = "ExternalMaterial:DownTurn";
            component6 = "ExternalMaterial:DownTurn2";
            component7 = "ExternalMaterial:DownTurn_1";
            RunJobID = CstAdd(mws,component1,component2,HistoryEnable,RunJobID);
            RunJobID = CstAdd(mws,component1,component3,HistoryEnable,RunJobID);
            RunJobID = CstAdd(mws,component1,component4,HistoryEnable,RunJobID);
            RunJobID = CstAdd(mws,component1,component5,HistoryEnable,RunJobID);
            RunJobID = CstAdd(mws,component1,component6,HistoryEnable,RunJobID);
            RunJobID = CstAdd(mws,component1,component7,HistoryEnable,RunJobID);

            %##---adding cable with patch
            component8 = 'Layer:Patch';
            RunJobID = CstAdd(mws,component8,component1,HistoryEnable,RunJobID);

      end
     %add-on module--Support
          if SupportAddOnEnable == 1
              if CableAddOnEnable == 1
                  pickFaceNum =7
              else
                  pickFaceNum =4
              end
              RunJobID = CstPickFace(mws,"GND:Groundplane",pickFaceNum,HistoryEnable,RunJobID);
              RunJobID = CstAlignWCSwithFace(mws,HistoryEnable,RunJobID);
              RunJobID = CstMoveLocalWCS(mws,0,0,20,HistoryEnable,RunJobID);%u,v,w
              RunJobID = CstRotateWCS(mws,"u",180,HistoryEnable,RunJobID)

               if CableAddOnEnable == 1
                   RunJobID = CstRotateWCS(mws,"w",-90,HistoryEnable,RunJobID)
               else
                   RunJobID = CstRotateWCS(mws,"w",-90,HistoryEnable,RunJobID)
                   RunJobID = CstRotateWCS(mws,"v",180,HistoryEnable,RunJobID)
                   RunJobID = CstRotateWCS(mws,"u",180,HistoryEnable,RunJobID)
               end
              
              Lthick = 2;% l channel thickness
              
              TestCo1= [  -2     -2        -10-Lthick      -10-Lthick       -10    -10     -2 ;
                         -60 -60-Lthick  -60-Lthick         -42           -42      -60   -60]; %(U,V)
              RunJobID = CstDefine2DCurve(mws, "Curve","Curve 1", TestCo1(1,:), TestCo1(2,:),HistoryEnable,RunJobID);
             
              RunJobID = CstAluminiumlossy(mws,HistoryEnable,RunJobID);
              Name = 'L_channel_R';
              component = 'Support Structure';
              material = 'Aluminum';
              Curve ='Curve 1';
              thickness = -1100;
              Twistangle = 0;
              Taperangle =0 ;
              %Extrude the 2D pattern(length of L channel!)
              RunJobID = CstExtrudeProfile(mws, Name, component, material, thickness, Twistangle, Taperangle,Curve,HistoryEnable,RunJobID);
           
              TestCo2= [  -2      -2         -10-Lthick    -10-Lthick      -10   -10       -2  ;
                          60  60+Lthick   60+Lthick         42             42      60       60]; %(U,V)
              RunJobID = CstDefine2DCurve(mws, "Curve","Curve 1", TestCo2(1,:), TestCo2(2,:),HistoryEnable,RunJobID);
              
              %Draw a line in a plane
              Name = 'L_channel_L';
              component = 'Support Structure';
              material = 'Aluminum';
              Curve ='Curve 1';
              thickness = 1100;
              Twistangle = 0;
              Taperangle =0 ;
              
              %Extrude the 2D pattern(length of L channel!)
              RunJobID = CstExtrudeProfile(mws, Name, component, material, thickness, Twistangle, Taperangle,Curve,HistoryEnable,RunJobID);
              
%               RunJobID = CstAdd(mws,"GND:Groundplane","Support Structure:L channel L",HistoryEnable,RunJobID);
%               RunJobID = CstAdd(mws,"GND:Groundplane","Support Structure:L channel R",HistoryEnable,RunJobID);

              % reset local WCS
              RunJobID = CstActivateLocalWCS(mws,[0 0 1],[0 0 0],[1 0 0],0,HistoryEnable,RunJobID);

              LchannelNaming(1,:) = ["L_channel_L" "L_channel_R"];
              StrLchanNam(1,:) = ["Support Structure:L_channel_L" "Support Structure:L_channel_R"];

              
          end

      %%%-----add-on module-----isolation blade
        if IsolationBladeEnable == 1;
           Name = 'Blade_1T2';
           component ='Isolation';
           material = 'PEC';
           invoke(mws,'StoreParameterWithDescription','BLx',GNDx,'Blade length in X direction');
           invoke(mws,'StoreParameterWithDescription','BLy',GNDy,'Blade width in Y direction');
           invoke(mws,'StoreParameterWithDescription','BLz',3,'Blade gap in Z direction');
           %invoke(mws,'StoreParameter','Msgap',1);
            Xrange = ["-BLx/2" "1020"];%[-WL/4 WL/4];
            Yrange = ["-BLy/2" "BLy/2"];%[-WL/4 WL/4];
            Zrange = ["Dz+BLz" "Dz+BLz"];%[0 1];
            RunJobID = Cstbrick(mws, Name, component, material, Xrange, Yrange, Zrange,HistoryEnable,RunJobID);

            BladeNaming(1,:) = "Blade_1T2";
            StrBladNam(1,:) = "Isolation:Blade_1T2";
            
            %-----additional blade modification
          
            if  MiddleElementEliminateEnable == 1 % set structure centre for rotation 
                ii = [1:UN];
                if MiddleCirculeElementEliminateEnable == 1;
                    SetOrigin = "(USpa*(UN+2))/2";
                else
                    SetOrigin = "(USpa*(UN)-20)/2";
                end
            else
                ii = [1:floor(UN/2) ceil(UN/2)+1:UN];% we dont need middle unitcell so new number sequence create
                SetOrigin = "(USpa*(UN-1))/2";
            end
            
            RunJobID = CstRotate(mws,StrBladNam,[SetOrigin 0 0],[0 0 (180/LN)/2],"true",1,HistoryEnable,RunJobID);
            RunJobID = CstRotate(mws,StrBladNam,[SetOrigin 0 0],[0 0 -(180/LN)/2],"true",1,HistoryEnable,RunJobID);

            RunJobID = CstAdd(mws,StrBladNam,"Isolation:Blade_1T2_1",HistoryEnable,RunJobID);
            RunJobID = CstAdd(mws,StrBladNam,"Isolation:Blade_1T2_2",HistoryEnable,RunJobID);
        end
  
 %%%-----add-on module-----TripletTriangle rotation
  if TripletTriangle==1
      FlipAng = 270;
    %patch rotate
        component1 = "Layer:Patch";
        RunJobID= CstRotate(mws, component1,[0 0 1],[0 0 FlipAng],"False",1,HistoryEnable,RunJobID);
    %hole rotate
        component2 = "subtract:hole";
        RunJobID= CstRotate(mws, component2,[0 0 1],[0 0 FlipAng],"False",1,HistoryEnable,RunJobID);
    %Dielectric rotate
        component3 = "Dielectric:DiEle";
        RunJobID =CstRotate(mws, component3,[0 0 1],[0 0 FlipAng],"False",1,HistoryEnable,RunJobID);
    %portNumer Rotate
        PortNumber = "port1"; 
        RunJobID = CstPortRotate(mws,PortNumber,[0 0 1],[0 0 FlipAng],"False",1,HistoryEnable,RunJobID);
  end
        

 %% unitcell setting ---port 1-3
 fprintf('[%s] Creating First Unitcell ... \n', datestr(now,'HH:MM:SS'));
        US = WL/4; % unitcell Spacing
        invoke(mws,'StoreParameter','US',US);
      %Structure setting 
        %##------MicroStrip
        Name = 'Patch';
        component = 'Layer';
        %#----MicroStrip-Built
        if EN == 2
            MPole = string([component ':' Name]);
            RunJobID = CstTransform(mws,MPole,[0 WL/8 0],"false",1,HistoryEnable,RunJobID);
            RunJobID = CstRotate(mws,MPole,[0 0 0],[0 0 180],"true",1,HistoryEnable,RunJobID);
        elseif EN == 3
            MPole = string([component ':' Name]);
            RunJobID = CstTransform(mws,MPole,["(US/2)/cosd(30)" 0 0],"false",1,HistoryEnable,RunJobID);
            RunJobID = CstRotate(mws,MPole,[0 0 0],[0 0 120],"true",2,HistoryEnable,RunJobID);
        end

        %#-----MicroStrip-Rename
        RunJobID = CstRename(mws,[component ':' Name],"L1U1E1",HistoryEnable,RunJobID);
        if EN == 2 
          RunJobID = CstRename(mws,[component ':' Name '_1'],"L1U1E2",HistoryEnable,RunJobID);
          LayerNaming(1,:) = ["L1U1E1" "L1U1E2"];
          StrTransNam(1,:) = ["Layer:L1U1E1" "Layer:L1U1E2"];
        elseif EN == 3
          RunJobID = CstRename(mws,[component ':' Name '_1'],"L1U1E2",HistoryEnable,RunJobID);
          RunJobID = CstRename(mws,[component ':' Name '_2'],"L1U1E3",HistoryEnable,RunJobID);
          LayerNaming(1,:) = ["L1U1E1" "L1U1E2" "L1U1E3"];
          StrTransNam(1,:) = ["Layer:L1U1E1" "Layer:L1U1E2" "Layer:L1U1E3"];
        else
          LayerNaming(1,:) = ["L1U1E1"];
          StrTransNam(1,:) = ["Layer:L1U1E1"];
        end
        
        %##------Dielectric
        Name = 'DiEle';
        component = 'Dielectric';
        %#----Dielectric-Built
        DiEle = string([component ':' Name]);
        if EN == 2 
            RunJobID = CstTransform(mws,DiEle,[0 WL/8 0],"false",1,HistoryEnable,RunJobID);
            RunJobID = CstRotate(mws,DiEle,[0 0 0],[0 0 180],"true",1,HistoryEnable,RunJobID);
        elseif EN == 3
            RunJobID = CstTransform(mws,DiEle,["(US/2)/cosd(30)" 0 0],"false",1,HistoryEnable,RunJobID);
            RunJobID = CstRotate(mws,DiEle,[0 0 0],[0 0 120],"true",2,HistoryEnable,RunJobID);
        end

        %#-----Dielectric-Rename
        RunJobID = CstRename(mws,[component ':' Name],"DiEle_L1U1E1",HistoryEnable,RunJobID);
        if EN == 2 
          RunJobID = CstRename(mws,[component ':' Name '_1'],"DiEle_L1U1E2",HistoryEnable,RunJobID);
          DiLayerNaming(1,:) = [string([Name '_L1U1E1']) string([Name '_L1U1E2'])];
          DiStrTransNam(1,:) = ["Dielectric:DiEle_L1U1E1" "Dielectric:DiEle_L1U1E2"];
        elseif EN == 3
          RunJobID = CstRename(mws,[component ':' Name '_1'],"DiEle_L1U1E2",HistoryEnable,RunJobID);
          RunJobID = CstRename(mws,[component ':' Name '_2'],"DiEle_L1U1E3",HistoryEnable,RunJobID);
          DiLayerNaming(1,:) = [string([Name '_L1U1E1']) string([Name '_L1U1E2']) string([Name '_L1U1E3'])];
          DiStrTransNam(1,:) = ["Dielectric:DiEle_L1U1E1" "Dielectric:DiEle_L1U1E2" "Dielectric:DiEle_L1U1E3"];
        else
          DiLayerNaming(1,:) = ["DiEle_L1U1E1"];
          DiStrTransNam(1,:) = ["Dielectric:DiEle_L1U1E1"];
        end  
        
        %##------hole
        if UnitcellGNDEnable == 1;
            Name = 'hole';
            component = 'subtract';
            HoleEle = string([component ':' Name]);
            if EN == 2 
                RunJobID = CstTransform(mws,HoleEle,[0 WL/8 0],"false",1,HistoryEnable,RunJobID);
                RunJobID = CstRotate(mws,HoleEle,[0 0 0],[0 0 180],"true",1,HistoryEnable,RunJobID);
                component1 = "GND:Groundplane";
                component2 = ["subtract:hole" "subtract:hole_1"];
                RunJobID  = CstSubtract(mws,component1,component2(1:2),HistoryEnable,RunJobID);
            elseif EN == 3
                RunJobID = CstTransform(mws,HoleEle,["(US/2)/cosd(30)" 0 0],"false",1,HistoryEnable,RunJobID);
                RunJobID = CstRotate(mws,HoleEle,[0 0 0],[0 0 120],"true",2,HistoryEnable,RunJobID);
                component1 = "GND:Groundplane";
                component2 = ["subtract:hole" "subtract:hole_1" "subtract:hole_2"];
                RunJobID = CstSubtract(mws,component1,component2(1:3),HistoryEnable,RunJobID);

            else
                component1 = "GND:Groundplane";
                component2 = "subtract:hole";
                RunJobID = CstSubtract(mws,component1,component2,HistoryEnable,RunJobID);
            end
        end

        %##-----GroundPlane-Rename
        if UnitcellGNDEnable == 1
            component = "GND";
            RunJobID = CstRename(mws,[char(component) ':' 'Groundplane'],['Groundplane_L1U1'],HistoryEnable,RunJobID);
            GNDNaming(1,:) = string(['Groundplane_L1U' num2str(1)]);
            StrGNDNaming(1,:) =string(['GND:Groundplane_L1U' num2str(1)]);
        else
%           RunJobID = CstRename(mws,[char(component) ':' 'Groundplane'],['Groundplane'],HistoryEnable,RunJobID);
        end

      %port setting
        if EN == 2
           RunJobID = CstPortTransform(mws,"port1",[0 WL/8 0],"false",1,HistoryEnable,RunJobID);
            %CstPortTransform(mws,"port1",[0 0 WL/2],"true",1)
           RunJobID = CstPortRotate(mws,"port1",[0 0 0],[0 0 180],"true",1,HistoryEnable,RunJobID);
            port = ["port1" "port2"];
        elseif EN == 3
            RunJobID = CstPortTransform(mws,"port1",["(US/2)/cosd(30)" 0 0],"false",1,HistoryEnable,RunJobID);
            %CstPortTransform(mws,"port1",[0 0 WL/2],"true",1)
            RunJobID = CstPortRotate(mws,"port1",[0 0 0],[0 0 120],"true",2,HistoryEnable,RunJobID);
            port = ["port1" "port2" "port3"];
        else
            port = ["port1"];
        end

    %#----Add-on moudle: Change groundplane shape 
     if ChangeGNDIslandShape == 1;
            mws.invoke('AddToHistory',['Activate local WCS' num2str(RunJobID)],[
                        sprintf(['WCS.ActivateWCS "local" '])]);

            mws.invoke('AddToHistory',['Align WCS with face' num2str(RunJobID)],[
                        sprintf(['Pick.ForceNextPick \n'...
                                 'Pick.PickFaceFromId "GND:Groundplane_L1U1", "7" \n'...
                                 'WCS.AlignWCSWithSelected "Face" \n' ...
                                ])]);
            mws.invoke('AddToHistory',['Store picked point 1' num2str( RunJobID)],[
                        sprintf(['Pick.NextPickToDatabase "1"  \n'...
                                 'Pick.PickEndpointFromId "GND:Groundplane_L1U1", "9" \n'...
                                ])]);
            mws.invoke('AddToHistory',['Store picked point 2' num2str( RunJobID)],[
                        sprintf(['Pick.NextPickToDatabase "2"  \n'...
                                 'Pick.PickEndpointFromId "GND:Groundplane_L1U1", "13" \n'...
                                ])]);
            mws.invoke('AddToHistory',['Store picked point 3' num2str( RunJobID)],[
                        sprintf(['Pick.NextPickToDatabase "3"  \n'...
                                 'Pick.PickEndpointFromId "GND:Groundplane_L1U1", "9" \n'...
                                ])]);
            mws.invoke('AddToHistory',['define curve polygon: curve1:polygon1' num2str( RunJobID)],[
                        sprintf(['With Polygon \n'... 
                                     '.Reset \n' ...
                                     '.Name "polygon1" \n'...
                                     '.Curve "curve1" \n'...
                                     '.Point "xp(1)", "yp(1)" \n'...
                                     '.LineTo "15", "-10" \n'...
                                     '.LineTo "15", "10" \n'...
                                     '.LineTo "xp(2)", "yp(2)" \n'...
                                     '.LineTo "xp(3)", "yp(3)" \n'...
                                     '.Create \n'...
                                'End With \n'...
                                ])]);
             mws.invoke('AddToHistory',['Store picked point 4' num2str( RunJobID)],[
                        sprintf(['Pick.NextPickToDatabase "4"  \n'...
                                 'Pick.PickEndpointFromId "GND:Groundplane_L1U1", "12" \n'...
                                ])]);
            mws.invoke('AddToHistory',['Store picked point 5' num2str( RunJobID)],[
                        sprintf(['Pick.NextPickToDatabase "5"  \n'...
                                 'Pick.PickEndpointFromId "GND:Groundplane_L1U1", "11" \n'...
                                ])]);
            mws.invoke('AddToHistory',['Store picked point 6' num2str( RunJobID)],[
                        sprintf(['Pick.NextPickToDatabase "6"  \n'...
                                 'Pick.PickEndpointFromId "GND:Groundplane_L1U1", "12" \n'...
                                ])]);
              mws.invoke('AddToHistory',['define curve polygon: curve1:polygon2' num2str( RunJobID)],[
                        sprintf(['With Polygon \n'... 
                                     '.Reset \n' ...
                                     '.Name "polygon2" \n'...
                                     '.Curve "curve1" \n'...
                                     '.Point "xp(4)", "yp(4)" \n'...
                                     '.LineTo "xp(5)", "yp(5)" \n'...
                                     '.LineTo "-15", "10" \n'...
                                     '.LineTo "-15", "-10" \n'...
                                     '.LineTo "xp(6)", "yp(6)" \n'...
                                     '.Create \n'...
                                'End With \n'...
                                ])]);

              %Extrude the 2D pattern(L GND hollow !)
              Name = 'solid1';
              component = 'subtract';
              material = 'PEC';
              Curve ='curve1:polygon1';
              thickness = GNDz;
              Twistangle = 0;
              Taperangle =0 ;
              
              RunJobID = CstExtrudeProfile(mws, Name, component, material, thickness, Twistangle, Taperangle,Curve,HistoryEnable,RunJobID);
              

              
              %Extrude the 2D pattern(R GND hollow !)
              Name = 'solid2';
              component = 'subtract';
              material = 'PEC';
              Curve ='curve1:polygon2';
              thickness = GNDz;
              Twistangle = 0;
              Taperangle =0 ;
              
              RunJobID = CstExtrudeProfile(mws, Name, component, material, thickness, Twistangle, Taperangle,Curve,HistoryEnable,RunJobID);
              
              % Subtract the remaining part
                RunJobID = CstSubtract(mws, "GND:Groundplane_L1U1", "subtract:solid1",HistoryEnable,RunJobID);
                RunJobID = CstSubtract(mws, "GND:Groundplane_L1U1","subtract:solid2",HistoryEnable,RunJobID);

            % reset local WCS
              RunJobID = CstActivateLocalWCS(mws,[0 0 1],[0 0 0],[1 0 0],0,HistoryEnable,RunJobID);
         end
    %##----add-on module---adding director in GNDplane
    if DirectorSet == 1  % have to put it in here otherwise the GND plane cutting will not work!
         component1 = 'Director:Director1';
         component2 =  StrGNDNaming(1,:);
         RunJobID = CstAdd(mws,component2,component1,HistoryEnable,RunJobID);
    end    

%% Layer setting --port 1-21
if UN>1
        %Structure setting 
        Layrep= UN-1;
        component = "Layer";
        Name = 'Patch';
        if  MiddleElementEliminateEnable == 1 %if middle pole has to be install on structure
            LayrepMod = (UN/2-1);
            if MiddleCirculeElementEliminateEnable == 1;
                LayrepModloopStart = (UN/2)+3;
                LayrepModloopEnd = UN+2;
            else
                LayrepModloopStart = (UN/2)+1;
                LayrepModloopEnd = UN;
            end
            RunJobID = CstTransform(mws,StrTransNam(1:EN),["USpa" "0" "0"],"true",LayrepMod,HistoryEnable,RunJobID);
            for i = LayrepModloopStart:LayrepModloopEnd
                RunJobID = CstTransform(mws,StrTransNam(1:EN),[string(['USpa*' num2str(i) '-20']) "0" "0"],"true",1,HistoryEnable,RunJobID);
            end
        else
            RunJobID = CstTransform(mws,StrTransNam(1:EN),["USpa" "0" "0"],"true",Layrep,HistoryEnable,RunJobID);
        end

        component = "Dielectric";
        if  MiddleElementEliminateEnable == 1 %if middle pole has to be install on structure
            RunJobID = CstTransform(mws,component,["USpa" "0" "0"],"true",LayrepMod,HistoryEnable,RunJobID);
            for i = LayrepModloopStart:LayrepModloopEnd
                RunJobID = CstTransform(mws,DiStrTransNam(1:EN),[string(['USpa*' num2str(i) '-20']) "0" "0"],"true",1,HistoryEnable,RunJobID);
            end
        else
             RunJobID = CstTransform(mws,component,["USpa" "0" "0"],"true",Layrep,HistoryEnable,RunJobID);
        end
        
            
        component = "GND";
        if UnitcellGNDEnable == 1
            %$$$$-----embedded module:middle pole structure1------$$$$$
            if MiddleElementEliminateEnable == 1
                RunJobID = CstTransform(mws,component,["USpa" "0" "0"],"true",LayrepMod,HistoryEnable,RunJobID);
                for i = LayrepModloopStart:LayrepModloopEnd
                    RunJobID = CstTransform(mws,StrGNDNaming(1),[string(['USpa*' num2str(i) '-20']) "0" "0"],"true",1,HistoryEnable,RunJobID);
                end
             
            else
                RunJobID = CstTransform(mws,component,["USpa" "0" "0"],"true",Layrep,HistoryEnable,RunJobID);
            end
        else
            %$$$$-----embedded module:middle pole structure2------$$$$$ 
            if MiddleElementEliminateEnable == 1
                RunJobID = CstTransform(mws,"subtract",["USpa" "0" "0"],"true",LayrepMod,HistoryEnable,RunJobID);%hole
                for i = LayrepModloopStart:LayrepModloopEnd
                    RunJobID = CstTransform(mws,"subtract:hole",[string(['USpa*' num2str(i)]) "0" "0"],"true",1,HistoryEnable,RunJobID);%hole
                end
            else
                RunJobID = CstTransform(mws,"subtract",["USpa" "0" "0"],"true",Layrep,HistoryEnable,RunJobID);%hole
            end
        end
      
      
       for i = 1:Layrep
           
            %#########-------------layer monopole  setting -------#########
            component = "Layer";
            RunJobID = CstRename(mws,[char(component) ':' 'L1U1E1' '_' num2str(i)],['L1U' num2str(i+1) 'E1'],HistoryEnable,RunJobID);
            fprintf('[%s] Renaming unitcell %d... \n', datestr(now,'HH:MM:SS'),i);

           if EN == 2
                RunJobID = CstRename(mws,[char(component) ':' 'L1U1E2' '_' num2str(i)],['L1U' num2str(i+1) 'E2'],HistoryEnable,RunJobID);
                LayerNaming(i+1,:)= [string(['L1U' num2str(i+1) 'E1']), string(['L1U' num2str(i+1) 'E2'])];
                StrTransNam(i+1,:)= [string([char(component) ':' char(['L1U' num2str(i+1) 'E1'])]) string([char(component) ':' char(['L1U' num2str(i+1) 'E2'])])] ;
           elseif EN == 3
                RunJobID = CstRename(mws,[char(component) ':' 'L1U1E2' '_' num2str(i)],['L1U' num2str(i+1) 'E2'],HistoryEnable,RunJobID);
                RunJobID = CstRename(mws,[char(component) ':' 'L1U1E3' '_' num2str(i)],['L1U' num2str(i+1) 'E3'],HistoryEnable,RunJobID);
                LayerNaming(i+1,:)= [string(['L1U' num2str(i+1) 'E1']), string(['L1U' num2str(i+1) 'E2']), string(['L1U' num2str(i+1) 'E3'])];
                StrTransNam(i+1,:)= [string([char(component) ':' char(['L1U' num2str(i+1) 'E1'])]) string([char(component) ':' char(['L1U' num2str(i+1) 'E2'])]) string([char(component) ':' char(['L1U' num2str(i+1) 'E3'])])] ;
           else
                LayerNaming(i+1,:)= [string(['L1U' num2str(i+1) 'E1'])];
                StrTransNam(i+1,:)= [string([char(component) ':' char(['L1U' num2str(i+1) 'E1'])])] ;  
           end


            %#########-------------layer Dielectric  setting -------#########
            component = "Dielectric";
            RunJobID = CstRename(mws,[char(component) ':DiEle_L1U1E1_' num2str(i)],['DiEle_L1U' num2str(i+1) 'E1'],HistoryEnable,RunJobID);
            fprintf('[%s] Renaming Dielectric %d... \n', datestr(now,'HH:MM:SS'),i);

           if EN == 2
                RunJobID = CstRename(mws,[char(component) ':' 'DiEle_L1U1E2' '_' num2str(i)],['DiEle_L1U' num2str(i+1) 'E2'],HistoryEnable,RunJobID);
                DiLayerNaming(i+1,:)= [string(['DiEle_L1U' num2str(i+1) 'E1']), string(['DiEle_L1U' num2str(i+1) 'E2'])];
                DiStrTransNam(i+1,:)= [string([char(component) ':' char(['DiEle_L1U' num2str(i+1) 'E1'])]) string([char(component) ':' char(['DiEle_L1U' num2str(i+1) 'E2'])])] ;
           elseif EN == 3
               RunJobID = CstRename(mws,[char(component) ':' 'DiEle_L1U1E2' '_' num2str(i)],['DiEle_L1U' num2str(i+1) 'E2'],HistoryEnable,RunJobID);
               RunJobID = CstRename(mws,[char(component) ':' 'DiEle_L1U1E3' '_' num2str(i)],['DiEle_L1U' num2str(i+1) 'E3'],HistoryEnable,RunJobID);
                DiLayerNaming(i+1,:)= [string(['DiEle_L1U' num2str(i+1) 'E1']), string(['DiEle_L1U' num2str(i+1) 'E2']), string(['DiEle_L1U' num2str(i+1) 'E3'])];
                DiStrTransNam(i+1,:)= [string([char(component) ':' char(['DiEle_L1U' num2str(i+1) 'E1'])]) string([char(component) ':' char(['DiEle_L1U' num2str(i+1) 'E2'])]) string([char(component) ':' char(['DiEle_L1U' num2str(i+1) 'E3'])])] ;

           else
                DiLayerNaming(i+1,:)= [string(['DiEle_L1U' num2str(i+1) 'E1'])];
                DiStrTransNam(i+1,:)= [string([char(component) ':' char(['DiEle_L1U' num2str(i+1) 'E1'])])] ;  
           end

             
            %#########-------------Layer GND setting -------#########
            if UnitcellGNDEnable == 1
                component = "GND";
                RunJobID = CstRename(mws,[char(component) ':' 'Groundplane_L1U1_' num2str(i)],['Groundplane_L1U' num2str(i+1)],HistoryEnable,RunJobID);
                GNDNaming(i+1,:) = ['Groundplane_L1U' num2str(i+1)];
                StrGNDNaming(i+1,:) =['GND:Groundplane_L1U' num2str(i+1)];
            end
         end
          
            

      %port setting
        if  MiddleElementEliminateEnable == 1
            RunJobID = CstPortTransform(mws,port,["USpa" "0" "0"],"true",LayrepMod,HistoryEnable,RunJobID);
            for i = LayrepModloopStart:LayrepModloopEnd
                RunJobID = CstPortTransform(mws,port(1:EN),[string(['USpa*' num2str(i) '-20']) "0" "0"],"true",1,HistoryEnable,RunJobID);
            end
        else
            RunJobID = CstPortTransform(mws,port(1:EN),["USpa" "0" "0"],"true",Layrep,HistoryEnable,RunJobID);
        end
         
        for i = 1: TLUN*EN
        port(i) = ['port' num2str(i)];
        end
end 
        %%%-----add-on module-----unitcell adjustment with variable optmisation

        UPy = zeros(1,UN);%[120 -120 240 60 -60 -240 120 -120];
        UPrx =zeros(1,UN);%[0 20 -20 0 0 20 -20 0];% rotation angle
        for i = 1:length(StrTransNam(1:UN))
            %%% Create Parameter
            positionx(i) = string(['UPx_' num2str(i)]);
            positiony(i) = string(['UPy_' num2str(i)]);
            positionRota(i) = string(['UPxRota_' num2str(i)]);
            invoke(mws,'StoreParameterWithDescription',char(positionx(i)),0,char(["The position for unitcell " num2str(i) " in x Direction"]));
            invoke(mws,'StoreParameterWithDescription',char(positiony(i)),UPy(i),char(["The position for unitcell " num2str(i) " in y Direction"]));
            invoke(mws,'StoreParameterWithDescription',char(positionRota(i)),UPrx(i),char(["The position for unitcell " num2str(i) " in x Rotation"]));

            %%% Moving patch antenna 
            RunJobID = CstTransform(mws,StrTransNam(i),[positionx(i) positiony(i) "0"],"false",1,HistoryEnable,RunJobID);
            RunJobID = CstTransform(mws,DiStrTransNam(i),[positionx(i) positiony(i) "0"],"false",1,HistoryEnable,RunJobID);
            RunJobID = CstTransform(mws,StrGNDNaming(i),[positionx(i) positiony(i) "0"],"false",1,HistoryEnable,RunJobID);
            
            %%% rotating patch antenna 
            RunJobID = CstRotate(mws,StrTransNam(i),[0 0 1],[positionRota(i) 0 0],"false",1,HistoryEnable,RunJobID);
            RunJobID = CstRotate(mws,DiStrTransNam(i),[0 0 1],[positionRota(i) 0 0],"false",1,HistoryEnable,RunJobID);
            RunJobID = CstRotate(mws,StrGNDNaming(i),[0 0 1],[positionRota(i) 0 0],"false",1,HistoryEnable,RunJobID);

            %%% Move&rotate port
            RunJobID = CstPortTransform(mws,port(i),[positionx(i) positiony(i) "0"],"false",1,HistoryEnable,RunJobID);
            RunJobID = CstPortRotate(mws,port(i),[0 0 1],[positionRota(i) 0 0],"false",1,HistoryEnable,RunJobID);
        end
       
       
        
%% structure setting (rotating part) --port 1-231
       %compo = invoke(mws,'component');
if LN >1
        %Structure setting 
        fprintf('[%s] Creating Layer ... \n', datestr(now,'HH:MM:SS'));
        StrRep = LN-1;

        component = "Layer";
        RunJobID = CstTransform(mws,component,["0" "0" "LS"],"true",StrRep,HistoryEnable,RunJobID);
        
        component = "Dielectric";
        RunJobID = CstTransform(mws,component,["0" "0" "LS"],"true",StrRep,HistoryEnable,RunJobID);
        
       %Structure setting --addon module: support structure 
       if SupportAddOnEnable == 1
         
          RunJobID = CstTransform(mws,StrLchanNam(1,1:2),["0" "0" "LS"],"true",StrRep,HistoryEnable,RunJobID);
          
       end
        %Structure setting --addon module: Blade isolation 
       if IsolationBladeEnable == 1;
            RunJobID = CstTransform(mws,StrBladNam(1,:),["0" "0" "LS"],"true",StrRep,HistoryEnable,RunJobID);
       end
        

         for i = 1:StrRep
             for ii = 1:UN
             fprintf('[%s] Renaming Layer %d in Unitcell %d... \n', datestr(now,'HH:MM:SS'),i,ii);
             component = "Layer";
                if EN == 2
                    a1 =char(LayerNaming(ii,1));%element 1
                    d1 =char(DiLayerNaming(ii,1));%dielectric 1

                    a2 =char(LayerNaming(ii,2));%element 2
                    d2 =char(DiLayerNaming(ii,2));%dielectric 2
                   
                    a1 = [a1(1) num2str(i+1) a1(3:end)];
                    d1 = [d1(1:7) num2str(i+1) d1(9:end)];

                    a2 = [a2(1) num2str(i+1) a2(3:end)];
                    d2 = [d2(1:7) num2str(i+1) d2(9:end)];
                    
                    %#---layer_Rename + stord name
                    component = "Layer";
                    RunJobID = CstRename(mws,[char(component) ':' char(LayerNaming(ii,1)) '_' num2str(i)],a1,HistoryEnable,RunJobID);
                    RunJobID = CstRename(mws,[char(component) ':' char(LayerNaming(ii,2)) '_' num2str(i)],a2,HistoryEnable,RunJobID);
                    LayerNaming(ii+i*UN,:)= [string(a1), string(a2)];
                    StrTransNam(ii+i*UN,:)= [string([char(component) ':' char(a1)]) string([char(component) ':' char(a2)])] ;
                    
                    %#---dielectric_Rename + stord name
                    component = "Dielectric";
                    RunJobID = CstRename(mws,[char(component) ':' char(DiLayerNaming(ii,1)) '_' num2str(i)],d1,HistoryEnable,RunJobID);
                    RunJobID = CstRename(mws,[char(component) ':' char(DiLayerNaming(ii,2)) '_' num2str(i)],d2,HistoryEnable,RunJobID);
                    DiLayerNaming(ii+i*UN,:)= [string(d1), string(d2)];
                    DiStrTransNam(ii+i*UN,:)= [string([char(component) ':' char(d1)]) string([char(component) ':' char(d2)])] ;
                elseif EN == 3
                    a1 =char(LayerNaming(ii,1));%element 1
                    d1 =char(DiLayerNaming(ii,1));%dielectric 1

                    a2 =char(LayerNaming(ii,2));%element 2
                    d2 =char(DiLayerNaming(ii,2));%dielectric 2

                    a3 =char(LayerNaming(ii,3));%element 3
                    d3 =char(DiLayerNaming(ii,3));%dielectric 3
                   
                    a1 = [a1(1) num2str(i+1) a1(3:end)];
                    d1 = [d1(1:7) num2str(i+1) d1(9:end)];

                    a2 = [a2(1) num2str(i+1) a2(3:end)];
                    d2 = [d2(1:7) num2str(i+1) d2(9:end)];

                    a3 = [a3(1) num2str(i+1) a3(3:end)];
                    d3 = [d3(1:7) num2str(i+1) d3(9:end)];
                    
                    %#---layer_Rename + stord name
                    component = "Layer";
                    RunJobID = CstRename(mws,[char(component) ':' char(LayerNaming(ii,1)) '_' num2str(i)],a1,HistoryEnable,RunJobID);
                    RunJobID = CstRename(mws,[char(component) ':' char(LayerNaming(ii,2)) '_' num2str(i)],a2,HistoryEnable,RunJobID);
                    RunJobID = CstRename(mws,[char(component) ':' char(LayerNaming(ii,3)) '_' num2str(i)],a3,HistoryEnable,RunJobID);
                    LayerNaming(ii+i*UN,:)= [string(a1), string(a2), string(a3)];
                    StrTransNam(ii+i*UN,:)= [string([char(component) ':' char(a1)]) string([char(component) ':' char(a2)]) string([char(component) ':' char(a3)])] ;
                    
                    %#---dielectric_Rename + stord name
                    component = "Dielectric";
                    RunJobID = CstRename(mws,[char(component) ':' char(DiLayerNaming(ii,1)) '_' num2str(i)],d1,HistoryEnable,RunJobID);
                    RunJobID = CstRename(mws,[char(component) ':' char(DiLayerNaming(ii,2)) '_' num2str(i)],d2,HistoryEnable,RunJobID);
                    RunJobID = CstRename(mws,[char(component) ':' char(DiLayerNaming(ii,3)) '_' num2str(i)],d3,HistoryEnable,RunJobID);
                    DiLayerNaming(ii+i*UN,:)= [string(d1), string(d2), string(d3)];
                    DiStrTransNam(ii+i*UN,:)= [string([char(component) ':' char(d1)]) string([char(component) ':' char(d2)]) string([char(component) ':' char(d3)])] ;

                else
                    a1 =char(LayerNaming(ii,1));
                    d1 =char(DiLayerNaming(ii,1));%dielectric 1

                    a1 = [a1(1) num2str(i+1) a1(3:end)];
                    d1 = [d1(1:7) num2str(i+1) d1(9:end)];
                    
                    %#---layer_Rename + stord name
                    component = "Layer";
                    RunJobID = CstRename(mws,[char(component) ':' char(LayerNaming(ii,1)) '_' num2str(i)],a1,HistoryEnable,RunJobID);
                    LayerNaming(ii+i*UN,:)= [string(a1)];
                    StrTransNam(ii+i*UN,:)= [string([char(component) ':' char(a1)]) ] ;
                    
                    %#---dielectric_Rename + stord name
                    component = "Dielectric";
                    RunJobID = CstRename(mws,[char(component) ':' char(DiLayerNaming(ii,1)) '_' num2str(i)],d1,HistoryEnable,RunJobID);
                    DiLayerNaming(ii+i*UN,:)= [string(d1)];
                    DiStrTransNam(ii+i*UN,:)= [string([char(component) ':' char(d1)])] ;

                end
             end
             %add-on module -- L-channel-support
                 if SupportAddOnEnable == 1
                                       
                    RunJobID = CstRename(mws,[char(StrLchanNam(1,1)) '_' num2str(i)],[char(StrLchanNam(1,1))  num2str(i)],HistoryEnable,RunJobID);
                    RunJobID = CstRename(mws,[char(StrLchanNam(1,2)) '_' num2str(i)],[char(StrLchanNam(1,2))  num2str(i)],HistoryEnable,RunJobID);  
                    
                    StrLchanNam(i+1,1) = [string([char(StrLchanNam(1,1))  num2str(i)])];
                    StrLchanNam(i+1,2) = [string([char(StrLchanNam(1,2))  num2str(i)])];
                 end
             
             %add-on module -- Isolation Blade
                 if IsolationBladeEnable == 1
                    RunJobID = CstRename(mws,[char(StrBladNam(1)) '_' num2str(i)],[char(StrBladNam(1))  num2str(i)],HistoryEnable,RunJobID);
                   
                   StrBladNam(i+1,1) = [string([char(StrBladNam(1,1))  num2str(i)])];
                  
                 end

       end
              
              

             

      %port setting
                
        for i = 1: TLUN*EN*LN
        port(i) = ['port' num2str(i)];
        end
      
       for iii = 1:(LN-1)
        fprintf('[%s] Creating port %d to port %d... \n', datestr(now,'HH:MM:SS'),(1+(UN*(iii-1))),(UN*iii));     
        portt = port((1+(EN*UN*(iii-1))):(EN*UN*iii));      
        RunJobID = CstPortTransform(mws,portt,["0" "0" "LS"],"true",1,HistoryEnable,RunJobID);   
        end

      %GND setting
        component = "GND";
         fprintf('[%s] Creating ground plane ... \n', datestr(now,'HH:MM:SS'));
        
        RunJobID = CstTransform(mws,component,["0" "0" "LS"],"true",StrRep,HistoryEnable,RunJobID);
    

        for i = 1:StrRep
            if UnitcellGNDEnable == 1
                for ii = 1:UN
                 % GNDTransNam(i)= [string([char(component) ':' 'Groundplane_' num2str(i)])] ;
                    component = "GND";
                    g1 = char(GNDNaming(ii));
                    g1 = [g1(1:13) num2str(i+1) g1(13:end)]; 
                    Sg1 = ['GND:' g1];

                    RunJobID = CstRename(mws,[char(component) ':' char(GNDNaming(ii,1)) '_' num2str(i)],g1,HistoryEnable,RunJobID);
                    GNDNaming(ii+i*UN,:) = [string(g1)];
                    StrGNDNaming(ii+i*UN,:) = [string(Sg1)];  
                end
            else
                GNDTransNam(i)= [string([char(component) ':' 'Groundplane_' num2str(i)])] ;
            end

        end

%---------------------------------------------------------------------------------%
%-----------------------         Structure rotate        -------------------------%
%---------------------------------------------------------------------------------%
    ClkorAntiCLK = -1;% spinning it in anticlockwise or clockwise
    RotaAngle= ClkorAntiCLK*180/(LN);

    if  MiddleElementEliminateEnable == 1 % set structure centre for rotation 
        ii = [1:UN];
        if MiddleCirculeElementEliminateEnable == 1;
            SetOrigin = "(USpa*(UN+2))/2";
        else
            SetOrigin = "(USpa*(UN)-20)/2";
        end
    else
        ii = [1:floor(UN/2) ceil(UN/2)+1:UN];% we dont need middle unitcell so new number sequence create
        SetOrigin = "(USpa*(UN-1))/2";
    end

    %#---layer+dielectric rotate
    for i = 0:(LN-1)
    StrRota = StrTransNam(1+(TLUN*i):TLUN+(TLUN*i),:);
    DiStrRota = DiStrTransNam(1+(TLUN*i):TLUN+(TLUN*i),:);
    StrRota = StrRota(:);
    DiStrRota = DiStrRota(:);
    fprintf('[%s] rotate %d layer... \n', datestr(now,'HH:MM:SS'),i);
    RunJobID = CstRotate(mws,StrRota,[SetOrigin 0 0],[0 0 RotaAngle*i],"false",1,HistoryEnable,RunJobID);
    RunJobID = CstRotate(mws,DiStrRota,[SetOrigin 0 0],[0 0 RotaAngle*i],"false",1,HistoryEnable,RunJobID);
    end

    %#---port rotate
    for i = 0:(LN-1)
    portRota = port(1+((EN*TLUN)*i):(EN*TLUN)+((EN*TLUN)*i));
    fprintf('[%s] rotate  port from %d port to %d ... \n', datestr(now,'HH:MM:SS'),1+((EN*UN)*i),(EN*UN)+((EN*UN)*i));
    RunJobID = CstPortRotate(mws,portRota,[SetOrigin 0 0],[0 0 RotaAngle*i],"false",1,HistoryEnable,RunJobID);
    end

    %#---GND plane rotate
    if UnitcellGNDEnable == 1
       Forstart = 0;
       Forend = (LN-1);  
    else
       Forstart = 1;
       Forend = (LN-1); 
    end

        for i = Forstart:Forend
            if UnitcellGNDEnable == 1
                GNDRota = StrGNDNaming(1+(TLUN*i):TLUN+(TLUN*i));
            else
                GNDRota = GNDTransNam(i);
            end  
            fprintf('[%s] rotate %d GND plane... \n', datestr(now,'HH:MM:SS'),i);
            RunJobID = CstRotate(mws,GNDRota,[SetOrigin 0 0],[0 0 RotaAngle*i],"false",1,HistoryEnable,RunJobID);
        end

     %add-on module -- L-channel-support
     if SupportAddOnEnable == 1
           for i = 0:(LN-1)
            LChanRota = StrLchanNam(i+1,:);                   
            fprintf('[%s] rotate %d L-channel... \n', datestr(now,'HH:MM:SS'),i);
    
            RunJobID = CstRotate(mws,LChanRota,[SetOrigin 0 0],[0 0 RotaAngle*i],"false",1,HistoryEnable,RunJobID);
           end
     end

     %add-on module -- Isolation blade
     if IsolationBladeEnable == 1
        for i = 1:(LN)
            BladeRota = StrBladNam(i);                   
            fprintf('[%s] rotate %d isolation blade... \n', datestr(now,'HH:MM:SS'),i);
    
            RunJobID = CstRotate(mws,BladeRota,[SetOrigin 0 0],[0 0 (RotaAngle/2)+(RotaAngle*(i-1))],"false",1,HistoryEnable,RunJobID);
        end
       
     
 
     end

end

%---------------------------------------------------------------------------------%
%-------------------     set original to structure       -------------------------%
%---------------------------------------------------------------------------------%
if UN > 1
    if MiddleElementEliminateEnable == 1
        if MiddleCirculeElementEliminateEnable == 1
            uUN = UN+3;
        else
            uUN = UN+1;
        end
    else
        uUN = UN;
    end 
    
    if rem(UN,2) == 1 %% the unitcell number has to be even number
       MovDis = floor(uUN/2);
    else 
       if MiddleElementEliminateEnable == 1
           MovDis = floor(uUN/2);
       else
           MovDis = floor(uUN/2)-0.40;%0.5
       end
    end

    %#---layer+dielectric trans
    for i = 0:(LN-1)
    StrTrans = StrTransNam(1+(TLUN*i):TLUN+(TLUN*i),:);
    DiStrTrans = DiStrTransNam(1+(TLUN*i):TLUN+(TLUN*i),:);
    StrTrans = StrTrans(:);
    DiStrTrans = DiStrTrans(:);
    fprintf('[%s] moved %d layer... \n', datestr(now,'HH:MM:SS'),i);
    RunJobID = CstTransform(mws,StrTrans,[['-USpa*' num2str(MovDis) '+10'] "0" "0"],"false",1,HistoryEnable,RunJobID);
    RunJobID = CstTransform(mws,DiStrTrans,[['-USpa*' num2str(MovDis) '+10'] "0" "0"],"false",1,HistoryEnable,RunJobID);
    end

    %#---port trans
    for i = 0:(LN-1)
    portTrans = port(1+((EN*TLUN)*i):(EN*TLUN)+((EN*TLUN)*i));
    fprintf('[%s] moved port from %d to %d... \n', datestr(now,'HH:MM:SS'),1+((EN*UN)*i),(EN*UN)+((EN*UN)*i));
    RunJobID = CstPortTransform(mws,portTrans,[['-USpa*' num2str(MovDis) '+10'] "0" "0"],"false",1,HistoryEnable,RunJobID);
    end

    %add-on module -- L-channel-support
    if SupportAddOnEnable == 1
        for i = 0:(LN-1)
            LChanTrans = StrLchanNam(i+1,:);                  
            fprintf('[%s] move %d L-channel... \n', datestr(now,'HH:MM:SS'),i);
    
            RunJobID =  CstTransform(mws,LChanTrans,[['-USpa*' num2str(MovDis) '+10'] "0" "0"],"false",1,HistoryEnable,RunJobID);
        end
        component = 'Support Structure';
        Name = 'Big pole'
        OuterRadius = 40;
        InnerRadius = 30;
        RunJobID = CstPLAlossy(mws,HistoryEnable,RunJobID);
        material = "PLA (lossy)";
        Xcenter = 10;
        Ycenter = 0;
        Zrange= [-20 720];
        RunJobID = Cstcylinder(mws, Name, component, material, 'Z', OuterRadius, InnerRadius, Xcenter, Ycenter, Zrange,HistoryEnable,RunJobID);
    end

     %add-on module -- IsolationBlade
    
     if IsolationBladeEnable == 1
        for i = 0:(LN-1)
            BladeTrans = StrBladNam(i+1,:);                  
            fprintf('[%s] move %d blade... \n', datestr(now,'HH:MM:SS'),i);
    
            RunJobID =  CstTransform(mws,BladeTrans,[['-USpa*' num2str(MovDis) '+10'] "0" "0"],"false",1,HistoryEnable,RunJobID);
        end
       
        % Remove reductant part
       RunJobID = CstDelete(mws,StrBladNam(end),HistoryEnable,RunJobID);
     end

    %#---GND plane trans
    if UnitcellGNDEnable == 1
         %[[nothing happened]]%
    else
        if LN > 1
         GNDTransNam = ["GND:Groundplane" GNDTransNam];
        else
         GNDTransNam = ["GND:Groundplane"];
        end
    end

    for i = 0:(LN-1)
        fprintf('[%s] moved %d GND plane... \n', datestr(now,'HH:MM:SS'),i);
            if UnitcellGNDEnable == 1 
                GNDTrans = StrGNDNaming(1+(TLUN*i):TLUN+(TLUN*i));
            else
                GNDTrans = GNDTransNam(i+1);
            end

        RunJobID = CstTransform(mws,GNDTrans,[['-USpa*' num2str(MovDis) '+10'] "0" "0"],"false",1,HistoryEnable,RunJobID);
    end
end

%----add-on module---% 

%---------------------------------------------------------------------------------%
%-----------------------         Planewave set           -------------------------%
%---------------------------------------------------------------------------------%

if PlanewaveSet == 1
    invoke(mws,'StoreParameter','theta',90);
    invoke(mws,'StoreParameter','phi',PhiAngSimulate(ModleRepeated));

    PW = invoke(mws,'planewave');
    invoke(PW,'Normal',"-sinD(theta)*cosD(phi)", "-sinD(theta)*sinD(phi)", "-cosD(theta)");
    invoke(PW,'EVector',"-cosD(theta)*cosD(phi)", "-cosD(theta)*sinD(phi)", "sinD(theta)");
    invoke(PW,'Polarization','Linear');
    invoke(PW,'ReferenceFrequency',"2.45");
    invoke(PW,'PhaseDifference',"-90.0");
    invoke(PW,'CircularDirection',"Left");
    invoke(PW,'AxialRatio' ,"0.0");
    invoke(PW,'SetUserDecouplingPlane',"False");
    invoke(PW,'Store'); 


    mws.invoke('AddToHistory', ['PlaneWaveSet'],[
            sprintf(' With PlaneWave \n')...
            sprintf('  .Reset\n')...
            sprintf('  .Normal "-sinD(theta)*cosD(phi)", "-sinD(theta)*sinD(phi)", "-cosD(theta)"  \n')...
            sprintf('  .EVector "-cosD(theta)*cosD(phi)", "-cosD(theta)*sinD(phi)", "sinD(theta)" \n')...
            sprintf('  .Polarization "Linear"   \n')...
            sprintf('  .ReferenceFrequency"2.45"   \n')...
            sprintf(' .PhaseDifference "-90.0"    \n')...
            sprintf('  .CircularDirection "Left"     \n')...
            sprintf('  .AxialRatio "0.0"    \n')...
            sprintf('  .SetUserDecouplingPlane "False" \n') ...
            sprintf('  .Store \n')...
            sprintf('End With')]);

    SolverFlagSetting = 'Plane wave';
else
    SolverFlagSetting = 'All';
end 

%---------------------------------------------------------------------------------%
%---------------------    fieldmointor set for 7x11 only      --------------------%
%---------------------------------------------------------------------------------%

if FieldMointorSet ==1
% FM =invoke(mws,'Monitor');
%     invoke(FM,'Reset');
%     invoke(FM,'Name',"farfield (f=2.45)");
%     invoke(FM,'Domain', "Frequency");
%     invoke(FM,'FieldType',"Farfield");
%     invoke(FM,'MonitorValue',"2.45");
%     invoke(FM,'ExportFarfieldSource',"False");
%     invoke(FM,'UseSubvolume',"False");
%     invoke(FM,'Coordinates',"Structure");
%     invoke(FM,'SetSubvolume', "-436.24824567816", "68.901245678162", "-251.51062701523", "250.86427358419", "-612.245", "31" );
%     invoke(FM,'SetSubvolumeOffset', "10", "10", "10", "10", "10", "10" );
%     invoke(FM,'SetSubvolumeInflateWithOffset',  "False" );
%     invoke(FM,'SetSubvolumeOffsetType',"FractionOfWavelength" );
%     invoke(FM,'EnableNearfieldCalculation',"True");
%     invoke(FM,'Create');

 
    mws.invoke('AddToHistory', ['MonitorSet'],[
            sprintf(' With Monitor \n')...
            sprintf('  .Reset\n')...
            sprintf('  .Name "farfield (f=2.45)" \n')...
            sprintf('  .Domain "Frequency"  \n')...
            sprintf('  .FieldType "Farfield"   \n')...
            sprintf('  .MonitorValue "2.45"    \n')...
             sprintf(' .ExportFarfieldSource "False"     \n')...
            sprintf('  .Coordinates "Structure"      \n')...
            sprintf('  .SetSubvolume "-653.68658117516", "653.68658117516", "-653.68658117516", "653.68658117516", "0", "1920.377536"     \n')...
            sprintf('  .SetSubvolumeOffset "10", "10", "10", "10", "10", "10"  \n') ...
            sprintf('  .SetSubvolumeInflateWithOffset "False"  \n')...
            sprintf('  .SetSubvolumeOffsetType "FractionOfWavelength"  \n')...
            sprintf('  .EnableNearfieldCalculation "True"  \n')...
            sprintf('   .Create  \n')...
            sprintf('End With')]);
    

end

%---------------------------------------------------------------------------------%
%---------------------    Acceleration!!!                     --------------------%
%---------------------------------------------------------------------------------%

if AccerelationSet == 1

mws.invoke('AddToHistory', ['SolverSet'],[
            sprintf(' With Solver \n')...
            sprintf('  .UseParallelization "True"\n')...
            sprintf('  .StimulationPort "%s" \n',SolverFlagSetting)...
            sprintf('  .MaximumNumberOfThreads "128" \n')...
            sprintf('  .MaximumNumberOfCPUDevices "8"  \n')...
            sprintf('  .RemoteCalculation "False"   \n')...
            sprintf('  .UseDistributedComputing "False"   \n')...
             sprintf(' .MaxNumberOfDistributedComputingPorts "64"     \n')...
            sprintf('  .DistributeMatrixCalculation "True"     \n')...
            sprintf('  .MPIParallelization "False"     \n')...
            sprintf('  .HardwareAcceleration "True"  \n')...
            sprintf('  .MaximumNumberOfGPUs "1"  \n')...
            sprintf('End With \n') ...
            sprintf('UseDistributedComputingForParameters "False" \n') ...
            sprintf('MaxNumberOfDistributedComputingParameters "2" \n') ...
            sprintf('UseDistributedComputingMemorySetting "False" \n') ...
            sprintf('MinDistributedComputingMemoryLimit "0" \n') ...
            sprintf('UseDistributedComputingSharedDirectory "False" \n')]);

end

CstDefineFrequencyRange(mws,2.3,2.5)


%mws.invoke('rebuild'); to refresh history list

%---------------------------------------------------------------------------------%
%---------------------    Optmization parameter set!!!        --------------------%
%---------------------------------------------------------------------------------%

if OptmizationParameterSet == 1
    for i = 1:length(StrTrans)
        %%% Create Parameter
        positionx(i) = string(['UP_' num2str(i)])
        invoke(mws,'StoreParameterWithDescription',char(positionx(i)),0,char(["The position for unitcell " num2str(i)]));
        
        %%% Moving patch antenna 
        RunJobID = CstTransform(mws,StrTrans(i),[positionx(i) "0" "0"],"false",1,HistoryEnable,RunJobID);
        RunJobID = CstTransform(mws,DiStrTransNam(i),[positionx(i) "0" "0"],"false",1,HistoryEnable,RunJobID);
        RunJobID = CstTransform(mws,GNDTrans(i),[positionx(i) "0" "0"],"false",1,HistoryEnable,RunJobID);
        
        %%% Move port
        RunJobID = CstPortTransform(mws,port(i),[positionx(i) "0" "0"],"false",1,HistoryEnable,RunJobID);
    end
        

    %%%-----Optimizer setting----%%%
    Optimizer = invoke(mws,'Optimizer');
    invoke(Optimizer,'InitParameterList');
    invoke(Optimizer,'ResetParameterList');
    invoke(Optimizer,'SetOptimizerType',"Nelder_Mead_Simplex");

    for i =1:length(positionx)
       invoke(Optimizer,'SelectParameter',positionx(i),'True');
       invoke(Optimizer,'SetParameterMin',-15);
       invoke(Optimizer,'SetParameterMax',15);
       invoke(Optimizer,'SetParameterAnchors',4);% define the number of sample
       invoke(Optimizer,'SetParameterInit',0);
       
    end
    
    invoke(Optimizer,'SetGoalSummaryType',"Sum_All_Goals");
    goalID = invoke(Optimizer,'AddGoal',"1D Primary Result");
    invoke(Optimizer,'SetGoal1DResultName','1D Results\S-Parameters\S1,1');

    invoke(Optimizer,'SelectGoal',goalID, 'True');
    invoke(Optimizer,'SetGoalScalarType',"maglin");
    invoke(Optimizer,'SetGoalTarget',0);
    invoke(Optimizer,'SetGoalWeight',1);
    
end
   
   %File Repeated module
   if Repeatednumber >1
        FileRecord(ModleRepeated) = string(InitialfileName); 
        mws.invoke('saveas',FilePath,'false');
        pause(1);
        mws.invoke('quit');
        pause(1);
   end

end

%---------------------------------------------------------------------------------%
%---------------------    File name  record  module!!!          --------------------%
%---------------------------------------------------------------------------------%

if Repeatednumber >1
%Filename_Record printf
            fprintf('[%s] Filename write in txt file... \n', datestr(now,'HH:MM:SS'));
            fileID = fopen(FileNameRecordPath,'w');
            fprintf(fileID,'File Name \n');
            fprintf(fileID,'----------------------------------------------------- \n');
            for FsP = 1:Repeatednumber
             fprintf(fileID,'   %s       \n',FileRecord(FsP));    
            end

            fclose(fileID);
end
