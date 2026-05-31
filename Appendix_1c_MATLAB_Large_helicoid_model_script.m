
clc
clear
close all


%--------Super Large CAssie setting 
    TLnu = 20000;% final layer
    TUnu =20000; % final cell
    
    Layerperfile = 5000;%Layer per each Matlab file 
    Unitcellperfile = 5000;%Layer per each cell file 
    
    divLaynum=TLnu/Layerperfile;%
    divUCnum=TUnu/Unitcellperfile;%
     
    FileSplit =  divLaynum* divUCnum;% total of file split

    for i = 1:divLaynum
        if i==1
            Laylowerlim(i)= min([1:Layerperfile]+Layerperfile*(i-1));
            Layupperlim(i)=max([1:Layerperfile]+Layerperfile*(i-1));
        else
            Laylowerlim(i)= min(([1:Layerperfile]+Layerperfile*(i-1)));
            Layupperlim(i)=max([1:Layerperfile]+Layerperfile*(i-1));
        end
    end 

    for i = 1:divUCnum
        if i==1
            Unilowerlim(i)= min([1:Unitcellperfile]+Unitcellperfile*(i-1));
            Uniupperlim(i)=max([1:Unitcellperfile]+Unitcellperfile*(i-1));
        else
            Unilowerlim(i)= min(([1:Unitcellperfile]+Unitcellperfile*(i-1)));
            Uniupperlim(i)=max([1:Unitcellperfile]+Unitcellperfile*(i-1));
        end
    end 

    %$----steering angle
    SteeringPhi = 90; 
    SteeringTheta = 90; 
    VertError = 3;

FileNameRecordEnable = 1;
FileSplitEnable = 1;

% FileSaveDirectirity = 'K:\OneDrive - Queen''s University Belfast\PHD research\Matlab_\MTC testing\MTC Casseopeia array generator\CST Automation & Assistant Toolbox\Phase and data output calculator\Matlab Final Helicoid\20000x20000Test\';
FileSaveDirectirity = '20000x20000HozErrorImprvoeAccuracy3degreeError/';
%gpuDevice()


