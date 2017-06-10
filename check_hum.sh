#!/bin/bash
while true; do
	NOW=$(date +"%Y.%m.%d %H:%M:%S")
	ALL=$(/home/pi/src/dht22/read_sensors)
	TEMP=$(echo $ALL|awk '{print $2}')
	HUM=$(echo $ALL|awk '{print $4}')
	TD=$(echo $ALL|awk '{print $6}')
	TW=$(echo $ALL|awk '{print $8}')
	TIMER=$(cat /home/pi/src/dht22/timer.dat)
	HUMVAL=$(cat /home/pi/src/dht22/humval.dat)
	HUMCOUNT=$(cat /home/pi/src/dht22/humcount.dat)
	echo -n $NOW $ALL >> /home/pi/src/dht22/humidity.dat
	#date=`date +%Y%m%d`
	#echo -n $NOW $ALL >> /home/pi/src/dht22/humidity_`echo $date`.dat

	# wenn der Taupunkt an der Wand erreicht ist, 25min laufen lassen
	if [[ `echo ' ('$TW' - 3.5) < '$TD'' | bc -l` -eq "1" ]]; then
		echo "on"
		if [ "$TIMER" -eq 0 ]; then
			TIMER=25
			sispmctl -o 1
		fi
	fi

	#off timer
	if [ $TIMER -gt 0 ]; then
		TIMER=$[ $TIMER - 1 ]
		echo "Luefter noch" $TIMER "min aktiv"
		echo $TIMER > /home/pi/src/dht22/timer.dat
		echo " L_ON 1" >> /home/pi/src/dht22/humidity.dat
	else 
		#wenn timer abgelaufen, dann wird lüfter aus in datei geschrieben
		echo "Luefter deaktiviert"
		sispmctl -f 1
		echo " L_ON 0" >> /home/pi/src/dht22/humidity.dat
	fi
	
	#check if humidity is still rising
	#if (( $(echo "$HUM >= $HUMVAL" |bc -l) )); then
	if [[ $(echo "$HUM >= $HUMVAL" |bc -l) &&  $TIMER -gt 1 ]]; then
		HUMCOUNT=$[ $HUMCOUNT + 1 ]
		echo $HUMCOUNT > /home/pi/src/dht22/humcount.dat
	fi

	#if hum is rising for 30min buket is maybe full?
	if [ $HUMCOUNT -gt 45 ]; then
		echo "Bucket maybe full? Send email..."
		echo "Bitte wieder mal leeren, LF liegt bei $HUMVAL%" | mail -s "Update Luftentfeuchter" "lalabar@gmail.com"
		echo "0" > /home/pi/src/dht22/humcount.dat
	fi

	echo $HUM > /home/pi/src/dht22/humval.dat

	sync;
	sleep 60;
done
