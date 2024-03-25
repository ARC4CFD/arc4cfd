set logscale y
set title "Residuals" font "arial,22"
set ylabel "Residual" font "arial,18"
set xlabel "Iteration" font "arial,18"
set key outside
set grid

nCorrectors=1
nNonOrthogonalCorrectors=3

nCont = nCorrectors
nP = (nNonOrthogonalCorrectors+1)*nCont
nPSkip = nP-1
nContSkip = nCont-1

plot "< cat log.pimpleFoam | grep 'Solving for Ux' | cut -d' ' -f9 | tr -d ','" title 'Ux' with linespoints,\
"< cat log.pimpleFoam | grep 'Solving for Uy' | cut -d' ' -f9 | tr -d ','" title 'Uy' with linespoints,\
"< cat log.pimpleFoam | grep 'Solving for Uz' | cut -d' ' -f9 | tr -d ','" title 'Uz' with linespoints lc 8
pause 1
xmax = GPVAL_DATA_X_MAX+2
xmin = xmax-40
set xrange [xmin:xmax]
reread
