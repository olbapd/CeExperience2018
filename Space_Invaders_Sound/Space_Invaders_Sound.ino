/* * * * * * * * * * * * * * * * * * * * * 
 *  Instituto Tecnologico de Costa Rica  *
 *       Ingenieria en Computadores      *
 *            CE Experience 2017         *
 *           Pablo Garcia Brenes         *
 *         Arduino Version 1.8.5         *
 * * * * * * * * * * * * * * * * * * * * */
byte buttons[] = {14,15,16,17,18,19}; // the analog 0-5 pins are also known as 14-19
const int debounce = 10;
const int numButtons = sizeof(buttons);
int pinLed1 = 8;
int pinLed2 = 9;
int pinBuzzer1 = 10;
int pinBuzzer2 = 11;
byte pressed[numButtons], justpressed[numButtons], justreleased[numButtons];
static byte previousstate[numButtons];
static byte currentstate[numButtons];
static long lasttime;
void setup() {
  byte i;
  Serial.begin(9600);
  // pin13 LED
  pinMode(pinLed1, OUTPUT);
  pinMode(pinLed2, OUTPUT);
  pinMode(pinBuzzer1, OUTPUT);
  pinMode(pinBuzzer2, OUTPUT);
  for (i=0;i<6;i++){ 
    pinMode(buttons[i], INPUT_PULLUP);
    digitalWrite(buttons[i], HIGH);
  }
  lasttime=millis();
}

void check_switches(){
  if ((lasttime + debounce) > millis()) {
    return; 
  }
  for (byte i = 0; i<6;i++){
    justreleased[i] = 0;
    currentstate[i] = digitalRead(buttons[i]);
         
    /*Serial.print(i, DEC);
    Serial.print(": cstate=");
    Serial.print(currentstate[i], DEC);
    Serial.print(", pstate=");
    Serial.print(previousstate[i], DEC);
    Serial.print(", press=");*/
    
    
    if (currentstate[i] == previousstate[i]) {
      if ((pressed[i] == LOW) && (currentstate[i] == LOW)) {
          justpressed[i] = 1;
      }
      else if ((pressed[i] == HIGH) && (currentstate[i] == HIGH)) {
          justreleased[i] = 1;
      }
      pressed[i] = !currentstate[i];  // remember, digital HIGH means NOT pressed
    }
    
    previousstate[i] = currentstate[i];   // keep a running tally of the buttons
  }
  lasttime = millis();
}
void send_Message(String message){
  Serial.println(message);  
}
void loop() {
  check_switches(); 
  for (byte i = 0; i<6;i++){
   if (justpressed[i]) {
      Serial.print(i, DEC);
      Serial.println(" Just pressed");
      justpressed[i]=0;
      if(i==1){
        digitalWrite(pinLed1,HIGH);
        tone(pinBuzzer1, 1000);
      }
      else if(i==4){
        digitalWrite(pinLed2,HIGH);
        tone(pinBuzzer2, 1000);
      }
    }
    if (justreleased[i]) {
      justreleased[i]=0;
      if(i==1){
        digitalWrite(pinLed1,LOW);
        noTone(pinBuzzer1);
      }
      else if(i==4){
        digitalWrite(pinLed2,LOW);
        noTone(pinBuzzer2);
      }
    }
    
    /*if (pressed[i]) {
      Serial.print(i, DEC);
      Serial.println(" pressed");
    }*/
  }
}


