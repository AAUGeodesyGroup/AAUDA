function [state,out]=W3RA_timestep_model(in,state,par)

% This cript contains the World-Wide Water Resources Assessment (W3RA) time step model
% 
% The model is modified from the Australian Water Resources Assessment
% Landscape (AWRA-L) model version 0.5
% 
% W3RA is documented in 
% van Dijk et al. (2013), Water Resour. Res., 49, 2729–2746, doi:10.1002/wrcr.20251
% URL: http://onlinelibrary.wiley.com/doi/10.1002/wrcr.20251/abstract
%
% More comprehensive documentation of AWRA-L version 0.5 can be found in:
%
% Van Dijk, A.I.J.M. (2010) The Australian water resources assessment system
% (version 0.5), 3.0.5.Technical description of the landscape hydrology model
% (AWRA-L). WIRADA Technical Report, CSIRO Water for a Healthy Country
% Flagship, Canberra. 
% URL: http://www.clw.csiro.au/publications/waterforahealthycountry/2010/wfhc-aus-water-resources-assessment-system.pdf
%
% The section references below refer to the sections in the AWRA-L report.
% Changes compared to that code are indicated, e.g. by commenting out
% redundant code.
%
% Further question please contact albert.vandijk@anu.edu.au

% ASSIGN STATE VARIABLES
S0          =   state.S0;
Ss          =   state.Ss;
Sd          =   state.Sd;
Sg          =   state.Sg;
Sr          =   state.Sr;
Mleaf       =   state.Mleaf;
% LAI        =   state.LAI;
% EVI         =   state.EVI;
FreeWater   =   state.FreeWater;  % added variables, part of snow model
DrySnow     =   state.DrySnow; % added variables, part of snow model

% ASSIGN INPUT VARIABLES
Pg          =   in.Pg; % prcp
Rg          =   in.Rg; % rad
Ta          =   in.Ta; % effective average air temp
T24         =   in.T24;
pe          =   in.pe;
pair        =   in.pair;
u2          =   in.u2; % effective wind speed at 2m 
fday        =   in.fday;  % is now calculated rather than assumed
ns_alb      =   in.ns_alb;

% ASSIGN PARAMETERS
Nhru        =   par.Nhru;
Fhru        =   par.Fhru;
SLA         =   par.SLA;          % (5.3)
LAIref      =   par.LAIref;       % (5.3)
Sgref       =   par.Sgref;
S0FC        =   par.S0FC; % accessible deep soil water storage at field capacity
SsFC        =   par.SsFC;
SdFC        =   par.SdFC;
% fday        =   par.fday;         % (3.1)
Vc          =   par.Vc;           %
alb_dry     =   par.alb_dry;      % (3.2)
alb_wet     =   par.alb_wet;      % (3.2)
w0ref_alb   =   par.w0ref_alb;    % (3.2)
Gfrac_max   =   par.Gfrac_max;    % (3.5)
fvegref_G   =   par.fvegref_G;    % (3.5)
hveg        =   par.hveg;         % (3.7)
Us0         =   par.Us0;          % (2.3)
Ud0         =   par.Ud0;          % (2.3)
wslimU      =   par.wslimU;
wdlimU      =   par.wdlimU;
cGsmax      =   par.cGsmax;
FsoilEmax   =   par.FsoilEmax;    % (4.5)
w0limE      =   par.w0limE;       % (4.5)
FwaterE     =   par.FwaterE;      % (4.7)
S_sls       =   par.S_sls;        % (4.2)
ER_frac_ref =   par.ER_frac_ref;  % (4.2)
InitLoss    =   par.InitLoss;     % (2.2)
PrefR       =   par.PrefR;        % (2.2)
FdrainFC    =   par.FdrainFC;     % (2.4)
beta        =   par.beta;         % (2.4)
Fgw_conn    =   par.Fgw_conn;     % (2.6)
K_gw        =   par.K_gw;         % (2.5)
K_rout      =   par.K_rout;       % (2.7)
LAImax      =   par.LAImax;       % (5.5)
Tgrow       =   par.Tgrow;        % (5.4)
Tsenc       =   par.Tsenc;        % (5.4)

