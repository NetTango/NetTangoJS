import 'dart:html';
import 'dart:math';
import 'package:json/json.dart' as json;

import '../core/ntango.dart';
  
  void main() {
    DesignerModel model = new DesignerModel();
    model.restart();
    model.play(1);
  }

class DesignerModel extends Model { 
  CritterDesignerPad designPad;
  
  
   final int TURTLE_COUNT = 60;
   
   
   DesignerModel() : super() {  
      patchSize = 20;
      
   }
   
   void setup() {
      clearTurtles();
      clearPatches();
      initPatches();
      
      var colors = [
                   new Color(255, 0, 0, 255),
                   new Color(0, 255, 0, 255),
                   new Color(0, 0, 255, 255),
                   new Color(255, 255, 0, 255),
                   new Color(0, 255, 255, 255)];      
      designPad = new CritterDesignerPad();

//   // TEST LIST of points
//      Point p1 = new Point(0, 0);
//      Point p2 = new Point(0, 1);
//      Point p3 = new Point(1, 1);
//      
//      List<Point> points = new List<Point>();
//      points.add(p1);
//      points.add(p2);
//      points.add(p3);
//      
//      DesignerTurtle turtle = new DesignerTurtle(this, points);
      
   
   }
   
  void createTurtle(int x, int y){
    DesignerTurtle turtle = new DesignerTurtle(this, designPad.getPoints());
    turtle.setXY(x, y);
    addTurtle(turtle);
  }
   
   
  void tick() {
    designPad.draw();
//     remove dead turtles
    for (int i=turtles.length - 1; i >= 0; i--) {
      Turtle t = turtles[i];
      if (t.dead) {
        turtles.removeAt(i);
        TouchManager.removeTouchable(t);
        deadTurtles.add(t);
      }
    }
    
    // animate turtles
    for (var turtle in turtles) {
      turtle.tick();
      
    }
//    
    // animate patches
    if (patches != null) {
      for (var col in patches) {
        for (var patch in col) {
          patch.tick();
        }
      }
    }
  }
   
   
   // overwrite so we can create our special patches that spawn turtles
   void initPatches() { 
      patches = new List(worldWidth);
      for (int i=0; i < patches.length; i++) {
        patches[i] = new List<DesignerPatch>(worldHeight);
//        patches[i] = new List<Patch>(worldHeight);
         for (int j=0; j < worldHeight; j++) {
           patches[i][j] = new DesignerPatch(this, i + minPatchX, j + minPatchY);
//           patches[i][j] = new Patch(this, i + minPatchX, j + minPatchY);
            TouchManager.addTouchable(patches[i][j]);
         }
      }
   }   
   
   
}

class DesignerTurtle extends Turtle {
  
  
  // number for keeping track of where in its movement the turtle is
  int movementIndex;
  // list for keeping track of how fast to move forward
  List<int> speeds;
  // list for keeping track of how much to turn
  List<int> turns;
  // list that contains movement points
  List<Point> movementPoints;  

  num energy = 1;
  
  DesignerTurtle(DesignerModel model, movementPoints) : super(model) {
    // set random energy
    energy = 0.5 + Turtle.rnd.nextDouble() * 0.5;
    // set random heading
    heading = Turtle.rnd.nextInt(360); 
    
    // initiate our speed and turns lists
    speeds = new List<int>();
    turns = new List<int>();
    
    // initiate movement index
    movementIndex = 0;
    
    // getting a copy of movement poitns
    this.movementPoints = movementPoints.getRange(0, movementPoints.length - 1);
    


    // call method for converting movement points to series of right/left turns and forwards
    calculateMovement();
    
    //TEST: iterate through and see what we got
//    for (int i = 0; i < speeds.length; i++)
//    {
//      print("speed:");
//      print(speeds[i]);
//      print("turn:");
//      print(turns[i]);
//    }
//    
  }
  
  calculateMovement(){
    // create copy of movementpoints so that we do not corrupt the original one
    List<Point> movementCopy = movementPoints.getRange(0, movementPoints.length - 1);
    
    // if there are more than 3 points, the turtle moves
    if (movementPoints.length >= 3) {
      // do the first three 'manually'
      Point p1 = movementCopy[0];
      Point p2 = movementCopy[1];
      Point p3 = movementCopy[2];
      
      speeds.add(pointDistance(p1, p2));
      turns.add(turnAngle(p1, p2, p3));
      movementCopy.removeAt(0);
      
      // add turns and speeds
      for (Point p in movementCopy){
        p1 = p2;
        p2 = p3;
        p3 = p;
        speeds.add(pointDistance(p1, p2));
        turns.add(turnAngle(p1, p2, p3));
      }
    } // else it dies
    else die();
  
  }
  
  void tick(){
    
    
//    if (speeds == null) return;
    // iterate through speeds and turns and move around
    if(movementIndex > speeds.length - 1) {movementIndex = 0;}
    forward(speeds[movementIndex] / 20);
    right(turns[movementIndex]);
    movementIndex++;
//    
    // eat stuff (need to add for carnivorous)
    Patch p = patchHere();
    if (energy < 1 && p.energy > 0.2) {
      energy += 0.03;
      p.energy -= 0.2;
    }
    color.alpha = (255 * energy).toInt();
    energy -= 0.01;
    if (energy <= 0) {
      die();
    } else if (energy > 0.9 && Turtle.rnd.nextInt(100) > 95) {
      reproduce();
    }    
    
    }
  
