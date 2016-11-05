function a_ballistic_equations()

clc

%% create the 2D space

xmin = 0;
xmax = 10;

ymin = 0;
ymax = 5;

%% Target trajectory

xTarg = linspace(xmin,xmax,50);

g = 9.8; % gravitational constant
y0 = 0; % initial height
theta = 60; % incidence of launch
vel = 10; % velocity of launch

yfunc = @(xin) y0 + xin.*tand(theta) - g.*xin.^2./(2*(vel*cosd(theta)).^2);

% actual x vector
xTarg(yfunc(xTarg) < ymin) = nan;
yTarg = yfunc(xTarg);

figure(1), clf
plot(round(xTarg), round(yTarg), 'r.','MarkerSize',20)
axis([xmin xmax ymin ymax])
grid on