% diagnostic equations
LAI         =   SLA.*Mleaf;    % (5.3) 
% Mleaf        =   LAI./SLA;    % (5.3)
fveg        =   1 - exp(-LAI./LAIref) ;     % (5.3)
% Vc          =   max(0,EVI-0.07)./fveg;
fsoil       =   1 - fveg;
w0          =   S0./S0FC;     % (2.1)
ws          =   Ss./SsFC;     % (2.1)
wd          =   Sd./SdFC;     % (2.1)

TotSnow     =   FreeWater+DrySnow;
wSnow       =   FreeWater./(TotSnow+1e-5);

% Spatialise catchment fractions
fwater=[];fsat=[]; Sghru=[];
Sgfree=max(Sg,0);
for i=1:par.Nhru
    fwater  =   [fwater; min(0.005,0.007.*Sr.^0.75)]; % fraction of area covered by water
    fsat    =   [fsat; min(1,max(min(0.005,0.007.*Sr.^0.75),Sgfree./Sgref))]; % fraction of area covered by satured soil (2.3)
    Sghru   =   [Sghru; [Sg]];
end
        
% CALCULATION OF PET
% Conversions and coefficients (3.1)
pes         =   610.8.*exp(17.27.*Ta./(237.3+Ta));     % saturated vapour pressure
fRH         =   pe./pes;     % relative air humidity
cRE         =   0.03449+4.27e-5.*Ta;
Caero       =   fday.*0.176.*(1+Ta./209.1).*(pair-0.417.*pe).*(1-fRH);
keps        =   1.4e-3.*((Ta./187).^2+Ta./107+1).*(6.36.*pair+pe)./pes;
Rgeff       =   Rg./fday;
% shortwave radiation balance (3.2)
%alb_veg     =   0.452.*Vc;
%alb_soil    =   alb_wet+(alb_dry-alb_wet).*exp(-w0./w0ref_alb);
% new equations for snow albedo
alb_snow    =   0.65-0.2.*wSnow;         % assumed; ideally some lit research needed
fsnow       =   min(1,0.05*TotSnow);   % assumed; ideally some lit research needed
%alb         =   fveg.*alb_veg+(fsoil-fsnow).*alb_soil +fsnow.*alb_snow;
%alb         =   albedo;
alb         =   (1-fsnow).*ns_alb +fsnow.*alb_snow;
RSn         =   (1-alb).*Rgeff;
% long wave radiation balance (3.3 to 3.5)
StefBolz    =   5.67e-8;
Tkelv       =   Ta+273.16;
RLin        =   (0.65.*(pe./Tkelv).^0.14).*StefBolz.*Tkelv.^4;     % (3.3)
RLout       =   1.*StefBolz.*Tkelv.^4;      % (3.4)
RLn         =   RLin-RLout;
fGR         =   Gfrac_max.*(1-exp(-fsoil./fvegref_G));     % (3.5)
Rneff       =   (RSn+RLn).*(1-fGR);
% Aerodynamic conductance (3.7)
fh          =   log(813./hveg-5.45);
ku2         =   0.305./(fh.*(fh+2.3));
ga          =   ku2.*u2;
%  Potential evaporation
kalpha      =   1+Caero.*ga./Rneff;
E0          =   cRE.*(1./(1+keps)).*kalpha.*Rneff.*fday;
E0          =   max(E0,0);

% CALCULATION OF ET FLUXES AND ROOT WATER UPTAKE
% Root water uptake constraint (4.4)
Usmax       =   max(0, Us0.*min(1,ws./wslimU) );
Udmax       =   max(0, Ud0.*min(1,wd./wdlimU) );
% U0max       =   max(0, Us0.*min(1,w0./wslimU) );
U0max       = 0;
Utot        =   max(Usmax, max(Udmax,U0max) );

