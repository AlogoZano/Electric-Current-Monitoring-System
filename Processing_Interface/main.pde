import processing.serial.*;
import java.text.DecimalFormat;
Wave wave;

// variables para texto
PFont font, font2, font3;
PImage[] images;
float xPosition = 0;
float yPosition;

// botones
int buttonX = 100;
int buttonY = 100;
int buttonWidth = 200;
int buttonHeight = 100;
boolean buttonPressed = false;

// arreglo de imagenes
int numImages = 7;
boolean isBrandRunning = true;  // Flag to track if brand animation is running
int actual;

// para uso en menú secundario
String uso_recomendable;
String lum;
int corriente_ref;
String nivel_lum;
float cfe;

// para insertar datos desde ventana de Processing
String userInput = "";

int luminosidad; // se recibe de micro
int corriente; // se recibe de micro

//para medición de eficiciencia (%)
float eficiencia;

// medición de potencia
float potencia; // potencia se calcula aquí

float con_mensual;
// para comunicación serial
int numFoco;
int alta;
int baja;
int valorCompleto;
Serial puerto;

int voltaje = 130; // valor promedio calculado

String eficiencia_f;
String potencia_f;
String con_mensual_f; 
String cfe_f;
  
boolean bandera;

DecimalFormat df = new DecimalFormat("#.###");

void setup() {
  // se define tamaño de ventana  
  size(1200, 900);
  smooth();
  noStroke();
  yPosition = height / 4;
  wave = new Wave();
  wave.setup();

  // se define tipo de letra
  font = loadFont("CenturyGothic-Bold-150.vlw");
  font2 = loadFont("Calibri-Bold-20.vlw");
  font3 = loadFont("AgencyFB-Bold-48.vlw");
  textFont(font);
  frameRate(30);

  // se importan imagenes para GUI
  images = new PImage[numImages];
  images[0] = loadImage("lb512.png"); // Foco apagado
  images[1] = loadImage("lbon512.png"); // Foco encendido
  images[2] = loadImage("danger.png"); // Warning
  images[3] = loadImage("home.png");
  images[0].resize(420,0);
  images[1].resize(430,0);
  images[2].resize(120,0);
  images[3].resize(250,0);
  
  // comunicación serial
 /*printArray(Serial.list()); // lista de puertos
 puerto = new Serial(this, Serial.list()[0],9600); */

 }
  
  //Valor completo almacena el dato completo recibido por serial
 /*void comSerial(){
  delay(10);
  if (puerto.available()>0){
      alta = puerto.read();
      delay(10);
      baja = puerto.read();
      valorCompleto = (alta<<8)+baja;
      println(valorCompleto); 
  }
}*/
  
// función que recibe valor leído de luminosidad y evalúa si es baja, media o alta.  
String lum(int luminosidad){
  if (luminosidad == 1){
    return "Baja";
  } else if(luminosidad ==2){
    return "Media";
  } else {
    return "Alta";
  }
}
// función que recibe valores de corriente, corriente de referencia y luminosidad. 
// evalúa que los valores de corriente estén por debajo del margen de referencia y que la luminosidad sea buena.
String usoRecomendable(int corriente, int corriente_ref, int luminosidad){
  if(corriente<corriente_ref){
    if (luminosidad == 2 || luminosidad == 3){
      return "Sí";
    } 
  }
    return  "No";
}
  
