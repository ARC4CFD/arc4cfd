set datafile separator ","
set title "Residuals" font "arial,22"
set ylabel "log10 of Residual" font "arial,18"
set xlabel "Iteration" font "arial,18"
set key autotitle columnhead
set grid

plot "history.csv" using 1:5 with lines, "history.csv" using 1:6 with lines, "history.csv" using 1:7 with lines
pause 1
if (GPVAL_DATA_X_MAX<=500) {
	xmax = 550
}
else {
	xmax = GPVAL_DATA_X_MAX+50
}
xmin = 0
ymax = GPVAL_DATA_Y_MAX+1
ymin = GPVAL_DATA_Y_MIN-1
set xrange [xmin:xmax]
set yrange [ymin:ymax]
reread
