clear, clc

load('targetTrajec.mat');
load('subjectdata.mat');

%% parameters to calibrate

FR = 0.016;
spdfactor = .1; % slow down the speed, add momentum
noiselevel = 0.01; % sensorimotor noise
targPred = 10; % time points of visual prediction


%%
subnum = 1; % 20 subjects
blk = 1; % 7 blocks per sugject

for trl = 1:50 % 50 trls per block
    
    RT = round(randi([200,400])/1000/FR); % reaction time divide by FR to get indexes delay
    
    
    si = slotdata(subnum, blk, trl)+1;
    
    % subject data
    azW = squeeze(subjectAZ(subnum, blk, trl,:)); azW = azW(~isnan(azW));
    elW = squeeze(subjectEL(subnum, blk, trl,:)); elW = elW(~isnan(elW));
    
    
    % full target information
    azT = squeeze(targTrajec(si, 1, :)); azT = azT(~isnan(azT));
    elT = squeeze(targTrajec(si, 2, :)); elT = elT(~isnan(elT));
    
    trltime = length(azW);
    
    azWsim = nan(1,trltime);
    elWsim = nan(1,trltime);
    spdsim = nan(1,trltime);
    
    
    %% iterations through trial
    azWsim(1) = azW(1); elWsim(1) = elW(1);
    rho_pre = 0;
    
    for t = 2:trltime-targPred
        
        if t < RT
            dx = 0; dy = 0;
            rho = 0;
        else
            
            dxc = azT(t+targPred) - azWsim(t-1);
            dyc = elT(t+targPred) - elWsim(t-1);
            
            % direction of intended movement
            [theta, rho_p] = cart2pol(dxc, dyc);
            rho = (spdfactor*rho_p + rho_pre)/2;
            [dxp, dyp] = pol2cart(theta, rho);
            
            dx = dxp + normrnd(0,noiselevel);
            dy = dyp + normrnd(0,noiselevel);
            
        end % RT
        
        azWsim(t) = azWsim(t-1) + dx;
        elWsim(t) = elWsim(t-1) + dy;
        spdsim(t) = sqrt((dx/FR).^2 + (dy/FR).^2);
        
        rho_pre = rho;
    end % trial (t)
    
    
    %% plotting
    figure(2), clf,     
    subplot(2,1,1), hold on
    plot(azT, elT, 'ok','MarkerSize', 10, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k', 'LineWidth',2)
    plot(azW, elW, 'ok','MarkerSize', 10, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth',2)
    plot(azWsim, elWsim, 'ok','MarkerSize', 10, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'LineWidth',2)
    xlabel('Azimuthal Angle (deg)', 'FontSize', 20)
    ylabel('Pitch Angle (deg)', 'FontSize', 20)
    axis([-40 40 -5 10])
    set(gca,'FontSize', 20)
    legend({'Target','Subject','Simulation'})
    
    
    subplot(2,1,2), hold on
    plot((0:trltime-1).*FR, spdsim, 'o-k', 'LineWidth', 2, 'MarkerSize', 15, 'MarkerFaceColor', 'b' )
    plot((0:trltime-2).*FR, sqrt((diff(azW)/FR).^2 + (diff(elW)/FR).^2), 'o-k', 'LineWidth', 2, 'MarkerSize', 15, 'MarkerFaceColor', 'r' )
    xlim([0 1.5])
    ylim([0 125])
    ylabel('Angular Speed (deg/sec)')
    xlabel('Time (s)')
    set(gca, 'FontSize', 20)
    
    
end