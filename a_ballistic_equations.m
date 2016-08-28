clear, clc

%% create the 2D space

xmax = 100;
ymax = 50;

%% Target trajectory

xTarg = linspace(0,xmax,50);

g = 9.8; % gravitational constant
y0 = 0.1; % initial height
theta = 45; % incidence of launch
vel = 30; % velocity of launch

yfunc = @(xin) y0 + xin.*tand(theta) - g.*xin.^2./(2*(vel*cosd(theta)).^2);

% actual x vector
xTarg(yfunc(xTarg) < 0) = nan;
yTarg = yfunc(xTarg);

figure(1), clf
plot(xTarg, yTarg, 'r.','MarkerSize',20)
axis([0 xmax 0 ymax])
grid on

%% All possible cursor positions

xspace = -xmax:xmax;
yspace = -ymax:ymax;

% there are four possible actions for now
% 1 = left, 2 = up, 3 = right, 4 = down

% initialize a matrix of actions, all random for now
Qgrid = randi([1 4],[length(xspace),length(yspace)]);

% Qgrid [=] For every spatial location the cursor is in, there's an
% appropriate action that can be taken

%% Iterate through time and figure out cursor actions

% introduce a delay before movement begins
RT = 4;

% cursor positions
curxy = nan(sum(~isnan(xTarg)), 2);
curxy(2:RT,:) = repmat([0,0],RT,1);

% iterate
for t = RT:sum(~isnan(xTarg))
    
    % determine the state for time t-1
    distx = round(xTarg(t-1) - curxy(t-1,1));
    disty = round(yTarg(t-1) - curxy(t-1,2));
    
    % find the corresponding Q matrix indecies
    xi = find(xspace == distx);
    yi = find(yspace == disty);
    
    % pick the state-action pair
    act = Qgrid(xi,yi);
    
    % place holder action
    curxy(t,:) = curxy(t-1,:);
    
    % generate action
    switch act
        case 1 % left
            if curxy(t-1,1) - 1 >= 0
                curxy(t,1) = curxy(t-1,1) - 1;
            end
        case 2 % up
            if curxy(t-1,2) + 1 <= ymax
                curxy(t,2) = curxy(t-1,2) + 1;
            end
        case 3 % right
            if curxy(t-1,1) + 1 <= xmax
                curxy(t,1) = curxy(t-1,1) + 1;
            end
        case 4 % down
            if curxy(t-1,2) - 1 >= 0
                curxy(t,2) = curxy(t-1,2) - 1;
            end
    end %switch
    
end

%% plot the resulting cursor positions

figure(1), hold on
plot(curxy(:,1), curxy(:,2), 'b.', 'MarkerSize', 20)
plot(curxy(:,1), curxy(:,2), 'b-', 'LineWidth', 0.75)

