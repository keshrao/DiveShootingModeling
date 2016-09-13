clear, clc

[Qgrid, gridspace] = b_ballSpace_StaticTarget();
for i = 1:10000
    fprintf('Iter: %i, ', i)
    [Qgrid, gridspace] = b_ballSpace_StaticTarget(Qgrid);
end
save('Qgrid_9-13.mat','Qgrid','gridspace')
c_showQgrid(Qgrid, gridspace)
d_trackBallistic(Qgrid,gridspace)