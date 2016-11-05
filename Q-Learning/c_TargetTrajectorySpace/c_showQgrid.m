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

uv_vec = [-1 0; 0 1; 1  0;  0 -1;...
          -1 1; 1 1; 1 -1; -1 -1]; 
uv_vec = uv_vec .* div;

%% 


figure(3), clf, hold on
%axis([-xrng-1 xrng+1 -yrng-1 yrng+1])
set(gca, 'XTick', -xrng:xrng, 'YTick', -yrng:yrng)
grid on

%% now plot using mesh grids

% I'm not sure yet why xm/ym have to be flipped
[xm,ym] = meshgrid(xspace,yspace); 

q = quiver(ones(size(xm)),ones(size(ym)), ...
                nan(size(xm)), nan(size(ym))); 

%[~, decmat] = max(Qgrid,[],3);
umat = zeros(size(xm'));
vmat = zeros(size(ym'));

for row = 1:length(xspace)
    for col = 1:length(yspace)
        
        thisStateActVals = squeeze(Qgrid(row,col,:));
        maxVal = max(thisStateActVals);
        idx = find(thisStateActVals == maxVal);
        
        if length(idx) > 1
            % dec = datasample(idx,1);
            dec = idx(1);
        else
            dec = idx;
        end
%         [probval, dec] = max(Qgrid(row,col,:));
        
        step = double(idivide(int32(dec),int32(8)) + 1);
        act = mod(dec,8);
        if act == 0
            act = 8;
        end
    
        %if direc ~= 0
            umat(row,col) = uv_vec(act,1)*step;
            vmat(row,col) = uv_vec(act,2)*step;
            
        %else
        %    umat(row,col) = 0;
        %    vmat(row,col) = 0;
        %end
        
    end
end

set(q, 'XData', xm,'YData',ym,'UData',umat','VData',vmat','MaxHeadSize',1);
set(q, 'MaxHeadSize', 1, 'Color','b')

% highlight the center location
plot(0,0,'ko','LineWidth',2)
