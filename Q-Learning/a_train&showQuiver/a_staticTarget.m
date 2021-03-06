function [Qgrid, gridspace] = a_staticTarget(Qgrid)
% static target and time can go for longer
% move cursor randomly till target is acquired
% use Q-learning to move the cursor in a more systemic way

% run using something like this:
if false
    [Qgrid, gridspace] = a_staticTarget();
    for i = 1:2000
        [Qgrid, gridspace] = a_staticTarget(Qgrid);
    end
    b_showQgrid(Qgrid, gridspace)
end

%% create the 2D space

xmin = -5;
xmax = 5;

ymin = -5;
ymax = 5;

gridspace = [xmin, xmax, ymin, ymax];
%% Q learning params

alpha = 0.5; % learning rate
gam = 0.75; % discounting rate

isPlot = false; % refers to the continous plotting that occurs through trials

%% Target Position and Initial Cursor Position

targXY = [randi([xmin xmax]), randi([ymin ymax])];

cursorXY = [randi([xmin xmax]), randi([ymin ymax])];

% if the cursor and the target are overlaid, just pick a new initial
% position
while sum(cursorXY == targXY) == 2
    cursorXY = [randi([xmin xmax]), randi([ymin ymax])];
end

if isPlot
    figure(1), clf, hold on
    plot(targXY(1), targXY(2), 'r.','MarkerSize',30)
    hcur = plot(cursorXY(1), cursorXY(2), 'bo','MarkerSize',10, 'LineWidth',2);
    axis([xmin-2 xmax+2 ymin-2 ymax+2])
    grid on
end

%% All possible cursor positions

xspace = 2*xmin:2*xmax;
yspace = 2*ymin:2*ymax;

% there are eight possible actions for now
% 1 = left, 2 = up, 3 = right, 4 = down
% 5 = UL,  6 = UR,  7 = DR,  8 = DL

if nargin == 0
    % initialize a matrix of actions, all equally weighted actions
    useSteps = false;
    if useSteps
        Qgrid = ones([length(xspace),length(yspace),16]);
    else
        Qgrid = ones([length(xspace),length(yspace),8]);
    end
end

% Qgrid [=] For every spatial location the cursor is in, there's an
% appropriate action that can be taken

% note that there will be no action taken when the cursor is on the target
Qgrid(xspace==0,yspace==0,:) = 0;

%% Iterate through time and figure out cursor actions

% store all the cursor positions
cursorMAT = [];
cursorMAT = [cursorMAT; cursorXY];

numIter = 0;
% iterate till cursor intersects the target
while sum(cursorXY == targXY) < 2 && size(cursorMAT,1) < 200
    
    % determine the state for time t-1
    distx = round(cursorXY(1) - targXY(1));
    disty = round(cursorXY(2) - targXY(2));
    
    % find the corresponding Q matrix indecies
    xi = find(xspace == distx);
    yi = find(yspace == disty);
    
    % pick the state-action pair
    actvec = squeeze(Qgrid(xi,yi,:)); % all possible actions and their respective rewards
    actvec = round((actvec./sum(actvec)).*100); % ensure they are all probabilities
    decivec = [];
    for d = 1:length(actvec) % iterate through the possible decisions
       decivec = [decivec, d.*ones(1,actvec(d))];
    end
    
    % pick a decision
    act = datasample(decivec, 1);
    
    % try to integrate a multiplier
    step = 1;
    if act > 8
        act = act - 8;
        step = 2;
    end
    
    % generate action
    switch act
        case 1 % left
            if cursorXY(1) - step >= xmin
                cursorXY(1) = cursorXY(1) - step;
            end
        case 2 % up
            if cursorXY(2) + step <= ymax
                cursorXY(2) = cursorXY(2) + step;
            end
        case 3 % right
            if cursorXY(1) + step <= xmax
                cursorXY(1) = cursorXY(1) + step;
            end
        case 4 % down
            if cursorXY(2) - step >= ymin
                cursorXY(2) = cursorXY(2) - step;
            end
        case 5 % UL
            if cursorXY(2) + step <= ymax && cursorXY(1) - step >= xmin
                cursorXY(2) = cursorXY(2) + step;
                cursorXY(1) = cursorXY(1) - step;
            end
        case 6 % UR
            if cursorXY(2) + step <= ymax && cursorXY(1) + step <= xmax
                cursorXY(2) = cursorXY(2) + step;
                cursorXY(1) = cursorXY(1) + step;
            end
        case 7 % DR
            if cursorXY(2) - step >= ymin && cursorXY(1) + step <= xmax
                cursorXY(2) = cursorXY(2) - step;
                cursorXY(1) = cursorXY(1) + step;
            end
        case 8 % DL
            if cursorXY(2) - step >= ymin && cursorXY(1) - step >= xmin
                cursorXY(2) = cursorXY(2) - step;
                cursorXY(1) = cursorXY(1) - step;
            end
    end %switch
    
    % determine reward
    if sum(cursorXY == targXY) == 2 
        rew = 50; % 
    else
        rew = -1;
    end
    
    % find out what the next state will be
    distx = round(targXY(1) - cursorXY(1));
    disty = round(targXY(2) - cursorXY(2));
    
    % find the corresponding Q matrix indecies
    xi_p = xspace == distx;
    yi_p = yspace == disty;
    
    % restore act to it's stepped value
    if step == 2
        act = act + 8;
    end
    
    % update the Q matrix
    % Q(s,a) <- (1-alpha)*Q(s,a) + alpha*(rew + gam*max(Q(s',a')))
    Qgrid(xi,yi,act) = (1-alpha)*Qgrid(xi,yi,act) + alpha*(rew + gam*max(Qgrid(xi_p,yi_p,:)));
    
    
    % plotting
    cursorMAT = [cursorMAT; cursorXY]; %#ok<AGROW>
    
    if isPlot
        set(hcur, 'XData', cursorXY(1), 'YData', cursorXY(2))
        drawnow
        pause(0.01)
    end
    
    % keep track of the number of steps taken
    numIter = numIter + 1;
end

%% plot the resulting cursor positions

if isPlot
    figure(1),
    plot(cursorMAT(:,1), cursorMAT(:,2), 'b.', 'MarkerSize', 20)
    plot(cursorMAT(:,1), cursorMAT(:,2), 'b-', 'LineWidth', 0.75)
    pause(1);
end

fprintf('Number of Steps Taken: %i\n', numIter)

