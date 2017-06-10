#!/bin/sh
gnuplot plot.g > /var/www/cgi-bin/humidity.png
cat humidity.png
