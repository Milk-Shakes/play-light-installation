/// BasicTest example to demonstrate massive parallel output with FastLED using
/// ObjectFLED for Teensy 4.0/4.1.
///
/// This mode will support upto 42 parallel strips of WS2812 LEDS! ~7x that of OctoWS2811!
///
/// The theoritical limit of Teensy 4.0, if frames per second is not a concern, is
/// more than 200k pixels. However, realistically, to run 42 strips at 550 pixels
/// each at 60fps, is 23k pixels.
///
/// @author Kurt Funderburg
/// @reddit: reddit.com/u/Tiny_Structure_7
/// The FastLED code was written by Zach Vorhies

#define MaxLEDCount 3740

byte LEDDisplay[MaxLEDCount][3];



#if !defined(__IMXRT1062__)  // Teensy 4.0/4.1 only.
#include "platforms/sketch_fake.hpp"
#else

// As if FastLED 3.9.12, this is no longer needed for Teensy 4.0/4.1.
#define FASTLED_USES_OBJECTFLED

// Optional define to override the latch delay (microseconds)
#define FASTLED_OBJECTFLED_LATCH_DELAY 75
#define FASTLED_OVERCLOCK 1.5
#include "FastLED.h"

#define VENDOR_ID 0x16C0
#define PRODUCT_ID 0x0480
#define RAWHID_USAGE_PAGE 0xFFAB  // recommended: 0xFF00 to 0xFFFF
#define RAWHID_USAGE 0x0200       // recommended: 0x0100 to 0xFFFF


#define NUM_LEDS1 63
#define NUM_LEDS2 94
#define NUM_LEDS3 126
#define NUM_LEDS4 157
#define NUM_LEDS5 189
#define NUM_LEDS6 220
#define NUM_LEDS7 251
#define NUM_LEDS8 283
#define NUM_LEDS9 314
#define NUM_LEDS10 346
#define NUM_LEDS11 377
#define NUM_LEDS12 409
#define NUM_LEDS13 440
#define NUM_LEDS14 471
#define NUM_LEDSSub 90

#define Offset1 0
#define Offset2 NUM_LEDS1
#define Offset3 Offset2 + NUM_LEDS2
#define Offset4 Offset3 + NUM_LEDS3
#define Offset5 Offset4 + NUM_LEDS4
#define Offset6 Offset5 + NUM_LEDS5
#define Offset7 Offset6 + NUM_LEDS6
#define Offset8 Offset7 + NUM_LEDS7
#define Offset9 Offset8 + NUM_LEDS8
#define Offset10 Offset9 + NUM_LEDS9
#define Offset11 Offset10 + NUM_LEDS10
#define Offset12 Offset11 + NUM_LEDS11
#define Offset13 Offset12 + NUM_LEDS12
#define Offset14 Offset13 + NUM_LEDS13

CRGB leds1[NUM_LEDS1];
CRGB leds2[NUM_LEDS2];
CRGB leds3[NUM_LEDS3];
CRGB leds4[NUM_LEDS4];
CRGB leds5[NUM_LEDS5];
CRGB leds6[NUM_LEDS6];
CRGB leds7[NUM_LEDS7];
CRGB leds8[NUM_LEDS8];
CRGB leds9[NUM_LEDS9];
CRGB leds10[NUM_LEDS10];
CRGB leds11[NUM_LEDS11];
CRGB leds12[NUM_LEDS12];
CRGB leds13[NUM_LEDS13];
CRGB leds14[NUM_LEDS14];
CRGB ledsSub[NUM_LEDSSub];


byte buffer[64];

byte DisplayCode[64];

void setup() {
  //Serial.begin(9600);

  CLEDController& c1 = FastLED.addLeds<WS2812, 9, GRB>(leds1, NUM_LEDS1);
  CLEDController& c2 = FastLED.addLeds<WS2812, 6, GRB>(leds2, NUM_LEDS2);
  CLEDController& c3 = FastLED.addLeds<WS2812, 5, GRB>(leds3, NUM_LEDS3);
  CLEDController& c4 = FastLED.addLeds<WS2812, 4, GRB>(leds4, NUM_LEDS4);
  CLEDController& c5 = FastLED.addLeds<WS2812, 3, GRB>(leds5, NUM_LEDS5);
  CLEDController& c6 = FastLED.addLeds<WS2812, 2, GRB>(leds6, NUM_LEDS6);
  CLEDController& c7 = FastLED.addLeds<WS2812, 14, GRB>(leds7, NUM_LEDS7);
  CLEDController& c8 = FastLED.addLeds<WS2812, 15, GRB>(leds8, NUM_LEDS8);
  CLEDController& c9 = FastLED.addLeds<WS2812, 16, GRB>(leds9, NUM_LEDS9);
  CLEDController& c10 = FastLED.addLeds<WS2812, 22, GRB>(leds10, NUM_LEDS10);
  CLEDController& c11 = FastLED.addLeds<WS2812, 21, GRB>(leds11, NUM_LEDS11);
  CLEDController& c12 = FastLED.addLeds<WS2812, 20, GRB>(leds12, NUM_LEDS12);
  CLEDController& c13 = FastLED.addLeds<WS2812, 19, GRB>(leds13, NUM_LEDS13);
  CLEDController& c14 = FastLED.addLeds<WS2812, 18, GRB>(leds14, NUM_LEDS14);

  CLEDController& Sub = FastLED.addLeds<WS2812, 17, GRB>(ledsSub, NUM_LEDSSub);

  FastLED.setBrightness(255);

  for (int d = 0; d < NUM_LEDSSub; d++) {
    ledsSub[d] = CRGB(255, 255, 255);
  }

  for (int c = 0; c < 64; c++) {
    DisplayCode[c] = 255;
  }
  DisplayCode[3] = 123;
  DisplayCode[4] = 45;
  DisplayCode[5] = 67;
  DisplayCode[6] = 89;
  DisplayCode[7] = 10;
  DisplayCode[8] = 11;
}

