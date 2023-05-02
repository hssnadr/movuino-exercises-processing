/*
  * This tempate is dedicated to show how to receive the data from the Movuina interface
  * It also shows how to interact with the vibrator by using the 2 functions:
    * vibroNow() : to switch ON/OFF the vibrator
    * vibroPule() : to make pulsation with 3 parameters (delayOn, delayOff, number of pulsations)
  * Simple click on the window to trig vibroNow() function, when release the mouse the program trigs the vibroPulse() function
*/

boolean switchVibroMod = false;

void setup() {
  size(400, 400);
  callMovuino("127.0.0.1", 3000, 3001); // no need to change if using the Movuino interface on the same computer
}

void draw() {
  // Receive and print Movuino data from the interface Movuina
  println("Device:", movuino.device);
  println("ID:", movuino.id);
  println("Accelerometer:", movuino.ax, movuino.ay, movuino.az);
  println("Gyroscope:", movuino.gx, movuino.gy, movuino.gz);
  println("Magnetometer:", movuino.mx, movuino.my, movuino.mz);
  println("Repetitions:", movuino.repAcc, movuino.repGyr, movuino.repMag);
  println("Gesture recognition:", movuino.xmmGestId, movuino.xmmGestProg);
  println("-------------------------");
  
  /* You can also directly print all those data by simply calling the dedicated function */
  //movuino.printInfo(); // uncomment to print Movuino data from the movuino class
}

void mousePressed() {
  movuino.vibroNow(true);  // activate continuous vibration
}

void mouseReleased() {
  movuino.vibroNow(false); // turn off vibrator
  movuino.vibroPulse(100, 150, 5); // send 5 pulsations of 100ms separate by 150ms
}
