# SDrive for CPC

sdrive4cpc is a Tool for Amstrad(Schneider)-CPC computers to access
to a SD-Card connected to the parallel port of the CPC.
It is in early development state and can now only write DSK-Images
stored on SD back to real disc.

## Wirering:

	CPC parallel port		SD-Card

	2(Data0)	----->		5(SCLK)
	3(Data1)	----->		2(DI)
	4(Data2)	----->		1(CS)
	11(Busy)	<-----		7(DO)
	19..26(GND)	------		3,6(VSS) ----- GND
					4(VDD)	<----- 3.3V external

- For output pins 2-4 to SD-Card use a simple voltage divider with
resistors, e. g. 1.8K/3.3K(GND).
- For input pin 11 use a NPN-transistor(BC547) collector to pin 11,
emitter to GND and base over 10K resistor to SD-Card(7),
because there is an internal pullup to 5V! This will invert the
logic level, but it is inverted by software again.
- For power supply you will need a 3.3V source to the SD-Card pin 4(VDD).
(or a voltage regulator and so on...)

(c) 2019 by KBr
