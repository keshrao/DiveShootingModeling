clear, clc

load('targetTrajec.mat');

FR = 0.016; %frame rate, of target 
si = randi(10);

azT = squeeze(targTrajec(si, 1, :)); azT = azT(~isnan(azT));
elT = squeeze(targTrajec(si, 2, :)); elT = elT(~isnan(elT));

trltime = length(azT);

azW = nan(1,trltime);
elW = nan(1,trltime);
spd = nan(1,trltime);

%% parameters to calibrate
RT = round(randi([200,400])/1000/FR); % reaction time divide by FR to get indexes delay
spdfactor = 0.1; % increment with each iteration
smoothspd = 0; % amount to which previous spd influences 
noiselevel = 0.01;


%% online plotting
figure(2), clf, hold on
hq = quiver(0,0,1,1); set(hq, 'Color', [1 0 0], 'LineWidth', 2, 'autoScaleFactor', 1, 'MaxHeadSize',3)
xlabel('Azimuthal Angle (deg)', 'FontSize', 20)
ylabel('Pitch Angle (deg)', 'FontSize', 20)
axis([-40 40 -5 10])
set(gca,'FontSize', 20)
drawnow

%% iterations through trial
azW(1) = 0; elW(1) = -4;
dxpre = 0; dypre = 0;

for t = 2:trltime
    
    if t < RT
        dx = 0; dy = 0;
        dxp = 0; dyp = 0;
        amp = 0;
    else
        
        dxc = azT(t) - azW(t-1);
        dyc = elT(t) - elW(t-1);
        amp = sqrt(dx.^2 + dy.^2);
        
        % direction of intended movement
        [theta, rho] = cart2pol(dxc, dyc);
        [dxp, dyp] = pol2cart(theta, rho*spdfactor);
        
        dx = dxp - sign(dxp)*smoothspd*dxpre + normrnd(0,noiselevel);
        dy = dyp - sign(dyp)*smoothspd*dypre + normrnd(0,noiselevel);
        
    end % RT
    
    azW(t) = azW(t-1) + dx;
    elW(t) = elW(t-1) + dy;
    spd(t) = sqrt((dx/FR).^2 + (dy/FR).^2);
    
    plot(azT(t), elT(t), 'o','MarkerSize', 20, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k')
    plot(azW(t), elW(t), 'o','MarkerSize', 20, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k')
    set(hq, 'XData', azW(t-1), 'YData', elW(t-1), 'UData', dx*100, 'VData', dy*100)
    drawnow
    
    dxpre = dxp;
    dypre = dyp;
end % trial (t)

%%
figure(1), clf, 

subplot(2,1,1), hold on
plot(azT, elT, 'ok','MarkerSize', 10, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'LineWidth',2)
plot(azW, elW, 'ok','MarkerSize', 10, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth',2)
xlabel('Azimuthal Angle (deg)', 'FontSize', 20)
ylabel('Pitch Angle (deg)', 'FontSize', 20)
axis([-40 40 -5 10])
set(gca,'FontSize', 20)

subplot(2,1,2)
plot((0:trltime-1).*FR, spd, 'o-k', 'LineWidth', 2, 'MarkerSize', 15, 'MarkerFaceColor', 'g' )
xlim([0 1.5])
ylim([0 150])
ylabel('Angular Speed (deg/sec)')
xlabel('Time (s)')
set(gca, 'FontSize', 20)
