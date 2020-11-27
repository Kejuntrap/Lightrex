import java.util.LinkedList; //<>//
import java.util.List;

Enemy[] enemies;    // 敵
Me me;    // プレイキャラ
int courseX;    // コース長
int numEnemy;    // 敵の数
int numObstacle;    // 障害物の数
int obstacleInterval;    // 障害物と障害物の最小の感覚
Obstacle[] obstacles;    // 障害物
int showX;    // 今映しているX座標の端
int straight;  // ストレート
int turnX;    // 曲がるときの横方向
int turnY;   // 曲がるときの縦方向
int minimumX;    // 自分敵の最も後ろ
int obstacleIndex;    // 最も左の障害物のインデックス
int lineWidth;
int fixedView;    // 固定始点するX座標
int[] times;    // ゴールタイムを記録
boolean isGoaled;  // すべてゴールしたか
List<Long> fps = new LinkedList<Long>();
PFont font;
long begin, now;
long frames;
String scenes;

void setup() {
  size(1600, 900);
  frameRate(60);
  background(0);
  scenes  = "title";
  font = loadFont("../data/font.vlw");
}

void draw() {
  background(0);
  if(scenes.equals("title")){
    
  }else if(scenes.equals("game")){
    if(!isGoaled){
      detectCollision();
      AI();
      positionUpdate();
  
    }
    drawObstacle();
    drawLines();
    reduction();
    showX = Math.max(me.x - fixedView, 0);
    if(me.x >= courseX){
      isGoaled = true;
    }
    frames++;
    if(frames % 300 == 0){
      System.gc();
    }
  }
  Show();
    
}

void Show() {
  textFont(font);
  textSize(48);
  stroke(255);
  if(scenes.equals("game")){
    if(!isGoaled){
      now = System.currentTimeMillis();
      
      if(fps.size()<= 100){
        fps.add(System.currentTimeMillis());
      }else{
        fps.remove(0);
        fps.add(System.currentTimeMillis());
      }
      
      if(fps.size() == 101){
        long last100fps = 1000000L / (fps.get( fps.size()-1) - fps.get(0)) ;
        text( last100fps/10+"."+last100fps%10+"fps", 10, 170);
      }
    
    }
    text("Your mark is "+ Position(), 10, 50);
    text("Time: "+getTime(now - begin), 10, 110);
  }else if(scenes.equals("title")){
    stroke(255);
    fill(255);
    PFont tf =loadFont("../data/title.vlw");
    textFont(tf);
    textSize(120);
    text("LightreX", width/2, height/2);
    textSize(24);
    text("Press any key", width/2, height/2+150);
  }
}

String getTime(long ms) {
  String s = String.format("%02d", ms/60000)+":"+String.format("%02d", (ms/1000)%60)+"."+String.format("%03d", ms%1000);
  return s;
}

int Position(){
  int pos = 0;
  for(int i=0; i<enemies.length; i++){
    if(me.x < enemies[i].x){
      pos++;
    }
  }
  return pos+1;
}
void reduction() {
  if (me.pushed.size() > 3) {
    if (me.pushed.get(0).x < minimumX - fixedView * 2) {
      me.pushed.remove(0);
    }
  }
  for (int i=0; i<enemies.length; i++) {
    if (enemies[i].pushed.size() > 3) {
      if (enemies[i].pushed.get(0).x < minimumX - fixedView * 2) {
        enemies[i].pushed.remove(0);
      }
    }
  }
}

void init(int _courseX, int _numEnemy, int _obstacleInterval, int _straight, int _turnX, int _turnY, int _lineWidth, int _fixedView) {
  fixedView = _fixedView;
  lineWidth = _lineWidth;
  straight = _straight;
  turnX = _turnX;
  turnY = _turnY;
  courseX = _courseX;
  numEnemy = _numEnemy;
  obstacleInterval = _obstacleInterval;
  showX = 0;
  obstacleIndex = 0;
  minimumX = Integer.MAX_VALUE;
  isGoaled = false;
  frames = 0;

  me = new Me();
  me.Add(me.x, me.y);
  enemies = new Enemy[numEnemy];
  for (int i=0; i<numEnemy; i++) {
    enemies[i] = new Enemy(360 * i / numEnemy);
    enemies[i].Add(enemies[i].x, enemies[i].y);
  }
  numObstacle = (courseX - obstacleInterval * 3) / obstacleInterval;
  obstacles = new Obstacle[numObstacle + 2];    // 最後と最初の1つは配列外参照されない為のもの
  for (int i=1; i< obstacles.length -1; i++) {
    int tmpconst = obstacleInterval * 3 + obstacleInterval * (i-1);
    obstacles[i] = new Obstacle(tmpconst, tmpconst + obstacleInterval / 2);
  }
  obstacles[0] = new Obstacle(-99999999, -99999999 + obstacleInterval / 2);
  obstacles[obstacles.length - 1] = new Obstacle(99999999, 99999999 + obstacleInterval / 2);
  times = new int[enemies.length + 1];
}