  void reproduce() {
    DesignerTurtle copy = new DesignerTurtle(model, movementPoints);
    copy.x = x;
    copy.y = y;
    copy.heading = heading;
    copy.color.red = color.red;
    copy.color.green = color.green;
    copy.color.blue = color.blue;
    copy.energy = 0.5;
    energy = 0.5;
    model.addTurtle(copy);
  }  
    
  
  int pointDistance(Point p1, Point p2){
    int distance = sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y,2)).toInt();
    return distance;
  }
  
  int turnAngle(Point p1, Point p2, Point p3){
    double angle1Rad = atan2(p2.x - p1.x, p2.y - p1.y);
    double angle2Rad = atan2(p3.x - p2.x, p3.y - p2.y);
    double angleRad = angle2Rad - angle1Rad;
    double angleDeg = angleRad * 180 / PI;
    int angle = angleDeg.toInt();
    return angle;
    
  }
  
  
  
  
}


class CritterDesignerPad implements Touchable {
  // a random because they are nice to have around
  Random rnd = new Random();
  // list of buttons contained in the designer pad
  List<Button> buttons;
  
  // list of points that are being drawn 
  List<Point> drawnPoints;
  
  // drawing context 
  var ctx;
  
  // for dispatching touch events
  Button target = null;
  
  // used to control the model
  NetTango app;
  
  // toolbar dimensions
  int x, y, width, height;
  
  // a color
  Color color;
  
  CritterDesignerPad(){

    // get canvas
    CanvasElement canvas = document.query("#design-pad");
    // and context
    ctx = canvas.getContext("2d");
    // Manually set x,y,w,h
    // @todo this should be calculated automatically, somehow
    width = 300;
    height = 500;
    x = 900;
    y = 100;
    // init drawn points
    drawnPoints = new List<Point>();
   
    // and add it to the list of touchables
    TouchManager.addTouchable(this);    
    
  }
  
  void draw(){

    ctx.beginPath(); 
    // clear drawing area 
    ctx.clearRect(x,y,width,height); 
    ctx.fillStyle = "rgba(0, 0, 255, 0.3)"; 
    ctx.strokeStyle = "rgba(255, 255, 255, 0.8)";
    ctx.fillRect(x, y, width, height); 
    ctx.stroke(); 
    ctx.closePath(); 
    
    // now draw the drawn path from all the points in the list
    // create a copy so we can remove 1st point before we iterate through
    // to arc around all the different points
    if(drawnPoints.length > 1){

      List drawingPoints = drawnPoints.getRange(0, drawnPoints.length - 1);
      Point lastPoint = drawingPoints[0];
      drawingPoints.removeAt(0);
//      ctx.beginPath();
      ctx.moveTo(lastPoint.x, lastPoint.y);

      for (Point p in drawnPoints){
        // get destination point
        Point nextPoint = p;
        ctx.lineTo(p.x, p.y);
        ctx.arcTo(p.x,p.y, 1, 1, 1);

        }
//      Color color = new Color(255, 255, 0, 50);
      ctx.strokeStyle = color.toString();//"rgba(255, 255, 255, 0.2)";
      ctx.lineWidth = 8;
      ctx.stroke();      
    }
    
  }
  
  void setApp(NetTango app){
    
  }
  
  List<Point> getPoints(){
    return drawnPoints.getRange(0, drawnPoints.length - 1);
  }



  bool containsTouch(TouchEvent event) {
    num tx = event.touchX;
    num ty = event.touchY;
    return (tx >= x && ty >= y && tx <= x + width && ty <= y + height);
  }
  

  bool touchDown(TouchEvent event) {
    event.touchX -= x;
    event.touchY -= y;
    
    // create a new List<points> here
    drawnPoints.clear();
    
    // create a new color
    color.red = rnd.nextInt(255);
    color.green = rnd.nextInt(255);
    color.blue = rnd.nextInt(255);
    color.alpha = 100;    
    
    
    if (this.containsTouch(event)) {return true;}
    return false;

  }
  
  
  void touchUp(TouchEvent event) {
    print("touch up");

    // stop recording to the list here
    // then calculate the turtle movements
    // and create a new designer turtle that moves like that
    
    print('pad touch up');
    event.touchX -= x;
    event.touchY -= y;
    if (target != null) {
      target.touchUp(event);
      target = null;
    }
  }
  

  void touchDrag(TouchEvent event) {
    
//    // add points to the list here
//    
//    event.touchX -= x;
//    event.touchY -= y;
//    if (target != null) {
//      target.touchDrag(event);
//    }
  }
  

  void touchSlide(TouchEvent event) {
    // adding points 
    Point aPoint = new Point(event.touchX, event.touchY);
    drawnPoints.add(aPoint);   
    
    
  }
}



  class DesignerPatch extends Patch {
    CritterDesignerPad dpad;
    DesignerModel dmodel;

    DesignerPatch(DesignerModel model, int x, int y) : super(model, x, y) {
      this.dpad = model.designPad;
      dmodel = model;
      


  }
    

    bool touchDown(TouchEvent event) {
//      energy -= 0.5;
//      if (energy < 0) energy = 0;
//      dirty = true;
      dmodel.createTurtle(this.x, this.y);
      return false;



    }

    
  


  
  }
