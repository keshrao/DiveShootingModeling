clear, clc

datain = csvread('target_motion_detail.csv',1,0);

% slotvec
slotvec = datain(:,3);

% target trajectory
tpx = datain(:,18);
tpy = -1*datain(:,20);
tpz = datain(:,19);

% hand controller position 
cpx = datain(:,9);
cpy = -1*datain(:,11);
cpz = datain(:,10);

% - 
figure(1), clf, hold on
figure(2), clf, hold on

% trajec number, az/el, frame
targTrajec = nan(10,2,200);

for si = 0:9
    
    %idx = find(slotvec == si & state == 1);
    idx = find(slotvec == si);
    
    % first the raw 3d target trajectory
    trl_tpx = tpx(idx);
    trl_tpy = tpy(idx);
    trl_tpz = tpz(idx);
    
    figure(1)
    plot3(trl_tpx,trl_tpy,trl_tpz)
    
    fprintf('Slot %i: %5.4f\n',si+1, length(trl_tpx)*0.01666)
    
    axis([-200 200 0 300 -5 25])
    view(-20,15)
    drawnow
    
    % now the 2d projection into azim & el. 
    trl_cpx = cpx(idx);
    trl_cpy = cpy(idx);
    trl_cpz = cpz(idx);
    
    % 
    [azT, elT, rT] = cart2sph(trl_tpx - trl_cpx, trl_tpy - trl_cpy, trl_tpz - trl_cpz);
    azT = -1.*((azT .* 180 ./ pi)-90); elT = elT .* 180 ./ pi; 
    
    targTrajec(si+1, 1, 1:length(azT)) = azT;
    targTrajec(si+1, 2, 1:length(azT)) = elT;
    
    figure(2)
    plot(azT, elT, 'k','LineWidth',2)
    xlabel('Azimuthal Angle (deg)', 'FontSize', 20)
    ylabel('Pitch Angle (deg)', 'FontSize', 20)
    axis([-40 40 -5 10])
    drawnow
end

save('targetTrajec.mat', 'targTrajec')