void menuFoco1(){
// foco 1 -- min 30 / 220 
  corriente = 40; // IMPORTANTE: VALOR LEÍDO POR SERIAL DE CORRIENTE
  corriente_ref = 220; // Corriente de referenica basada en el rango
  luminosidad = 2; // IMPORTANTE: VALOR LEÍDO POR SERIAL DE LUMINOSIDAD
  potencia = (corriente*voltaje)*0.001;
  eficiencia = eficiencia(13,potencia);
  con_mensual = kwh_mensual(potencia, 6); // en lugar de 6 se pueden insertar las horas que se necesiten
  cfe = costo_cfe(con_mensual);
  background(0);
  image(images[3],880,580); // IMAGEN CASA
  
  if(corriente>30 && corriente<220){ // encendido
  image(images[1],20,40);
  } else if (corriente >220){ // supera umbral
  image(images[1],10,40);
  image(images[2], 300, 400); 
  } else { // apagado
  image(images[0],20,100); 
  } 
  uso_recomendable = usoRecomendable(corriente,corriente_ref,luminosidad);
  lum = lum(luminosidad);
  
  fill(255,255,0);
  textSize(85);
  text("Foco 1", 600, 150);
  textFont(font3);
  textSize(41);
  fill(255);
  
  text("Tipo: Fluorescente",600,220);
  text("Consumo: 13 W", 600, 270);
  text("Corriente: "+ corriente + " mA",600,320);
  text("Luminosidad: "+lum,600,370);
  text("Uso Recomendable: "+uso_recomendable,600,420);
  text("Costo Aproximado: $49",600,470);
  text("Tiempo de vida: 10000 h",600,520); 
  
  // Formatear valores para 2 decimales
  eficiencia_f = df.format(eficiencia);
  potencia_f = df.format(potencia);
  con_mensual_f = df.format(con_mensual);
  cfe_f = df.format(cfe);
  
  // eficiencia energética
  fill (0,255,150);
  text("Eficiencia energética: " + eficiencia_f + "%",50, 650);
  // consumo
  text("Consumo mensual: " + con_mensual_f + "kwH",50,700);
  // costo CFE 
  text("Costo CFE mensual: $" + cfe_f, 50, 750);
  textSize(25);
  text("Nota: para el costo mensual se considera 6h de uso promedio al día (por foco).", 50, 800);
}
void menuFoco2(){
// ESTE ES EL FOCO A CAMBIAR
// foco 2 -- min 30 / 220
  corriente = 300; // IMPORTANTE: VALOR LEÍDO POR SERIAL DE CORRIENTE
  corriente_ref = 220; // Corriente de referenica basada en el rango
  luminosidad = 2; // IMPORTANTE: VALOR LEÍDO POR SERIAL DE LUMINOSIDAD  
  potencia = (corriente*voltaje)*0.001;
  eficiencia = eficiencia(13, potencia);
  con_mensual = kwh_mensual(potencia, 6); // en lugar de 6 se pueden insertar las horas que se necesiten
  cfe = costo_cfe(con_mensual);

  background(0);
  image(images[3],880,580); // IMAGEN CASA

  if(corriente>30 && corriente<220){ // encendido
    image(images[1],20,40);  
  } else if (corriente >220){ // supera umbral
  image(images[1],10,40);
  image(images[2], 300, 400); 
  } else { // apagado
    image(images[0],20,100); 
  } 
  
  uso_recomendable = usoRecomendable(corriente, corriente_ref, luminosidad);
  lum = lum(luminosidad);
  
  fill(255,255,0);
  textSize(85);
  text("Foco 2", 500, 150);  
  textFont(font3);
  textSize(41);
  fill(255);
  
  text("Tipo: ",500,220);
  text("Consumo:  W", 500, 270);
  text("Corriente: "+corriente + " mA",500,320);
  text("Luminosidad: "+lum,500,370);
  text("Uso Recomendable: "+uso_recomendable,500,420);
  text("Costo Aproximado: ",500,470);
  text("Tiempo de vida: ",500,520);
  
  eficiencia_f = df.format(eficiencia);
  potencia_f = df.format(potencia);
  con_mensual_f = df.format(con_mensual);
  cfe_f = df.format(cfe);
  
  // eficiencia energética
  fill (0,255,150);
  text("Eficiencia energética: " + eficiencia_f + "%",50, 650);
  // consumo
  text("Consumo mensual: " + con_mensual_f + "kwH",50,700);
  // costo CFE 
  text("Costo CFE mensual: $" + cfe_f, 50, 750);
  textSize(25);
  text("Nota: para el costo mensual se considera 6h de uso promedio al día (por foco) ", 50, 800);
  
    
}
void menuFoco3(){
  corriente = 300; // IMPORTANTE: VALOR LEÍDO POR SERIAL DE CORRIENTE
  corriente_ref = 115; // Corriente de referenica basada en el rango
  luminosidad = 2; // IMPORTANTE: VALOR LEÍDO POR SERIAL DE LUMINOSIDAD  
  potencia = (corriente*voltaje)*0.001;
  eficiencia = eficiencia(8, potencia);
  con_mensual = kwh_mensual(potencia, 6); // en lugar de 6 se pueden insertar las horas que se necesiten
  cfe = costo_cfe(con_mensual);

   background(0);
   image(images[3],880,580); // IMAGEN CASA

// foco 3 -- min 30 / 115
  if(corriente>30 && corriente<115){ // encendido
    image(images[1],20,40);  
  } else if (corriente >115){ // supera umbral
    image(images[1],10,40);
    image(images[2], 300, 400); 
  } else { // apagado
    image(images[0],20,100); 
  } 
  
  uso_recomendable = usoRecomendable(corriente, corriente_ref, luminosidad);
  lum = lum(luminosidad);
  
  fill(255,255,0);
  textSize(85);
  text("Foco 3", 500, 150);  
  textFont(font3);
  textSize(35);
  fill(255);
  
  text("Tipo: LED (azul)",500,220);
  text("Consumo: 8 W", 500, 270);
  text("Corriente: "+corriente + " mA",500,320);
  text("Luminosidad: "+lum,500,370);
  text("Uso Recomendable: "+uso_recomendable,500,420);
  text("Costo Aproximado: $115",500,470);
  text("Tiempo de vida: 10000 h",500,520);
  
  eficiencia_f = df.format(eficiencia);
  potencia_f = df.format(potencia);
  con_mensual_f = df.format(con_mensual);
  cfe_f = df.format(cfe);
  
   // eficiencia energética
  fill (0,255,150);
  text("Eficiencia energética: " + eficiencia_f + "%",50, 650);
  // consumo
  text("Consumo mensual: " + con_mensual_f + "kwH",50,700);
  // costo CFE 
  text("Costo CFE mensual: $" + cfe_f, 50, 750);
  textSize(25);
  text("Nota: para el costo mensual se considera 6h de uso promedio al día (por foco).", 50, 800);
    
}
void menuFoco4(){
  corriente = 300; // IMPORTANTE: VALOR LEÍDO POR SERIAL DE CORRIENTE
  corriente_ref = 65; // Corriente de referenciaa basada en el rango
  luminosidad = 2; // IMPORTANTE: VALOR LEÍDO POR SERIAL DE LUMINOSIDAD  
  potencia = (corriente*voltaje)*0.001;
  eficiencia = eficiencia(4, potencia);
  con_mensual = kwh_mensual(potencia, 6); // en lugar de 6 se pueden insertar las horas que se necesiten
  cfe = costo_cfe(con_mensual);

  background(0);
  image(images[3],880,580); // IMAGEN CASA

// foco 4 -- min 30 / 65 // todo se maneja en mA
  if(corriente>30 && corriente<65){ // encendido
    image(images[1],20,40);  
  } else if (corriente >65){ // supera umbral
    image(images[1],10,40);
    image(images[2], 300, 400); 
  } else { // apagado
    image(images[0],20,100); 
  }
  uso_recomendable = usoRecomendable(corriente, corriente_ref, luminosidad);
  lum = lum(luminosidad);
  
  fill(255,255,0);
  textSize(85);
  text("Foco 4", 500, 150);  
  textSize(35);
  fill(255);
  text("Tipo: LED (minibulb)",500,220);
  text("Consumo: 4 W", 500, 270);
  text("Corriente: "+corriente + " mA",500,320);
  text("Luminosidad: "+lum,500,370);
  text("Uso Recomendable: "+uso_recomendable,500,420);
  text("Costo Aproximado: $44",500,470);
  text("Tiempo de vida: 150000 h",500,520); 
  
  eficiencia_f = df.format(eficiencia);
  potencia_f = df.format(potencia);
  con_mensual_f = df.format(con_mensual);
  cfe_f = df.format(cfe);
  
  // eficiencia energética
  fill (0,255,150);
  text("Eficiencia energética: " + eficiencia_f + "%",50, 650);
  // consumo
  text("Consumo mensual: " + con_mensual_f + "kwH",50,700);
  // costo CFE 
  text("Costo CFE mensual: $" + cfe_f, 50, 750);
  textSize(25);
  text("Nota: para el costo mensual se considera 6h de uso promedio al día (por foco).", 50, 800);
  
  
}