void AI() {
  for (int h=0; h<enemies.length; h++) {
    //enemies[h].vec = 0;
    for (int i=obstacleIndex; i<obstacles.length; i++) {
      if (enemies[h].x + enemies[h].obstacle >= obstacles[i].x && enemies[h].x + enemies[h].obstacle <= obstacles[i].x + obstacles[i].obstacleWidth) {  // まだ障害物の範囲内なら 複数の障害物は重ならないので1つ見ればよい
        if ( enemies[h].y >= obstacles[i].y && enemies[h].y <= obstacles[i].y + obstacles[i].obstacleHeight) {
          if (Math.abs(enemies[h].y - obstacles[i].y) <= Math.abs(obstacles[i].y + obstacles[i].obstacleHeight - enemies[h].y)) {
            enemies[h].Add(enemies[h].x, enemies[h].y);
            enemies[h].vec = -1;
          } else {
            enemies[h].Add(enemies[h].x, enemies[h].y);
            enemies[h].vec = 1;
          }
        } else {
          enemies[h].Add(enemies[h].x, enemies[h].y);
          enemies[h].vec = 0;
        }
        break;
      } else {
        //enemies[h].Add(enemies[h].x,enemies[h].y);
      }
    }
  }
}

void drawObstacle() {
  colorMode( RGB, 256, 256, 256, 256 );
  strokeWeight(1);
  fill(255, 255, 255, 191);
  stroke(255, 255, 255, 191);
  for (int i=1; i<obstacles.length - 1; i++) {
    rect(obstacles[i].x - showX, obstacles[i].y, obstacles[i].obstacleWidth, obstacles[i].obstacleHeight);
  }
  colorMode( RGB, 256, 256, 256, 256 );
}

void drawLines() {
  colorMode( RGB, 256, 256, 256, 256 );
  strokeWeight(lineWidth);
  if (!me.isOntheObstacle) {
    stroke(255, 255, 255, 255);
    for (int i=0; i<me.pushed.size(); i++) {
      if ( i == me.pushed.size() -1) {
        line(me.pushed.get(i).x - showX, me.pushed.get(i).y, me.x  - showX, me.y);
      } else {
        line(me.pushed.get(i).x  - showX, me.pushed.get(i).y, me.pushed.get(i+1).x  - showX, me.pushed.get(i+1).y);
      }
    }
  } else {
    stroke(255, 255, 255, 127);
    for (int i=0; i<me.pushed.size(); i++) {
      if ( i == me.pushed.size() -1) {
        line(me.pushed.get(i).x - showX, me.pushed.get(i).y, me.x  - showX, me.y);
      } else {
        line(me.pushed.get(i).x  - showX, me.pushed.get(i).y, me.pushed.get(i+1).x  - showX, me.pushed.get(i+1).y);
      }
    }
  }
  colorMode( HSB, 360, 100, 100 );
  for (int h=0; h<enemies.length; h++) {
    if(enemies[h].x >= me.x - fixedView * 2){
      if(!enemies[h].isOntheObstacle){
        stroke( enemies[h].linecolor, 100, 100 );
      }else{
        stroke( enemies[h].linecolor, 100, 100 ,127);
      }
      
      for (int i=0; i<enemies[h].pushed.size(); i++) {
        if ( i == enemies[h].pushed.size() -1) {
          line(enemies[h].pushed.get(i).x  - showX, enemies[h].pushed.get(i).y, enemies[h].x  - showX, enemies[h].y);
        } else {
          line(enemies[h].pushed.get(i).x  - showX, enemies[h].pushed.get(i).y, enemies[h].pushed.get(i+1).x  - showX, enemies[h].pushed.get(i+1).y);
        }
      }
    }
  }
  colorMode( RGB, 256, 256, 256, 256 );
  stroke(255, 255, 255);
}
void positionUpdate() {
  for (int h=0; h<enemies.length; h++) {
    int vx = 0;
    int vy = 0;
    switch(enemies[h].vec) {
    case -1:
      vx = turnX;
      vy = -turnY;
      break;
    case 0:
      vx = straight;
      vy = 0;
      break;
    case 1:
      vx = turnX;
      vy = turnY;
      break;
    default:
      break;
    }
    if ( enemies[h].isOntheObstacle) {
      vx /=4;
      vy /=4;
    }
    enemies[h].x += vx;
    if ( enemies[h].y + vy > height) {
      enemies[h].y = height;
      enemies[h].Add(enemies[h].x, enemies[h].y);
    } else if (enemies[h].y + vy < 0) {
      enemies[h].y = 0;
      enemies[h].Add(enemies[h].x, enemies[h].y);
    } else {
      enemies[h].y += vy;
    }
  }
  {
    int vx = 0;
    int vy = 0;
    switch(me.button) {
    case -1:
      vx = turnX;
      vy = -turnY;
      break;
    case 0:
      vx = straight;
      vy = 0;
      break;
    case 1:
      vx = turnX;
      vy = turnY;
      break;
    default:
      break;
    }
    if ( me.isOntheObstacle) {
      vx /=4;
      vy /=4;
    }
    me.x += vx;
    if ( me.y + vy > height) {
      me.y = height;
      me.Add(me.x, me.y);
    } else if (me.y + vy < 0) {
      me.y = 0;
      me.Add(me.x, me.y);
    } else {
      me.y += vy;
    }
  }
  
}
void keyPressed() {
  if(scenes.equals("game")){
    if(!isGoaled){
      if (key == 'W' || key == 'w') {
        me.Add(me.x, me.y);
        me.button = -1;
      } else if (key == 'S' || key == 's') {
        me.Add(me.x, me.y);
        me.button = 1;
      }
    }else{
      scenes = "title";
    }
  }else if(scenes.equals("title")){
    if(key == '1'){
      init(60000, 19, 500, 29, 20,21, 10, 500);
      scenes = "game";
    }else if(key == '2'){
      init(80000, 49, 240, 20, 16 ,12, 10, 600);
      scenes = "game";
    }else if(key == '3'){
      init(120000, 19, 400, 26, 24 ,10, 10, 600);
      scenes = "game";
    }else if(key == '4'){
      init(80000, 19, 700, 41, 9,40, 10, 600);
      scenes = "game";
    }
    begin = System.currentTimeMillis();
    
  }
}

