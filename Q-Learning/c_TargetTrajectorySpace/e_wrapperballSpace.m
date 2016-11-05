clear, clc

fname = 'Qgrid_10-18.mat';

[Qgrid, gridspace] = b_ballSpace_StaticTarget();
maxIters = 500000;

for i = 1:maxIters
    fprintf('Iter: %i, ', i)
    [Qgrid, gridspace] = b_ballSpace_StaticTarget(Qgrid);
    
    if mod(i,1000) == 0
        save(fname,'Qgrid','gridspace')
    end
end

save(fname,'Qgrid','gridspace')
c_showQgrid(Qgrid, gridspace)

d_trackBallistic(Qgrid,gridspace)
