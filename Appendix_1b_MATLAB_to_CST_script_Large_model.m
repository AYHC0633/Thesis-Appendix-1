
clear;
close all;
clc;

%%% the programme below are mixture of TCSTInterface() and activeX
%%% framework
%%% maximum of element allowed == 3

%%% ----------------------slicing method + main control plannel -----------------------------%%
 LayerSplit = 2 ; % number of file to splite layer 
 Unitcellsplit = 2;% number of file to splite unitcell
 FileSplit = LayerSplit*Unitcellsplit; %% number of CST file will be create
 FileSplitEnable = 1; %% on off switch 
 FileSaveDirectirity = 'D:\OneDrive - Queen''s University Belfast\PHD research\Matlab_\MTC testing\MTC combine result\20000_element\';
 InitialfileName = 'CASS_100x100_1of10.cst'; 
 FilePath = [FileSaveDirectirity InitialfileName]; % this can be change in for loop !!!!!
 Version = 2023;
 %------------add-on module control pannel--------------------%
PlanewaveSet = 1; 
FieldMointorSet = 1;
AccerelationSet = 1;
MeshCellSet = 1;
FileNameRecordEnable = 1;

%------------function add-on control pannel -----------------%
HistoryEnable = 1;
RunJobID = 1;%this is the job count, incase there is the same history name appear, dont change this 



%----file-split mode---% 

%---------------------------------------------------------------------------------%
%-----------------------         structure split set     -------------------------%
%---------------------------------------------------------------------------------%

 if FileSplitEnable == 1
       
       %%% automatic set how many layer in one file, you can adjust it by
       %%% setting LLS and LLN eg, if i have 5 file want to split 50
       %%% layer  , instead of [10 10 10 10 10], you can [5 10 15 10 5],
       %%% change it in LLN, then change LLS to [0 5 10 15 10];LLS is for
       %%% spacing shift up
       TLN = 11 ; % number of layer in overall file
       TUN = 8;% number of unitcell in each layer
       %FLN = floor(TLN/FileSplit);
       FLN = ceil(TLN/LayerSplit);
       FUN = ceil(TUN/Unitcellsplit);

       %%%---------layer allocation------------------%
       if rem(TLN,FLN) == 0
        LLN  = [FLN*ones(1,LayerSplit)]; % number of layer in each file
       else
        %LN  = [FLN*ones(1,(LayerSplit-1)) (TLN-FLN*(LayerSplit-1))*ones(1,1)]; 
        LLN  = [FLN*ones(1,(LayerSplit-1)) (TLN-(FLN)*(LayerSplit-1))*ones(1,1)];
       end 

       LLS = [ 0 FLN*ones(1,(LayerSplit-1))];% for shifting up structure 
      
       %%%---------Unitcell allocation------------------%
       if rem(TUN,FUN) == 0
            UUN  = [FUN*ones(1,Unitcellsplit)]; % number of Unitcell in each file
       else
            %LN  = [FLN*ones(1,(Unitcellsplit-1)) (TLN-FLN*(LayerSplit-1))*ones(1,1)]; 
            UUN  = [FUN*ones(1,(Unitcellsplit-1)) (TUN-(FUN)*(Unitcellsplit-1))*ones(1,1)];
       end 

       UUS = [ 0 FUN*ones(1,(Unitcellsplit-1))];% for shifting up structure 

       RoTA = 180/ LayerSplit;
       

 end

 
for LiS = 1 : LayerSplit %1 : LayerSplit
  for UiS = 1 : Unitcellsplit 
%------------File Name change--------------------%
   if FileSplitEnable == 1
    InitialfileName = ['CASS_R_' num2str(TUN) 'x' num2str(TLN) '_' num2str(Unitcellsplit *(LiS-1)+UiS) 'of_' num2str(FileSplit) '.cst']; 
    FilePath = [FileSaveDirectirity InitialfileName];
   end

RTD = 180/pi;


%%%%--- control center command/ configuration setting 
%addpath(genpath('C:\Users\cyh06\Documents\OneDrive - Queen''s University Belfast\PHD research\Matlab_\MTC testing\Casseopeia MTC control\To Matlab Path root folder'));
%addpath(genpath('D:\OneDrive - Queen''s University Belfast\PHD research\Matlab_\MTC testing\CST-MATLAB-API-master\cst api'));

