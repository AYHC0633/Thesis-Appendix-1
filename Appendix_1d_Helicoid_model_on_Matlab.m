
clc
clear
% close all
HS = conformalArray ()
uc = circularArray ()
% CUDi = dipole ()
% %------ Conformal array definition----% %
    %--- Unit Cell---%

% %----property of circular Array setting ---%
       %% array = circularArray(Name,Value) for universal format, name is property name (eg Element)
       fprintf('[%s] Program started... \n', datestr(now,'HH:MM:SS'));
       Nu = 3 % number of element
       f=24.5e8 %240 MHz
       c=3e8
       WL =c/f
      CUDi = design(dipole (),f);
       R = (WL/8)/cosd(30) %/sqrt(3)%M/(2*sin(pi/Nu)) %for each antenna are equally spacing 
       
      
       NoE = 7 % has to be odd number,if shifting this number make sure to shift the axis 
       layer = 11
       EleSp = WL/2 %element spacing
       LaySP = WL/2 %layer spacing

CUDi.Length = WL/2 %  length in meter, default for 75MHz for dipole 
CUDi.Width = WL/48.1 %


% % ------ Property of conformal Array setting ------ % %
   
    %--- structure generator ---%
% polar plot axis
    DTR = pi/180 %DegToRad
    RTD = 180/pi %DegToRad

     % Unit element config.
        ElementSpacing = WL/4
        a =  (ElementSpacing/2)/cosd(30) %radius of circular array % Spacing = Sqrt(3)* radius;  for 3 element antenna
        Nu = 3 % number of element 
        for N = 1:Nu
        PhiD(N) = ((2*pi)/Nu)*(N-1) % unitcell spacing location
        end
        
        % UnitCell config.
        UNu = 7%Number of Unitcell
        dx = WL/2 % Unitcell spacing
        LayPhaShifx = 0

        %Layer config 
        LNu = 11 % No. of Layer
        dz =WL/2
        StrPhaShifz = 0

fprintf('[%s] constructing CASSIOPeiA array... \n', datestr(now,'HH:MM:SS'));

Co = 1;
 for L = 1:LNu

            for N = 1:Nu
            PhiD(N) = (((2*pi)/Nu)*(N-1)+((L-1)*(180/LNu)*DTR)); % unitcell spacing location
            end

       for M = 1:UNu   
        for N = 1:Nu

         Coorinate(Co,1:3) = [a*sin(pi/2)*cos(0-PhiD(N))+(M-round(UNu/2))*dx*sin(pi/2)*cos(0-((L-1)*(180/LNu)*DTR))  a*sin(pi/2)*cos((pi/2)-PhiD(N))+(M-round(UNu/2))*dx*sin(pi/2)*cos((pi/2)-((L-1)*(180/LNu)*DTR))  (L-1)*dz*cos(0)];
         Co = Co+1;
         end 
       end
 end

HS.Element = CUDi%Structure %{uc uc}                         
HS.ElementPosition = Coorinate %LayerCO %[Couc;Couc1]
    %---------------------------%
 
PhiStr = 90;
ThetaStr = 0;

HS.Reference = 'feed'% CoA = conformalArray ('Reference',1)
HS.AmplitudeTaper = 1%  CoA = conformalArray ('AmplitudeTaper',1)
HS.PhaseShift = phaseShift(HS,f,[PhiStr;ThetaStr]) %  CoA = conformalArray ('PhaseShift',1)
HS.Tilt = 0 %  CoA = conformalArray ('Tilt',0)
HS.TiltAxis = [1 0 0]%  CoA = conformalArray ('TiltAxis',[1 0 0])

 

% %---show ,plot view-----% %
    figure
    layout(HS) %show the layout of array in 2D
 
     figure
     show(HS)%show the layout of array in 3D
 
    figure
    pattern(HS,f)% in 3D radiation pattern (arrray, Frequency = 70MHz)
%   
%     figure
%     patternAzimuth(HS,f)% in 2D Azimuth plan, [Front view]
%     
%     figure
%     patternElevation(HS,f)% in 2D Azimuth
