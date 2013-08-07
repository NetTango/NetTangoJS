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
      t.setXY(Model.rnd.nextInt(worldWidth) - worldWidth / 2, 
              Model.rnd.nextInt(worldHeight) - worldHeight / 2);
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
   
   
  void draw(CanvasRenderingContext2D ctx) {
    ctx.beginPath();
    ctx.arc(0, 0, 0.3, 0, PI * 2, true);
    ctx.fillStyle = color.toString();
    ctx.fill();
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
}