%addpath(genpath('C:\Users\40210776\OneDrive - Queen''s University Belfast\PHD research\Matlab_\MTC testing\CST-MATLAB-API-master\cst api'));

addpath(genpath('K:\OneDrive - Queen''s University Belfast\PHD research\Matlab_\MTC testing\Casseopeia MTC control\To Matlab Path root folder'));
addpath(genpath('K:\OneDrive - Queen''s University Belfast\PHD research\Matlab_\MTC testing\CST-MATLAB-API-master\cst api'));

fprintf('[%s] Initializeing... \n', datestr(now,'HH:MM:SS'));
fprintf('[%s] opening CST... \n', datestr(now,'HH:MM:SS'));

%%%%%%%%%%---------Read the phase from plane wave-----%%%%%%%%%%

cst = actxserver(['CSTStudio.application.' num2str(Version)]);%('CSTStudio.application.2020');
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
mws.invoke('AddToHistory', ['FrequencyDefine'],[sprintf('Solver.FrequencyRange "2.3", "2.5"')]);


%%% structure setting %%%%%
   %%casseopeia setting
        f =2.45e9;
        c=3e11;
        WL=c/f;
        gap = 1; % for large structure the gap cant smaller than 1
        
       
        LN = LLN(LiS); %24
        LS = WL/2; %% the negative sign is to controll the structure direction
        invoke(mws,'StoreParameter','LS',LS);

        UN = UUN(UiS);%13%
        invoke(mws,'StoreParameter','UN',UN);
        USpa = WL/2; %% same here, you can just add '- sign to controll the direction' 
        invoke(mws,'StoreParameter','USpa',USpa);
        UCSpac = WL/8/cosd(30);

        EN = 3;
        ENL = 26.5;
        
        invoke(mws,'StoreParameter','GNDx','LS*UN');
        GNDx = (WL/2)*UN;
        GNDy = (WL/2);





 %% element setting 
 fprintf('[%s] Creating element ... \n', datestr(now,'HH:MM:SS'));
    %##---set ground plane
        Name = 'Groundplane';
        component = 'GND';
        material = 'PEC';
        Xrange = [-WL/2 "GNDx"];
        Yrange = [-GNDy WL/2];
        Zrange = [0 0];%[0 1];

        RunJobID = Cstbrick(mws, Name, component, material, Xrange, Yrange, Zrange,HistoryEnable,RunJobID);


    %##---set monopole 
        Name = 'Conductor';
        component = 'Layer';
        OuterRadius = 3;
        InnerRadius = 0;
        Xcenter = 0;
        Ycenter = 0;
        Zrange = [gap ENL];
        RunJobID = Cstcylinder(mws, Name, component, material, 'Z', OuterRadius, InnerRadius, Xcenter, Ycenter, Zrange,HistoryEnable,RunJobID);


    %port setting
    %##---set port
        PortNumber = 1;
        SetP1 = [0 0 0];
        SetP2 = [0 0 gap];
        impedance = 50;
        RunJobID = CstDiscretePort(mws,PortNumber,SetP1,SetP2,impedance,HistoryEnable,RunJobID);

 %% unitcell setting ---port 1-3
 fprintf('[%s] Creating First Unitcell ... \n', datestr(now,'HH:MM:SS'));
        US = WL/4; % unitcell Spacing
      %Structure setting 
        if EN >1 
        MPole = string([component ':' Name]);
        RunJobID = CstTransform(mws,MPole,[(US/2)/cosd(30) 0 0],"false",1,HistoryEnable,RunJobID);
        RunJobID = CstRotate(mws,MPole,[0 0 0],[0 0 120],"true",2,HistoryEnable,RunJobID);
        end

        %Solid = invoke(mws,'Solid');
        
        RunJobID = CstRename(mws,[component ':' Name],"L1U1E1",HistoryEnable,RunJobID);

        if EN >1 
          RunJobID = CstRename(mws,[component ':' Name '_1'],"L1U1E2",HistoryEnable,RunJobID);
          RunJobID = CstRename(mws,[component ':' Name '_2'],"L1U1E3",HistoryEnable,RunJobID);
         LayerNaming(1,:) = ["L1U1E1" "L1U1E2" "L1U1E3"];
         StrTransNam(1,:) = ["Layer:L1U1E1" "Layer:L1U1E2" "Layer:L1U1E3"];
        else
         LayerNaming(1,:) = ["L1U1E1" ];
         StrTransNam(1,:) = ["Layer:L1U1E1"];
        end
            
           
      %port setting
        if EN > 1
           RunJobID = CstPortTransform(mws,"port1",[(US/2)/cosd(30) 0 0],"false",1,HistoryEnable,RunJobID);
            %CstPortTransform(mws,"port1",[0 0 WL/2],"true",1)
           RunJobID = CstPortRotate(mws,"port1",[0 0 0],[0 0 120],"true",2,HistoryEnable,RunJobID);
            port = ["port1" "port2" "port3"];
        else
            port = ["port1"];
        end

        

