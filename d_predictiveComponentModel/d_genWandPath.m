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
spdfactor = .05; % slow down the speed, add momentum
noiselevel = 0.01; % sensorimotor noise
targPred = 10; % time points of visual prediction

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
rho_pre = 0;


for t = 2:trltime-targPred
    
    if t < RT
        dx = 0; dy = 0;
        dxp = 0; dyp = 0;
        rho = 0;
    else
        
        dxc = azT(t+targPred) - azW(t-1);
        dyc = elT(t+targPred) - elW(t-1);
        
        % direction of intended movement
        [theta, rho_p] = cart2pol(dxc, dyc);
        
        %rho = (spdfactor*rho_p + (1-spdfactor)*rho_pre)/2;
        rho = (spdfactor*rho_p + rho_pre)/2;
       
        [dxp, dyp] = pol2cart(theta, rho);
        
        
        dx = dxp + normrnd(0,noiselevel);
        dy = dyp + normrnd(0,noiselevel);
        
    end % RT
    
    azW(t) = azW(t-1) + dx;
    elW(t) = elW(t-1) + dy;
    spd(t) = sqrt((dx/FR).^2 + (dy/FR).^2);
    
    plot(azT(t), elT(t), 'o','MarkerSize', 20, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k')
    plot(azW(t), elW(t), 'o','MarkerSize', 20, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k')
    set(hq, 'XData', azW(t-1), 'YData', elW(t-1), 'UData', dx*20, 'VData', dy*20)
    drawnow
    
    rho_pre = rho;
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
plot((0:trltime-1).*FR, spd, 'o-k', 'LineWidth', 2, 'MarkerSize', 10, 'MarkerFaceColor', 'g' )
xlim([0 1.5])
ylim([0 150])
ylabel('Angular Speed (deg/sec)')
xlabel('Time (s)')
set(gca, 'FontSize', 20)
