VERSION = 1.0
C      = gcc
CFLAGS  = -Wall -O2 -DVERSION=\"$(VERSION)\"
LDFLAGS =  -lwiringPiDev -lwiringPi -lm 

OBJ = read_sensors.o

prog: $(OBJ)
	$(CC) $(CFLAGS) -o read_sensors $(OBJ) $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $<
