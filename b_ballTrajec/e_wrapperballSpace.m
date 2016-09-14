clear, clc

fname = 'Qgrid_9-13.mat';

[Qgrid, gridspace] = b_ballSpace_StaticTarget();
for i = 1:500000
    fprintf('Iter: %i, ', i)
    [Qgrid, gridspace] = b_ballSpace_StaticTarget(Qgrid);
    
    if mod(i,5000)
        save(fname,'Qgrid','gridspace')
    end
end
save(fname,'Qgrid','gridspace')
c_showQgrid(Qgrid, gridspace)
d_trackBallistic(Qgrid,gridspace)
