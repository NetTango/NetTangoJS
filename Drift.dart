import 'dart:html';
import 'dart:math';
import 'dart:json';

part 'Color.dart';
part 'Touch.dart';
part 'Turtle.dart';
part 'Patch.dart';
part 'Tween.dart';
part 'Model.dart';
part 'Toolbar.dart';
part 'Button.dart';
part 'StackGraph.dart';
part 'JsonObject.dart';
part 'NetTango.dart';


void main() {
   DriftModel model = new DriftModel();
   NetTango ntango = new NetTango(model);
   ntango.showToolbar();
   ntango.restart();
}


class DriftModel extends Model { 
  
   final int TURTLE_COUNT = 60;
   
   DriftModel() : super() {  }
   
   
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
     
      for (int i=0; i<TURTLE_COUNT; i++) {
         DriftTurtle t = new DriftTurtle(this);
         t.color = colors[i % 5].clone();
         addTurtle(t);
      }
   }
}


class DriftTurtle extends Turtle {

   num energy = 1;
  
   
   DriftTurtle(Model model) : super(model) {
      energy = 0.5 + Turtle.rnd.nextDouble() * 0.5;
   }
   
   
   void tick() {
      forward(0.1);
      right(Turtle.rnd.nextInt(20));
      left(Turtle.rnd.nextInt(20));
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
   
   
   bool touchDown(TouchEvent event) {
      die();
   }
   
   
   void reproduce() {
      DriftTurtle copy = new DriftTurtle(model);
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
}