% Maximum transpiration (4.3)
Gsmax       =   cGsmax.*Vc;
gs          =   fveg.*Gsmax;
ft          =   1./(1+(keps./(1+keps)).*ga./gs);
Etmax       =   ft.*E0;
% Actual transpiration (4.1)
Et          =   min(Utot, Etmax);
% % Root water uptake distribution (2.3)
U0          =   max( min( (U0max./(U0max + Usmax + Udmax)).*Et, S0-1e-2 ) , 0);
Us          =   max( min( (Usmax./(U0max + Usmax + Udmax)).*Et, Ss-1e-2 ) , 0);
Ud          =   max( min( (Udmax./(U0max + Usmax + Udmax)).*Et, Sd-1e-2 ) , 0);
Et          =   U0 + Us + Ud;      % to ensure mass balance
% Soil evaporation (4.5);
S0          =   max(0, S0 - U0);
w0          =   S0./S0FC;     % (2.1)
fsoilE      =   FsoilEmax.*min(1,w0./w0limE) ;
Es          =   max(0, min( (1-fsat).*fsoilE.*( E0-Et ), S0-1e-2 ) ) ;
% Groundwater evaporation (4.6);
Eg          =   min( (fsat-fwater).*FsoilEmax.*( E0-Et ), Sghru) ;
% Open water evaporation (4.7);
Er          =   min(fwater.*FwaterE.*max(0, E0-Et ), [Sr; Sr]);
% Rainfall interception evaporation (4.2)
Sveg        =   S_sls.*LAI;
fER         =   ER_frac_ref.*fveg;
Pwet        =   -log(1-fER./fveg).*Sveg./fER;
Ei          =   (Pg<Pwet).*fveg.*Pg+(Pg>=Pwet).*(fveg.*Pwet+fER.*(Pg-Pwet));

% HBV snow routine
Pn  = Pg-Ei;
%InSoil=Pn;
[FreeWater,DrySnow,InSoil]=snow_submodel(Pn,T24,FreeWater,DrySnow);

% CALCULATION OF WATER BALANCES
% surface water fluxes (2.2)
NetInSoil   =   max(0, InSoil - InitLoss)  ;
Rhof    	=   (1-fsat).*( NetInSoil./(NetInSoil+PrefR) ).*NetInSoil  ;
Rsof        =   fsat .*NetInSoil ;
QR          =   Rhof + Rsof ; % estimated event surface runoff [mm] (2.3)
I           =   InSoil - QR  ;
% SOIL WATER BALANCES (2.1 & 2.4)
% Topsoil water balance (S0)
S0          =   S0  + I - Es - U0 ;
SzFC        =   S0FC;
Sz          =   S0;
wz          =   max(1e-2,Sz)./SzFC;
fD          =  (wz>1).*max(FdrainFC,1-1./wz) + (wz<=1).*FdrainFC.*exp(beta.*(wz-1) );
Dz          =   max(0, min(fD.*Sz,Sz-1e-2));
D0          =   Dz;
S0          =   S0  - D0 ;
% Shallow root zone water balance (Ss)
Ss          =   Ss  + D0 -  Us;
SzFC        =   SsFC;
Sz          =   Ss;
wz          =   max(1e-2,Sz)./SzFC;
fD          =  (wz>1).*max(FdrainFC,1-1./wz) + (wz<=1).*FdrainFC.*exp(beta.*(wz-1) );
Dz          =   max(0, min(fD.*Sz,Sz-1e-2));
Ds          =   Dz;
Ss          =   Ss  - Ds ;
% Deep root zone water balance (Sd) (2.6)
Sd          =   Sd  + Ds -  Ud;
SzFC        =   SdFC;
Sz          =   Sd;
wz          =   max(1e-2,Sz)./SzFC;
fD          =  (wz>1).*max(FdrainFC,1-1./wz) + (wz<=1).*FdrainFC.*exp(beta.*(wz-1) );
Dz          =   max(0, min(fD.*Sz,Sz-1e-2) ); % drainage from layer z [mm d^-1] (2.5)
Dd          =   Dz;
Sd          =   Sd  - Dd;
Y           =   min(Fgw_conn.*max(0,wdlimU.*SdFC-Sd),Sghru-Eg); % capillary rise of groundwater into deeper root zone (2.7)
%Y           =   Fgw_conn.*max(0,wdlimU.*SdFC-Sd);
Sd          =   Sd + Y;

