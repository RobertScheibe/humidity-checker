#set terminal png size 2048,1536
set terminal png size 1024,768
#stats 'humidity.dat'
set xdata time 
set timefmt "%Y.%m.%d %H:%M:%S"
set format x "%d.%m.%Y"
set xrange [ time(0) - 7*86400 : time(0) + 10000 ] #x days back in time
set xtics nomirror rotate by -45
set bmargin 8
set grid xtics ytics
set key at screen 0.95,0.5
set style line 1 lt 2 lc rgb "red" lw 3
set title "Luftfeuchtigkeits- und Temperaturverlauf der letzten 7 Tage\n Herzogstandstrasse 9 vom ".strftime("%a %d.%b.%Y %H:%M", time(0) + 7200)

temp = `tail -n 1 humidity.dat | awk '{print $4}'`
set label 1 sprintf("%3.2f°C",temp) at time(0),temp center front
hum = `tail -n 1 humidity.dat | awk '{print $6}'`
set label 2 sprintf("%3.2f%%",hum) at time(0),hum+2 center front
td = `tail -n 1 humidity.dat | awk '{print $8}'`
set label 3 sprintf("%3.2f°C",td) at time(0),td center front
twall = `tail -n 1 humidity.dat | awk '{print $10-3.5}'`
set label 4 sprintf("%3.2f°C",twall) at time(0),twall+2 center front

#calc time and currrent money spend
on_minutes = `grep "L_ON 1" humidity.dat | wc -l`
on_hours = on_minutes/60.0
costs = on_hours*0.6*0.25
set label 5 sprintf("Gesamtlüfterlaufzeit seit 9.5.2015: %3.1f h, Kosten: %3.2f Euro", on_hours, costs) at screen 0.33, 0.915 font "Arial,10"

plot	'< tail -n 20000 humidity.dat' u 1:6 t 'rel. Luftfeuchtigkeit in %' w l,\
	'< tail -n 20000 humidity.dat' u 1:4 t 'Raumtemperatur in °C' w l,\
	'< tail -n 20000 humidity.dat' u 1:($10-3.5) t 'Temperatur Wand in °C (-3.5°C offset)' w l,\
	'< tail -n 20000 humidity.dat' u 1:8 t 'Taupunkt in °C' w l,\
	'< tail -n 20000 humidity.dat' u 1:($12==1?$12*55:50) t 'Lüfter an/aus' lc rgb "black" ps 1 w l
show label
