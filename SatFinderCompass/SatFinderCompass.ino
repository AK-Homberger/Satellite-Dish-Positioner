/*
  This code is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.
  This code is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.
  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

// ESP8266 Diseqc SatFinder
// Controls satellite dish direction with Diseqc rotor (azimut) and linear actuator (elevation)
// Uses an MPU6050 device for Elevation and a QMC5883L compass for Azimut control.

// Version 0.5, 07.11.2020, AK-Homberger

#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <ArduinoJson.h>
#include <ESP8266WiFiGratuitous.h>
#include <ArduinoOTA.h>
#include <TinyMPU6050.h>
#include <QMC5883LCompass.h>

#include "index.h"  // Web page header file

//    SDA => D2
//    SCL => D1

#define datapin D5      // Digital pin for 22 kHz signal D5
#define motor1 D6       // Linear Actuator 1
#define motor2 D0       // Linear Actuator 2
#define motorSpeed 800  // Actuator speed     // Change (lower) this if dish is begining to swing
#define UP 1
#define DOWN 2

//Enter your SSID and PASSWORD
const char* ssid = "hope";
const char* password = "thisis123";

float Astra_Az = 164, Astra_El = 30.19, El_Offset = -18, Az_Offset = -10.0; // Astra 19.2 position and dish specific offsets

float Azimut = 0, Elevation = 0;
float sAzimut = 0, sElevation = 0;
float dAzimut = 0, dElevation = 0;
float IsRotor = 0, RotorPos = 0;

bool auto_on = false;
bool update_rotor = false;
bool rotor_changed = false;
bool rotor_off = false;

unsigned long comp_on_time = 0, motor_on_time = 0;

int motor_error = 0;
int LED_level = 0;

QMC5883LCompass compass;
MPU6050 mpu (Wire);

ESP8266WebServer server(80);

void setup(void) {
  bool LED = false;

  Serial.begin(115200);
  delay(1000);
  Serial.println();
  Serial.println("Initialise Compass and MPU...");

  compass.init();
  compass.setCalibration(-1598, 1511, -2365, 872, -1417, 1440);   // Do a calibration for the compass and put your values here!!!
  compass.setSmoothing(10, true);

  // MPU Initialization
  mpu.Initialize();
  //Serial.println("Starting calibration...");
  //mpu.Calibrate();
  //Serial.println("Calibration complete!");

  pinMode(datapin, OUTPUT);
  pinMode(motor1, OUTPUT);
  pinMode(motor2, OUTPUT);
  digitalWrite(motor1, HIGH);
  digitalWrite(motor2, HIGH);
  pinMode(D4, OUTPUT);
  digitalWrite(D4, HIGH);

  // ESP connects to your wifi
  WiFi.mode(WIFI_STA);
  WiFi.hostname("SatFinder");
  WiFi.begin(ssid, password);

  Serial.print("Connecting to ");
  Serial.print(ssid);

  // Wait for WiFi to connect
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
    digitalWrite(D4, LED);
    LED = ! LED;
  }
  digitalWrite(D4, HIGH);

  // If connection successful show IP address in serial monitor
  Serial.println("");
  Serial.print("Connected to ");
  Serial.println(ssid);
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());  //IP address assigned to your ESP

  experimental::ESP8266WiFiGratuitous::stationKeepAliveSetIntervalMs(5000);

  // Arduino OTA config and start
  ArduinoOTA.setHostname("Satfinder");
  ArduinoOTA.begin();

  server.on("/", handleRoot);      //This is display page
  server.on("/get_data", handleGetData);//To get update of values
  server.on("/on", handleOn);
  server.on("/off", handleOff);
  server.on("/r_off", handleRotorOff);
  server.on("/az_up", handleAzUp);
  server.on("/az_down", handleAzDown);
  server.on("/el_up", handleElUp);
  server.on("/el_down", handleElDown);
  server.on("/rotor_up", handleRotorUp);
  server.on("/rotor_down", handleRotorDown);
  server.on("/rotor_up_step", handleRotorUpStep);
  server.on("/rotor_down_step", handleRotorDownStep);
  server.on("/cal", handleCal);

  server.on("/slider1", handleSlider1);
  server.on("/slider2", handleSlider2);
  server.on("/slider3", handleSlider3);

  server.onNotFound(handleNotFound);

  server.begin();                  //Start server
  Serial.println("HTTP server started");

  sAzimut = Astra_Az;
  sElevation = Astra_El;
}


void handleRoot() {
  server.send(200, "text/html", MAIN_page); //Send web page
}


void handleGetData() {
  String Text;

  StaticJsonDocument<300> root;

  root["azimut"] = Azimut;
  root["elevation"] = Elevation;

  root["s_azimut"] = sAzimut;
  root["s_elevation"] = sElevation;

  root["d_azimut"] = dAzimut;
  root["d_elevation"] = dElevation;

  root["rotor"] = IsRotor;
  root["led_level"] = LED_level;

  if (auto_on) root["state"] = "On"; else root["state"] = "Off";
  if (auto_on && rotor_off) root["state"] = "R-Off";

  serializeJsonPretty(root, Text);
  server.send(200, "text/plain", Text); //Send sensors values to client ajax request
}


void handleCal() {
  Serial.println("Starting calibration...");
  mpu.Calibrate();
  Serial.println("Calibration complete!");
  server.send(200, "text/html");
}


void handleAzDown() {
  if (dAzimut > -50) dAzimut -= 0.5;
  update_rotor = true;
  server.send(200, "text/html");
}


void handleAzUp() {
  if (dAzimut < 50) dAzimut += 0.5;
  update_rotor = true;
  server.send(200, "text/html");
}


void handleElDown() {
  if (dElevation > -8) dElevation -= 0.1;
  server.send(200, "text/html");
}


void handleElUp() {
  if (dElevation < 8) dElevation += 0.1;
  server.send(200, "text/html");
}


void handleRotorDown() {
  if (RotorPos > -70) RotorPos -= 1;
  update_rotor = true;
  server.send(200, "text/html");
}


void handleRotorUp() {
  if (RotorPos < 70) RotorPos += 1;
  update_rotor = true;
  server.send(200, "text/html");
}


void handleRotorDownStep() {
  noInterrupts();
  write_byte_with_parity(0xE0);
  write_byte_with_parity(0x31);
  write_byte_with_parity(0x69);
  write_byte_with_parity(0xfe);
  interrupts();
  server.send(200, "text/html");
  comp_on_time = millis() + 1000;
  rotor_changed = true;
  IsRotor = IsRotor + 1.0 / 8.0;
}


void handleRotorUpStep() {
  noInterrupts();
  write_byte_with_parity(0xE0);
  write_byte_with_parity(0x31);
  write_byte_with_parity(0x68);
  write_byte_with_parity(0xfe);
  interrupts();
  server.send(200, "text/html");
  comp_on_time = millis() + 1000;
  rotor_changed = true;
  IsRotor = IsRotor - 1.0 / 8.0;
}



void handleOn() {
  digitalWrite(D4, LOW);
  server.send(200, "text/html");
  auto_on = true;
  rotor_off = false;
  motor_error = 0;
}


void handleOff() {
  auto_on = false;
  rotor_off = true;
  digitalWrite(D4, HIGH);
  server.send(200, "text/html");
  noInterrupts();
  write_byte_with_parity(0xE0);
  write_byte_with_parity(0x31);
  write_byte_with_parity(0x60);
  interrupts();
  comp_on_time = 0;
  digitalWrite(motor2, HIGH);
  digitalWrite(motor1, HIGH);
}


void handleRotorOff() {
  rotor_off = true;

  server.send(200, "text/html");

  noInterrupts();
  write_byte_with_parity(0xE0);
  write_byte_with_parity(0x31);
  write_byte_with_parity(0x60);
  interrupts();
  comp_on_time = 0;
  digitalWrite(motor2, HIGH);
  digitalWrite(motor1, HIGH);
}



void handleSlider1() {
  if (server.args() > 0) {
    dAzimut =  server.arg(0).toFloat();
    Serial.print("Azimut:");
    Serial.println(Azimut);
    //update_rotor = true;
  }
  server.send(200, "text/html");
}


void handleSlider2() {
  if (server.args() > 0) {
    dElevation = server.arg(0).toFloat();
    Serial.print("Elevation:");
    Serial.println(Elevation);
  }
  server.send(200, "text/html");
}


void handleSlider3() {
  if (server.args() > 0) {
    RotorPos = server.arg(0).toFloat();
    Serial.print("Rotor:");
    Serial.println(RotorPos);
    update_rotor = true;
  }
  server.send(200, "text/html");
}


void handleNotFound() {                                           // Unknown request. Send error 404
  server.send(404, "text/plain", "File Not Found\n\n");
}


void write0() {                      // write a '0' bit toneburst
  for (int i = 1; i <= 22; i++) {    // 1 ms of 22 kHz (22 cycles)
    digitalWrite(datapin, HIGH);
    delayMicroseconds(16);
    digitalWrite(datapin, LOW);
    delayMicroseconds(17);
  }
  delayMicroseconds(500);             // 0.5 ms of silence
}


void write1() {                      // write a '1' bit toneburst
  for (int i = 1; i <= 11; i++) {    // 0.5 ms of 22 kHz (11 cycles)
    digitalWrite(datapin, HIGH);
    delayMicroseconds(16);
    digitalWrite(datapin, LOW);
    delayMicroseconds(17);
  }
  delayMicroseconds(1000);            // 1 ms of silence
}


// Calculate parity of a byte
bool parity_even_bit(byte x) {
  unsigned int count = 0, i, b = 1;

  for (i = 0; i < 8; i++) {
    if ( x & (b << i) ) {
      count++;
    }
  }
  if ( (count % 2) ) {
    return 0;
  }
  return 1;
}


// write the parity of a byte (as a toneburst)
void write_parity(byte x) {
  if (parity_even_bit(x)) write0(); else write1();
}


// write out a byte (as a toneburst)
// high bit first (ie as if reading from the left)
void write_byte(byte x) {
  for (int j = 7; j >= 0; j--) {
    if (x & (1 << j)) write1(); else write0();
  }
}


// write out a byte with parity attached (as a toneburst)
void write_byte_with_parity(byte x) {
  write_byte(x);
  write_parity(x);
}


// goto position angle a in degrees, south = 0.
// (a must be in the range +/- 75 degrees)
void goto_angle(float a) {
  /*
    Note the diseqc "goto x.x" command is not well documented.
    The general decription is available at https://de.eutelsat.com/en/support/technical-support/diseqc.html
    See "Positioner Application Note.pdf".

  */

  byte n1, n2, n3, n4, d1, d2;
  int a16;
  // get the angle in range +/- 75 degrees.  Sit at these limits and switch
  // over at ~ midnight unless otherwise instructed.

  if (a < -75.0) {
    a = -75;
  }
  if (a > 75.0) {
    a = 75;
  }

  // set the sign nibble in n1 to E (east) or D (west).
  if (a < 0) {
    n1 = 0xE0;
  } else {
    n1 = 0xD0;
  }
  // shift everything up so the fraction (1/16) nibble is in the
  //integer, and round to the nearest integer:
  a16 =  (int) (16.0 * abs(a) + 0.5);
  // n2 is the top nibble of the three-nibble number a16:
  n2 = (a16 & 0xF00) >> 8;
  // the second data byte is the bottom two nibbles:
  d2 = a16 & 0xFF;
  //the first data byte is
  d1 = n1 | n2;
  // send the command to the positioner
  noInterrupts();
  write_byte_with_parity(0xE0);
  write_byte_with_parity(0x31);
  write_byte_with_parity(0x6E);
  write_byte_with_parity(d1);
  write_byte_with_parity(d2);
  interrupts();
}


