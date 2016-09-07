function c_showQgrid(Qgrid,gridspace)
% use quiver plot to show the convergence of the Q learning grid

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

%% 

figure(2), clf, hold on
axis([-xrng-1 xrng+1 -yrng-1 yrng+1])
set(gca, 'XTick', -xrng:xrng, 'YTick', -yrng:yrng)
grid on

%% now plot using mesh grids

% I'm not sure yet why xm/ym have to be flipped
[xm,ym] = meshgrid(xspace,yspace); 

q = quiver(ones(size(xm)),ones(size(ym)), ...
                nan(size(xm)), nan(size(ym))); 

%[~, decmat] = max(Qgrid,[],3);
umat = [];
vmat = [];

for row = 1:length(xspace)
    for col = 1:length(yspace)
        
        [direc, dec] = max(Qgrid(row,col,:));
        
        if direc ~= 0
            umat(row,col) = uv_vec(dec,1);
            vmat(row,col) = uv_vec(dec,2);
        else
            umat(row,col) = 0;
            vmat(row,col) = 0;
        end
        
    end
end

set(q, 'XData', xm,'YData',ym,'UData',umat','VData',vmat','MaxHeadSize',1);
set(q, 'MaxHeadSize', 1, 'Color','b')

% highlight the center location
plot(0,0,'ko','LineWidth',2)

%% use stupid plotting method

if false % - only use if if you want to check the plotting accuracy
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
end
