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

class PieChart implements Touchable {

   // drawing context 
   var ctx;
   
   // used to control the model
   NetTango app;
   
   // toolbar dimensions
   int x, y, width, height;
   
   
   PieChart(this.app) {
      
      CanvasElement canvas = document.query("#plots");
      ctx = canvas.getContext("2d");
      width = canvas.width;
      height = canvas.height;
      x = canvas.offsetLeft;
      y = canvas.offsetTop;

      int w = width;
      int h = height;
 
      window.setTimeout(updatePlot, 200);
      
      TouchManager.addTouchable(this);
   }
   
   
   void updatePlot() {
     
   }
   

   void draw() {
      int w = width;
      int h = height;
      ctx.clearRect(0, 0, w, h);
   }

   
   bool containsTouch(TouchEvent event) {
      num tx = event.touchX;
      num ty = event.touchY;
      return (tx >= x && ty >= y && tx <= x + width && ty <= y + height);
   }
   

   bool touchDown(TouchEvent event) {
      event.touchX -= x;
      event.touchY -= y;
      return false;
   }
   
   
   void touchUp(TouchEvent event) {
      event.touchX -= x;
      event.touchY -= y;
   }
   

   void touchDrag(TouchEvent event) {
      event.touchX -= x;
      event.touchY -= y;
   }
   

   void touchSlide(TouchEvent event) { }
}