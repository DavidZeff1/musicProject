import processing.sound.*;

// Start menu
boolean gameStarted = false;
boolean cursorVisible = true;
SoundFile gameMusic;
SoundFile menuMusic;
SoundFile pause;
SoundFile lazer;
SoundFile kill;
SoundFile hitBoom;
SoundFile start_retry;
SoundFile game_over;
Sound s;
float modFreq = 250;  // Frequency of the modulator oscillator
float modIndex = 50;  // Modulation index (how much the modulator affects the carrier frequency)
// Sprites
PImage shipImage, laserImage, alienImage, spaceImage, menuImage;
float bgX = 0;

// Player variables
float starshipY = 0;
float starshipX = 50;

// Shot variables
float shotX, shotY, shotVisible, shotStart;
boolean shooting = false;

// Enemies
Enemy[] enemies = new Enemy[5];
int enemiesDefeated = 0;

// Score
int score = 0;
int lives = 5;

// Collision
int collisionTime = -3000;

// Pause and game over
boolean isPaused = false;
boolean gameOverClicked = false;
int bestScore = 0;
int previousScore = 0;

void startScreen() {
  image(menuImage, 0, 0, width, height);
  fill(255);
  textSize(80);
  textAlign(CENTER, CENTER);
  text("Generic Space Shooter", width / 2, height / 4);

  rectMode(CENTER);
  fill(200, 170, 0);
  rect(width / 2, height / 2 + 50, 120, 50, 10);
  fill(255);
  textSize(30);
  textAlign(CENTER, CENTER);
  text("Play", width / 2, height / 2 + 50);

  // CONTROL
  textSize(18);
  textAlign(CENTER, BOTTOM);
  fill(255);
  text("CONTROLS", width / 2, height - 100);

  textSize(25);
  textAlign(CENTER, TOP);
  fill(255);
  text("Move - Mouse    /    Shoot - Space    /    Pause - P", width / 2, height - 75);
  
  if(gameStarted) {
    gameMusic.stop();
  }
}

void setup() {
  size(960, 540);
  frameRate(60);
  noSmooth();
  rectMode(CENTER);

   
  gameMusic = new SoundFile(this, "data/audio/gameMusic.wav");
  menuMusic = new SoundFile(this, "data/audio/musicMenu.wav");
  pause = new SoundFile(this, "data/audio/pause.wav");
  lazer = new SoundFile(this, "data/audio/lazer.wav");
  kill = new SoundFile(this, "data/audio/kill.wav");
  hitBoom = new SoundFile(this, "data/audio/boomHit.wav");
  start_retry = new SoundFile(this, "data/audio/start_retry.wav");
  game_over = new SoundFile(this, "data/audio/game_over.wav");
  s = new Sound(this);
  menuMusic.loop();
  
  // Load images
  shipImage = loadImage(dataPath("sprites/Ship.png"));
  laserImage = loadImage(dataPath("sprites/Laser.png"));
  alienImage = loadImage(dataPath("sprites/Alien.png"));
  spaceImage = loadImage(dataPath("sprites/GameBG.jpeg"));
  menuImage = loadImage(dataPath("sprites/MenuBG.png"));

  // Create enemies
  for (int i = 0; i < enemies.length; i++) {
    enemies[i] = new Enemy(random(60, 300), random(4.5, 6.5));
  }

}

void starship() {
  if (millis() - collisionTime < 1500) {
    if ((millis() / 100) % 2 == 0) {
      image(shipImage, starshipX, starshipY, 120, 60);
    }
  } else {
    image(shipImage, starshipX, starshipY, 120, 60);
  }

  starshipY = mouseY;
}

void shot() {
      
  fill(222, 0, 0, shotVisible);
  noStroke();

  if (!shooting) {
    shotStart = starshipY + 20;
    shotX = starshipX;
  }
  if (shooting) {    
    shotY = shotStart;
    shotX = shotX + 60;
    image(laserImage, shotX, shotY, 70, 30);
  }
  
  if (keyPressed && key == ' '){
    shooting = true;  
  }
  if (shotX > width) {
    shooting = false;
  }
}

