function [Qgrid, gridspace] = b_ballSpace_StaticTarget(Qgrid)
% static target and time can go for longer
% move cursor randomly till target is acquired
% use Q-learning to move the cursor in a more systemic way

%% create the 2D space

xmin = 0;
xmax = 10;

ymin = 0;
ymax = 5;

div = 1;

gridspace = [xmin, xmax, ymin, ymax, div];
%% Q learning params

alpha = 0.5; % learning rate
gam = 0.75; % discounting rate

isPlot = false; % refers to the continous plotting that occurs through trials

%% Target Position and Initial Cursor Position

% r = a + (b-a).*rand(N,1)
targXY = [xmin + (xmax-xmin)*rand, ymin + (ymax-ymin)*rand];
% round to the appropriate number of decimals
targXY = roundn(targXY, log10(div));

cursorXY = [xmin + (xmax-xmin)*rand, ymin + (ymax-ymin)*rand];

% if the cursor and the target are overlaid, just pick a new initial
% position
while norm(cursorXY - targXY) < div
    cursorXY = [xmin + (xmax-xmin)*rand, ymin + (ymax-ymin)*rand];
end
cursorXY = roundn(cursorXY, log10(div));

if isPlot
    figure(1), clf, hold on
    plot(targXY(1), targXY(2), 'r.','MarkerSize',30)
    hcur = plot(cursorXY(1), cursorXY(2), 'bo','MarkerSize',10, 'LineWidth',2);
    axis([xmin xmax ymin ymax])
    grid on
end

%% All possible cursor positions

xrng = xmax - xmin;
yrng = ymax - ymin;

xspace = roundn(-xrng:div:xrng,log10(div));
yspace = roundn(-yrng:div:yrng,log10(div));

% there are eight possible actions for now
% 1 = left, 2 = up, 3 = right, 4 = down
% 5 = UL,  6 = UR,  7 = DR,  8 = DL

if nargin == 0
    % initialize a matrix of actions, all equally weighted actions
    numSteps = 5;
    Qgrid = ones([length(xspace),length(yspace),8*numSteps]);
    Qgrid = Qgrid ./ size(Qgrid,3);
end

% Qgrid [=] For every spatial location the cursor is in, there's an
% appropriate action that can be taken

% note that there will be no action taken when the cursor is on the target
Qgrid(xspace==0,yspace==0,:) = 0;

%% Iterate through time and figure out cursor actions

% store all the cursor positions
cursorMAT = cursorXY;

numIter = 1;
% iterate till cursor intersects the target
while norm(cursorXY - targXY) >= div && size(cursorMAT,1) < 100/div
    
    % determine the state for time t-1
    distx = roundn(cursorXY(1) - targXY(1),log10(div));
    disty = roundn(cursorXY(2) - targXY(2),log10(div));
    
    % find the corresponding Q matrix indecies
    xi = find(xspace == distx);
    yi = find(yspace == disty);
    
    % pick the state-action pair - several problems in this part
    actvec = squeeze(Qgrid(xi,yi,:)); % all possible actions and their respective rewards
    act_I = find(mnrnd(1,actvec));

    % try to integrate a multiplier
    step = idivide(int32(act_I),int32(8)) + 1;
    step = double(step)*div;
    act = mod(act_I,8);
    if act == 0
        act = 8;
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
    if norm(cursorXY - targXY) < div
        rew = 50; % base reward for reaching target
        
        % ideal distance from start to finish
        idealDist = roundn(norm(cursorMAT(1,:) - targXY),log10(div));
        idealSteps = round(idealDist / div);
        
        % augment reward based on ideal steps
        rew = rew * (idealSteps/numIter);
        
    else
        rew = -1;
    end
    
    % find out what the next state will be
    distx = roundn(targXY(1) - cursorXY(1),log10(div));
    disty = roundn(targXY(2) - cursorXY(2),log10(div));
    
    % find the corresponding Q matrix indecies
    xi_p = xspace == distx;
    yi_p = yspace == disty;
    
    % update the Q matrix
    % Q(s,a) <- (1-alpha)*Q(s,a) + alpha*(rew + gam*max(Q(s',a')))
    Qgrid(xi,yi,act_I) = (1-alpha)*Qgrid(xi,yi,act_I) + alpha*(rew + gam*max(Qgrid(xi_p,yi_p,:)));
    
    % rescale to make it probabilities
    thisActVec = squeeze(Qgrid(xi,yi,:));
    thisActVec = (thisActVec - min(thisActVec))./(max(thisActVec) - min(thisActVec));
    thisActVec = thisActVec ./ sum(thisActVec);
    
    % reset the Qgrid row
    Qgrid(xi,yi,:) = thisActVec;
    
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

fprintf('Rew: %4.2f, ', rew)

%% plot the resulting cursor positions

if isPlot
    figure(1),
    plot(cursorMAT(:,1), cursorMAT(:,2), 'b.', 'MarkerSize', 20)
    plot(cursorMAT(:,1), cursorMAT(:,2), 'b-', 'LineWidth', 0.75)
    pause(1);
end

fprintf('NumSteps: %i\n', numIter)

