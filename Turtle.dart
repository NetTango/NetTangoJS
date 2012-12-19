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

class Turtle implements Touchable {
  
   static Random rnd = new Random();
   
   int id;            // all turtles have a unique id number
   num x = 0, y = 0;  // turtle coordinates in world space
   num size = 1;      // turtle size
   num heading = 0;   // turtle heading in radians ARTHUR: DEGREES, RIGHT? 
   Color color;       // turtle color
   Model model;       // reference back to the containing model
   bool dead = false; // flag used to remove turtle from the model

   var drawShape = null;   // function to draw specific turtle shapes
   
   
   Turtle(this.model) {
      id = model.nextTurtleId();
      heading = rnd.nextInt(360);
      color = new Color(255, 255, 0, 50);
   }
  
   
   Turtle clone(Turtle parent) {
      Turtle t = new Turtle(model);
      t.x = x;
      t.y = y;
      t.size = size;
      t.heading = heading;
      t.color = color.clone();
      t.dead = false;
      return t;
   }
   
   
   void setXY(num x, num y) {
      this.x = wrapX(x);
      this.y = wrapY(y);
   }
   
   
   void forward(num distance) {
     // if model world is set to wrap
     if(this.model.wrapping){
      x = wrapX(x - sin(heading) * distance);
      y = wrapY(y + cos(heading) * distance);
     }
     // else bounce off world border
     else{
       x = bounceX(x - sin(heading) * distance);
       y = bounceY(y - cos(heading) * distance);
       
     }
     
   }

   bounceY(num ty) {
   }

   bounceX(num tx) {
     if(tx > model.maxWorldX){
//       heading = 
           /*
            * are these NetLogo turtle headings, or are they "normal" trig headings? is 0 up or right?
            * if heading is 90, cos is 0, should come out to 270
            * if heading is 45, cos is ~.5 should come out to 135
            * if heading is 89, cos is ~1 should come out to 91
            */
     }
     
     
     
     // set new position
     x = tx;
   }
   
      
   void backward(num distance) {
      forward(-distance);
   }
   
   
   void left(num degrees) {
      heading -= (degrees / 180) * PI;   
   }
   
   
   void right(num degrees) {
      left(-degrees);
   }
   
   
   void die() {
      dead = true;
   }
   
   
   Turtle hatch() {
      Turtle copy = clone(this);
      model.addTurtle(copy);
      return copy;
   }
   
   
   num wrapX(num tx) {
      while (tx < model.minWorldX) {
         tx += model.worldWidth;
      }
      while (tx > model.maxWorldX) {
         tx -= model.worldWidth;
      }
      return tx;
   }
   
   
   num wrapY(num ty) {
      while (ty < model.minWorldY) {
         ty += model.worldHeight;
      } 
      while (ty > model.maxWorldY) {
         ty -= model.worldHeight;
      } 
      return ty;
   }
   
   
   void draw(var ctx) {
      if (drawShape != null) {
         drawShape(ctx);
      } else {
         roundRect(ctx, -0.2, -0.5, 0.4, 1, 0.2);
         ctx.fillStyle = color.toString();
         ctx.fill();
         ctx.strokeStyle = "rgba(255, 255, 255, 0.5)";
         ctx.lineWidth = 0.05;
         ctx.stroke();
      }
   }
   
   
   Patch patchHere() {
      return model.patchAt(x, y);
   }
   
   // returns a list of turtles here
   // uses the patch primitive/method of the same name
   List<Turtle> turtlesHere(){
     Patch p = patchHere();
     return p.turtlesHere();
     
   }
   // @todo
   List<Turtle> otherTurtlesHereWith(Map<String, dynamic> params){
     List<Turtle> turtleshere = turtlesHere();
     for (Turtle t in turtleshere){
       
     }
   }
   
   
   Patch patchAhead(distance) {
      num px = wrapX(x - sin(heading) * distance);
      num py = wrapY(y + cos(heading) * distance);
      return model.patchAt(x, y);
   }
   
   
   void tick() {
      if (dead) return;
   }
   
   
   void roundRect(var ctx, num x, num y, num w, num h, num r) {
      ctx.beginPath();
      ctx.moveTo(x+r,y);
      ctx.arcTo(x+w,y,x+w,y+r,r);
      ctx.arcTo(x+w,y+h,x+w-r,y+h,r);
      ctx.arcTo(x,y+h,x,y+h-r,r);
      ctx.arcTo(x,y,x+r,y,r);
   }
   
   
   //-------------------------------------------------------------------
   // Touchable implementation
   //-------------------------------------------------------------------
   bool containsTouch(TouchEvent event) {
      double tx = model.screenToWorldX(event.touchX, event.touchY);
      double ty = model.screenToWorldY(event.touchX, event.touchY);
      return (tx >= x-size/2 && tx <= x+size/2 && ty >= y-size/2 && ty <= y+size/2);
   }
   
   
   bool touchDown(TouchEvent event) {
      color.setColor(255, 0, 0, 255);
      return true;
   }
   
   
   void touchUp(TouchEvent event) {
      color.setColor(0, 255, 0, 255);
   }
   
   
   void touchDrag(TouchEvent event) {      
      double tx = model.screenToWorldX(event.touchX, event.touchY);
      double ty = model.screenToWorldY(event.touchX, event.touchY);
      x = tx;
      y = ty;
   }
   
   
   void touchSlide(TouchEvent event) { }
}