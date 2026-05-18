function [FreeWater,DrySnow,InSoil]=snow_submodel(Precipitation,Temperature,FreeWater,DrySnow)

% derived from HBV-96 shared by Jaap Schellekens (Deltares) in May 2011
% original in PCraster, adapted to Matlab by Albert van Dijk

MatDims=size(Precipitation);           
% Snow routine parameters
% parameters 
Cfmax=[0.6.*3.75653; 3.75653]*ones(1,MatDims(2));   % meltconstant in temperature-index - 0.6 correction is for forests
TT=-1.41934.*ones(MatDims);         % critical temperature for snowmelt and refreezing
TTI=1.00000.*ones(MatDims);        % defines interval in which precipitation falls as rainfall and snowfall
CFR=0.05000.*ones(MatDims);        % refreezing efficiency constant in refreezing of freewater in snow
WHC=0.10000.*ones(MatDims);        % fraction of Snowvolume that can store water

% Partitioning into fractions rain and snow
RainFrac=max(0,min((Temperature-(TT-TTI./2))./TTI,1)); %fraction of precipitation which falls as rain
SnowFrac=1-RainFrac;       %fraction of precipitation which falls as snow
% Snowfall/melt calculations
SnowFall=SnowFrac.*Precipitation;     %snowfall depth
RainFall=RainFrac.*Precipitation;     %rainfall depth
PotSnowMelt=Cfmax.*max(0,Temperature-TT); %Potential snow melt, based on temperature
PotRefreezing=Cfmax.*CFR.*max(TT-Temperature,0);    %Potential refreezing, based on temperature
Refreezing=min(PotRefreezing,FreeWater);       %actual refreezing
SnowMelt=min(PotSnowMelt,DrySnow);           %actual snow melt
DrySnow=DrySnow+SnowFall+Refreezing-SnowMelt; %dry snow content
FreeWater=FreeWater-Refreezing; %free water content in snow
MaxFreeWater=DrySnow.*WHC;
FreeWater=FreeWater+SnowMelt+RainFall;
InSoil = max(FreeWater-MaxFreeWater,0);  %abundant water in snow pack which goes into soil
FreeWater=FreeWater-InSoil;

%=========EoF=========
