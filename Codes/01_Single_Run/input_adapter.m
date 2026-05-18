function [in]=input_adapter(PRECIP,RAD,TMIN,TMAX,AIRPRESS,WINDSPEED,ALBEDO,date,par)

% 
% This script contains the input data converter for W3RA
% It is largely identical to that used for AWRA-L v0.5, with the exception
% of the fraction day length (fday) which is now calculatyed with
% stronomical formulae
%
% Full documentation on remainder is found in the technical reference:
%
% Van Dijk, A.I.J.M. (2010) The Australian water resources assessment system 
% (version 0.5), 3.Technical description of the landscape hydrology model
% (AWRA-L). WIRADA Technical Report, CSIRO Water for a Healthy Country
% Flagship, Canberra.
%
% The conversions below are explained in more detail in Section 3.1.
% for enquiries please contact albert.vandijk@anu.edu.au

% Daylength
m       = 1-tan(par.latitude*pi/180).*tan((23.439*pi/180)*cos(2.*pi.*(date.doy+9)./365.25));
fday    = min(max(0.02,acos(1-min(max(0,m),2))/pi),1); %fraction daylength
    
% Assign forcing and estimate effective meteorological variables
Pg      = PRECIP.*(24*60*60);                       % from m d-1 to mm d-1
Rg      = max(RAD,0.01);                            %  already in W m-2 s-1; set minimum of 0.01 to avoid numerical problems                 
Ta      = (TMIN+ 0.75.*(TMAX-TMIN)) - 273.15 ;      % from K to degC
T24     = (TMIN+ 0.5.*(TMAX-TMIN)) - 273.15  ;      % from K to degC
pe      = 610.8.*exp(17.27.*(TMIN- 273.15)./(237.3+TMIN-273.15));
% rescale factor because windspeed climatology is at 50m
WindFactor = 0.59904;
u2      = WindFactor.*WINDSPEED.*(1-(1-fday).*0.25)./fday ;  
pair    = AIRPRESS;                                 % already in Pa
ns_alb = ALBEDO;

% Assign in correct matrix dimensions
in.Pg=[]; 
in.Rg=[]; 
in.Ta=[]; 
in.pe=[];
in.T24=[]; 
in.fday=[]; 
in.u2=[]; 
in.pair=[]; 
in.ns_alb=[];
for i=1:par.Nhru
    in.Pg   = [in.Pg; Pg];
    in.Rg   = [in.Rg; Rg];
    in.Ta   = [in.Ta; Ta];
    in.pe   = [in.pe; pe];
    in.T24  = [in.T24; T24];
    in.fday = [in.fday; fday];
    in.u2 =   [in.u2; u2];
    in.pair =   [in.pair; pair];
    in.ns_alb =   [in.ns_alb; ns_alb];
end

%=========EoF=========