%%%------------------------each mathlab file generator--------------
for LiS=1:divLaynum
    for UiS =1:divUCnum

        %%%------------------------each mathlab file and result name--------------
            if FileSplitEnable == 1
                InitialfileName= ['CASS' num2str(TLnu) 'x' num2str(TUnu) '_' num2str(divUCnum *(LiS-1)+UiS) 'of_' num2str(FileSplit) '.m']; 
                K2FileName(divUCnum *(LiS-1)+UiS)= string(['CASS' num2str(TLnu) 'x' num2str(TUnu) '_' num2str(divUCnum *(LiS-1)+UiS) 'of_' num2str(FileSplit)]); 
                FilePath = [FileSaveDirectirity InitialfileName];%[FileSaveDirectirity InitialfileName];
                Resultname=['CASSEfield_' num2str(divUCnum *(LiS-1)+UiS) '_of_' num2str(FileSplit) '.csv'];
                Storename(divUCnum *(LiS-1)+UiS,:) = [string(InitialfileName) string(Resultname)];
                ShellScriptName(divUCnum *(LiS-1)+UiS) = string(char(['MAT_GPUCassie_' num2str(divUCnum *(LiS-1)+UiS) '_of_' num2str(FileSplit) '.sh']));
            end
            
            Layerfile = length(Laylowerlim(LiS):Layupperlim(LiS));
            Unitcellfile =length(Unilowerlim(UiS):Uniupperlim(UiS));
            fileID = fopen(FilePath,'w');
            fprintf(fileID,['format long \n'...
			                'DTR = pi/180; \n'...
                            'RTD = 180/pi; \n' ...
                            'theta = linspace(89.5,90.5,701);\n' ...
                            'phi = linspace(89.5,90.5,701);\n' ...
                            'C= physconst(''LightSpeed'');\n' ...
                            'F=2.45e9; \n' ...
                            'WL=C/F;  \n' ...
                            'k =(2*pi)/WL; \n' ...
                            'UNu = %d ;\n'...
                            'dx = 0.1; \n'...
                            'Clk = -1;\n'],TUnu);
            fprintf(fileID,['errorR= %f/%d; \n'],VertError,TLnu);
            fprintf(fileID,['%%NoError=linspace(0,0,%d).*(linspace(0,0,%d)'');\n'],Unitcellfile,Layerfile);
            fprintf(fileID,['LNu = %d;\n'...
                            'dz = 0.1; \n'...
                            'StTh = %d;\n'...
                            'StPh = %d;\n'...
                            'HozError=linspace(1,1,%d).*(linspace(%d,%d,%d)''*errorR);\n' ...   
                            'parallel.gpu.enableCUDAForwardCompatibility(true) \n' ...
                            'tic \n' ...
                            'LogDirNE= helicalArrayCalculator(theta,phi,LNu,UNu,StTh,StPh,dx,dz,Clk,k,HozError);\n' ...
                            '\n ' ],TLnu,SteeringPhi,SteeringTheta,Unitcellfile,Laylowerlim(LiS),Layupperlim(LiS),Layerfile);
            fprintf(fileID,['toc \n']); 
            fprintf(fileID,['writematrix(LogDirNE,''%s'');\n'],Resultname); 
             
            fprintf(fileID,['function Eview= helicalArrayCalculator(theta,phi,LNu,UNu,StTh,StPh,dx,dz,Clk,k,phaseError)'...
                            '\n ' ...
                            '   DTR = pi/180; %%DegToRad \n'...
                            '   RTD = 180/pi;\n'...
                            '   Lay = gpuArray([%d:%d]'');\n'...
                            '   Nel = gpuArray([%d:%d]);\n'...
                            '   Eview=zeros(length(phi),length(theta));\n'...
                            '   if mod(UNu,2) == 0 \n'...
                            '       rtpos = (UNu/2+0.5); \n'...
                            '   else  \n'...
                            '       rtpos = round(UNu/2);\n'...
                            '   end \n' ...
                            '\n '],Laylowerlim(LiS),Layupperlim(LiS),Unilowerlim(UiS),Uniupperlim(UiS));
            
            fprintf(fileID,['LayPhaShifx= -(Nel-rtpos)*k*dx*sind(StTh).*cosd(StPh-(Clk*(Lay-1)*(180/LNu)));%% steering config in Layer\n'...
                            'StrPhaShifz= -ones(1,length(Nel)).*((Lay-1)*k*dz*cosd(StTh)); %% steering config in structure\n'...
                            'PhaShifTab = gpuArray((LayPhaShifx + StrPhaShifz)'');\n'...
                            'phaseerror =gpuArray(phaseError);\n'...
                            '    for ith = 1:length(theta)\n'  ...  
                            '        parfor iph = 1:length(phi)\n'  ...        
                            '           LayAF = (Nel-rtpos)*k*dx*sind(theta(ith)).*cosd(phi(iph)-(Clk*(Lay-1)*(180/LNu)));\n'...
                            '           StrAF = ones(1,length(Nel)).*((Lay-1)*k*dz*cosd(theta(ith)));\n'...
                            '           totalAF =gpuArray((LayAF+StrAF)'');\n'...
                            '           overalpattern =PhaShifTab+totalAF+phaseerror;\n'...
                            '           AF =gpuArray(1.6*sind(theta(ith))*exp(j*overalpattern));\n'...
                            '           Eview(iph,ith) = sum(sum(AF));\n' ...
                            '        end\n'...
                            '    end\n'...
                        'end\n']);
           
            % fprintf(fileID,['save("%s.txt","LogDirNE","-ascii")'],Resultname);
            fclose(fileID);
   
    end 
end

    %---------calculate

if FileNameRecordEnable == 1 
%Filename_Record printf
FileNameRecordPath = [FileSaveDirectirity 'MatlabFilename_Record.txt'];
            fprintf('[%s] Filename write in txt file... \n', datestr(now,'HH:MM:SS'));
            fileID = fopen(FileNameRecordPath,'w');
            fprintf(fileID,'File Name \n');
            fprintf(fileID,'----------------------------------------------------- \n');
            for FsP = 1:FileSplit
             fprintf(fileID,'   %s  \n',Storename(FsP,1));    
            end

            fclose(fileID);


            FileNameRecordPath = [FileSaveDirectirity 'MatlabFileResult.txt'];
            fprintf('[%s] Filename write in txt file... \n', datestr(now,'HH:MM:SS'));
            fileID = fopen(FileNameRecordPath,'w');
            fprintf(fileID,'File Name \n');
            fprintf(fileID,'----------------------------------------------------- \n');
            for FsP = 1:FileSplit
             fprintf(fileID,'   %s   \n',Storename(FsP,2));    
            end

            fclose(fileID);

end



