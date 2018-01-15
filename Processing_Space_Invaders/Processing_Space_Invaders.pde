/* * * * * * * * * * * * * * * * * * * * * 
 *  Instituto Tecnologico de Costa Rica  *
 *       Ingenieria en Computadores      *
 *            CE Experience 2017         *
 *           Pablo Garcia Brenes         *
 *         Processing Version 3.3.6      *
 * * * * * * * * * * * * * * * * * * * * */

import processing.serial.*; //imports for serial comunicaction
import cc.arduino.*;

//Dimension variables
int screenXsize;
int pixelsize = 4;  
int gridsize  = pixelsize * 7 + 5;

Player player1;
Player player2;

ArrayList enemies = new ArrayList(); //Array with enemies 
ArrayList bullets = new ArrayList(); //Array with bullets

int direction = 1;
boolean incy = false;
boolean playingWithKeys=false;

//Setup for arduino
Serial myPort;  // Create object from Serial class
String val;     // Data received from the serial port


//Look of the enemies
final String[] playerSprite =  {"0010100", 
"0110110", 
"1111111", 
"1111111", 
"0111110"};
final String[] enemySprite =  {"1011101", 
"0101010", 
"1111111", 
"0101010", 
"1000001"};

void setup() {
  if(!playingWithKeys){
    String portName = Serial.list()[1]; //change the 0 to a 1 or 2 etc. to match your port
    println(portName);
    myPort = new Serial(this, portName, 9600);
  }

  background(0);
  noStroke();
  fill(255);
  size(500, 400);
  screenXsize= 500;
  player1 = new Player(1);
  player2 = new Player(2);
  createEnemies();
}

void draw() {
  background(0);
  
  
  player1.draw();
  player2.draw();
  if (!playingWithKeys){
    listen();
  }

  for (int i = 0; i < bullets.size(); i++) {
    Bullet bullet = (Bullet) bullets.get(i);
    bullet.draw();
  }

  for (int i = 0; i < enemies.size(); i++) {
    Enemy enemy = (Enemy) enemies.get(i);
    if (enemy.outside() == true) {
      direction *= (-1);
      incy = true;
      break;
    }
  }

  for (int i = 0; i < enemies.size(); i++) {
    Enemy enemy = (Enemy) enemies.get(i);
    if (!enemy.alive()) {
      enemies.remove(i);
    } else {
      enemy.draw();
    }
  }

  incy = false;
}
void listen(){
   if ( myPort.available() > 0){  // If data is available
      val = trim(myPort.readStringUntil('\n'));
      if (val != null){
        if(val.equals("0 Just pressed")){
          player1.moveLeft();
        }
        else if(val.equals("2 Just pressed")){
          player1.moveRight();
        }
        else if(val.equals("1 Just pressed")){
          player1.shoot();
        }
       else if(val.equals("3 Just pressed")){
          player2.moveLeft();
        }
       else if(val.equals("5 Just pressed")){
         player2.moveRight();
       }
       else if(val.equals("4 Just pressed")){
         player2.shoot();
       }
       else{
          print("Text not recognized: "+ val);
       } 
     }
   }
}

void createEnemies() {
  for (int i = 0; i < width/gridsize/2; i++) {
    for (int j = 0; j <= 5; j++) {
      enemies.add(new Enemy(i*gridsize, j*gridsize));
    }
  }
}

class SpaceShip {
  int x, y;
  String sprite[];

  void draw() {
    updateObj();
    drawSprite(x, y);
  }

  void drawSprite(int xpos, int ypos) {
    for (int i = 0; i < sprite.length; i++) {
      String row = (String) sprite[i];

      for (int j = 0; j < row.length(); j++) {
        if (row.charAt(j) == '1')
          rect(xpos+(j * pixelsize), ypos+(i * pixelsize), pixelsize, pixelsize);
      }
    }
  }

  void updateObj() {
  }
}

class Player extends SpaceShip {
  boolean canShoot = true;
  int shootdelay = 0;
  int playerNumber;

  Player(int num) {
    if (num==1) {  
      x = width/gridsize/2;
      y = height - (10 * pixelsize);
      sprite = playerSprite;
    }
    if (num==2) {  
      x = width-50;
      y = height - (20 * pixelsize);
      sprite = playerSprite;
    }
    playerNumber = num;
  }
  void moveRight(){
    if (x<screenXsize-25) {
      x += 5;
    }
  }
  void moveLeft(){
    if (x>0) {
      x -= 5;
    }
  }
  void shoot(){
   bullets.add(new Bullet(x, y));
   canShoot = false;
   shootdelay = 0;
  }
  void updateObj() {
    if (playingWithKeys){
      updateObjKeys();
    }
  }
  
  void updateObjKeys() {  
    if (playerNumber==1) { 
      if (keyPressed && keyCode == LEFT) {
        moveLeft();
      }
      if (keyPressed && keyCode == RIGHT) {
        moveRight();
      }
      if (keyPressed && keyCode == UP && canShoot) {
        shoot();
      }
      shootdelay++;
      if (shootdelay >= 20) {
        canShoot = true;
      }
    } 
    else {
      if (keyPressed && key != CODED) {
        String letter= str(key);
        if (letter.equals("a")) {
          moveLeft();
        } else if ( letter.equals("d")) {
          moveRight();
        } else if (letter.equals("w") && shootdelay >= 20) {
          shoot();
        }
      }
      shootdelay++;
    }
  }
}

class Enemy extends SpaceShip {
  Enemy(int xpos, int ypos) {
    x = xpos;
    y = ypos;
    sprite    = enemySprite;
  }

  void updateObj() {
    if (frameCount%30 == 0) x += direction * gridsize;
    if (incy == true) y += gridsize / 2;
  }

  boolean alive() {
    for (int i = 0; i < bullets.size(); i++) {
      Bullet bullet = (Bullet) bullets.get(i);
      if (bullet.x > x && bullet.x < x + 7 * pixelsize + 5 && bullet.y > y && bullet.y < y + 5 * pixelsize) {
        bullets.remove(i);
        return false;
      }
    }

    return true;
  }

  boolean outside() {
    if (x + (direction*gridsize) < 0 || x + (direction*gridsize) > width - gridsize) {
      return true;
    } else {
      return false;
    }
  }
}

class Bullet {
  int x, y;

  Bullet(int xpos, int ypos) {
    x = xpos + gridsize/2 - 4;
    y = ypos;
  }

  void draw() {
    rect(x, y, pixelsize, pixelsize);
    y -= pixelsize;
  }
}