#include <FastLED.h>
#include "AS5600.h"

//#define Pointer_NUM_LEDS 7
#define Rope_NUM_LEDS 284

//#define ControlsUpdate 15
//#define ControlsUpdateTime 1000 / ControlsUpdate
//volatile unsigned long LastGodotCommunication;

#define FPS 90
#define UpdateTime 1000 / FPS
volatile unsigned long CurrentMillis;
volatile unsigned long LastFrame;

#define Pointer_State_0 0
#define Pointer_State_1 85
#define Pointer_State_2 170
#define Pointer_State_3 255

#define Pointer_DATA_PIN 0
#define Rope_DATA_PIN 4
#define Throttle_Input_1 33
#define Throttle_Input_2 25
#define Ring_Rotation_SDA 21
#define Ring_Rotation_SCL 22
#define Ring_Offset 0

//  Uncomment the line according to your sensor type
//AS5600L as5600;   //  use default Wire
AS5600 as5600;  //  use default Wire


#define AverageArraySize 50
int AveragedInput = 0;
byte Averaged_Throttle_1[AverageArraySize] = {};
byte Averaged_Throttle_2[AverageArraySize] = {};
int Throttle_1 = 0;
byte Throttle_1_Active = 0;
int Throttle_2 = 0;
byte Throttle_2_Active = 0;
byte Throttle_Speed = 0;
byte LastThrottle_Speed = 0;

#define AngleAverageAmount 200
int Ring_Angle = 0;
int Ring_Angle_Averaging[AngleAverageAmount];
int Angle_Current_Average = 0;
int LastAverageRingAngle = 0;

char buffer[5];

//CRGB Pointer[Pointer_NUM_LEDS];
CRGB Rope[Rope_NUM_LEDS];

void setup() {
  // put your setup code here, to run once:

  Serial.begin(115200);

  Wire.begin();

  pinMode(Pointer_DATA_PIN, OUTPUT);

  analogWrite(Pointer_DATA_PIN, Pointer_State_0);

  pinMode(Throttle_Input_1, INPUT);
  pinMode(Throttle_Input_2, INPUT);

  as5600.begin(17);                         //  set direction pin.
  as5600.setDirection(AS5600_CLOCK_WISE);  //  default, just be explicit.
  as5600.setOffset(Ring_Offset);

  FastLED.addLeds<WS2811, Rope_DATA_PIN, GRB>(Rope, Rope_NUM_LEDS);  // GRB ordering is assumed
}