void loop() {
  int n;
  n = RawHID.recv(buffer, 0);  // 0 timeout = do not wait
  if (n != 0) {
    int c = buffer[0] + (buffer[1] * 256);
    if (buffer[0] != DisplayCode[0] && buffer[1] != DisplayCode[1] && buffer[2] != DisplayCode[2] && buffer[3] != DisplayCode[3] && buffer[4] != DisplayCode[4] && buffer[6] != DisplayCode[6] && buffer[7] != DisplayCode[7] && buffer[8] != DisplayCode[8]) {

      for (int i = 1; i < 21; i = i + 3) {
        if (c + i - 1 < MaxLEDCount) {
          LEDDisplay[c + i - 1][0] = buffer[1 + (i * 3)];
          LEDDisplay[c + i - 1][1] = buffer[2 + (i * 3)];
          LEDDisplay[c + i - 1][2] = buffer[3 + (i * 3)];
        }
      }
      //Serial.println(c);
      


    } else {

      //Serial.println(c);
      /*for (int i = 0; i < 201; i = i + 3) {
        Serial.print(LEDDisplay[Offset13-i][0]);
        Serial.print(", ");
        Serial.print(LEDDisplay[Offset13-i][1]);
        Serial.print(", ");
        Serial.print(LEDDisplay[Offset13-i][2]);
        Serial.print(" : ");
      }
      Serial.println(" ");*/

      //Serial.println("Printing LEDS! ");

      for (int i = 0; i < NUM_LEDS1; i++) {
        leds1[i] = CRGB(LEDDisplay[(Offset2 - 1) - i][0], LEDDisplay[(Offset2 - 1) - i][1], LEDDisplay[(Offset2 - 1) - i][2]);
      }
      for (int i = 0; i < NUM_LEDS2; i++) {
        leds2[i] = CRGB(LEDDisplay[Offset2 + i][0], LEDDisplay[Offset2 + i][1], LEDDisplay[Offset2 + i][2]);
      }
      for (int i = 0; i < NUM_LEDS3; i++) {
        leds3[i] = CRGB(LEDDisplay[(Offset4 - 1) - i][0], LEDDisplay[(Offset4 - 1) - i][1], LEDDisplay[(Offset4 - 1) - i][2]);
      }
      for (int i = 0; i < NUM_LEDS4; i++) {
        leds4[i] = CRGB(LEDDisplay[Offset4 + i][0], LEDDisplay[Offset4 + i][1], LEDDisplay[Offset4 + i][2]);
      }
      for (int i = 0; i < NUM_LEDS5; i++) {
        leds5[i] = CRGB(LEDDisplay[(Offset6 - 1) - i][0], LEDDisplay[(Offset6 - 1) - i][1], LEDDisplay[(Offset6 - 1) - i][2]);
      }
      for (int i = 0; i < NUM_LEDS6; i++) {
        leds6[i] = CRGB(LEDDisplay[Offset6 + i][0], LEDDisplay[Offset6 + i][1], LEDDisplay[Offset6 + i][2]);
      }
      for (int i = 0; i < NUM_LEDS7; i++) {
        leds7[i] = CRGB(LEDDisplay[(Offset8 - 1) - i][0], LEDDisplay[(Offset8 - 1) - i][1], LEDDisplay[(Offset8 - 1) - i][2]);
      }
      for (int i = 0; i < NUM_LEDS8; i++) {
        leds8[i] = CRGB(LEDDisplay[(Offset9 - 1) - i][0], LEDDisplay[(Offset9 - 1) - i][1], LEDDisplay[(Offset9 - 1) - i][2]);
      }
      for (int i = 0; i < NUM_LEDS9; i++) {
        leds9[i] = CRGB(LEDDisplay[(Offset10 - 1) - i][0], LEDDisplay[(Offset10 - 1) - i][1], LEDDisplay[(Offset10 - 1) - i][2]);
      }
      for (int i = 0; i < NUM_LEDS10; i++) {
        leds10[i] = CRGB(LEDDisplay[Offset10 + i][0], LEDDisplay[Offset10 + i][1], LEDDisplay[Offset10 + i][2]);
      }
      for (int i = 0; i < NUM_LEDS11; i++) {
        leds11[i] = CRGB(LEDDisplay[(Offset12 - 1) - i][0], LEDDisplay[(Offset12 - 1) - i][1], LEDDisplay[(Offset12 - 1) - i][2]);
      }
      for (int i = 0; i < NUM_LEDS12; i++) {
        leds12[i] = CRGB(LEDDisplay[Offset12 + i][0], LEDDisplay[Offset12 + i][1], LEDDisplay[Offset12 + i][2]);
      }
      for (int i = 0; i < NUM_LEDS13; i++) {
        leds13[i] = CRGB(LEDDisplay[(Offset14 - 1) - i][0], LEDDisplay[(Offset14 - 1) - i][1], LEDDisplay[(Offset14 - 1) - i][2]);
      }
      for (int i = 0; i < NUM_LEDS14; i++) {
        leds14[i] = CRGB(LEDDisplay[Offset14 + i][0], LEDDisplay[Offset14 + i][1], LEDDisplay[Offset14 + i][2]);
      }
      FastLED.show();
      /*for (int b = 0; b < MaxLEDCount; b++) {
        LEDDisplay[b][0] = 0;
        LEDDisplay[b][1] = 0;
        LEDDisplay[b][2] = 0;
      }*/
    }
  }
}

#endif  //  __IMXRT1062__