%% Layer setting --port 1-21

        %Structure setting 
        component = "Layer";
        Layrep= UN-1;
       
        %---------------------shift space-----------------%
        if UiS > 1
             RunJobID = CstTransform(mws,component,[USpa 0 0],"false",sum(UUN(1:(UiS-1))),HistoryEnable,RunJobID);
        end
        
        %---------------------built element----------------%
        if Layrep > 0
            RunJobID = CstTransform(mws,component,[USpa 0 0],"true",Layrep,HistoryEnable,RunJobID);
            Solid = invoke(mws,'Solid');
        end

         for i = 1:Layrep
            RunJobID = CstRename(mws,[char(component) ':' 'L1U1E1' '_' num2str(i)],['L1U' num2str(i+1) 'E1'],HistoryEnable,RunJobID);
            fprintf('[%s] Renaming unitcell %d... \n', datestr(now,'HH:MM:SS'),i);
            if EN >1
                RunJobID = CstRename(mws,[char(component) ':' 'L1U1E2' '_' num2str(i)],['L1U' num2str(i+1) 'E2'],HistoryEnable,RunJobID);
                RunJobID = CstRename(mws,[char(component) ':' 'L1U1E3' '_' num2str(i)],['L1U' num2str(i+1) 'E3'],HistoryEnable,RunJobID);
                
                LayerNaming(i+1,:)= [string(['L1U' num2str(i+1) 'E1']), string(['L1U' num2str(i+1) 'E2']), string(['L1U' num2str(i+1) 'E3'])];
                StrTransNam(i+1,:)= [string([char(component) ':' char(['L1U' num2str(i+1) 'E1'])]) string([char(component) ':' char(['L1U' num2str(i+1) 'E2'])]) string([char(component) ':' char(['L1U' num2str(i+1) 'E3'])])] ;
            else
                LayerNaming(i+1,:)= [string(['L1U' num2str(i+1) 'E1'])];
                StrTransNam(i+1,:)= [string([char(component) ':' char(['L1U' num2str(i+1) 'E1'])])] ;  
            end

         
         end

          %CstRotate(mws,Unitcell,[0 0 0],[0 0 120],"true",2)

      %port setting
        if UiS > 1
        RunJobID = CstPortTransform(mws,port,[USpa 0 0],"false",sum(UUN(1:(UiS-1))),HistoryEnable,RunJobID);
        end
      
        if Layrep > 0
        RunJobID = CstPortTransform(mws,port,[USpa 0 0],"true",Layrep,HistoryEnable,RunJobID);
        %CstPortRotate(mws,"port1",[0 0 0],[0 0 120],"true",2)
        end
         
        for i = 1: UN*EN
        port(i) = ['port' num2str(i)];
        end
        
  

%% structure setting (rotating part) --port 1-231
       %compo = invoke(mws,'component');
