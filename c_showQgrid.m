function c_showQgrid(Qgrid,gridspace)
% use quiver plot to show the convergence of the Q learning grid

%% recreate the x/y space

xmin = gridspace(1);
xmax = gridspace(2);

ymin = gridspace(3);
ymax = gridspace(4);

xspace = 2*xmin:2*xmax;
yspace = 2*ymin:2*ymax;


%% Map the actions to a set of arrow directions

% there are eight possible actions for now
% 1 = left, 2 = up, 3 = right, 4 = down
% 5 = UL,  6 = UR,  7 = DR,  8 = DL

uv_vec = [-1 0; 0 1; 1 0; 0 -1;...
            -1 1; 1 1; 1 -1; -1 -1]; 
        
% why are these signs flipped? 
%uv_vec = -1.*uv_vec;

%% 

figure(2), clf, hold on
axis(2.*[xmin xmax ymin ymax])
set(gca, 'XTick', 2*xmin:2*xmax, 'YTick', 2*ymin:2*ymax)
grid on

% - now plot using mesh grids
% [xm,ym] = meshgrid(xspace,yspace);
% ym = -1.*ym;
% xm = -1.*xm;
% 
% q = quiver(ones(size(xm)),ones(size(ym)), ...
%                 nan(size(xm)), nan(size(ym))); 
% 
% %[~, decmat] = max(Qgrid,[],3);
% umat = [];
% vmat = [];
% 
% for row = 1:length(xspace)
%     for col = 1:length(yspace)
%         
%         [~, dec] = max(Qgrid(row,col,:));
%         %q = quiver(xspace(row),yspace(col), uv_vec(dec,1), uv_vec(dec,2), 'b');
%         umat(row,col) = uv_vec(dec,1);
%         vmat(row,col) = uv_vec(dec,2);
%         
%     end
% end
% 
% set(q, 'XData', xm,'YData',ym,'UData',umat,'VData',vmat,'MaxHeadSize',1);
% set(q, 'MaxHeadSize', 1, 'Color','b')
% 
% highlight the center location
plot(0,0,'ko','LineWidth',2)

%% use stupid plotting method

for row = 1:length(xspace)
    for col = 1:length(yspace)
        
        % find the indexed position for the space location
        xi = xspace == xspace(row);
        yi = yspace == yspace(col);
        
        % get the decision
        [direc, dec] = max(Qgrid(xi,yi,:));
        
        if direc == 0
            continue
        end
        
        q = quiver(xspace(row),yspace(col), uv_vec(dec,1), uv_vec(dec,2), 'r');
        set(q, 'MaxHeadSize', 1)
        drawnow
    end
end

