import processing.serial.*;
import oscP5.*;
import netP5.*;
//Thread
Movuino movuino;
Thread movuinoThread;

void callMovuino(String ip_, int portin_, int portout_) {
  movuino = new Movuino(ip_, portin_, portout_);
  movuinoThread = new Thread(movuino);
  movuinoThread.start();
  movuino.printRawDataCollect();
}

//-----------------------------
//------- MOVUINO THREAD ------
//-----------------------------
public class Movuino implements Runnable {
  float[] rawData; // array list to store each data sent from the Movuino. The size of the list correspond to the size of the moving mean
  int nDat = 9; // number of data receive from Movuino (example : N = 6 for Acc X, Y, Z and Gyr X, Y, Z) + 1 ID

  Thread thread;
  // OSC communication parameters
  OscP5 oscP5Movuino;
  NetAddress myMovuinoLocation;
  int portIn = 7400;
  int portOut = 7401;
  String ip;

  String device;  // type of device (smartphone or movuino)
  String id;      // id of the device
  float ax;       // current acceleration X
  float ay;       // current acceleration Y
  float az;       // current acceleration Z
  float gx;       // current gyroscope X
  float gy;       // current gyroscope Y
  float gz;       // current gyroscope Z
  float mx;       // current magnetometer X
  float my;       // current magnetometer Y
  float mz;       // current magnetometer Z
  boolean repAcc = false;
  boolean repGyr = false;
  boolean repMag = false;
  int xmmGestId = 0;
  float xmmGestProg;
  int red = 255;   // red component for neopixel color
  int green = 255; // green component for neopixel color
  int blue = 255;  // blue component for neopixel color
  private int brightness = 255;

  public Movuino(String ip_, int portin_, int portout_) {
    this.ip = ip_;
    this.portIn = portin_;
    this.portOut = portout_;
    oscP5Movuino = new OscP5(this, this.portIn); // this port must be the same than the port on the Movuino
    myMovuinoLocation = new NetAddress(this.ip, this.portOut);
    NetInfo.print();
    this.rawData = new float[nDat];
  }

  public void start() {
    thread = new Thread(this);
    thread.start();
  }

  public void run() {
    while (true) {   
      // Update Movuino data at each frame
      this.ax = this.rawData[0];
      this.ay = this.rawData[1];
      this.az = this.rawData[2];
      this.gx = this.rawData[3];
      this.gy = this.rawData[4];
      this.gz = this.rawData[5];
      this.mx = this.rawData[6];
      this.my = this.rawData[7];
      this.mz = this.rawData[8];

      delay(5); // regulation
    }
  }

  public void stop() {
    thread = null;
  }
  
  //-----------------------------
  //--------- DATA PRINT --------
  //-----------------------------

  void printInfo() {
    println("Device:", this.device);
    println("ID:", this.id);
    println("Accelerometer:", this.ax, this.ay, this.az);
    println("Gyroscope:", this.gx, this.gy, this.gz);
    println("Magnetometer:", this.mx, this.my, this.mz);
    println("Repetitions:", this.repAcc, this.repGyr, this.repMag);
    println("Gesture recognition:", this.xmmGestId, this.xmmGestProg);
    println("-------------------------");
  }

  void printRawDataCollect() {
    // Print raw data store from the Movuino
    for (int j=0; j < this.nDat; j++) {
      if (this.rawData != null) {
        print(this.rawData[j] + " ");
      }
      if (j==this.nDat-1) {
        println();
      }
    }
  }
  
  //-----------------------------
  //---------- NEOPIXEL ---------
  //-----------------------------

  void lightNow(boolean isLit_) {
    // Switch ON/OFF the light
    if (isLit_) {
      this.setNeopix(this.red, this.green, this.blue); // turn on to previous light color
    } else {
      this.setNeopix(0);                               // turn off
    }
  }
  
  void setBrightness(int bright_){
    this.brightness = constrain(bright_, 0, 255);     // set new brightness
    this.setNeopix(this.red, this.green, this.blue);  // send to Movuino
  }

  void setNeopix(color color_) {
    setNeopix(red(color_), green(color_), blue(color_));
  }
  
  void setNeopix(float greyShade_) {
    greyShade_ = constrain(greyShade_, 0, 255);
    setNeopix(greyShade_, greyShade_, greyShade_);
  }