void keyReleased() {
  if(scenes.equals("game")){
    me.Add(me.x, me.y);
    me.button = 0;  
  }
}

void detectCollision() {
  int tmpmin = Math.min(Integer.MAX_VALUE, me.x);
  for (int i=0; i<enemies.length; i++) {
    tmpmin = Math.min(tmpmin, enemies[i].x);
  }
  minimumX = tmpmin;
  for (int i = obstacleIndex; i < obstacles.length; i++) {
    if ( obstacles[i].x - minimumX >= 0) {
      obstacleIndex = i - 1;
      break;
    }
  }    // 見るべき障害物の数を減らす

  for (int h=0; h<enemies.length; h++) {
    enemies[h].isOntheObstacle = false;
    for (int i=obstacleIndex; i<obstacles.length; i++) {
      if (enemies[h].x >= obstacles[i].x && enemies[h].x <= obstacles[i].x + obstacles[i].obstacleWidth) {  // まだ障害物の範囲内なら 複数の障害物は重ならないので1つ見ればよい
        if ( enemies[h].y >= obstacles[i].y && enemies[h].y <= obstacles[i].y + obstacles[i].obstacleHeight) {
          enemies[h].isOntheObstacle = true;
        } else {
          //
        }
        break;
      } else {
        //
      }
    }
  }

  me.isOntheObstacle = false;
  for (int i=obstacleIndex; i<obstacles.length-1; i++) {
    if (me.x >= obstacles[i].x  && me.x <= obstacles[i].x + obstacles[i].obstacleWidth) {
      if ( me.y >= obstacles[i].y && me.y <= obstacles[i].y + obstacles[i].obstacleHeight) {
        me.isOntheObstacle = true;
      } else {
        //
      }
      break;
    } else {
      //
    }
  }
}


class Enemy {
  int x;
  int y;
  int obstacle;  // よける距離
  int linecolor;
  boolean isOntheObstacle = false;
  List<Point> pushed;
  int vec;
  Enemy(int c) {
    this.x = 0;
    this.y = height / 2;
    this.obstacle = int(random(-1000,1000));
    //this.obstacle = 1000 + int(random(0,200));
    this.linecolor =c;
    this.pushed = new LinkedList<Point>();
    this.vec = 0;
  }
  void Add(int _x, int _y) {
    pushed.add(new Point(_x, _y));
  }
}

class Obstacle {
  int x;
  int y;
  int obstacleWidth;
  int obstacleHeight;
  Obstacle(int min, int max) {    //どの範囲で障害物を置くか
    this.x = min + int(random(0, max-min)/2);
    this.y = int(random(height * 2)) - height/2;    //マイナスもあり得る
    this.obstacleHeight = int(random(height - 40));    // 必ずよけられるようにする
    this.obstacleWidth = int(random(max - this.x)/2) + (max - this.x)/2;      // こんな感じ
  }
}

class Me {
  int x;
  int y;
  int button;
  boolean isOntheObstacle = false;
  List<Point> pushed;
  Me() {
    this.x = 0;
    this.y = height / 2;
    this.button = 0;
    this.pushed = new LinkedList<Point>();
  }
  void Add(int _x, int _y) {
    pushed.add(new Point(_x, _y));
  }
}

class Point {
  int x;
  int y;
  Point(int _x, int _y) {
    this.x = _x;
    this.y = _y;
  }
}
