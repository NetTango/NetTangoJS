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
class StackGraph {
   
   int width, height;
   bool refresh = true;
   const int MARGIN = 8;
   
   List data;
   
   num maxX = 0;
   num maxY = 0;
   
  
   StackGraph(this.width, this.height) {
      this.data = new List();
   }
   
   
   void addDataPoint(int tick, int value) {
      data.add(new DataPoint(tick, value));
      maxX = (maxX > tick)? maxX : tick;
      maxY = (maxY > value)? maxY : value;
   }
   
   
   // For efficiency, only redraw the entire graph if the refresh flag is true
   void draw(var ctx) {
      if (refresh) {
         ctx.fillStyle = "#333";
         ctx.fillRect(0, 0, width, height);
         int x = MARGIN;
         int y = MARGIN;
         int w = width - MARGIN * 2;
         int h = height - MARGIN * 2;
         ctx.strokeStyle = "white";
         ctx.beginPath();
         ctx.moveTo(x, y);
         ctx.lineTo(x, y + h);
         ctx.lineTo(x + w, y + h);
         ctx.lineWidth = 0.5;
         ctx.stroke();
         
         ctx.beginPath();
         ctx.moveTo(x, y + h);
         for (int i = 0; i<data.length; i++) {
            var value = data[i];
            ctx.lineTo(x + i, y + h - value.value); 
         }
         ctx.lineTo(x + data.length, y + h);
         ctx.closePath();
         ctx.fillStyle = "rgba(0, 100, 200, 0.8)";
         ctx.fill();
         refresh = true;
      }
   }
}


class DataPoint {
   int tick = 0;
   int value = 0;
   
   DataPoint(this.tick, this.value);
}