if LN >1
        %Structure setting 
        component = "Layer";
        %invoke(compo,'new','Layer 1');
        fprintf('[%s] Creating Layer ... \n', datestr(now,'HH:MM:SS'));
        StrRep = LN-1;
        RunJobID = CstTransform(mws,component,[0 0 "LS"],"true",StrRep,HistoryEnable,RunJobID);
        
         for i = 1:StrRep
             for ii = 1:UN
             fprintf('[%s] Renaming Layer %d in Unitcell %d... \n', datestr(now,'HH:MM:SS'),i,ii);
                if EN >1
                    a1 =char(LayerNaming(ii,1));
                    a2 =char(LayerNaming(ii,2));
                    a3 =char(LayerNaming(ii,3));
                    a1 = [a1(1) num2str(i+1) a1(3:end)];
                    a2 = [a2(1) num2str(i+1) a2(3:end)];
                    a3 = [a3(1) num2str(i+1) a3(3:end)];
                    RunJobID = CstRename(mws,[char(component) ':' char(LayerNaming(ii,1)) '_' num2str(i)],a1,HistoryEnable,RunJobID);
                    RunJobID = CstRename(mws,[char(component) ':' char(LayerNaming(ii,2)) '_' num2str(i)],a2,HistoryEnable,RunJobID);
                    RunJobID = CstRename(mws,[char(component) ':' char(LayerNaming(ii,3)) '_' num2str(i)],a3,HistoryEnable,RunJobID);
                   
                    LayerNaming(ii+i*UN,:)= [string(a1), string(a2), string(a3)];
                    StrTransNam(ii+i*UN,:)= [string([char(component) ':' char(a1)]) string([char(component) ':' char(a2)]) string([char(component) ':' char(a3)])] ;
                else
                    a1 =char(LayerNaming(ii,1));
                    a1 = [a1(1) num2str(i+1) a1(3:end)];
                     RunJobID = CstRename(mws,[char(component) ':' char(LayerNaming(ii,1)) '_' num2str(i)],a1,HistoryEnable,RunJobID);
                    LayerNaming(ii+i*UN,:)= [string(a1)];
                    StrTransNam(ii+i*UN,:)= [string([char(component) ':' char(a1)]) ] ;
                end
             end
         end

     

      %port setting
                
        for i = 1: UN*EN*LN
        port(i) = ['port' num2str(i)];
        end
      
       for iii = 1:(LN-1)
        fprintf('[%s] Creating port %d to port %d... \n', datestr(now,'HH:MM:SS'),(1+(UN*EN*(iii-1))),(UN*EN*iii));     
        portt = port((1+(UN*EN*(iii-1))):(UN*EN*iii));      
        RunJobID = CstPortTransform(mws,portt,[0 0 "LS"],"true",1,HistoryEnable,RunJobID);   
        end

      %GND setting
         component = string('GND');%% it has to be string 
         fprintf('[%s] Creating ground plane ... \n', datestr(now,'HH:MM:SS'));

        if UiS > 1
         RunJobID = CstTransform(mws,component,[USpa 0 0],"false",sum(UUS(1:(UiS))),HistoryEnable,RunJobID);
        end
        
        if StrRep>0
         RunJobID = CstTransform(mws,component,[0 0 "LS"],"true",StrRep,HistoryEnable,RunJobID);
        end

        for i = 1:StrRep
           GNDTransNam(i)= [string([char(component) ':' 'Groundplane_' num2str(i)])] ; 
        end

%---------------------------------------------------------------------------------%
%-----------------------         Structure rotate        -------------------------%
%---------------------------------------------------------------------------------%
    RotaAngle= RoTA/(LN);

    %#---layer rotate
    for i = 0:(LN-1)
    StrRota = StrTransNam(1+(UN*i):UN+(UN*i),:);
    StrRota = StrRota(:);
    fprintf('[%s] rotate %d layer... \n', datestr(now,'HH:MM:SS'),i);
    RunJobID = CstRotate(mws,StrRota,[(USpa*(TUN-1))/2 0 0],[0 0 ((LiS-1)*RoTA)+RotaAngle*i],"false",1,HistoryEnable,RunJobID);
    end

    %#---port rotate
    for i = 0:(LN-1)
    portRota = port(1+((EN*UN)*i):(EN*UN)+((EN*UN)*i));
    fprintf('[%s] rotate  port from %d port to %d ... \n', datestr(now,'HH:MM:SS'),1+((EN*UN)*i),(EN*UN)+((EN*UN)*i));
    RunJobID = CstPortRotate(mws,portRota,[(USpa*(TUN-1))/2 0 0],[0 0 ((LiS-1)*RoTA)+RotaAngle*i],"false",1,HistoryEnable,RunJobID);
    end

    %#---GND plane rotate
    if FileSplitEnable == 1 && LiS ~= 1; 
     RunJobID = CstRotate(mws,["GND:Groundplane"],[(USpa*(TUN-1))/2 0 0],[0 0 ((LiS-1)*RoTA)],"false",1,HistoryEnable,RunJobID);% rotate from last layer and continuous at this file
    end

    for i = 1:(LN-1)
    fprintf('[%s] rotate %d GND plane... \n', datestr(now,'HH:MM:SS'),i);
    RunJobID = CstRotate(mws,GNDTransNam(i),[(USpa*(TUN-1))/2 0 0],[0 0 ((LiS-1)*RoTA)+RotaAngle*i],"false",1,HistoryEnable,RunJobID);
    end

