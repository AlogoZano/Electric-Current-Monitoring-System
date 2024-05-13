class Wave{
// variables para generación de animación
int xspacing = 8;   // How far apart should each horizontal location be spaced
int w;              // Width of entire wave
int maxwaves = 4;   // total # of waves to add together

float theta = 0.0;
float[] amplitude = new float[maxwaves];   // Height of wave
float[] dx = new float[maxwaves];          // Value for incrementing X, to be calculated as a function of period and xspacing
float[] yvalues;                           // Using an array to store height values for the wave (not entirely necessary)

int brandStartTime;             // Starting time of the brand animation


void setup(){
// Para animación
  colorMode(RGB, 255, 255, 255, 100);
  w = width + 16;
  for (int i = 0; i < maxwaves; i++) {
    amplitude[i] = random(10, 30);
    float period = random(100, 300); // How many pixels before the wave repeats
    dx[i] = (TWO_PI / period) * xspacing;
  }
  yvalues = new float[w / xspacing];
  brandStartTime = millis();  // Record the starting time of the brand animation
}

void calcWave() {
  // Increment theta (try different values for 'angular velocity' here
  theta += 0.02;
  // Set all height values to zero
  for (int i = 0; i < yvalues.length; i++) {
    yvalues[i] = 0;
  }

  // Accumulate wave height values
  for (int j = 0; j < maxwaves; j++) {
    float x = theta;
    for (int i = 0; i < yvalues.length; i++) {
      // Every other wave is cosine instead of sine
      if (j % 2 == 0)  yvalues[i] += sin(x) * amplitude[j];
      else yvalues[i] += cos(x) * amplitude[j];
      x += dx[j];
    }
  }
}

void onlyWave(){
   noStroke();
  fill(255, 50);
  ellipseMode(CENTER);
  for (int x = 0; x < yvalues.length; x++) {
    ellipse(x * xspacing, height / 2 + yvalues[x], 16, 16);
  }
}

void createWave(){
background(0);
calcWave();
onlyWave();
}

void renderWave() {
  // A simple way to draw the wave with an ellipse at each location
  welcome_msg();
  noStroke();
  fill(255, 50);
  ellipseMode(CENTER);
  for (int x = 0; x < yvalues.length; x++) {
    ellipse(x * xspacing, height / 2 + yvalues[x], 16, 16);
  }
}

void brand() {
  background(0);
  calcWave();
  renderWave();
  
  
  if (millis() - brandStartTime >= 3000) {
    isBrandRunning = false;  // Stop the brand animation
  }
}

// función para mensaje de bienvenida
void welcome_msg() {
  background(0);
  fill(255, 255, 0);
  textSize(70);
  String l1 = "AmpereWise,";
  String l2 = "The Path to Electrical Efficiency";
  float lineHeight = textAscent() + textDescent(); // calculate height of one line of text
  text(l1, xPosition, yPosition);
  float yPosition2 = yPosition + lineHeight;
  text(l2, xPosition, yPosition2, 300);
  xPosition += 1;
}

}