void loop() {
  // put your main code here, to run repeatedly:
  CurrentMillis = millis();


  Ring_Angle = as5600.rawAngle();
  //Serial.print(Ring_Angle);
  //Serial.println("  ");
  Ring_Angle_Averaging[Angle_Current_Average] = Ring_Angle;
  if (Ring_Angle > 2 && Ring_Angle < 4092) {
    for (int b = 0; b < AngleAverageAmount; b++) {
      Ring_Angle = Ring_Angle + Ring_Angle_Averaging[b];
    }
    Ring_Angle = Ring_Angle / AngleAverageAmount;
  } else if (Ring_Angle <= 2) {
    Ring_Angle = 0;
    for (int d = 0; d < AngleAverageAmount; d++) {
      Ring_Angle_Averaging[d] = 0;
    }
  } else if (Ring_Angle >= 4092) {
    Ring_Angle = 4095;
    for (int d = 0; d < AngleAverageAmount; d++) {
      Ring_Angle_Averaging[d] = 4095;
    }
  }

  if (Angle_Current_Average < AngleAverageAmount - 1) {
    Angle_Current_Average++;
  } else {
    Angle_Current_Average = 0;
  } 

  if (AveragedInput < AverageArraySize - 1) {
    Averaged_Throttle_1[AveragedInput] = digitalRead(Throttle_Input_1);
    Averaged_Throttle_2[AveragedInput] = digitalRead(Throttle_Input_2);
    AveragedInput++;
  } else {
    AveragedInput = 0;
  }

  Throttle_1 = 0;
  Throttle_2 = 0;
  for (int i = 0; i < AverageArraySize; i++) {
    Throttle_1 = Throttle_1 + Averaged_Throttle_1[i];
    Throttle_2 = Throttle_2 + Averaged_Throttle_2[i];
  }

  /*Serial.print(Throttle_1);
    Serial.print("  ");
    Serial.print(Throttle_2);
    Serial.println("  ");*/

  if (Throttle_1 > (AverageArraySize / 2)) {
    Throttle_1_Active = 1;
  } else {
    Throttle_1_Active = 0;
  }
  if (Throttle_2 > (AverageArraySize / 2)) {
    Throttle_2_Active = 1;
  } else {
    Throttle_2_Active = 0;
  }

  if (Throttle_1_Active == 1 && Throttle_2_Active == 0) {
    Throttle_Speed = 3;
  } else if (Throttle_1_Active == 1 && Throttle_2_Active == 1) {
    Throttle_Speed = 2;
  } else if (Throttle_1_Active == 0 && Throttle_2_Active == 1) {
    Throttle_Speed = 1;
  } else {
    Throttle_Speed = 0;
  }

  if (CurrentMillis - LastFrame > UpdateTime) {
    for (int i = 0; i < Rope_NUM_LEDS; i++) {
      Rope[i] = CRGB(0, 0, 0);
    }

    if (Throttle_Speed == 3) {
      analogWrite(Pointer_DATA_PIN, Pointer_State_3);
      for (int i = 0; i < Rope_NUM_LEDS - 36; i++) {
        Rope[i] = CRGB(255, 0, 0);
        //Red = 0, 0, 255
      }
      for (int i = 1; i < 36; i++) {
        Rope[Rope_NUM_LEDS - i] = CRGB(255, 0, 0);
        //Red = 0, 0, 255 (36 leds)
      }
    } else if (Throttle_Speed == 2) {
      analogWrite(Pointer_DATA_PIN, Pointer_State_2);
      for (int i = 0; i < Rope_NUM_LEDS - 36; i++) {
        Rope[i] = CRGB(255, 30, 0);
        //Orange = 255, 30, 0
      }
      for (int i = 1; i < 24; i++) {
        Rope[Rope_NUM_LEDS - i] = CRGB(255, 30, 0);
        //Orange = 255, 30, 0 (24 leds)
      }
    } else if (Throttle_Speed == 1) {
      analogWrite(Pointer_DATA_PIN, Pointer_State_1);
      for (int i = 0; i < Rope_NUM_LEDS - 36; i++) {
        Rope[i] = CRGB(255, 190, 0);
        //yellow = 255, 190, 0
      }
      for (int i = 1; i < 12; i++) {
        Rope[Rope_NUM_LEDS - i] = CRGB(255, 150, 0);
        //yellow = 255, 150, 0 (12 leds)
      }
    } else if (Throttle_Speed == 0) {
      analogWrite(Pointer_DATA_PIN, Pointer_State_0);
      for (int i = 0; i < Rope_NUM_LEDS - 36; i++) {
        Rope[i] = CRGB(0, 20, 150);
        // Blue = 0, 20, 150
      }
      for (int i = 1; i < 2; i++) {
        Rope[Rope_NUM_LEDS - i] = CRGB(0, 20, 200);
        // Blue = 0, 20, 200 (2 LEDS)
      }
    }


    /* Serial.print(Throttle_Speed);
    Serial.print("  ");
    Serial.print(Throttle_1_Active);
    Serial.print("  ");
    Serial.print(Throttle_2_Active);
    Serial.print("  ");
    Serial.print(AveragedInput);
    Serial.print("  ");
    Serial.println();*/

    FastLED.show();
    LastFrame = CurrentMillis;
  }

 /* String Read = Serial.readString();
  Serial.print(Read);
  if (Read != "") {                // If anything comes in Serial (USB),
    sprintf(buffer, "%04d", Ring_Angle + 1000);
    Serial.print(buffer);
    Serial.println(Throttle_Speed);
  }*/
  //Serial.flush();


  if (LastAverageRingAngle != Ring_Angle or LastThrottle_Speed != Throttle_Speed) {
    sprintf(buffer, "%04d", Ring_Angle + 1000);
    Serial.print(buffer);
    Serial.println(Throttle_Speed);
  }
  LastAverageRingAngle = Ring_Angle;
  LastThrottle_Speed = Throttle_Speed;
  /*
  if (CurrentMillis - LastGodotCommunication > ControlsUpdateTime) {

    sprintf(buffer, "%04d", Ring_Angle + 1000);
    Serial.print(buffer);
    Serial.println(Throttle_Speed);
    //Serial.print("  ");
    //Serial.println("202");

    LastGodotCommunication = CurrentMillis;
  }*/

  //Pointer[0] = CRGB(255,0,0);
  //Pointer[1] = CRGB(255,0,0);
  //Pointer[2] = CRGB(255,0,0);

  //Pointer[3] = CRGB(255,30,0);
  //Pointer[4] = CRGB(255,30,0);
  //Pointer[5] = CRGB(255,30,0);

  //Pointer[6] = CRGB(255, 190, 0);
  //Pointer[6] = CRGB(0, 20, 200);
}