void motor(int direction) {
  float X = 0, Y = 0;

  mpu.Execute();
  X = round(mpu.GetAngX() * 10) / 10;

  if (direction == UP) {
    digitalWrite(motor2, LOW);
    analogWrite(motor1, motorSpeed);
    delay(10);
    mpu.Execute();
    Y = round(mpu.GetAngX() * 10) / 10;
  }

  if (direction == DOWN) {
    digitalWrite(motor1, LOW);
    analogWrite(motor2, motorSpeed - 500);
    delay(10);
    mpu.Execute();
    Y = round(mpu.GetAngX() * 10) / 10;
  }

  digitalWrite(motor1, HIGH);
  digitalWrite(motor2, HIGH);

  delay(10);
  //comp_on_time = millis() + 500;
  //rotor_changed = true;
  if ( X == Y ) motor_error++; else motor_error = 0;
}


void loop(void) {
  server.handleClient();
  ArduinoOTA.handle();
  mpu.Execute();
  compass.read();

  sAzimut = Astra_Az + dAzimut;
  sElevation = Astra_El + dElevation;

  dAzimut = round(dAzimut * 10) / 10;
  dElevation = round(dElevation * 10) / 10;

  sAzimut = round(sAzimut * 10) / 10;
  sElevation = round(sElevation * 10) / 10;

  if (rotor_changed && (millis() > comp_on_time )) {
    rotor_changed = false;
    Serial.println("Compass On");
  }

  if (!rotor_changed && !rotor_off)  {
    Azimut = compass.getAzimuth() - 90 - Az_Offset;
    if (Azimut < 0) Azimut += 360;
    if (Azimut > 360) Azimut -= 360;
  }

  Elevation = -round((mpu.GetAngX() + El_Offset) * 10) / 10;
  if (Elevation < 0 ) Elevation = 0;

  if (auto_on) {
    RotorPos = sAzimut - Azimut;
    if (RotorPos > 70) RotorPos = 70;
    if (RotorPos < -70) RotorPos = -70;

    if (motor_error < 20) {
      if (sElevation - Elevation > 0.3) {
        motor(UP);
      }
      else if (sElevation - Elevation < -0.3) {
        motor(DOWN);
      }
    }
  }

  if ((!rotor_off && abs(RotorPos - IsRotor) > 1) || update_rotor) {
    comp_on_time = millis() + (abs(RotorPos - IsRotor) * 700);
    rotor_changed = true;

    goto_angle(-RotorPos);
    Serial.print("RotorPos: ");
    Serial.println(RotorPos);
    IsRotor = RotorPos;
    update_rotor = false;
  }
  delay(10);
}
