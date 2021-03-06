%% MNPA
%  DC and AC analysis of a linear circuit using MNA techniques
%
%  Author: Ragini Bakshi, March 2021
%  Structure and Problem provided by: Professor Smy, 2021

set(0,'DefaultFigureWindowStyle','docked')
set(0, 'defaultaxesfontsize', 12)
set(0, 'defaultaxesfontname', 'Times New Roman')
set(0, 'DefaultLineLineWidth',2);

clear all
close all

%% Defining Circuit Parameters
% The capacitor and inductor in the circuit give it a Bandpass-like filter.
% There are no non-linear capacitors (hence no charge designations are needed)
R1 = 1;
C_1 = 0.25;
R2 = 2;
L = 0.2;
R3 = 10;
alpha = 100;
R4 = 0.1;
Ro = 1000;

% DC sweep for 100 Vin values
Vin = -10:0.1:10;
%Vin = Vin';

%% Breaking the circuit down into Differential Equations
% Assuming V1 is the current that flows thru Node 1, V2 is the current that flows thru Node 2,
% Iin is the current going into the circuit, Il is the current thru
% inductor, etc, the differential equations become:

G1 = 1/R1;
G2 = 1/R2;
G3 = 1/R3;
G4 = 1/R4;
Go = 1/Ro;

% V1 = Vin;
% G1(V1 - V2) + sC_1(V1 - V2) + Iin = 0;
% G1(V2 - V1) + sC_1(V2 - V1) + V2*G2 + Il = 0;
% V2 - V3 -sL = 0
% G3*V3 - Il = 0
% V4 - G3*alpha*V3 = 0
% G4*(V4 - V5) + I_alpha = 0
% G4*(V5 - V4) + V5*Go = 0

% These equations were used to construct the G conductance matrix and the C
% capacitance matrix. The F vector is for the source. 
G = zeros(6,6);
C = zeros(6,6);
F = zeros(6,1);

G(1,1) = 1;
G(2,1) = G1;
G(2,2) = -(G1+G2);
G(2,6) = -1;
G(3,3) = -G3;
G(3,6) = 1;
G(4,3) = -G3*alpha;
G(4,4) = 1;
G(5,5) = -(G4+Go);
G(5,4) = G4;
G(6,2) = -1;
G(6,3) = 1;

C(2,1) = C_1;
C(2,2) = -C_1;
C(6,6) = L;

index = 0;
for Vin = linspace(-10,10,100)
   index = index + 1;
   F(1) = Vin;
   V = G\F;
   Vout(index) = V(5);
   V_3(index) = V(3);
   Vin_vector(index) = Vin;
end

%% Outputs
% Plot 1: Vout vs Vin DC simulation (circuit has some visible gain)
figure
subplot(3,2,1)
plot(Vin_vector, Vout);
title('Vout and V3 vs. Vin DC Sim');
xlabel('Vin (V)'); 
ylabel('V (V)');
hold on;
plot(Vin_vector, V_3);
legend('Vout', 'V3')
grid on;

% Converting to frequency domain requires the taking the time derivative
% which can then be solved for any omega
index = 0;
F(1) = 1;
for w = linspace(0,100,100)
    index = index + 1;
    omega(index) = w;
    V_ac = (G + 1j*omega(index).*C)\F;
    V_out_ac(index) = V_ac(5);
    gain(index) = 20*log10(abs(V_ac(5))/F(1));
end

% Plot 2: Voltage as a function of omega (going from 0 to 100) with a peak
% at approx 18 showing Bandpass filter-like behaviour
subplot(3,2,2)
plot(omega, abs(V_out_ac));
title('Vout as a fucntion of omega');
xlabel('omega (rad/s)'); 
ylabel('Vout (V)');
grid on;

%Plot 3: Gain in dB
subplot(3,2,3)
plot(omega, gain);
title('Gain Vo/Vin dB');
xlabel('omega (rads/s)'); 
ylabel('Gain (dB)');
grid on;

% Plot 4 and 5: Monte-Carlo simulation of the circuit multiple times with a
% given standard deviation = 0.05 and normal distribution centered around the
% given values of C = 0.25 and Gain figures, with omega = pi
std = 0.05;

index = 0;
for i = linspace(0,100,1000)
    index = index + 1;
    C(2,1) = C_1 + std*randn();
    C(2,2) = -(C_1 + std*randn());
    C(6,6) = L + std*randn();
    C_o(index) = C_1 + std*randn();
    V_vector = (G + 1j*pi.*C_o(index))\F;
    V_vec = (G + 1j*pi.*C)\F;
    gain_d(index) = 20*log10(abs(V_vec(5))/F(1));
end

subplot(3,2,5)
histogram(C_o)
xlim([0.10,0.40])
xlabel('C'); 
ylabel('Number');
grid on;

subplot(3,2,6)
histogram(gain_d)
xlabel('V_o/V_i (dB)'); 
ylabel('Number');
grid on;
