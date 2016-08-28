% static target and time can go for longer
% move cursor randomly till target is acquired
% use Q-learning to move the cursor in a more systemic way

clear, clc

%% create the 2D space

xmin = -3;
xmax = 3;

ymin = -3;
ymax = 3;

%% Target Position and Initial Cursor Position

targXY = [randi([xmin xmax]), randi([ymin ymax])];

cursorXY = [randi([xmin xmax]), randi([ymin ymax])];

% if the cursor and the target are overlaid, just pick a new initial
% position
while sum(cursorXY == targXY) == 2
    cursorXY = [randi([xmin xmax]), randi([ymin ymax])];
end

figure(1), clf, hold on
plot(targXY(1), targXY(2), 'r.','MarkerSize',30)
hcur = plot(cursorXY(1), cursorXY(2), 'bo','MarkerSize',10, 'LineWidth',2);
axis([xmin xmax ymin ymax])
grid on

%% All possible cursor positions

xspace = 2*xmin:2*xmax;
yspace = 2*ymin:2*ymax;

% there are eight possible actions for now
% 1 = left, 2 = up, 3 = right, 4 = down
% 5 = UL,  6 = UR,  7 = DR,  8 = DL

% initialize a matrix of actions, all equally weighted actions
%Qgrid = randi([1 16],[length(xspace),length(yspace)]);
Qgrid = ones([length(xspace),length(yspace) 16]).*(1/16);

% Qgrid [=] For every spatial location the cursor is in, there's an
% appropriate action that can be taken

%% Iterate through time and figure out cursor actions

% store all the cursor positions
cursorMAT = [];
cursorMAT = [cursorMAT; cursorXY];

% iterate till cursor intersects the target
while sum(cursorXY == targXY) < 2 && size(cursorMAT,1) < 100
    
    % determine the state for time t-1
    distx = round(targXY(1) - cursorXY(1));
    disty = round(targXY(2) - cursorXY(2));
    
    % find the corresponding Q matrix indecies
    xi = find(xspace == distx);
    yi = find(yspace == disty);
    
    % pick the state-action pair
    act = Qgrid(xi,yi);
    
    % try to integrate a multiplier
    step = 1;
    if act - 8 > 0
        act = act - 8;
        step = 2;
    end
    
    % generate action
    switch act
        case 1 % left
            if cursorXY(1) - step >= xmin
                cursorXY(1) = cursorXY(1) - step;
            else
                Qgrid(xi,yi) = randi([1 16]);
            end
        case 2 % up
            if cursorXY(2) + step <= ymax
                cursorXY(2) = cursorXY(2) + step;
            else
                Qgrid(xi,yi) = randi([1 16]);
            end
        case 3 % right
            if cursorXY(1) + step <= xmax
                cursorXY(1) = cursorXY(1) + step;
            else
                Qgrid(xi,yi) = randi([1 16]);
            end
        case 4 % down
            if cursorXY(2) - step >= ymin
                cursorXY(2) = cursorXY(2) - step;
            else
                Qgrid(xi,yi) = randi([1 16]);
            end
            
        case 5 % UL
            if cursorXY(2) + step <= ymax && cursorXY(1) - step >= xmin
                cursorXY(2) = cursorXY(2) + step;
                cursorXY(1) = cursorXY(1) - step;
            else
                Qgrid(xi,yi) = randi([1 16]);
            end
        case 6 % UR
            if cursorXY(2) + step <= ymax && cursorXY(1) + step <= xmax
                cursorXY(2) = cursorXY(2) + step;
                cursorXY(1) = cursorXY(1) + step;
            else
                Qgrid(xi,yi) = randi([1 16]);
            end
        case 7 % DR
            if cursorXY(2) - step >= ymin && cursorXY(1) + step <= xmax
                cursorXY(2) = cursorXY(2) - step;
                cursorXY(1) = cursorXY(1) + step;
            else
                Qgrid(xi,yi) = randi([1 16]);
            end
        case 8 % DL
            if cursorXY(2) - step >= ymin && cursorXY(1) - step >= xmin
                cursorXY(2) = cursorXY(2) - step;
                cursorXY(1) = cursorXY(1) - step;
            else
                Qgrid(xi,yi) = randi([1 16]);
            end
    end %switch
    
    cursorMAT = [cursorMAT; cursorXY]; %#ok<AGROW>
    
    set(hcur, 'XData', cursorXY(1), 'YData', cursorXY(2))
    drawnow
    pause(0.01)
end

%% plot the resulting cursor positions

figure(1),
plot(cursorMAT(:,1), cursorMAT(:,2), 'b.', 'MarkerSize', 20)
plot(cursorMAT(:,1), cursorMAT(:,2), 'b-', 'LineWidth', 0.75)

pause(2)