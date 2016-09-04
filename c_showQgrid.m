function c_showQgrid(Qgrid)
% use quiver plot to show the convergence of the Q learning grid

%% recreate the x/y space

xmin = -3;
xmax = 3;

ymin = -3;
ymax = 3;

xspace = 2*xmin:2*xmax;
yspace = 2*ymin:2*ymax;

figure(3), clf, hold on
axis(2.*[xmin xmax ymin ymax])
set(gca, 'XTick', 2*xmin:2*xmax, 'YTick', 2*ymin:2*ymax)
grid on


%% Map the actions to a set of arrow directions

% there are eight possible actions for now
% 1 = left, 2 = up, 3 = right, 4 = down
% 5 = UL,  6 = UR,  7 = DR,  8 = DL

uv_vec = [1 0; 0 -1; -1 0; 0 1;...
            1 -1; -1 -1; -1 1; 1 1]; % why are these signs flipped? 


%%

[xm,ym] = meshgrid(xspace,yspace);

q = quiver(ones(size(xm)),ones(size(ym)), ...
                nan(size(xm)), nan(size(ym))); 

%[~, decmat] = max(Qgrid,[],3);
umat = [];
vmat = [];

for row = 1:length(xspace)
    for col = 1:length(yspace)
        
        [~, dec] = max(Qgrid(row,col,:));
        %q = quiver(xspace(row),yspace(col), uv_vec(dec,1), uv_vec(dec,2), 'b');
        umat(row,col) = uv_vec(dec,1);
        vmat(row,col) = uv_vec(dec,2);
        
    end
end

set(q, 'XData', xm,'YData',ym,'UData',umat,'VData',vmat,'MaxHeadSize',1);
set(q, 'MaxHeadSize', 1, 'Color','b')

% highlight the center location
plot(0,0,'ko','LineWidth',2)

%% use stupid plotting method

for row = 1:length(xspace)
    for col = 1:length(yspace)
        
        [~, dec] = max(Qgrid(row,col,:));
        q = quiver(xspace(row),yspace(col), uv_vec(dec,1), uv_vec(dec,2), 'r');
        set(q, 'MaxHeadSize', 1)
        drawnow
    end
end