% CATCHMENT WATER BALANCE
% Groundwater store water balance (Sg) (2.5)
NetGf       =   sum(Fhru.*(Dd - Eg - Y));
Sg          =   Sg + NetGf;
Sgfree      =   max(Sg,0);
Qg          =   min(Sgfree, (1-exp(-K_gw)).*Sgfree) ; % groundwate discharge into stream (2.6)
Sg          =   Sg - Qg; % groundwater reservoir storage
% Surface water store water balance (Sr) (2.7)
Sr          =   Sr  +  sum(Fhru.*(QR - Er) ) + Qg ;
Qtot        =   min(Sr, (1-exp(-K_rout)).*Sr) ;
Sr          =   Sr  - Qtot;

% VEGETATION ADJUSTMENT (5)
fveq        =   (1./max((E0./Utot)-1,1e-3)).*(keps./(1+keps)).*(ga./Gsmax); % (5.5)
fvmax       =   1-exp(-LAImax./LAIref); % maximum achievable canopy cover
fveq        =   min(fveq,fvmax);
dMleaf      =   -log(1-fveq).*LAIref./SLA-Mleaf ; % equilibrium dry leaf biomass 
Mleafnet    =   (dMleaf>0).*(dMleaf./Tgrow) +(dMleaf<0).*dMleaf./Tsenc; % net biomass change of living leaves [kg/m^2] (5.2)
Mleaf       =   Mleaf + Mleafnet;


% Updating diagnostics
LAI         =   SLA.*Mleaf;    % (5.3) SLA=specific leaf area
fveg        =   1 - exp(-LAI./LAIref) ;     % (5.3) canopy fractional cover
fsoil       =   1 - fveg;
w0          =   S0./S0FC;     % (2.2)
ws          =   Ss./SsFC;     % (2.2)
wd          =   Sd./SdFC;     % (2.2)

% ASSIGN OUTPUT VARIABLES
% fluxes
out.Pg      =   sum(Fhru.*Pg);
out.E0      =   sum(Fhru.*E0);
out.Ee      =   sum(Fhru.*(Es + Eg + Er + Ei));
% out.Eg      =   sum(Fhru.*Eg);
out.Et      =   sum(Fhru.*Et);
out.Ei      =   sum(Fhru.*Ei);
out.Etot    =   out.Et + out.Ee;
out.Qtot    =   Qtot;
out.Qg      =   Qg;
out.QR      =   sum(Fhru.*QR);
out.gwflux  =   NetGf;
out.D       =   sum(Fhru.*Dd);
% HRU specific drainage
% out.D1    = Dd(1,:);
% out.D2    = Dd(2,:);
% out.Et1   = Et(1,:);
% out.Et2   = Et(2,:);
ETtot      = Es + Eg + Er+ Ei+ Et;
out.ET1   = ETtot(1,:);
out.ET2   = ETtot(2,:);
% states
out.S0      =   sum(Fhru .* S0);
out.Ss      =   sum(Fhru .* Ss);
out.Sd      =   sum(Fhru .* Sd);
out.Sg      =   Sg;
out.Sr      =   Sr;
out.Ssnow   =  sum(Fhru .*  (FreeWater + DrySnow ) ) ;
out.Stot    =   out.S0 + out.Ss + out.Sd + Sg + Sr + out.Ssnow + sum(Fhru .* Mleaf.*4);    % assume 80% water  in biomass
out.Mleaf   =   sum(Fhru .* Mleaf);
out.LAI     =   sum(Fhru .* LAI);
out.fveg    =   sum(Fhru .* fveg) ;
% out.fveq    =   sum(Fhru .* fveq);
% satellite equivalent
out.albedo  =   sum(Fhru .* alb ) ;
out.EVI     =   sum(Fhru .* (Vc.*fveg+0.07) ) ;     % assume 0.07 is EVI for bare soil
out.fsat    =   sum(Fhru .* fsat); % fraction of area covered by saturated soil
out.wunsat  =   sum(Fhru .* w0);

% ASSIGN STATE VARIABLES
state.S0    =   S0;
state.Ss    =   Ss;
state.Sd    =   Sd;
state.Sg    =   Sg;
state.Sr    =   Sr;
state.Mleaf =   Mleaf;
state.LAI   =   LAI;
state.FreeWater = FreeWater; 
state.DrySnow = DrySnow;

%=========EoF=========