else
        if FileSplitEnable == 1 && UiS > 1
          component = string('GND');%% it has to be string 
          fprintf('[%s] Creating ground plane ... \n', datestr(now,'HH:MM:SS'));
          RunJobID = CstTransform(mws,component,[USpa 0 0],"false",sum(UUS(1:(UiS))),HistoryEnable,RunJobID);
        end
end

%---------------------------------------------------------------------------------%
%-------------------     set original to structure       -------------------------%
%---------------------------------------------------------------------------------%
   
    if rem(UN,2) == 1
       MovDis = floor(TUN/2);
    else 
       MovDis = floor(TUN/2)-0.5;
    end


    %#---layer trans
    for i = 0:(LN-1)
    StrTrans = StrTransNam(1+(UN*i):UN+(UN*i),:);
    StrTrans = StrTrans(:);
    fprintf('[%s] moved %d layer... \n', datestr(now,'HH:MM:SS'),i);
    RunJobID = CstTransform(mws,StrTrans,[['-USpa*' num2str(MovDis)] "0" num2str(LS*sum(LLS(1:LiS)))],"false",1,HistoryEnable,RunJobID);
    end


    %#---port trans
    for i = 0:(LN-1)
    portTrans = port(1+((EN*UN)*i):(EN*UN)+((EN*UN)*i));
    fprintf('[%s] moved port from %d to %d... \n', datestr(now,'HH:MM:SS'),1+((EN*UN)*i),(EN*UN)+((EN*UN)*i));
    RunJobID = CstPortTransform(mws,portTrans,[['-USpa*' num2str(MovDis)] "0" num2str(LS*sum(LLS(1:LiS)))],"false",1,HistoryEnable,RunJobID);
    end
    

    %#---GND plane trans
    if LN > 1
     GNDTransNam = ["GND:Groundplane" GNDTransNam];
    else
     GNDTransNam = ["GND:Groundplane"];
    end

    for i = 1:(LN)
    fprintf('[%s] moved %d GND plane... \n', datestr(now,'HH:MM:SS'),i);
    %CstTransform(mws,GNDTransNam(i),[-LS*floor(UN/2) 0 0],"false",1);
    RunJobID = CstTransform(mws,GNDTransNam(i),[['-USpa*' num2str(MovDis)] "0" num2str(LS*sum(LLS(1:LiS)))],"false",1,HistoryEnable,RunJobID);
    end



%----add-on module---% 

%---------------------------------------------------------------------------------%
%-----------------------         Planewave set           -------------------------%
%---------------------------------------------------------------------------------%

if PlanewaveSet == 1
    invoke(mws,'StoreParameter','theta',90);
    invoke(mws,'StoreParameter','phi',30);

    PW = invoke(mws,'planewave');
    invoke(PW,'Normal',"-sinD(theta)*cosD(phi)", "-sinD(theta)*sinD(phi)", "-cosD(theta)");
    invoke(PW,'EVector',"0", "0", "1");
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
            sprintf('  .EVector "0", "0", "1" \n')...
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

 
   mws.invoke('AddToHistory', ['FieldMointorSet'],[
            sprintf(' With Monitor \n')...
            sprintf('  .Reset\n')...
            sprintf('  .Name "farfield (f=2.45)"  \n')...
            sprintf('  .FieldType "Farfield"  \n')...
            sprintf('  .MonitorValue "2.45"   \n')...
            sprintf('  .ExportFarfieldSource "False"   \n')...
             sprintf(' .UseSubvolume "False"     \n')...
            sprintf('  .Coordinates "Structure"     \n')...
            sprintf('  .SetSubvolumeInflateWithOffset "False"     \n')...
            sprintf('  .SetSubvolumeOffsetType "FractionOfWavelength"  \n') ...
            sprintf('  .EnableNearfieldCalculation "True"  \n')...
            sprintf('  .Create  \n')...
            sprintf('End With')]);

