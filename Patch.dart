/*
 * NetTango
 *
 * Michael S. Horn
 * Northwestern University
 * michael-horn@northwestern.edu
 * Copyright 2012, Michael S. Horn
 *
 * This project was funded in part by the National Science Foundation.
 * Any opinions, findings and conclusions or recommendations expressed in this
 * material are those of the author(s) and do not necessarily reflect the views
 * of the National Science Foundation (NSF).
 */
part of nettango;

class Patch implements Touchable {
   
   // patch coordinates
   int x, y;
   
   // patch color
   Color color;
   
   // reference to model
   var model;
   
   // only draw a patch if it needs updating
   bool dirty = true;
   
   num energy = 1;

   
   Patch(this.model, this.x, this.y) {
      color = new Color(0, 0, 0, 0);
   }
   
   
   void tick() {
      if (energy < 1) {
         energy += 0.01;
         dirty = true;
      }
   }

   
   void draw(var ctx) {
      if (dirty) {
         ctx.clearRect(x - 0.5, y - 0.5, 1, 1);
         color.alpha = (155 * (1 - energy)).toInt();
         ctx.fillStyle = color.toString();
         ctx.fillRect(x - 0.5, y - 0.5, 1, 1);
         dirty = false;
      }
   }
   
   
   bool containsTouch(TouchEvent event) {
     double tx = model.screenToWorldX(event.touchX, event.touchY);
     double ty = model.screenToWorldY(event.touchX, event.touchY);
     return (tx >= x-0.5 && tx <= x+0.5 && ty >= y-0.5 && ty <= y+0.5);
   }


   bool touchDown(TouchEvent event) {
      return false;
   }


   void touchUp(TouchEvent event) {
   }
   
   
   void touchSlide(TouchEvent event) {
     energy -= 0.5;
     if (energy < 0) energy = 0;
     dirty = true;
   }

   
   void touchDrag(TouchEvent event) {
   }
   
   
   
   List<Turtle> turtlesHere(){
     List<Turtle> turtleshere = new List<Turtle>();
     // go through all turtles
     for (Turtle t in model.turtles){
       // put the ones that have this as their patch in the list
       if(t.patchHere() == this){
         turtleshere.add(t);
         
       }
     }
     
     
     return turtleshere;
   }
   
   
}