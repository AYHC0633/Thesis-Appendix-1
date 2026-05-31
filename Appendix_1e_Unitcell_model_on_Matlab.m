
clc
clear
close all

CUDi = dipoleCylindrical()%design(dipole, 2.4e9)
CA = circularArray() %design(circularArray('Element', CUDi), 2.4e9, CUDi);% circularArray () % Circular antenna array created, default 4x4
% %----property of circular Array setting ---%
       %% array = circularArray(Name,Value) for universal format, name is property name (eg Element)
       Nu = 3 % number of element
       f= 2.45e9 %240 MHz
       c=physconst('lightspeed');
       freqRange = (1.8:0.1:3.6)*1e9; refImpedance = 50;
       WL = c/f %wavelength  
       unitcellspacing = WL/4;
       R = ((unitcellspacing)/2)/cosd(30); %M/sqrt(3)%M/(2*sin(pi/Nu)) %for each antenna are equally spacing 

CUDi.Length = WL/2 %  length in meter, default for 75MHz for dipole 
CUDi.Radius = 1e-3%(WL/2)/48.1 %

%phase beam steering %

PhiStr = 0
ThetaStr = 0
%phSH = phaseShift(CA1,f,[PhiStr;ThetaStr]);%only enable it when the programme run second time.(without clc clear command)

CA.Element = CUDi
CA.NumElements = Nu %  CA = circularArray ('NumElements',10)
CA.Radius = R %  CA = circularArray ('Radius',1)
CA.AngleOffset = 0%  CA = circularArray ('AngleOffset',0)
CA.AmplitudeTaper = [1 1 1]%[1 1 1]%<---paperproposed%[ones(1,Nu)]%  CA = circularArray ('AmplitudeTaper',1)
CA.PhaseShift = phaseShift(CA,f,[PhiStr;ThetaStr])%[phSH(1) phSH(2) phSH(3)]%phaseShift(CA,f,[PhiStr;ThetaStr]); %[0 0 0]%paper proposed %[zeros(1,Nu)]%  CA = circularArray ('PhaseShift',1)
CA.Tilt = 0 %  CA = circularArray ('Tilt',0)
CA.TiltAxis = [0 0 1]%  CA = circularArray ('TiltAxis',[1 0 0])

Location = CA.FeedLocation 

Spacing = sqrt((abs(Location(1,1)-Location(2,1))^2)+(abs(Location(1,2)-Location(2,2))^2))

%%---show ,plot view-----%%

% % % % % 
figure
show(CA)%show the layout of array in 3D

  figure
 pattern(CA,f)% in 3D radiation pattern




azRange =[-180:1:180];%0:1:360;

%% phase with mutual coupling
counter= 1;
  for PPhi = -90:30:90
    phSH = phaseShift(CA,f,[PPhi;ThetaStr]);
    CA.PhaseShift = phSH ;%[phSH(1) phSH(2) phSH(3)];
    Phasedatastore(counter,:)=phSH;
    a = patternAzimuth(CA,f);%patternMultiply(CA,f, azRange, 0);%%arrayFactor(CA,f)%
    polarplot(azRange*pi/180,a,'DisplayName',['Phi = ' num2str(PPhi)])%plot(azRange,a)%%(theta,abs(Eview(:,90)))
    pax.ThetaZeroLocation='Top'
    pax.RLim = [-inf inf]%[LL UL]
    axis([-inf inf -inf inf])
    hold on
    counter = counter +1; 
  end
  legend
  

  %% phase without mutual coupling
  figure
  counter= 1;
  for PPhi = -90:30:90
    phSH = phaseShift(CA,f,[PPhi;ThetaStr]);
    CA.PhaseShift = phSH ;%[phSH(1) phSH(2) phSH(3)];
    Phasedatastore(counter,:)=phSH;
    a = patternMultiply(CA,f, azRange, 0);%%arrayFactor(CA,f)%
    polarplot(azRange*pi/180,a,'DisplayName',['Phi = ' num2str(PPhi)])%plot(azRange,a)%%(theta,abs(Eview(:,90)))
    pax.ThetaZeroLocation='Top'
    pax.RLim = [-inf inf]%[LL UL]
    axis([-inf inf -inf inf])
    hold on
    counter = counter +1; 
  end
  legend
