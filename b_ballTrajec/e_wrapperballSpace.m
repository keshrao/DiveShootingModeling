clear, clc

fname = 'Qgrid_9-13.mat';

[Qgrid, gridspace] = b_ballSpace_StaticTarget();
maxIters = 50000;
skewer = 5;
% these are exponentially decaying epsilon values. In the beginning,
% epislon in high which favors more exloration, as the value of epsilon
% falls, the algorithm exploits more than it explores
epsilon = (1-linspace(0,1,maxIters)).^skewer;

for i = 1:maxIters
    fprintf('Iter: %i, ', i)
    [Qgrid, gridspace] = b_ballSpace_StaticTarget(Qgrid,epsilon(i));
    
    if mod(i,5000)
        save(fname,'Qgrid','gridspace')
    end
end
save(fname,'Qgrid','gridspace')
c_showQgrid(Qgrid, gridspace)
d_trackBallistic(Qgrid,gridspace)
