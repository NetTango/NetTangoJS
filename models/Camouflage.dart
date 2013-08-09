library nettango;

import 'dart:html';
import 'dart:math';
import 'dart:json';
import '../core/ntango.dart';

void main() {
   CamoModel model = new CamoModel();
   model.restart();
   model.play(1);
}


class CamoModel extends Model { 
  
  final int TURTLE_COUNT = 60;
   
  CamoModel() : super("Camouflage", "camo") {  
  }
   
   
  void setup() {
    clearTurtles();
    for (int i=0; i<TURTLE_COUNT; i++) {
      CamoTurtle t = new CamoTurtle(this);
      addTurtle(t);
      t.setXY(Model.rnd.nextDouble() * worldWidth - worldWidth / 2, 
              Model.rnd.nextDouble() * worldHeight - worldHeight / 2);
      t.stayWithinBoundaries();
    }
  }

   
  void doTouchDown(Contact c) {
    for (int i=0; i<turtles.length; i++) {
      CamoTurtle t = turtles[i] as CamoTurtle;
      if (t.containsTouch(c)) {
        t.die();
        CamoTurtle ct = oneOfTurtles() as CamoTurtle;
        ct.reproduce();
        return;
      }
    }
  }
}


class CamoTurtle extends Turtle {
   
   CamoTurtle(Model model) : super(model) {
      color.red = Turtle.rnd.nextInt(255);
      color.green = Turtle.rnd.nextInt(255);
      color.blue = Turtle.rnd.nextInt(255);
      color.alpha = 100;
      //drawShape = drawCircle;
   }
   
   
  void tick() { }
   
//   
//  void draw(CanvasRenderingContext2D ctx) {
//    ctx.beginPath();
//    ctx.arc(0, 0, 0.3, 0, PI * 2, true);
//    ctx.fillStyle = color.toString();
//    ctx.fill(); 
//  }
//   
  
  void draw(var ctx) {
    drawLegs(ctx, 0, 0, 0.1);
    //roundRect(ctx, -0.1, -0.1, 0.2, 0.2, 0.1);
    ctx.beginPath();
    ctx.arc(0, 0, 0.1, 0, PI * 2, true);
    ctx.fillStyle = color.toString();
    ctx.fill();
    ctx.strokeStyle = color.toString();
    ctx.lineWidth = 0.05;
    ctx.stroke();
  }
  
  void drawLegs(CanvasRenderingContext2D ctx, num x, num y, num r) {
    //double d = Turtle.rnd.nextDouble() * 1.5 * r;
    double d = 1.5 * r;
    
    ctx.beginPath();
    ctx.moveTo(x+2*r,y+d);
    ctx.lineTo(x-2*r,y-d);
    ctx.moveTo(x+2*r,y);
    ctx.lineTo(x-2*r,y);
    ctx.moveTo(x+2*r,y-d);
    ctx.lineTo(x-2*r,y+d);
    ctx.lineWidth = 0.02;
    ctx.strokeStyle = color.toString();
    ctx.stroke();
  }
  
  
   
  void reproduce() {
    CamoTurtle copy = new CamoTurtle(model);
    copy.x = x;
    copy.y = y;
    copy.color = this.color.clone();
    copy.color.red += (10 - Turtle.rnd.nextInt(20));
    copy.color.green += (10 - Turtle.rnd.nextInt(20));
    copy.color.blue += (10 - Turtle.rnd.nextInt(20));
    copy.right(Turtle.rnd.nextInt(360));
    copy.forward(Turtle.rnd.nextDouble());
    model.addTurtle(copy);
  }
  
  void stayWithinBoundaries(){
    if (x >= model.maxPatchX) {x--;}
    if (x <= model.minPatchX) {x++;}
    if (y >= model.maxPatchY) {y--;}
    if (y <= model.minPatchY) {y++;}
  }
  
  
}