float eficiencia(float input, float output){
  return (output/input)*100;

}

float kwh_mensual(float potencia, int horas){
  potencia = (potencia/1000000)*horas*31;
  return potencia;
}

float costo_cfe(float kwh){
// considerando que en 2023 1kwh es 0.945 pesos
return kwh*0.945;
}

void menuInicio(int numFoco){
  // aplicar un while a menuInicio
  if (numFoco == 1) {
    menuFoco1();
 
  } else if (numFoco == 2) {
    menuFoco2();
  } else if (numFoco == 3) {
    menuFoco3();
  } else if (numFoco == 4) {
    menuFoco4();
  } else {
    numFoco = numFoco;
  }
}
void draw() {
  
  if (isBrandRunning && !bandera){
   wave.brand();
   String txt = "Bienvenido a AmpereWise, un dispositivo de medición que te proporcionará información sobre el consumo energético de diferentes focos y más. Nuestra prioridad es que puedas probar diferentes tipos para determinar cuál te conviene más considerando el consumo en relación con la luminosidad y los costos.";
   textSize(23);
   text(txt,50,600,width-90, height-610);
   bandera = true;
 }
  menuInicio(numFoco);
  
  
      
  
  /*comSerial();
 
    numFoco = puerto.read();
    menuInicio(numFoco);*/
  }
