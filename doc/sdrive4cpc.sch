EESchema Schematic File Version 2
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:sdrive4cpc-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "sdrive4cpc"
Date "2019-05-04"
Rev "V0.1"
Comp "kbrnet"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L R R1
U 1 1 5CCAAEEC
P 2250 1250
F 0 "R1" V 2330 1250 50  0000 C CNN
F 1 "1,8K" V 2250 1250 50  0000 C CNN
F 2 "" V 2180 1250 50  0000 C CNN
F 3 "" H 2250 1250 50  0000 C CNN
	1    2250 1250
	0    1    1    0   
$EndComp
$Comp
L R R2
U 1 1 5CCAAF29
P 2250 1450
F 0 "R2" V 2330 1450 50  0000 C CNN
F 1 "1,8K" V 2250 1450 50  0000 C CNN
F 2 "" V 2180 1450 50  0000 C CNN
F 3 "" H 2250 1450 50  0000 C CNN
	1    2250 1450
	0    1    1    0   
$EndComp
$Comp
L R R3
U 1 1 5CCAAF9A
P 2250 1650
F 0 "R3" V 2330 1650 50  0000 C CNN
F 1 "1,8K" V 2250 1650 50  0000 C CNN
F 2 "" V 2180 1650 50  0000 C CNN
F 3 "" H 2250 1650 50  0000 C CNN
	1    2250 1650
	0    1    1    0   
$EndComp
$Comp
L R R4
U 1 1 5CCAB1A3
P 2650 1900
F 0 "R4" V 2730 1900 50  0000 C CNN
F 1 "3,3K" V 2650 1900 50  0000 C CNN
F 2 "" V 2580 1900 50  0000 C CNN
F 3 "" H 2650 1900 50  0000 C CNN
	1    2650 1900
	1    0    0    -1  
$EndComp
$Comp
L R R5
U 1 1 5CCAB1D8
P 2850 1900
F 0 "R5" V 2930 1900 50  0000 C CNN
F 1 "3,3K" V 2850 1900 50  0000 C CNN
F 2 "" V 2780 1900 50  0000 C CNN
F 3 "" H 2850 1900 50  0000 C CNN
	1    2850 1900
	1    0    0    -1  
$EndComp
$Comp
L R R6
U 1 1 5CCAB231
P 3050 1900
F 0 "R6" V 3130 1900 50  0000 C CNN
F 1 "3,3K" V 3050 1900 50  0000 C CNN
F 2 "" V 2980 1900 50  0000 C CNN
F 3 "" H 3050 1900 50  0000 C CNN
	1    3050 1900
	1    0    0    -1  
$EndComp
$Comp
L SD_Card CON1
U 1 1 5CCAB2BC
P 5100 1650
F 0 "CON1" H 4450 2200 50  0000 C CNN
F 1 "SD_Card" H 5700 1100 50  0000 C CNN
F 2 "10067847-001" H 5300 2000 50  0000 C CNN
F 3 "" H 5100 1650 50  0000 C CNN
	1    5100 1650
	1    0    0    -1  
$EndComp
Wire Wire Line
	1600 1250 2100 1250
Wire Wire Line
	1600 1450 2100 1450
Wire Wire Line
	2100 1650 1600 1650
Wire Wire Line
	2400 1650 3250 1650
Wire Wire Line
	2650 1650 2650 1750
Wire Wire Line
	2850 1750 2850 1450
Wire Wire Line
	2400 1450 4200 1450
Wire Wire Line
	3050 1250 3050 1750
Connection ~ 3050 1250
Wire Wire Line
	2400 1250 3650 1250
Wire Wire Line
	3250 1350 4200 1350
Wire Wire Line
	3250 1650 3250 1350
Connection ~ 2650 1650
Connection ~ 2850 1450
Wire Wire Line
	4200 1750 3650 1750
Wire Wire Line
	3650 1750 3650 1250
$Comp
L GND #PWR?
U 1 1 5CCAB56A
P 2850 3350
F 0 "#PWR?" H 2850 3100 50  0001 C CNN
F 1 "GND" H 2850 3200 50  0000 C CNN
F 2 "" H 2850 3350 50  0000 C CNN
F 3 "" H 2850 3350 50  0000 C CNN
	1    2850 3350
	1    0    0    -1  
$EndComp
Wire Wire Line
	3450 2150 2650 2150
Wire Wire Line
	2850 2050 2850 3350
