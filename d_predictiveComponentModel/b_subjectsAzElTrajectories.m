clear, clc

ddir = 'C:\Users\Hrishikesh\Box Sync\Home Folder hmr11\DiVE HFR\Data\';

subdir = {'Subject 1 - HFR/','Subject 2 - HFR/','Subject 3 - HFR/','Subject 4 - HFR/', ...
    'Subject 5 - HFR/', 'Subject 6 - HFR/', 'Subject 7 - HFR/', 'Subject 8 - HFR/', ...
    'Subject 9 - HFR/', 'Subject 10 - HFR/',...
    'Subject 31 - HFR/','Subject 32 - HFR/','Subject 33 - HFR/','Subject 34 - HFR/', ...
    'Subject 35 - HFR/', 'Subject 36 - HFR/', 'Subject 37 - HFR/', 'Subject 38 - HFR/', ...
    'Subject 39 - HFR/', 'Subject 40 - HFR/',...
    };

subnames = {'p1','p2','p3','p4','p5','p6','p7','p8','p9','p10',...
    'p11','p12','p13','p14','p15','p16','p17','p18','p19','p20'};


% save structures
% [subnum, block num, trial num, timevec, azT, elT, azW, elW]
targetAZ = nan(20,7,50,120);
targetEL = nan(20,7,50,120);
subjectAZ = nan(20,7,50,120);
subjectEL = nan(20,7,50,120);

% [subnum, block num, trial num, slot, shot 1 success]
successdata = nan(20,7,50,1);
slotdata = nan(20,7,50,1);

