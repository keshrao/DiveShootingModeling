function d_trackBallistic(Qgrid,gridspace)

%% recreate the x/y space

xmin = gridspace(1);
xmax = gridspace(2);

ymin = gridspace(3);
ymax = gridspace(4);

div = gridspace(5);

xrng = xmax - xmin;
yrng = ymax - ymin;

xspace = roundn(-xrng:div:xrng,log10(div));
yspace = roundn(-yrng:div:yrng,log10(div));


%% Map the actions to a set of arrow directions

% there are eight possible actions for now
% 1 = left, 2 = up, 3 = right, 4 = down
% 5 = UL,  6 = UR,  7 = DR,  8 = DL

uv_vec = [-1 0; 0 1; 1 0; 0 -1;...
            -1 1; 1 1; 1 -1; -1 -1]; 
uv_vec = uv_vec .* div;


%% generate the target trajectory 

xTargFull = xspace;

g = 9.8; % gravitational constant
y0 = 0; % initial height
theta = randi([45 75],1); % incidence of launch
vel = randi([8 10],1); % velocity of launch

yfunc = @(xin) y0 + xin.*tand(theta) - g.*xin.^2./(2*(vel*cosd(theta)).^2);

% actual x vector
xTargFull(yfunc(xTargFull) < ymin) = [];
yTargFull = yfunc(xTargFull);

xTarg = roundn(xTargFull,log10(div)); 
yTarg = roundn(yTargFull,log10(div));

% refine the target trajectory to not have repetitions
%[xTarg, ia, ~] = unique(xTargFull);
%yTarg = yTargFull(ia);

%% begin loop to try and catch the target 

cursorXY = zeros(length(xTarg),2);

RT = randi([2 4],1); % introduce some delay time

for t = RT:length(xTarg)-1

    % determine the state for time t-1
    distx = roundn(cursorXY(t,1) - xTarg(t),log10(div));
    disty = roundn(cursorXY(t,2) - yTarg(t),log10(div));
    
    % find the corresponding Q matrix indecies
    xi = xspace == distx;
    yi = yspace == disty;

    % get the decision
    [~, dec] = max(Qgrid(xi,yi,:));
    xmove = uv_vec(dec,1);
    ymove = uv_vec(dec,2);

    if cursorXY(t,1) + xmove >= xmin && cursorXY(t,1) + xmove <= xmax && ...
            cursorXY(t,2) + ymove >= ymin && cursorXY(t,2) + ymove <= ymax 
        cursorXY(t+1,1) = cursorXY(t,1) + xmove;
        cursorXY(t+1,2) = cursorXY(t,2) + ymove;
    else
        cursorXY(t+1,1) = cursorXY(t,1);
        cursorXY(t+1,2) = cursorXY(t,2);
    end
    
    if cursorXY(t+1,1) == -1 || cursorXY(t+1,2) == -1
        keyboard
    end
    
end

% plot the resulting trajectory

figure(1), clf, hold on
%plot(cursorXY(:,1), cursorXY(:,2), '-b')
axis([xmin xmax ymin ymax])
grid on
for t = 1:length(xTarg)
    plot(xTarg(t), yTarg(t), 'ro','MarkerSize',10)
    plot(cursorXY(t,1), cursorXY(t,2), '.-b','MarkerSize',30)
    drawnow
    pause(0.1)
end
