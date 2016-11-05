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

load('targetTrajec.mat')

si = randi([1 10]);

fprintf('Traject Trajec No. %i\n', si)

xTargFull = squeeze(targTrajec(si,1,:));
yTargFull = squeeze(targTrajec(si,2,:));

xTargRnd = roundn(xTargFull(~isnan(xTargFull)),log10(div)); 
yTargRnd = roundn(yTargFull(~isnan(xTargFull)),log10(div));

% refine the target trajectory to not have repetitions
xa  = find(xTargRnd(1:end-1) ~= xTargRnd(2:end));
ya = find(yTargRnd(1:end-1) ~= yTargRnd(2:end));

ia = union(xa,ya);

xTarg = xTargRnd(sort(ia));
yTarg = yTargRnd(sort(ia));

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
    step = double(idivide(int32(dec),int32(8)) + 1);
    act = mod(dec,8);
    if act == 0
        act = 8;
    end
    
    xmove = uv_vec(act,1)*step;
    ymove = uv_vec(act,2)*step;

    if cursorXY(t,1) + xmove >= xmin && cursorXY(t,1) + xmove <= xmax && ...
            cursorXY(t,2) + ymove >= ymin && cursorXY(t,2) + ymove <= ymax 
        cursorXY(t+1,1) = cursorXY(t,1) + xmove;
        cursorXY(t+1,2) = cursorXY(t,2) + ymove;
    else
        cursorXY(t+1,1) = cursorXY(t,1);
        cursorXY(t+1,2) = cursorXY(t,2);
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
    pause(0.01)
end
