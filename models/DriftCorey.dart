library nettango;

import 'dart:html';
import 'dart:math';
import 'dart:json';
import '../core/ntango.dart';


void main() {
   DriftModel model = new DriftModel();
   model.restart();
}


class DriftModel extends Model { 
  
   final int TURTLE_COUNT = 60;
  
   
   DriftModel() : super() { 
     
     patchSize = 20;
     
     // Dimensions of the world in patch coordinates
      maxPatchX = 18;
      minPatchX = -18;
      maxPatchY = 18;
      minPatchY = -18;
     
   }
   
   void initPatches() { 
     patches = new List(worldWidth);
     for (int i=0; i < patches.length; i++) {
       patches[i] = new List<Patch>(worldHeight);
       for (int j=0; j < worldHeight; j++) {
         patches[i][j] = new DriftPatch(this, i + minPatchX, j + minPatchY);
         TouchManager.addTouchable(patches[i][j]);
       }
     }
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
     
      for (int i=0; i<TURTLE_COUNT; i++) {
         DriftTurtle t = new DriftTurtle(this);
         t.color = colors[i % 5].clone();
         addTurtle(t);
      }
   }
}



class DriftPatch extends Patch {
  
  int timer = 0;
  bool amTiming = false; 
  
  
  static Random rnd = new Random();
  
  DriftPatch(Model model, int x, int y): super(model, x, y) {
    
  }
  
  //238-213-183
  
  bool containsTouch(TouchEvent event) {
    double tx = model.screenToWorldX(event.touchX, event.touchY);
    double ty = model.screenToWorldY(event.touchX, event.touchY);
    return (tx >= x-0.5 && tx <= x+0.5 && ty >= y-0.5 && ty <= y+0.5);
  }
  
  bool touchDown(TouchEvent event) {
    color.setColor(238, 213, 183, 0);
    startTimer();
    dirty = true;
   return false;
  }
  
  bool touchSlide(TouchEvent event) {
    color.setColor(238, 213, 183, 0);
    startTimer();
    dirty = true;
    return true;
  }
  
  void tick() {
    if (energy < 1) {
      energy += 0.01;
      dirty = true;
    }
    if (amTiming)
    {
      timer = timer + 1;
      if ( timer > 250 )
      {
       if (DriftPatch.rnd.nextInt(150) == 1)
       {
         color.setColor(0, 0, 0, 0);
         dirty = true;
         amTiming = false;
       }
      }
    }
  }
  
  void startTimer() {
    amTiming = true;
    timer = 0;
  }
  
  
  void draw(var ctx) {
    if (dirty) {
      ctx.clearRect(x - 0.5, y - 0.5, 1, 1);
      if ( amTiming )
      {
        color.alpha = 240;
      }
      else
      {
        color.alpha = (155 * (1 - energy)).toInt();
      }
      ctx.fillStyle = color.toString();
      ctx.fillRect(x - 0.5, y - 0.5, 1, 1);
      dirty = false;
    }
  }
  
}


class DriftTurtle extends Turtle {

   num energy = 1;
  
   
   DriftTurtle(Model model) : super(model) {
      energy = 0.5 + Turtle.rnd.nextDouble() * 0.5;
   }
   
   
   void tick() {
      forward(0.15);
      right(Turtle.rnd.nextInt(20));
      left(Turtle.rnd.nextInt(20));
      Patch p = patchHere();
      //    color.setColor(238, 213, 183, 0);
      if ( p.color.red == 238 && p.color.green == 213 && p.color.blue == 183 )
      {
        right(180);
        forward(.2);
      }
      
      if (energy < 1 && p.energy > 0.2) {
         energy += 0.02; //0.03;
         p.energy -= 0.2;
      }
      color.alpha = (255 * energy).toInt();
      energy -= 0.01;
      if (energy <= 0) {
         die();
      } else if (energy > 0.9 && Turtle.rnd.nextInt(100) > 85) {  //95
         reproduce();
      }
   }
   
   
   bool touchDown(TouchEvent event) {
      
     forward(2);
     //die();
   }
   
   
   void reproduce() {
      DriftTurtle copy = new DriftTurtle(model);
      copy.x = x;
      copy.y = y;
      copy.heading = heading;
      copy.color.red = color.red;
      copy.color.green = color.green;
      copy.color.blue = color.blue;
      copy.energy = 0.6;  //0.5
      energy = 0.6;  //0.5
      model.addTurtle(copy);
   }
}