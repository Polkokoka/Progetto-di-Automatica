clear all
clc
close all

%% Parametri
l       = 0.229;
M       = 0.57;
m       = 0.119;
mtot    = M + m;

J       = 4.458e-4;
Jtot    = m*l^2 + J;

cm      = 3;            % Forza attrito massa
cp      = 1e-5;         % Forza attrito pendolo 

g = 9.81;

s = tf('s');

% Vettore di stato x = [x teta x_dot teta_dot]
load('carroponte_param')

% Modello linearizzato 
sys_carroponte_OL = ss(A, B, C, D);

load("poli_R_ottimizzati.mat", "p1_best", "p2_best");
R = 35*(s^2 + 0.5803*s + 45)/((s + p1_best)*(s + p2_best));

% prepara la simulazione

t  = [0:0.001:15]';
x0 = [0 0*pi/180 0 0]';

% Nonlinear simulation
sim('sim_carroponte_CL_students')

%Posizione assoluta del carico
load_pos = car + l*sin(pend);
%%
% Plots
figure
sb(1) = subplot(4, 1, 1); 
plot(t, car,  'linewidth',  2); 
ylabel('x [m]');
xlabel('time [s]'); 
grid on; 

sb(2) = subplot(4, 1, 2);
plot(t, pend*180/pi,  'linewidth',  2); 
ylabel('\theta [°]'); 
xlabel('time [s]'); 
grid on

sb(3) = subplot(4, 1, 3);
plot(t, F,  'linewidth',  2); 
ylabel('Force [N]'); 
xlabel('time [s]'); 
grid on

sb(3) = subplot(4, 1, 4);
plot(t, load_pos ,  'linewidth',  2); 
ylabel('load position [m]'); 
xlabel('time [s]'); 
grid on


%%

animate_carroponte(t,[car,pend])