%%-----kelvin 2 script generator
Kelvin2GPUScript=1;
if Kelvin2GPUScript == 1
     for FsP = 1: FileSplit
            
            FileNameRecordPath = [FileSaveDirectirity char(ShellScriptName(FsP))];
            fprintf('[%s] Matlab (gpu) Filename write in txt file... \n', datestr(now,'HH:MM:SS'));
            fileID = fopen(FileNameRecordPath,'w');
             fprintf(fileID,'#!/bin/bash \n');
             fprintf(fileID,'\n \n');
             fprintf(fileID,'#SBATCH --job-name=MatGPUCass_%i \n',FsP);
             fprintf(fileID,'#SBATCH --time=0:50:00 \n');
             fprintf(fileID,'#SBATCH --partition=k2-gpu-a100 \n');
             fprintf(fileID,'#SBATCH --cpus-per-task=12 \n');
             fprintf(fileID,'#SBATCH --ntasks=2 \n');
             fprintf(fileID,'#SBATCH --mem-per-cpu=32G \n');
             fprintf(fileID,'#SBATCH --gres=gpu:a100:1 \n');
             fprintf(fileID,'#SBATCH --output=matlab_output_%i.out \n',FsP);
             fprintf(fileID,'\n \n');
             fprintf(fileID,'module load matlab/R2022a \n');
             fprintf(fileID,'\n \n');
             fprintf(fileID,'module load libs/nvidia-cuda/12.4.0 \n');
             fprintf(fileID,'\n \n');
      
             fprintf(fileID,'matlab -nosplash -nodisplay -r "%s"',K2FileName(FsP));
             fclose(fileID);
             filenameArray(FsP) = ShellScriptName(FsP);
     end
end
ExecuteBashScriptEnable=1;
GroupFileEnable = 1;
if ExecuteBashScriptEnable == 1 && GroupFileEnable == 1
    FileNameRecordPath = [FileSaveDirectirity char(['AYHC_batch_file.sh'])];
    fprintf('[%s] Main Filename write in txt file... \n', datestr(now,'HH:MM:SS'));
    fileID = fopen(FileNameRecordPath,'w');
    for FsP = 1: FileSplit
        fprintf(fileID,'sbatch %s \n',filenameArray(FsP));
    end
     fclose(fileID);

    FileNameRecordPath = [FileSaveDirectirity char(['Del_AYHC_batch_file.sh'])];
    fprintf('[%s] Delete filename write in txt file... \n', datestr(now,'HH:MM:SS'));
    fileID = fopen(FileNameRecordPath,'w');
    for FsP = 1: FileSplit
        fprintf(fileID,'scancel %s \n',filenameArray(FsP));
    end
     fclose(fileID);

end





%%==========================================Remark====================
function Eview= helicalArrayCalculator(theta,phi,LNu,UNu,StTh,StPh,dx,dz,Clk,k,phaseError)

    DTR = pi/180; %DegToRad
    RTD = 180/pi; %DegToRad
    
    Lay = gpuArray([1:LNu]');
    Nel = gpuArray([1:UNu]) ;
    Eview=zeros(length(theta),length(phi));
    if mod(UNu,2) == 0
        rtpos = (UNu/2+0.5);
    else 
        rtpos = round(UNu/2);
    end

    for ith = 1:length(theta)    
        parfor iph = 1:length(phi)       
            LayPhaShifx= -(Nel-rtpos)*k*dx*sind(StTh).*cosd(StPh-(Clk*(Lay-1)*(180/LNu)));% steering config in Layer
            StrPhaShifz= -ones(1,length(Nel)).*((Lay-1)*k*dz*cosd(StTh)); % steering config in structure
            PhaShifTab = gpuArray((LayPhaShifx + StrPhaShifz)');
            % Exp_AFPhaseShift = exp(j*PhaShifTab)';
    
            LayAF = (Nel-rtpos)*k*dx*sind(theta(ith)).*cosd(phi(iph)-(Clk*(Lay-1)*(180/LNu)));
            StrAF = ones(1,length(Nel)).*((Lay-1)*k*dz*cosd(theta(ith)));
            totalAF =gpuArray((LayAF+StrAF)');
            % AFonly = exp(j*gpuArray(LayAF+StrAF))';
            
            phaseerror =gpuArray(phaseError);
            % phaseerror =exp(j*gpuArray(phaseError));
            
            overalpattern =PhaShifTab+totalAF+phaseerror;
            AF =gpuArray(1.6*sind(theta(ith))*exp(j*overalpattern));
            %AF = 1.6*sind(theta(ith))*AFonly.*Exp_AFPhaseShift.*phaseerror;
            Eview(iph,ith) = sum(sum(AF))/(LNu*UNu);    
         end
    end

end

% format longG
% arraysize = 45000*45000*8;
% inKB = arraysize/1024;
% inMB = arraysize/1024^2;
% inGB = arraysize/1024^3;
% fprintf("The array will need  %.0f or %.5f KB or %.5f MB or %.5f GB of memory",arraysize, inKB, inMB, inGB)
