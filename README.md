# Satellite Dish Positioner


This is an automatical satellite dish positioner with Wemos D1, compass and MPU. It controls satellite dish direction with a Diseqc rotor (azimut) and linear actuator (elevation). It uses an gyroscope device for elevation and a compass device for azimut control.

![SatPositioner](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/IMG_1403.jpg)

The purpose of this device is to support me on the boat with the positioning of the satellite dish from the cabin. But it is also usable for campers and mobile homes.

The rotor is a standard Diseqc dish motor for less than 50 Euro. But for this project we use the motor upside down to move the dish in horizontal ballance. We have to remove the cranked dish connection tube from the motor. But keep the bolt and the nut. We need it to connect the upper and lower 3D-printed joint parts. 

The ESP12 (in Wemos D1 Mini) controls the Diseqc motor with 22 KHz tone signals as defined in the [Diseqc specification](https://de.eutelsat.com/en/support/technical-support/diseqc.html). The ESP12 generates the signal which has to be modulated on the coax signal line of the motor. I found the necessary circuit on GitHub:(https://github.com/acrerd/Arduino-Diseqc-solar-tracker). Many thanks for the helpful support. That saved me a lot of time. For simplification, I only used the right part of the [circuit](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/diseqc-interface.pdf) starting with the 100 Ohm resistor. The risistor directly connected to port D5 on Wemos D1 is sufficient to generate a signal that the Diseqc moter is recognising.

The motor gets the 12 Volt power also via the coax connection. Be careful with the coax connector when the device is powerd. A shortcut between core and shield would instantly destroy the inductor coil (it can only handle about 300 mA).

The motor is able to move from -75 to +75 degrees with an accuracy of 1/16 degree. That is more than sufficient for positioning the azimut.
You just have to position the sat finder in a general south facing direction. Thats all.

The elevation is controlled with a standard small linear actuator which is available for less than 30 Euro. I use here an actuator with 50 mm length. But 25 mm should work also.

In addition to the 22 KHz logic, only four other items are required:

- Step-down-converter 12V to 5V: D24V10F5
- Compass: GY-271 from AzDelivery (install [QMC5883LCompass](https://github.com/mprograms/QMC5883LCompass) library in Arduino)
- 6 axis gyroscope: GY-521 from AzDelivery (install [TinyMPU6050](https://github.com/gabriel-milan/TinyMPU6050) library in Arduino):
- Motor driver:  Adafruit DRV8871 DC Motor Driver

The compass and the gyroscope are connected to the I2C bus of the Wemos D1 (using D1=SCL and D2=SDA). The compass is inside the box on the pcb. The gyroscope is connected with a short 4-wire cable and placed on the back of the satellite dish.

The motor driver is using ports D0 and D6. The 22 KHz signal is generated on port D5.

![Circuit](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/IMG_1400.jpg)

![Schematic](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/SatFinderSchematic.png)

The positioner is controlled with a web interface. The ssid and password for WLAN has to be set in the code.
The device is pre-configured for Astra 19.2 and my home location. Please change this for your location and satellite.
You can use one of the free calculatores to get the angles for your location and desired setellite (e.g. https://www.satlex.us/en/azel_calc.html). Use "Azimut angle" and "Elevation angle". 

The true north Azimut angle needs to be corrected to match the magnetic north of the compass (sailors should know how to calculate). But you can also use the "Delta Azimut" setting to correct the position. 

The Elevation angle must be corrected with a dish specific value. For my dish about -20 degree between dish beam angle and angle of compass mount. The offset has to be calculated only once and defined in the program.

![WebInterface](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/StatfinderWeb.png)

With the web interface you can control the positioner. You can do fine tuning for azimut/elevation and switch automatic contol between Off, On and R-Off.
R-Off means only automatic control for azimut is switched off. Elevation remains on. This is a kind of "night" mode because the Diseqc motor is a bit noisy when constantly re-positioning. The "-Step/Step+" buttons are changing the rotor for 1/8 degree. Which should be sufficient for the desired purpose. It is possible to change it also to 1/16 degree.

The connection between the sat dish and the rotor as well as the other parts are designed with OpenSCAD. The files are stored in the SCAD folder.

![Connection](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/IMG_1404.jpg)

![Back](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/IMG_1409.jpg)

The GY-521 gyroscope is placed on the back of the dish in a hoizonal position. The compass is on the pcb facing to south direction. For other directions do a correction in the code (I had to add 90 degrees to get south direction, 180°).

![Gyroscope](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/IMG_1410.jpg)

The connection between the dish and the Diseqc motor has to be very stable. I used 0.2 mm accuracy and 70% fillrate for PLA. Use of ABS is also an option.


![Bottom](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/SCAD/SatFinderUnten.png)

![Bottom2](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/SCAD/SatFinderUnten2.png)

![Top](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/SCAD/SatFinderOben.png)

Parts:

- Sat dish: [Link](https://www.ebay.de/itm/Telestar-5103309-Camping-SAT-Anlage-ohne-Receiver-Teilnehmer-Anzahl-1-/193630407517#couponcode=ebay-voucher20183)
- Diseqc motor: [Link](https://www.ebay.de/itm/332284938131?chn=ps&norover=1&mkevt=1&mkrid=707-134425-41852-0&mkcid=2&itemid=332284938131&targetid=940585975411&device=c&mktype=pla&googleloc=9043858&poi=&campaignid=10203814992&mkgroupid=101937413437&rlsatarget=pla-940585975411&abcId=1145992&merchantid=112028706&gclid=EAIaIQobChMIg57du6jQ7AIVRtiyCh0ixQoGEAQYAyABEgJfgvD_BwE)
- Linear Actuator (25 or 50 mm): [Link](https://www.ebay.de/itm/750N-25-150-mm-Linear-Actuator-elektrische-Mikro-Linearantrieb-12V-Kraft-IP65/402438285052?_trkparms=aid%3D555021%26algo%3DPL.SIMRVI%26ao%3D1%26asc%3D225078%26meid%3De5d8f347c09a4ba989a35d0217f8cb5c%26pid%3D100008%26rk%3D1%26rkt%3D11%26mehot%3Dpf%26sd%3D383778548269%26itm%3D402438285052%26pmt%3D1%26noa%3D0%26pg%3D2047675%26algv%3DSimplRVIAMLv5WebWithPLRVIOnTopCombiner&_trksid=p2047675.c100008.m2219)
- Wemos D1 Mini: AzDelivery (e.g. on Amazon) [Link](https://www.amazon.de/stores/AZDelivery/AZDelivery/page/2DB821D9-4A4B-4FD2-A50B-AE111B57FC93)
- GY-271 compass: AzDelivery (e.g. on Amazon) [Link](https://www.amazon.de/stores/AZDelivery/AZDelivery/page/2DB821D9-4A4B-4FD2-A50B-AE111B57FC93)
- GY-521 gyroscope: AzDelivery (e.g. on Amazon) [Link](https://www.amazon.de/stores/AZDelivery/AZDelivery/page/2DB821D9-4A4B-4FD2-A50B-AE111B57FC93)
- D24V10F5 [Link](https://eckstein-shop.de/Pololu-5V-1A-Step-Down-Spannungsregler-D24V10F5)
- Adafruit DRV8871: [Link](https://eckstein-shop.de/Adafruit-DRV8871-DC-Motor-Driver-Breakout-Board-36A-Max)

For the 22 KHz signal generator:
- Resistor 51 Ohm [Link](https://www.reichelt.de/de/en/carbon-film-resistor-1-4-w-5-51-ohm-1-4w-51-p1441.html?&nbc=1)
- Resistor 100 Ohm [Link](https://www.reichelt.de/de/en/carbon-film-resistor-1-4-w-5-100-ohms-1-4w-100-p1336.html?&nbc=1)
- Inductor 1 mH - BOU RLB0914-102K [Link](https://www.reichelt.de/index.html?ACTION=446&LA=0&nbc=1&q=bou%20rlb0914-102k)
- Capacitor 56 nF - RND 150MKT563K2E [Link](https://www.reichelt.de/index.html?ACTION=446&LA=0&nbc=1&q=150mkt563k2e%20)
- Capacitor 3,3 µF - TON 3,3/63 [Link](https://www.reichelt.de/index.html?ACTION=446&LA=446&nbc=1&q=ton%203%2C3%2F63)


- Version 0.3 - 26.10.2010: Separated elevation and offset to work with true elevation angles from calculators. 
- Version 0.2 - 26.10.2010: Initial version. 









