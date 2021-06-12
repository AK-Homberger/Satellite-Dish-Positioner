# Satellite Dish Positioner


This is an automatical satellite dish positioner with an ESP8266 D1 Mini, a compass and an MPU. It controls the satellite dish direction with a Diseqc rotor (azimut) and a linear actuator (elevation). It uses an gyroscope device for elevation and a compass device for azimut control.

![SatPositioner](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/IMG_1403.jpg)

The purpose of this device is to support me on the boat with the positioning of the satellite dish from the cabin. But it is also usable for campers and mobile homes.

## Hardware
The rotor is a standard Diseqc dish motor for less than 50 Euro. But for this project we use the motor upside down to move the dish in horizontal ballance. We have to remove the cranked dish connection tube from the motor. But keep the bolt and the nut. We need them to connect the upper and lower 3D-printed joint parts. 

The ESP8266 (in D1 Mini) controls the Diseqc motor with 22 kHz tone signals as defined in the [Diseqc specification](https://www.eutelsat.com/files/PDF/DiSEqC-documentation.zip) (see bus_spec.pdf, section 5 and also positioner_appli_notice.pdf). The ESP8266 generates the signal which has to be modulated on the coax signal line of the motor. I found the necessary circuit and signal generator code on GitHub:(https://github.com/acrerd/Arduino-Diseqc-solar-tracker). Many thanks for the helpful support. That saved me a lot of time. For simplification, I only used the right part of the [circuit](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/diseqc-interface.pdf) starting with the 100 Ohm resistor. The risistor is directly connected to port D5 on the D1 Mini. This is sufficient to generate a signal that the Diseqc motor is recognising.

![22KhZ-Signal](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/22kHz-Signal.JPG)

The delay values in the Arduino code ( functions write0() and write1() ) had to be adjusted for the faster ESP8266. The delay with 21 microseconds works perfectly to generate a 22 kHz signal.

The motor gets the 12 Volt power via the coax connection. Be careful with the coax connector when the device is powerd. A shortcut between core and shield would instantly destroy the inductor coil (it can only handle about 300 mA).

The motor is able to move from -75 to +75 degrees with an accuracy of 1/16 degree. That is more than sufficient for positioning the azimut.
You just have to position the sat finder in a general south facing direction. Thats all.

The elevation is controlled with a standard small linear actuator which is available for less than 30 Euro. I use here an actuator with 50 mm length. But 25 mm should work also.

In addition to the 22 kHz logic, only four other items are required:

- Step-down-converter 12V to 5V: D24V10F5
- Compass: GY-271 from AzDelivery (install [QMC5883LCompass](https://github.com/mprograms/QMC5883LCompass) library in Arduino)
- 6 axis gyroscope: GY-521 from AzDelivery (install [TinyMPU6050](https://github.com/gabriel-milan/TinyMPU6050) library in Arduino):
- Motor driver:  Adafruit DRV8871 DC Motor Driver

**Be careful with the GY-271 from other sources. Some devices are using a HMC5883L compass instead of a QMC5883L. We need the QMC5883L for this project.**

The compass and the gyroscope are connected to the I2C bus of the D1 Mini (using D1=SCL and D2=SDA). The compass is inside the box on the pcb. The gyroscope is connected with a short 4-wire cable and placed on the back of the satellite dish.

The motor driver is using ports D0 and D6. The 22 kHz signal is generated on port D5.

![Circuit](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/IMG_1400.jpg)

![Schematic](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/SatFinderSchematic.png)

![PCB](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/SatFinderPCB.png)

Schematics and PCB layout is in KiCAD folder.

## Software
The positioner is controlled with a web interface. The ssid and password for WLAN has to be set in the code.

The device is pre-configured for Astra 19.2 and my home location. Please change this for your location and satellite.
You can use one of the free calculators to get the angles for your location and desired setellite (e.g. https://www.satlex.us/en/azel_calc.html). Use "Azimut angle" and "Elevation angle". 

The true north azimut angle needs to be corrected (Az_Offset) to match the magnetic north of the compass (sailors should know how to calculate) and to correct a possible placing error on the pcb. 

The elevation angle must be corrected (El_Offset) with a dish specific value. For my dish this is -18 degrees between dish beam angle and angle of gyroscope mount. The offset has to be calculated only once and defined in the program.

```cpp
//Enter your SSID and PASSWORD
const char* ssid = "ssid";
const char* password = "passwod";

float Astra_Az = 164, Astra_El = 30.19, El_Offset=-18, Az_Offset=-10.0;   // Astra 19.2 position and dish specific offsets
```

![WebInterface](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/SatfinderWeb.png)

With the web interface you can control the positioner. You can do fine tuning for azimut/elevation and switch automatic control between Off, On and R-Off.

R-Off means automatic control for azimut is switched off. Elevation remains on. This is a kind of "night" mode because the Diseqc motor is a bit noisy when constantly re-positioning. The "-Step/Step+" buttons are changing the rotor for 1/8 degree. Which should be sufficient for the desired purpose. It is possible to change it also to 1/16 degree.

Values for Azimut, Elevation, Offsets and Motor Speed can be changed with a "Settings" web page. Changed values are stored in flash memory (EEPROM) of ESP8266. With "Motor Speed" you can define the speed of the linear actuator. The value should be about 700 and defines the Pulse Width Modulation for the actuator. If the dish begins to "swing" you can adjust the value to avoid this.

![Settings](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/SatfinderWebSettings.png).

To improve the precision of the compass, it is necessary to calibrate the device before using it. To do the calibration load and run the [calibration sketch](https://github.com/mprograms/QMC5883LCompass/blob/master/examples/calibration/calibration.ino) from the QMC5883L compass library.

During the calibration process the device have to be moved in all possible directions (see library example). It is probably a good idea to do the calibration before placing the pcb on the dish.

The shown six values have to be set in this line:
```
compass.setCalibration(-1598, 1511, -2365, 872, -1417, 1440);   // Do a calibration for the compass and put your values here!!!
```
After calibration, comment out the three lines again.

For the MPU there is also an calibration function available. See library for [details](https://github.com/gabriel-milan/TinyMPU6050/blob/master/examples/ArduinoIDE_Angles_Example/ArduinoIDE_Angles_Example.ino). But due to the fact that the elevation offset has to be set anyway, it is not necessary to do the calibration for the device, to get the individual offsets.

The following line in the code:
```
experimental::ESP8266WiFiGratuitous::stationKeepAliveSetIntervalMs(5000);
```
is part of the internal [ESP8266WiFi](https://github.com/esp8266/Arduino/blob/master/libraries/ESP8266WiFi/src/ESP8266WiFiGratuitous.h) library. It solves a WLAN connection problem for my router by sending ARP packets every 5 seconds to keep the connection.

If you don't need this, simply uncomment the line.


## 3D Prints
The connection between the sat dish and the rotor as well as the other parts are designed with OpenSCAD. The files are stored in the SCAD folder.

You can either use the .scad files with OpenSCAD or you can directly print the .stl files stored [here](https://github.com/AK-Homberger/Satellite-Dish-Positioner/tree/main/SCAD/STL).

![Connection](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/IMG_1404.jpg)

![Back](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/IMG_1409.jpg)

The GY-521 gyroscope is placed on the back of the dish in a hoizonal position. The compass is on the pcb facing to south direction. For other directions do a correction in the code with "#define Az_PCB_Correction 90". I had to add 90 degrees to get south direction, 180°.

![Gyroscope](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/IMG_1410.jpg)

The connection between the dish and the Diseqc motor has to be very stable. I used 0.2 mm accuracy and 70% fillrate for PLA. Use of ABS is also an option.


![Bottom](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/SCAD/SatFinderUnten.png)

![Bottom2](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/SCAD/SatFinderUnten2.png)

![Top](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/SCAD/SatFinderOben.png)

## Parts
- Sat dish: [Link](https://www.voelkner.de/products/21807/Telestar-5103309-Camping-SAT-Anlage-ohne-Receiver-Teilnehmer-Anzahl-1.html?ref=43&offer=74abe2d23c3a61dabbbaf20649c0274a&gclid=EAIaIQobChMIhfuapsL67QIVaFXVCh3rzAHpEAYYASABEgIO9vD_BwE)
- Diseqc motor: [Link](https://www.ebay.de/itm/332284938131?chn=ps&norover=1&mkevt=1&mkrid=707-134425-41852-0&mkcid=2&itemid=332284938131&targetid=940585975411&device=c&mktype=pla&googleloc=9043858&poi=&campaignid=10203814992&mkgroupid=101937413437&rlsatarget=pla-940585975411&abcId=1145992&merchantid=112028706&gclid=EAIaIQobChMIg57du6jQ7AIVRtiyCh0ixQoGEAQYAyABEgJfgvD_BwE) or [Link](https://www.wiltanet.de/sat-empfang/diseqc-schalter-motor/diseqc-motor/diseqc-motor/a-120017)
- Linear Actuator (25 or 50 mm): [Link](https://www.ebay.de/itm/750N-25-150-mm-Linear-Actuator-elektrische-Mikro-Linearantrieb-12V-Kraft-IP65/402438285052?_trkparms=aid%3D555021%26algo%3DPL.SIMRVI%26ao%3D1%26asc%3D225078%26meid%3De5d8f347c09a4ba989a35d0217f8cb5c%26pid%3D100008%26rk%3D1%26rkt%3D11%26mehot%3Dpf%26sd%3D383778548269%26itm%3D402438285052%26pmt%3D1%26noa%3D0%26pg%3D2047675%26algv%3DSimplRVIAMLv5WebWithPLRVIOnTopCombiner&_trksid=p2047675.c100008.m2219)
- D1 Mini: AzDelivery (e.g. on Amazon) [Link](https://www.amazon.de/stores/AZDelivery/AZDelivery/page/2DB821D9-4A4B-4FD2-A50B-AE111B57FC93)
- GY-271 compass: AzDelivery (e.g. on Amazon) [Link](https://www.amazon.de/stores/AZDelivery/AZDelivery/page/2DB821D9-4A4B-4FD2-A50B-AE111B57FC93)
- GY-521 gyroscope: AzDelivery (e.g. on Amazon) [Link](https://www.amazon.de/stores/AZDelivery/AZDelivery/page/2DB821D9-4A4B-4FD2-A50B-AE111B57FC93)
- D24V10F5 [Link](https://eckstein-shop.de/Pololu-5V-1A-Step-Down-Spannungsregler-D24V10F5)
- Adafruit DRV8871: [Link](https://eckstein-shop.de/Adafruit-DRV8871-DC-Motor-Driver-Breakout-Board-36A-Max)
- Resistor 51 Ohm [Link](https://www.reichelt.de/de/en/carbon-film-resistor-1-4-w-5-51-ohm-1-4w-51-p1441.html?&nbc=1)
- Resistor 100 Ohm [Link](https://www.reichelt.de/de/en/carbon-film-resistor-1-4-w-5-100-ohms-1-4w-100-p1336.html?&nbc=1)
- Inductor 1 mH - BOU RLB0914-102K [Link](https://www.reichelt.de/index.html?ACTION=446&LA=0&nbc=1&q=bou%20rlb0914-102k)
- Capacitor 56 nF - RND 150MKT563K2E [Link](https://www.reichelt.de/index.html?ACTION=446&LA=0&nbc=1&q=150mkt563k2e%20) or alternative MKP-X2 56N2 [Link](https://www.reichelt.de/de/en/radio-interference-suppression-capacitors-56nf-305v-rm15-mkp-x2-56n2-p173414.html?&nbc=1)
- Capacitor 3,3 µF - TON 3,3/63 [Link](https://www.reichelt.de/index.html?ACTION=446&LA=446&nbc=1&q=ton%203%2C3%2F63)
- Connector 2-pin (*2) [Link](https://www.reichelt.de/de/en/2-pin-terminal-strip-spacing-5-08-akl-101-02-p36605.html?&nbc=1)
- Connector 4-pin [Link](https://www.reichelt.de/de/en/4-pin-terminal-strip-spacing-5-08-akl-101-04-p36607.html?&nbc=1)
- DC Jack [Link](https://www.reichelt.de/de/en/connector-dc-female-bulkhead-delock-89911-p259483.html?&nbc=1)


## Updates
- Version 1.1 - 19.05.2021: Improved 22 kHz signal generation (Issue #5).
- Version 1.0 - 09.02.2021: Added pcb mount correction value. Release version 1.0
- Version 0.6 - 05.02.2021: Added settings page and storage of settings in flash memory.
- Version 0.5 - 07.11.2020: Corrected error in azimut calculation (boundary check 0-360).
- Version 0.4 - 06.11.2020: Changed PCB layout to version 1.1. Larger terminal strips (5.08 mm).
- Version 0.4 - 28.10.2020: Added permanent azimut offset.
- Version 0.3 - 26.10.2010: Separated elevation and elevation offset to work with true elevation angles from calculators. 
- Version 0.2 - 26.10.2010: Initial version. 