for subnum = 1:length(subnames)
    
    fprintf('Subject: %i\n',subnum)
    
    % summary files to get trial hit or miss
    sumfiles = dir([ddir subdir{subnum} '*summary.csv']);
    
    % this should be sorted already
    allfiles = dir([ddir subdir{subnum} '*detail.csv']);
    
    for bi = 1:length(allfiles)
        
        % summary file load first
        sumfname = sumfiles(bi).name;
        datasummary = csvread([ddir subdir{subnum} sumfname],1,0);
        shot1success = datasummary(:,11);
        
        % this file name
        fname = allfiles(bi).name;
        datain = csvread([ddir subdir{subnum} fname],1,0);
        
        timevecblk = datain(:,1);
        
        % slot - map the two left handed onto contra/ipsi
        oldslotvec = datain(:,3);
        slotvec = nan(size(oldslotvec));
        % 0-4 top (left - right)
        % 5-9 bottom (left - right)
        oldset = [0 1 2 3 4 5 6 7 8 9];
        newdirs = [4 3 2 1 0 9 8 7 6 5];
        % S3 and S8 are lefthanded/handedness
        if subnum == 3 || subnum == 8
            for di = 1:10
                idxD = oldslotvec == oldset(di);
                slotvec(idxD) = newdirs(di);
            end
        else
            slotvec = oldslotvec;
        end
        
        % trial numbers 0:49
        trlid = datain(:,2);
        
        % button
        button = datain(:,21);
        
        % controller position
        cpx = datain(:,9);    
        cpy = -1*datain(:,11);
        cpz = datain(:,10);   
        
        % wand direction 
        wdx = datain(:,12); 
        wdy = datain(:,13); 
        wdz = datain(:,14); 
        
        % wand trajectory (x,-z,y) - cartesian position - only use for plotting purposes
        wpx = datain(:,22);    
        wpy = -1*datain(:,24); 
        wpz = datain(:,23);    
        
        % target trajectory (x,-z,y)
        tpx = datain(:,18);    
        tpy = -1*datain(:,20); 
        tpz = datain(:,19);    
        
        tpx_raw = datain(:,18);    
        tpy_raw = datain(:,19); 
        tpz_raw = datain(:,20);
        
        %% 
        for trl = 0:max(trlid)
            
            idx = find(trlid == trl);
            
            % trial slot
            trlslot = slotvec(idx(1));
            
            % from absolute time to relative time within this trial
            trltime = timevecblk(idx) - timevecblk(idx(1));
            
            % get the response time (time to shot 1)
            shotIndBlk = find(trlid == trl & button == 1); % regardless of success
            
            if isempty(shotIndBlk) % no shots taken
                % bad trial, skip and continue
                
                fprintf('No Shot Taken: %i, %i\n', bi, trl)
                continue
            else
                si = [1;find(diff(shotIndBlk)>1)+1];
                useshotind = shotIndBlk(si);
                
                % index of shot in the structure of the whole file
                shot1BlkInd = useshotind(1);
                
                % get the index of the first shot to compute the directional and velocity components
                shot1_trlidx = shot1BlkInd - idx(1) + 1; % to check : [shot1time trltime(shot1_trlidx)]
           
                % shot 1 time relative to trial onset
                shot1time = timevecblk(shot1BlkInd) - timevecblk(idx(1));
                
            end % shot 1 & 2 times
            
            if shot1_trlidx > 120
                
                fprintf('Bad Trial Shot Time \n')
                continue
            end
            
            % controller hand position
            trl_wpx = cpx(idx);
            trl_wpy = cpy(idx);
            trl_wpz = cpz(idx);
            
            % wand directions trl directions
            trl_cpx = wpx(idx);
            trl_cpy = wpy(idx);
            trl_cpz = wpz(idx);
            
            idxGlitch = trl_cpy < 50;
            trl_cpx(idxGlitch) = nan;
            trl_cpy(idxGlitch) = nan;
            trl_cpz(idxGlitch) = nan;
            
            % target directions 
            trl_tpx = tpx(idx);
            trl_tpy = tpy(idx);
            trl_tpz = tpz(idx);
            
            % map onto spherical coordinates
            [azW, elW, rW] = cart2sph(trl_cpx-trl_wpx, trl_cpy-trl_wpy, trl_cpz-trl_wpz);
            azW = -1.*((azW .* 180 ./ pi)-90); elW = elW .* 180 ./ pi; 
            % should be the same as the wand dir - this is probably the better way to do it - check
            
            [azT, elT, rT] = cart2sph(trl_tpx-trl_wpx, trl_tpy-trl_wpy, trl_tpz-trl_wpz);
            azT = -1.*((azT .* 180 ./ pi)-90); elT = elT .* 180 ./ pi; 
            
            
%             figure(1), clf, hold on
%             plot(azT(1:shot1_trlidx), elT(1:shot1_trlidx), 'ok','MarkerSize', 10, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'LineWidth',2)
%             plot(azW(1:shot1_trlidx), elW(1:shot1_trlidx), 'ok','MarkerSize', 10, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth',2)
%             xlabel('Azimuthal Angle (deg)', 'FontSize', 20)
%             ylabel('Pitch Angle (deg)', 'FontSize', 20)
%             axis([-40 40 -5 10])
%             set(gca,'FontSize', 20)

            %%
            % [subnum, block num, trial num, timevec, azT, elT, azW, elW]
            subjectAZ(subnum, bi, trl+1, 1:shot1_trlidx) = azW(1:shot1_trlidx);
            subjectEL(subnum, bi, trl+1, 1:shot1_trlidx) = elW(1:shot1_trlidx);
            targetAZ(subnum, bi, trl+1, 1:shot1_trlidx) = azT(1:shot1_trlidx);
            targetEL(subnum, bi, trl+1, 1:shot1_trlidx) = elT(1:shot1_trlidx);
            
            % [subnum, block num, trial num, slot, shot 1 success]
            slotdata(subnum,bi,trl+1,1) = trlslot;
            successdata(subnum,bi,trl+1,1) = shot1success(trl+1);

        end % trial
        
    end % block, bi
    
end % subject


%% save data

save('subjectdata.mat', 'subjectAZ', 'subjectEL', 'targetAZ', 'targetEL', 'slotdata', 'successdata')