end

%---------------------------------------------------------------------------------%
%---------------------    Acceleration!!!                     --------------------%
%---------------------------------------------------------------------------------%

if AccerelationSet == 1
% AC = invoke(mws,'Solver');
%      invoke(AC,'UseParallelization',"True");
%      invoke(AC,'MaximumNumberOfThreads',"128");
%      invoke(AC,'MaximumNumberOfCPUDevices',"8");
%      invoke(AC,'RemoteCalculation',"False");
%      invoke(AC,'UseDistributedComputing',"False");
%      invoke(AC,'MaxNumberOfDistributedComputingPorts',"64");
%      invoke(AC,'DistributeMatrixCalculation',"True");
%      invoke(AC,'MPIParallelization',"False");
%      invoke(AC,'HardwareAcceleration',"True");
%      invoke(AC,'MaximumNumberOfGPUs',"1");
% %invoke(AC,'End With')
%      invoke(mws,'UseDistributedComputingForParameters',"False");
%      invoke(mws,'MaxNumberOfDistributedComputingParameters',"2");
%      invoke(mws,'UseDistributedComputingMemorySetting',"False");
%      invoke(mws,'MinDistributedComputingMemoryLimit',"0");
%      invoke(mws,'UseDistributedComputingSharedDirectory',"False");

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

%---------------------------------------------------------------------------------%
%---------------------    MeshCell Set!!!                     --------------------%
%---------------------------------------------------------------------------------%

