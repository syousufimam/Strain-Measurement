#include "motorcontrol.h"
#include "user_io.h"
#include "config.h"


#include <math.h>
#include <stdio.h>


stepper motor1(9, 8, 10, 11); 


double readSensor(void) {
  
    double mean0 = 0.0;
    for (int i = 0; i < NUMBER_OF_SAMPLES; ++i) {
      mean0 += ((double)analogRead(A3)) / ((double)NUMBER_OF_SAMPLES);
      delay(5);
    }
    
    return mean0 / 1024.0 * 5.0;
}


double calculateResistance(double voltage) {
    return (voltage * REFERENCE_RESISTANCE) / (5.0 - voltage);
  }


double zeroDeflectionResistance;

double resistanceToStrain(double resistance) {
  return (resistance - zeroDeflectionResistance) / resistance / FACTOR_COEFICIEN_THING;
}

double deflectionToStrain(double deflection) {
  return 0.05984 * deflection;  
}



int cantileverPosition;


void setup() {
  Serial.begin(115200);
  pinMode(A3, INPUT);
  motor1.goToBottom();
  motor1.step(ZERO_DEFELCTION_POINT);
  cantileverPosition = 0;
  delay(2000);
  zeroDeflectionResistance = calculateResistance(readSensor());
}





userInput sweepConfig;
bool startSweep = false;



void loop() {

  getInput(&sweepConfig, &startSweep);


  if (startSweep) {
    
    Serial.print("Start Pos:");
    Serial.print(sweepConfig.startPoint);
    Serial.print(" , End Pos:");
    Serial.print(sweepConfig.endPoint);
    Serial.print(" , No of Readings:");
    Serial.println(sweepConfig.nrOfStops);
    sweepConfig.nrOfStops += 1;//Add one to include endpoint, given value will be number of stops between start and end.
    
    int moveSize = (sweepConfig.endPoint - sweepConfig.startPoint) / (double)sweepConfig.nrOfStops * STEPS_PER_TURN * TURNS_PER_MM; //Calculate the movesize in steps, to move between the stops

    cantileverPosition += motor1.step((int)(sweepConfig.startPoint * STEPS_PER_TURN * TURNS_PER_MM) - cantileverPosition);
    delay(2000); //Wait so that the cantilever stabilises before sampling the sensor. This wait is longer than the later once as initial move to this position was probobaly longer and the cantilever might threfor be vibrating more.
    double currentP = ((double)cantileverPosition) / ((double)(STEPS_PER_TURN * TURNS_PER_MM));
    double data = calculateResistance(readSensor());
    
   // sendData(currentP, data, deflectionToStrain(currentP / 1000.0)); //Divide position with 1000 to convert the value from mm to m when calculating strain
    data = calculateResistance(readSensor());
      data = ((data - zeroDeflectionResistance)*100/zeroDeflectionResistance);
      if (data <0)
      {
        data = data * -1;
      }
      Serial.println("Position  , Strain , (R-R0)/R0  ");
     sendData(currentP, data,deflectionToStrain(currentP*100 / 1000.0));
      for (int i = 0; i < sweepConfig.nrOfStops; ++i) {
      cantileverPosition += motor1.step(moveSize);
      delay(2000); 
      currentP = ((double)cantileverPosition) / ((double)(STEPS_PER_TURN * TURNS_PER_MM));
      data = calculateResistance(readSensor());
      data = ((data - zeroDeflectionResistance)*100/zeroDeflectionResistance); // Calculation of the Delta R / R0
      if (data <0)
      {
        data = data * -1;
      }
      sendData(currentP, data,deflectionToStrain(currentP*100 / 1000.0));
    }
    Serial.println("Readings Completed");
    startSweep = false;  
  }

  

  delay(3);
}
