#include "motorcontrol.h"
#include "Arduino.h"
  stepper::stepper(int stepPin, int dirPin, int bottomPin, int topPin) { //Step and direction pins to the motor controller as well as pin to the switch detecting bottom position
    pinS = stepPin;
    pinD = dirPin;
    pinB = bottomPin;
    pinT = topPin;

    pinMode(pinS, OUTPUT);
    pinMode(pinD, OUTPUT);
    pinMode(pinB, INPUT_PULLUP);
    pinMode(pinT, INPUT_PULLUP);
    digitalWrite(pinS, LOW);
  }
  
  
  int stepper::step(int nrOfSteps) {
    if (nrOfSteps == 0)
      return 0;

    bool up = nrOfSteps > 0;
    digitalWrite(pinD, up);
    
    int i;
    for (i = 0; i < abs(nrOfSteps) && (up || digitalRead(pinB) != LOW) && ((!up) || digitalRead(pinT) != LOW); ++i) { //Only check top switch if going up, and vice versa. So that the motor is not 
                                                                                                                      //  stopped if trying to leave end position.
      digitalWrite(pinS, HIGH);
      delayMicroseconds(STEPTIME / 2);
      digitalWrite(pinS, LOW);
      delayMicroseconds(STEPTIME / 2);
    }

    return (up ? 1 : -1) * i; //returning sign of nrOfSteps multiplied by i, will be nrOfSteps if it was not stopped early.
    
  }


  int stepper::goToBottom(void) {
    digitalWrite(pinD, LOW);
    int steps = 0;

    while(digitalRead(pinB) != LOW) {
      digitalWrite(pinS, HIGH);
      delayMicroseconds(STEPTIME / 2);
      digitalWrite(pinS, LOW);
      delayMicroseconds(STEPTIME / 2);
      
      --steps;
    }
    return steps;
    
  }