if MeshCellSet == 1
mws.invoke('AddToHistory', ['MeshCellSet'],[
            sprintf(' With  Mesh   \n')...
            sprintf('  .MeshType "PBA"   \n')...
            sprintf(' .SetCreator "High Frequency"   \n')...
            sprintf(' End With \n')...
            sprintf(' With MeshSettings  \n')...
            sprintf('  .SetMeshType "Hex"  \n')...
            sprintf('   .Set "Version", 1%  \n')...
            sprintf('   ''MAX CELL - WAVELENGTH REFINEMENT  \n')...
            sprintf('  .Set "StepsPerWaveNear", "10"  \n')...
            sprintf('  .Set "StepsPerWaveFar", "10"  \n')...
            sprintf('  .Set "StepsPerBoxNear", "10"   \n')...
            sprintf('  .Set "WavelengthRefinementSameAsNear", "1"    \n')...
            sprintf('   ''MAX CELL - GEOMETRY REFINEMENT   \n')...
            sprintf('   .Set "StepsPerBoxNear", "10"    \n')...
            sprintf('  .Set "StepsPerBoxFar", "1"    \n')...
            sprintf('  .Set "MaxStepNear", "0"    \n')...
            sprintf('  .Set "MaxStepFar", "0"     \n')...
            sprintf('  .Set "ModelBoxDescrNear", "maxedge"   \n')...
            sprintf('  .Set "ModelBoxDescrFar", "maxedge"    \n')...
            sprintf('  .Set "UseMaxStepAbsolute", "0"     \n')...
            sprintf('  .Set "GeometryRefinementSameAsNear", "0"     \n')...
            sprintf('  ''MIN CELL    \n')...
            sprintf('  .Set "UseRatioLimitGeometry", "1"     \n')...
            sprintf('  .Set "RatioLimitGeometry", "10"     \n')...
            sprintf('  .Set "MinStepGeometryX", "0"    \n')...
            sprintf('  .Set "MinStepGeometryY", "0"     \n')...
            sprintf('  .Set "MinStepGeometryZ", "0"     \n')...
            sprintf('  .Set "UseSameMinStepGeometryXYZ", "1"      \n')...
            sprintf(' End With     \n')...
            sprintf(' With MeshSettings    \n')...
            sprintf(' .Set "PlaneMergeVersion", "2"      \n')...
            sprintf(' End With      \n')...
            sprintf(' With MeshSettings      \n')...
            sprintf(' .SetMeshType "Hex"     \n')...
            sprintf(' .Set "FaceRefinementOn", "0"     \n')...
            sprintf(' .Set "FaceRefinementPolicy", "2"      \n')...
            sprintf(' .Set "FaceRefinementRatio", "2"      \n')...
            sprintf(' .Set "FaceRefinementStep", "0"      \n')...
            sprintf('  .Set "FaceRefinementNSteps", "2"     \n')...
            sprintf(' .Set "EllipseRefinementOn", "0"     \n')...
            sprintf('  .Set "EllipseRefinementPolicy", "2"     \n')...
            sprintf(' .Set "EllipseRefinementRatio", "2"      \n')...
            sprintf(' .Set "EllipseRefinementStep", "0"     \n')...
            sprintf(' .Set "EllipseRefinementNSteps", "2"     \n')...
            sprintf('  .Set "FaceRefinementBufferLines", "3"      \n')...
            sprintf('  .Set "EdgeRefinementOn", "1"       \n')...
            sprintf('  .Set "EdgeRefinementPolicy", "1"       \n')...
            sprintf('  .Set "EdgeRefinementRatio", "2"       \n')...
            sprintf('  .Set "EdgeRefinementStep", "0"      \n')...
            sprintf('  .Set "FaceRefinementBufferLines", "3"      \n')...
            sprintf('  .Set "RefineEdgeMaterialGlobal", "0"       \n')...
            sprintf('  .Set "RefineAxialEdgeGlobal", "0"      \n')...
            sprintf('  .Set "BufferLinesNear", "3"      \n')...
            sprintf('   .Set "UseDielectrics", "1"       \n')...
            sprintf('  .Set "EquilibrateOn", "0"       \n')...
            sprintf('  .Set "Equilibrate", "1.5"      \n')...
            sprintf('  .Set "IgnoreThinPanelMaterial", "0"       \n')...
            sprintf('  End With       \n')...
            sprintf('  With MeshSettings        \n')...
            sprintf('   .SetMeshType "Hex"       \n')...
            sprintf('   .Set "SnapToAxialEdges", "1"      \n')...
            sprintf(' .Set "SnapToPlanes", "1"       \n')...
            sprintf('   .Set "SnapToSpheres", "1"       \n')...
            sprintf('  .Set "SnapToEllipses", "1"       \n')...
            sprintf('  .Set "SnapToCylinders", "1"       \n')...
            sprintf('  .Set "SnapToCylinderCenters", "1"       \n')...
            sprintf('  .Set "SnapToEllipseCenters", "1"      \n')...
            sprintf('  End With       \n')...
            sprintf('  With Mesh        \n')...
            sprintf('  .ConnectivityCheck "True"       \n')...
            sprintf('  .UsePecEdgeModel "True"        \n')...
            sprintf('  .PointAccEnhancement "0"      \n')...
            sprintf('  .TSTVersion "0"       \n')...
            sprintf('  .PBAVersion "2022060322"        \n')...
            sprintf('  End With       \n')]);;

end

FileRecord(Unitcellsplit *(LiS-1)+UiS) = string(InitialfileName); 
% mws.invoke('saveas',FilePath,'false');
% pause(1);
% mws.invoke('quit');
% pause(1);

  end
end


%---------------------------------------------------------------------------------%
%---------------------    File name  record  module!!!          --------------------%
%---------------------------------------------------------------------------------%

if FileNameRecordEnable == 1 
%Filename_Record printf
FileNameRecordPath = [FileSaveDirectirity 'Filename_Record_W.txt'];
            fprintf('[%s] Filename write in txt file... \n', datestr(now,'HH:MM:SS'));
            fileID = fopen(FileNameRecordPath,'w');
            fprintf(fileID,'File Name \n');
            fprintf(fileID,'----------------------------------------------------- \n');
            for FsP = 1:FileSplit
             fprintf(fileID,'   %s       \n',FileRecord(FsP));    
            end

            fclose(fileID);
end
%mws.invoke('rebuild'); to refresh history list
