#include <NeoPixelBus.h>


#define Pointer_Setting_Input 0
#define LED_Output 2
#define LED_1_Num 2
#define LED_2_Num 4
#define LED_3_Num 4


RgbColor Black(0, 0, 0);
RgbColor Red(255, 0, 0);
RgbColor Orange(255, 30, 0);
RgbColor Yellow(255, 150, 0);
RgbColor Blue(0, 20, 150);

//NeoPixelBus<NeoGrbFeature, NeoWs2812xMethod> strip1(LED_1_Num, LED_Output_1);
//NeoPixelBus<NeoGrbFeature, NeoWs2812xMethod> strip2(LED_2_Num, LED_Output_2);
NeoPixelBus<NeoGrbFeature, NeoWs2812xMethod> strip(LED_1_Num + LED_2_Num + LED_3_Num, LED_Output);

//CRGB StopSlow[LED_1_Num];
//CRGB Medium[LED_2_Num];
//CRGB Fast[LED_3_Num];

#define AveragingAmount 200
#define AverageDelay 10
#define ExtraDelayAmount 300
int ExtraDelay = ExtraDelayAmount;
int AnalogReadSmoothing[AveragingAmount];
int CurrentRead = 0;
int SmoothedRead = 0;
int Delay = 0;

#define FPS 60
#define UpdateTime 1000 / FPS
volatile unsigned long CurrentMillis;
volatile unsigned long LastFrame;

void setup() {

  strip.Begin();
  strip.Show();


  //Serial.begin(115200);
  //pinMode(Pointer_Setting_Input, INPUT);
}

void loop() {
  CurrentMillis = millis();
  Delay++;


  // put your main code here, to run repeatedly:
  if (CurrentMillis - LastFrame > UpdateTime) {

    for (int i = 0; i < LED_1_Num + LED_2_Num + LED_3_Num; i++) {
      strip.SetPixelColor(i, Black);  // Clear to blank
    }

    for (int i = LED_2_Num + LED_3_Num; i < LED_1_Num + LED_2_Num + LED_3_Num; i++) {
      strip.SetPixelColor(i, Blue);
      // Yellow = 255, 150, 0
    }

    if (SmoothedRead > 600) {
      for (int i = LED_2_Num + LED_3_Num; i < LED_1_Num + LED_2_Num + LED_3_Num; i++) {
        strip.SetPixelColor(i, Yellow);
        // Yellow = 255, 150, 0
      }
    }

    if (SmoothedRead > 1900) {
      for (int i = LED_3_Num; i < LED_2_Num + LED_3_Num; i++) {
        strip.SetPixelColor(i, Orange);
        // Orange = 255, 30, 0
      }
    }

    if (SmoothedRead > 3500) {
      for (int i = 0; i < LED_3_Num; i++) {
        strip.SetPixelColor(i, Red);
        // Red = 0, 0, 255
      }
    }
    //strip1.Show();
    //strip2.Show();
    strip.Show();
    LastFrame = CurrentMillis;
    Delay = 0;
    ExtraDelay = ExtraDelayAmount;
  } else if (Delay > (AverageDelay + ExtraDelay)) {
    SmoothedRead = 0;
    AnalogReadSmoothing[CurrentRead] = analogRead(Pointer_Setting_Input);
    for (int c = 0; c < AveragingAmount; c++) {
      SmoothedRead = SmoothedRead + AnalogReadSmoothing[c];
    }
    SmoothedRead = SmoothedRead / AveragingAmount;
    //Serial.println(SmoothedRead);
    Delay = 0;
    ExtraDelay = 0;
  }

  if (CurrentRead + 1 > AveragingAmount) {
    CurrentRead = 0;
  } else {
    CurrentRead++;
  }
}