  void setNeopix(float red_, float green_, float blue_) {
    OscMessage myOscMessage = new OscMessage("/neopix"); // create a new OscMessage with an address pattern
    
    float bright_ = map(this.brightness, 0, 255, 255, 1);

    // Add new color values to message
    myOscMessage.add(int(red_/bright_));
    myOscMessage.add(int(green_/bright_));
    myOscMessage.add(int(blue_/bright_));

    // Send message
    oscP5Movuino.send(myOscMessage, myMovuinoLocation); // send the OscMessage to a remote location specified in myNetAddress
    
    // Store new color values
    if (red_ > 0 && green_ > 0 && blue_ > 0) {
      red = int(red_);
      green = int(green_);
      blue = int(blue_);
    }
  }
  
  //-----------------------------
  //---------- VIBRATOR ---------
  //-----------------------------
  
  void vibroNow(boolean isVibro_) {
    OscMessage myOscMessage = new OscMessage("/vibro/now"); // create a new OscMessage with an address pattern
    if(isVibro_){
      myOscMessage.add(1); // add a value to the OscMessage
    }
    else{
      myOscMessage.add(0);
    }
    oscP5Movuino.send(myOscMessage, myMovuinoLocation); // send the OscMessage to a remote location specified in myNetAddress
  }

  void vibroPulse(int on_, int off_, int n_) {
    OscMessage myOscMessage = new OscMessage("/vibro/pulse"); // create a new OscMessage with an address pattern
    myOscMessage.add(on_);   // add active time to osc message
    myOscMessage.add(off_);  // add inactive time to osc message
    myOscMessage.add(n_);    // add number of repetitions to the osc message
    oscP5Movuino.send(myOscMessage, myMovuinoLocation); // send the OscMessage to a remote location specified in myNetAddress
  }
  
  //-----------------------------
  //----- OSC COMMUNICATION -----
  //-----------------------------

  void sendToMovuino(String addr_, String mess_) {
    // Send messages to Movuino through OSC protocol
    OscMessage myOscMessage = new OscMessage("/" + addr_); // create a new OscMessage with an address pattern
    myOscMessage.add(mess_); // add a value to the OscMessage
    oscP5Movuino.send(myOscMessage, myMovuinoLocation); // send the OscMessage to a remote location specified in myNetAddress
  }
  
  void oscEvent(OscMessage theOscMessage) {
    // Receive data from Movuino on the channel /movuinOSC
    if (theOscMessage.checkAddrPattern("/movuino")) {
      this.device = "Movuino";
      if (theOscMessage.checkTypetag("sfffffffffii")) {
        this.id = theOscMessage.get(0).stringValue();
        for (int i=0; i<nDat; i++) {
          this.rawData[i] = theOscMessage.get(i+1).floatValue();
        }
        return;
      }
    }
    if (theOscMessage.checkAddrPattern("/streamo")) {
      this.device = "Smartphone";
      if (theOscMessage.checkTypetag("sfffffffffii")) {
        this.id = theOscMessage.get(0).stringValue();
        for (int i=0; i<nDat; i++) {
          this.rawData[i] = theOscMessage.get(i+1).floatValue();
        }
        return;
      }
    }
    if (theOscMessage.checkAddrPattern("/repetitions")) {
      if (theOscMessage.checkTypetag("s")) {
        this.repAcc = false;
        this.repGyr = false;
        this.repMag = false;

        String sensor_ =  theOscMessage.get(0).stringValue();

        switch(sensor_) {
        case "accelerometer":
          this.repAcc = true;
          break;
        case "gyroscope":
          this.repGyr = true;
          break;
        case "magnetometer":
          this.repMag = true;
          break;
        default:
          break;
        }
        return;
      }
    }
    if (theOscMessage.checkAddrPattern("/gesture")) {
      if (theOscMessage.checkTypetag("if")) {
        this.xmmGestId = theOscMessage.get(0).intValue();
        this.xmmGestProg = theOscMessage.get(1).floatValue();
        this.xmmGestProg = constrain(this.xmmGestProg, 0, 1);
        return;
      }
    }
    println("### received an osc message. with address pattern "+theOscMessage.addrPattern()+" and typetag "+theOscMessage.typetag());
  }
}
