# Satellite-Dish-Positioner


This is an automatical satellite dish positioner with Wemos D1, compass and MPU. It controls satellite dish direction with a Diseqc rotor (azimut) and linear actuator (elevation). Uses an MPU6050 device for Elevation and a QMC5883L compass for azimut control.

![SatPositioner](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/IMG_1403.jpg)

The purpose of this device is to support me on the boat with the positining of the satllite dish from the cabin. But it is als usable for campers and mobile homes.

The rotor is a standard Diseqc dish motor. But for this project we use the motor upside down to move the dish in horizontal ballance.

The ESP12 (in Wemos D1 Mini) controls the Diseqc motor with 22Khz tone signals as defined in the Diseqc standard. The ESP12 generates the signal which has to be modulated on the coax signal line of the motor. I found the necessary circuit on GitHub:(https://github.com/acrerd/Arduino-Diseqc-solar-tracker). Many thanks for the helpful support. That saved a lot of time.

The motor gets the power voltage also via the coax connection. 

The motor is able to move from -75 to +75 degrees with an accuracy of 1/16 degree. Which is more than sufficient for positioning the Azimut.
You just have to position the sat finder in a general south facing direction. Thats all.

The Elevation is controlled with a standard small linear actuator which is availebal for less than 30 Euro. I use here a actuator with 50 mm length.

The Wemos D1 Mini gets the power with a step-down converter from the 12-14 Volt from  the power source (e.g. from boat battery).
In addition to the 22KHz logic only three other items are required:

- Compass: GY-271 from AzDelivery (use QMC5883L library in Arduino)
- 6 axis gyroscope: GY-521 from AzDelivery (use MPU6050 library in Arduino):
- Motor driver:  Adafruit DRV8871 DC Motor Driver

The compass and the gyroscope are connected to the I2C bus of the Wemos D1 (using D1=SCL and D2=SDA).
The motor driver is using ports D0 and D6. The 22KHz signal is generated on port D5.

![Circuit](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/IMG_1400.jpg)

The positioner is controlled with a web interface. The ssid and password for WLAN has to be set in the code.
The device is pre-cofigured for Astra 19.2. Translated to stadard navigational compass cordinates this is 164° and elevation to horizontal is 8.1°.
Please change this for other satellites.

![WebInterface](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/StatfinderWeb.png)

With the web interface you can control the positioner. You can do fine tuning for azimut/elevation and switch automatic contol between Off, On and R-Off.
R-Off means only automatic control for azimut is switched off. Elevation remains on. The is a kind of "night" mode because the diseqc motor is a bit noisy when constantly re-positioning. The -Step/+Step buttons are changing the rotpr for 1/8 degree. Which should be sufficient for the desired purpose. It is possible to change it also to 1/16 degree.

The connection between the sat dish and the rotor as well as the other parts are designed with OpenSCAD. The files are stored in the SCAD folder.

![Connection](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/IMG_1404.jpg)

![Back](https://github.com/AK-Homberger/Satellite-Dish-Positioner/blob/main/IMG_1409.jpg)

Parts:

- Wemos D1 Mini: AzDelivery (e.g on Amazon)
- GY-271 compass: AzDelivery (e.g on Amazon)
- GY-521 gyroscope: AzDelivery (e.g on Amazon)
- D24V10F5 [Link](https://eckstein-shop.de/Pololu-5V-1A-Step-Down-Spannungsregler-D24V10F5)
- Adafruit DRV8871: [Link](https://eckstein-shop.de/Adafruit-DRV8871-DC-Motor-Driver-Breakout-Board-36A-Max)

For the 22KHz signal generator:
- Resistor 51 [Link](https://www.reichelt.de/)
- Resistor 100 [Link](https://www.reichelt.de/)
- Indictivity 1 mH - BOU RLB0914-102K [Link](https://www.reichelt.de/)
- Condensator 53 nF - RND 150MKT563K2E [Link](https://www.reichelt.de/)
- Condensator 3,3 yF - TON 3,3/63 [Link](https://www.reichelt.de/)