Connection ~ 2850 2150
$Comp
L Q_NPN_CBE Q1
U 1 1 5CCAB5C4
P 2250 2550
F 0 "Q1" H 2450 2600 50  0000 L CNN
F 1 "BC547" H 2450 2500 50  0000 L CNN
F 2 "" H 2450 2650 50  0000 C CNN
F 3 "" H 2250 2550 50  0000 C CNN
	1    2250 2550
	-1   0    0    -1  
$EndComp
$Comp
L R R7
U 1 1 5CCAB68D
P 2600 2550
F 0 "R7" V 2680 2550 50  0000 C CNN
F 1 "10K" V 2600 2550 50  0000 C CNN
F 2 "" V 2530 2550 50  0000 C CNN
F 3 "" H 2600 2550 50  0000 C CNN
	1    2600 2550
	0    1    1    0   
$EndComp
Wire Wire Line
	3650 2550 2750 2550
Wire Wire Line
	3450 1550 3450 2150
Wire Wire Line
	3450 1850 4200 1850
Connection ~ 3050 2150
Wire Wire Line
	4200 1550 3450 1550
Connection ~ 3450 1850
Wire Wire Line
	2650 2150 2650 2050
Wire Wire Line
	3050 2150 3050 2050
Wire Wire Line
	4200 1950 3650 1950
Wire Wire Line
	3650 1950 3650 2550
$Comp
L LM2931Z-3.3/5.0 U2
U 1 1 5CCDA04B
P 4800 2900
F 0 "U2" H 4800 3200 50  0000 C CNN
F 1 "LM2931Z-3.3V/100mA" H 4800 3100 50  0000 C CNN
F 2 "TO92-123" H 4800 3000 50  0000 C CIN
F 3 "" H 4800 2900 50  0000 C CNN
	1    4800 2900
	-1   0    0    -1  
$EndComp
$Comp
L CP C1
U 1 1 5CCDA1F8
P 4250 3000
F 0 "C1" H 4275 3100 50  0000 L CNN
F 1 "10µF" H 4275 2900 50  0000 L CNN
F 2 "" H 4288 2850 50  0000 C CNN
F 3 "" H 4250 3000 50  0000 C CNN
	1    4250 3000
	1    0    0    -1  
$EndComp
$Comp
L C C2
U 1 1 5CCDA233
P 5350 3000
F 0 "C2" H 5375 3100 50  0000 L CNN
F 1 "0,1µF" H 5375 2900 50  0000 L CNN
F 2 "" H 5388 2850 50  0000 C CNN
F 3 "" H 5350 3000 50  0000 C CNN
	1    5350 3000
	1    0    0    -1  
$EndComp
Wire Wire Line
	1600 3150 5950 3150
Connection ~ 4800 3150
Connection ~ 2850 3150
Connection ~ 4250 3150
Wire Wire Line
	4050 2850 4400 2850
Wire Wire Line
	5200 2850 5950 2850
$Comp
L +5V #PWR?
U 1 1 5CCDA411
P 5950 2850
F 0 "#PWR?" H 5950 2700 50  0001 C CNN
F 1 "+5V" H 5950 2990 50  0000 C CNN
F 2 "" H 5950 2850 50  0000 C CNN
F 3 "" H 5950 2850 50  0000 C CNN
	1    5950 2850
	1    0    0    -1  
$EndComp
Connection ~ 5350 3150
Connection ~ 5350 2850
$Comp
L VSS #PWR?
U 1 1 5CCDA4E0
P 5950 3150
F 0 "#PWR?" H 5950 3000 50  0001 C CNN
F 1 "VSS" H 5950 3300 50  0000 C CNN
F 2 "" H 5950 3150 50  0000 C CNN
F 3 "" H 5950 3150 50  0000 C CNN
	1    5950 3150
	1    0    0    -1  
$EndComp
Wire Wire Line
	4200 1650 4050 1650
Wire Wire Line
	4050 1650 4050 2850
Connection ~ 4250 2850
Text Label 1100 900  0    60   ~ 12
CPC-Parallelport
Text GLabel 1600 1650 0    60   Input ~ 0
4(D2)
Text GLabel 1600 1450 0    60   Input ~ 0
3(D1)
Text GLabel 1600 1250 0    60   Input ~ 0
2(D0)
Text GLabel 1600 2100 0    60   Output ~ 0
11(Busy)
Text GLabel 1600 3150 0    60   UnSpc ~ 0
23(GND)
Wire Wire Line
	1600 2100 2150 2100
Wire Wire Line
	2150 2100 2150 2350
Wire Wire Line
	2150 2750 2150 3150
Connection ~ 2150 3150
$EndSCHEMATC