void hit() {
  
  for (int i = 0; i < enemies.length; i++) {
    if (enemies[i].enemyX <= starshipX && enemies[i].enemyX >= starshipX - 80 && enemies[i].position >= starshipY - 40 && enemies[i].position <= starshipY + 40) {
      if (millis() - collisionTime > 1500) {
       //   
          hitBoom.play();
          hitBoom.amp(1.5);

        lives--;
        collisionTime = millis();
        enemies[i].enemyX = -80;
      }
    }
    
  }

  if (lives == 0) {
    noLoop();
    stroke(255, 255, 255);
    strokeWeight(5);
    fill(100, 0, 0, 75);
    rect(width / 2, height / 2 + 8, 600, 300);
    fill(255, 0, 0);
    textSize(120);
    textAlign(CENTER, CENTER);
    text("GAME OVER", width / 2, height / 2);
    
    stroke(0,0,0);
    strokeWeight(3);
    fill(200, 170, 0);
    rect(width / 2, height / 2 + 200, 120, 50, 10);
    fill(0);
    textSize(30);
    textAlign(CENTER, CENTER);
    text("RETRY?", width / 2, height / 2 + 200);
    
    cursorVisible = true;
    cursor();
    game_over.play();
  }
}

void kill() {
  for (int i = 0; i < enemies.length; i++) {
    if (shotX >= enemies[i].enemyX && shotY >= enemies[i].position - 50 && shotY <= enemies[i].position + 50) {
      kill.play();
      //kill.amp(0.3);

      enemies[i].enemyX = width + 80;
      enemies[i].position = random(60, 300);
      enemies[i].speed = random(4.5, 6.5);
      enemies[i].startTime = millis();
      shooting = false;
      score++;
      enemiesDefeated++;     
    }
  }
}

void keyPressed() {
 
  
  if (key == 'p' || key == 'פ') {
    isPaused = !isPaused;
    if (isPaused) {
      
      pause.play();
      pause.amp(0.5);
      
      menuMusic.stop();
      gameMusic.stop();
      fill(255);
      textSize(80);
      textAlign(CENTER, CENTER);
      text("Pause", width / 2, height / 2);
      noLoop();
      
    } 
    else {      
      if (gameStarted) {
        gameMusic.loop();
      }
      else {
        menuMusic.loop();
      }
      loop();
      
  }

  }
  
  if (key == ' ') {
    lazer.play();
    lazer.amp(0.3);
  
  }
}



void resetGame() {
  previousScore = enemiesDefeated;
  lives = 5;
  score = 0;
  bgX = 0;
  collisionTime = -3000;
  gameStarted = false;
  cursorVisible = true;
  
  for (int i = 0; i < enemies.length; i++) {
    enemies[i] = new Enemy(random(60, 300), random(4.5, 6.5));
  }
  enemiesDefeated = 0;
  gameOverClicked = false;
  loop();
 
  if (previousScore > bestScore) {
    bestScore = previousScore;
  }

}


void resetEnemies() {
  for (int i = 0; i < enemies.length; i++) {
    enemies[i].enemyX = width;
    enemies[i].position = random(60, 300);
    enemies[i].speed = random(4.5, 6.5);
    enemies[i].startTime = millis();
  }
}

void scoreCount(){
  if (lives > 0) {
      
      fill(255, 255, 255);
      textSize(30);
      textAlign(LEFT, TOP);
      text("Life: " + lives, 20, 20);

      fill(255);
      textSize(30);
      textAlign(RIGHT, TOP);
      text("Score: " + score, width - 20, 20);
    } 
    else {
       // if the game stopped
           gameMusic.stop();   

     
      fill(255);
      textSize(25);
      textAlign(CENTER, TOP);
      text("Your Score: " + score, width / 2, 345);
      
      if (score > bestScore) {
        textSize(25);
        text("NEW RECORD: " + score, width / 2, 385);
      } else {
        textSize(25);
        text("Best Score: " + bestScore, width / 2, 385);
      }
    }
  
}


void mousePressed() {
  
  if (!gameStarted && mouseX > width / 2 - 120 && mouseX < width / 2 + 120 && mouseY > height / 2 && mouseY < height / 2 + 180) {
    //
      start_retry.play();
      start_retry.amp(1.5);
      
    gameStarted = true;
    menuMusic.stop();
    gameMusic.loop();
    
    cursorVisible = false;
    noCursor();
    resetEnemies();  
  }
  
  else if (lives <= 0 && mouseX > width / 2 - 60 && mouseX < width / 2 + 60 && mouseY > height / 2 + 150 && mouseY < height / 2 + 200) {
   //
    start_retry.play();
    start_retry.amp(1.5);

    resetGame();
        menuMusic.loop();

    gameOverClicked = true;
  } else {
    gameOverClicked = false;
  }
}


void draw() {
  
  image(spaceImage, bgX, 0, width, height);
  
  if (!gameStarted) {
    startScreen();
    
   } else {
    bgX -= 4;

    if (bgX <= -width) {
      bgX = 0;
    }

   image(spaceImage, bgX + width, 0, width, height);

    starship();
    shot();
    kill();

    for (int i = 0; i < enemies.length; i++) {
      enemies[i].move();
      enemies[i].display();
    }

    hit();
    scoreCount();
    
  }
}
