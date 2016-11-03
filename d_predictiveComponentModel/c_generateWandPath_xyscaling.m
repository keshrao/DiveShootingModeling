clear, clc

load('targetTrajec.mat');

FR = 0.016;
si = randi(10);

azT = squeeze(targTrajec(si, 1, :)); azT = azT(~isnan(azT));
elT = squeeze(targTrajec(si, 2, :)); elT = elT(~isnan(elT));

trltime = length(azT);

azW = nan(1,trltime);
elW = nan(1,trltime);
spd = nan(1,trltime);

%% parameters to calibrate
RT = round(.3/FR); % reaction time divide by FR to get indexes delay
spdfactor = 0.1; % increment with each iteration
smoothspd = 0.4; % amount to which previous spd influences 

%% online plotting
figure(2), clf, hold on
xlabel('Azimuthal Angle (deg)', 'FontSize', 20)
ylabel('Pitch Angle (deg)', 'FontSize', 20)
axis([-40 40 -5 10])
set(gca,'FontSize', 20)
drawnow

%% iterations through trial
azW(1) = 0; elW(1) = 0;
dxpre = 0; dypre = 0;

for t = 2:trltime
    
    if t < RT
        dx = 0; dy = 0;
    else
        
        dx = azT(t) - azW(t-1);
        dy = elT(t) - elW(t-1);
        amp = sqrt(dx.^2 + dy.^2); % more of an angular error
        
        dx = dx*spdfactor - sign(dx)*smoothspd*dxpre;
        dy = dy*spdfactor - sign(dy)*smoothspd*dypre;
        
    end % RT
    
    azW(t) = azW(t-1) + dx;
    elW(t) = elW(t-1) + dy;
    spd(t) = sqrt((dx/FR).^2 + (dy/FR).^2);
    
    
    plot(azT(t), elT(t), 'o','MarkerSize', 20, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k')
    plot(azW(t), elW(t), 'o','MarkerSize', 20, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k')
    drawnow
    
    dxpre = dx;
    dypre = dy;
end % trial (t)

%%
figure(1), clf, hold on
plot((0:trltime-1).*FR, spd, '.-r', 'LineWidth', 2, 'MarkerSize', 40 )
