/*
 * This example is based on the FlowField example of the Generative Typography example
 * Here is the link of the original source: https://github.com/AmnonOwed/CAN_GenerativeTypography
 *
 * In this sketch, the typo is generated with bubbles
 * For this part we only use the mouse:
 * the more you go away from the center of the screen the more you excite the bubbles
 * and so the more the text is visible
 * the bubbles tend to follow the mouse cursor
 */

// Color swatch
color c0 = color(73, 81, 208, 0);
color c1 = color(243, 240, 114, 200);
color c2 = color(125, 222, 227, 100);
color c3 = color(245, 91, 85, 200);

ArrayList <Particle> particles = new ArrayList <Particle> (); // the list of particles
color BACKGROUND_COLOR = c0;
color PGRAPHICS_COLOR = color(0);
PGraphics pg;

long timerParticles0;
int maxParticles = 1000; // the maximum number of active particles

long timerSensor0;
int deltaTimeSensor = 40;
float oldx;
float oldy;
float oldTime;

void setup() {
  size(1000, 450, P2D);
  // smooth(16); // higher smooth setting = higher quality rendering

  // create the offscreen PGraphics with the text
  pg = createGraphics(width, height, JAVA2D);
  pg.beginDraw();
  pg.textSize(350);
  pg.textAlign(CENTER, CENTER);
  pg.fill(PGRAPHICS_COLOR);
  pg.text("TYPE", pg.width/2, pg.height/2);
  pg.endDraw();
  background(BACKGROUND_COLOR);

  // MOVUINO
  callMovuino("127.0.0.1", 3000, 3001); // do not change values if using the Movuino interface

  // Data
  oldx = 0;
  oldy = 0;
  oldTime = millis();

  timerParticles0 = millis();
  timerSensor0 = millis();
}

void draw() {
  // Clear background
  background(BACKGROUND_COLOR);

  if (millis() - timerSensor0 > deltaTimeSensor) {
    timerSensor0 = millis();

    // ----------------------------------------------------------------------------------------------
    // Exercise: change those variables to adapt the behavior of the bubbles with the Movuino movement
    float particleEnergy;    // valeur varie entre 0 et 1
    float angleDirection;  // valeur varie entre 0 et TWO_PI // entre 0 et 6,28
    int particleDensity;   // valeur varie entre 0 et 10

    float x_ = movuino.ax; // (mouseX - width/2) / float(width/2);
    float y_ = movuino.ay; // (mouseY - height/2) / float(height/2);
    long time_ = millis();

    float dx_ = abs(x_ - oldx) / deltaTimeSensor;
    float dy_ = abs(y_ - oldy) / deltaTimeSensor;
    oldx = x_;
    oldy = y_;
    oldTime = time_;

    particleEnergy = 10 * pow(pow(100 * dx_, 2) + pow(100 * dy_, 2), 2);
    particleEnergy = constrain(particleEnergy, 0, 23);
    float ratioEnergy = particleEnergy / 23.0f; 
    particleDensity = round(random(2) + particleEnergy);
    println(particleEnergy);
    float particleEnergy_ =  particleEnergy / 23.0f;
    // ----------------------------------------------------------------------------------------------

    // Manage particles creation
    float deltaTime_ = 300 * (1 - ratioEnergy);
    angleDirection = getOrientationAngle(x_, y_);
    if (millis()-timerParticles0 > deltaTime_) {
      timerParticles0 = millis();
      for (int i=0; i < particleDensity; i++) {
        particles.add(new Particle(ratioEnergy, angleDirection)); // particle is created with a specific initial energy and a moving orientation defined by an angle
        delay(1);
      }
    }
  }

  // update and display each particle in the list
  for (Particle p : particles) {
    p.update();  // update position, life time, color and radius
    p.display();
  }

  // Remove particles with no life left
  for (int i=particles.size()-1; i>=0; i--) {
    Particle p = particles.get(i);
    if (p.life <= 0) {
      particles.remove(i);
    }
  }

  // Remove exceeding particles
  for (int i=0; i < particles.size() - maxParticles; i++) {
    particles.remove(i);
  }
}

float getOrientationAngle(float x_, float y_) {
  float angle_ = 0.0f;
  if (x_ != 0) {
    if (x_>0) {
      angle_ = atan(y_/x_);
    } else {
      angle_ = atan(y_/x_) + PI;
    }
  } else {
    angle_ = 0.0f;
    if (y_ > 0) {
      angle_ = PI;
    } else {
      angle_ = 3*PI/4.0f;
    }
  }
  return angle_;
}

void mousePressed() {
  background(BACKGROUND_COLOR); // clear the screen
  particles.clear(); // remove all particles
}
