part of nettango;

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
class Button implements Touchable {

   // this is returned with callback functions
   var action;
   
   // button image icon
   var img;
   
   // bounding box of the button
   int x, y, w, h;
   
   // callback when the button is touched
   var onClick = null;
   
   // callback when the button is released
   var onDown = null;
   
   // button can be clicked on
   bool enabled = true;
   
   // is the button down 
   bool down = false;
   
   // is the button visible
   bool visible = true;
      

   Button(this.x, this.y, this.w, this.h, this.action);

   
   void setImage(var path) {
      img = new ImageElement();
      img.src = path;
   }
   

//-------------------------------------------------------------
// Touchable implementation
//-------------------------------------------------------------
   bool containsTouch(TouchEvent event) {
      num tx = event.touchX;
      num ty = event.touchY;
      return (tx >= x && ty >= y && tx <= x + w && ty <= y + h);
   }
   
   
   bool touchDown(TouchEvent event) {
      down = true;
      if (onDown != null) onDown(action);
      return true;
   }
   
   
   void touchUp(TouchEvent event) {
      down = false;
      if (onClick != null && containsTouch(event)) {
         onClick(action);
      }
   }
   
   
   void touchDrag(TouchEvent event) { 
      down = containsTouch(event);
   }
   
   
   void touchSlide(TouchEvent event) { }

   
   void draw(var ctx) {
      if (!visible) return;
      int ix = down? x + 2 : x;
      int iy = down? y + 2 : y;
      int iw = img.width;
      int ih = img.height;
      
      ctx.drawImage(img, ix, iy, iw, ih);
   }
}
