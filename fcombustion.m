function [combustion, massflow] = fcombustion(comb, T_max)
%   -comb is a structure containing combustion data : 
%       -comb.Tmax    [�C] : maximum combustion temperature
%       -comb.lambda  [-] : air excess
%       -comb.x       [-] : the ratio O_x/C. Example 0.05 in CH_1.2O_0.05
%       -comb.y       [-] : the ratio H_y/C. Example 1.2 in CH_1.2O_0.05


% COMBUSTION is a structure with :
%   -combustion.LHV    : the Lower Heat Value of the fuel [kJ/kg]
%   -combustion.e_c    : the combustible exergie         [kJ/kg]
%   -combustion.lambda : the air excess                   [-]
%   -combustion.Cp_g   : heat capacity of exhaust gas     [kJ/kg/K]
%   -combustion.fum  : is a vector of the exhaust gas composition :
%       -fum(1) = m_O2f  : massflow of O2 in exhaust gas [kg/s]
%       -fum(2) = m_N2f  : massflow of N2 in exhaust gas [kg/s]
%       -fum(3) = m_CO2f : massflow of CO2 in exhaust gas [kg/s]
%       -fum(4) = m_H2Of : massflow of H2O in exhaust gas [kg/s] 

% MASSFLOW is a vector containing : 
%   -massflow(1) = m_a, air massflow [kg/s]
%   -massflow(3) = m_v, water massflow at 2 [kg/s]
%   -massflow(2) = m_c, combustible massflow [kg/s] 
%   -massflow(3) = m_f, exhaust gas massflow [kg/s]

Tmax = comb.Tmax;  %  [�C] : maximum combustion temperature
T_ex  = T3 + Tpinch;
lambda = comb.lambda; % [-] : air excess
x = comb.x; %   [-] : the ratio O_x/C. Example 0.05 in CH_1.2O_0.05
y = comb.y; %    [-] : the ratio H_y/C. Example 1.2 in CH_1.2O_0.05

PCIco = 282400e3;
PCIch4 = 802400e3;
PCIc = 393400e3;

PCI = 1e-6*(393400 + 102250*y - x/(1+0.5*y) * (111000 + 102250 * y))/(12e-3 + y * 1e-3 + x * 16e-3); %[MJ/kg]

if lambda<1
    k = (1-lambda)*2*(1+0.25*(y-2*x))/(1+0.25*y); %fraction d'imbrules
else
    k = 0;
end

%m_c = (T_max - T_init)*

ratio_O2f = ((lambda-1)*(1+0.25*(y-2*x))+0.5*k*(1+0.25*y))*32/(12+y+16*x+lambda*(1+0.25*(y-2*x))*(32+3.76*28));
ratio_N2f = (1+0.25*(y-2*x))*3.76*lambda*28/(12+y+16*x+lambda*(1+0.25*(y-2*x))*(32+3.76*28));
ratio_CO2f = (1-k)*44/(12+y+16*x+lambda*(1+0.25*(y-2*x))*(32+3.76*28));
ratio_H2Of = (1-0.5*k)*0.5*y*18/(12+y+16*x+lambda*(1+0.25*(y-2*x))*(32+3.76*28));
ratio_COf = k*28/(12+y+16*x+lambda*(1+0.25*(y-2*x))*(32+3.76*28));
ratio_H2f = 0.25*y*k*28/(12+y+16*x+lambda*(1+0.25*(y-2*x))*(32+3.76*28));

cp_f = ratio_O2f*920 + ratio_N2f*1025 + ratio_CO2f * 650 + ratio_H2Of*2010 + ratio_COf * 1050+ ratio_H2f*29.5;

I=0;
for i =1:(T3-T2)
    I = I + XSteam('Cp_pT',p2,T2+i);
end

h_lv = XSteam('hV_p',p2) - XSteam('hL_p',p2);
Q = m_v*(h_lv + I); %+surchauffeurs

m_f = Q/((Tmax-T_ex)*cp_f);

m_a = lambda*(32+3.76*28)*(1+(y-2*x)/4)/(12+y+16*x) * m_f/(1+lambda*((32+3.76*28)*(1+(y-2*x)/4)/(12+y+16*x)));
m_c = m_f - m_a;


m_O2f  = ratio_O2f*m_c; %kg/s
m_N2f = ratio_N2f*m_c;
m_CO2f = ratio_CO2f*m_c;
m_H2Of = ratio_H2Of*m_c;


end

