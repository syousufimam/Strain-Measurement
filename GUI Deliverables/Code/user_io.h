#pragma once

struct userInput {
  double endPoint;
  double startPoint;
  int nrOfStops;
};



void getInput(userInput* data, bool* go);

void sendData(double position, double resistance, double strain);
