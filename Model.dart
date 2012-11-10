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
abstract class Model {
   
   // Drawing context for turtles (TODO: use proper type)
  CanvasRenderingContext2D tctx;
   
   // Drawing context for patches
  CanvasRenderingContext2D pctx;
  
   // A collection of turtles in the model
   List turtles;
   
   // List of dead turtles
   List deadTurtles;
   
   // A list of patches
   List patches;
   
   // Size of a patch in pixels
   // TODO: Maybe patch size should vary according to world size rather than vice versa
   int patchSize = 40;
   
   // Dimensions of the world in patch coordinates
   int maxPatchX = 12;
   int minPatchX = -12;
   int maxPatchY = 12;
   int minPatchY = -12;
   
   // position of the canvas on the screen
   int offsetX = 0, offsetY = 0;
   
   // Used to generate unique turtle id numbers
   int TURTLE_ID = 0;
   
   static Random rnd = new Random();
   
   
   Model() {
      turtles = new List<Turtle>();
      deadTurtles = new List<Turtle>();
      patches = null; // don't create patches until resize is called
      
      CanvasElement canvas = document.query("#patches");
      pctx = canvas.getContext("2d");
      
      canvas = document.query("#turtles");
      tctx = canvas.getContext("2d");
      
      offsetX = canvas.offsetLeft;
      offsetY = canvas.offsetTop;
   }
   
   
   abstract void setup();
   
   
   void initPatches() { 
      patches = new List(worldWidth);
      for (int i=0; i < patches.length; i++) {
         patches[i] = new List<Patch>(worldHeight);
         for (int j=0; j < worldHeight; j++) {
            patches[i][j] = new Patch(this, i + minPatchX, j + minPatchY);
            TouchManager.addTouchable(patches[i][j]);
         }
      }
   }
   
   
   void addTurtle(Turtle t) {
      turtles.add(t);
      TouchManager.addTouchable(t);
   }
   
   
   void clearTurtles() {
      for (var t in turtles) {
         TouchManager.removeTouchable(t);
      }
      turtles = new List<Turtle>();
      deadTurtles = new List<Turtle>();
   }
   
   
   void clearPatches() {
      if (patches == null) return;
      for (var col in patches) {
         for (var patch in col) {
            TouchManager.removeTouchable(patch);
         }
      }
      patches = null;
   }
   
   
   Turtle oneOfTurtles() {
      return turtles[rnd.nextInt(turtles.length)];
   }
   
   
   void resize(int x, int y, int w, int h) {
      CanvasElement canvas = document.query("#patches");
      canvas.width = w;
      canvas.height = h;
      canvas.style.left = "${x}px";
      canvas.style.top = "${y}px";

      canvas = document.query("#turtles");
      canvas.width = w;
      canvas.height = h;
      canvas.style.left = "${x}px";
      canvas.style.top = "${y}px";
      
      offsetX = x;
      offsetY = y;

      int hpatches = w ~/ patchSize;
      int vpatches = h ~/ patchSize;
      maxPatchX = hpatches ~/ 2;
      maxPatchY = vpatches ~/ 2;
      minPatchX = maxPatchX - hpatches + 1;
      minPatchY = maxPatchY - vpatches + 1;
      
      if (patches != null) {
         clearPatches();
         initPatches();
      }
   }
   
   
   void tick(int count) {
     
      // remove dead turtles
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
      
      // animate patches
      if (patches != null) {
         for (var col in patches) {
            for (var patch in col) {
               patch.tick();
            }
         }
      }
   }
   
   
   void draw() {
      drawPatches(pctx);
      drawTurtles(tctx);
   }
 
   
   void drawTurtles(var ctx) {
      num cx = (0.5 - minPatchX) * patchSize;
      num cy = (0.5 - minPatchY) * patchSize;
      ctx.save();
      ctx.translate(cx, cy);
      ctx.scale(patchSize, -patchSize);
      
      ctx.clearRect(minWorldX, minWorldY, worldWidth, worldHeight);
      for (var turtle in turtles) {
         ctx.save();
         ctx.translate(turtle.x, turtle.y);
         ctx.rotate(turtle.heading);
         turtle.draw(ctx);
         ctx.restore();
      }
      ctx.restore();
   }
   
   
   void drawPatches(var ctx) {
      if (patches == null) return;
      num cx = (0.5 - minPatchX) * patchSize;
      num cy = (0.5 - minPatchY) * patchSize;
      ctx.save();
      ctx.translate(cx, cy);
      ctx.scale(patchSize, -patchSize);
      for (var col in patches) {
         for (var patch in col) {
            patch.draw(ctx);
         }
      }
      ctx.restore();
   }
   
   
   Patch patchAt(num tx, num ty) {
      if (patches == null) {
         return null;
      } else {
         int i = tx.round().toInt() - minPatchX;
         int j = ty.round().toInt() - minPatchY;
         return patches[i][j];
      }
   }
   
   
   num screenToWorldX(num sx, num sy) {
      sx -= offsetX;
      num cx = (0.5 - minPatchX) * patchSize;
      return (sx - cx) / patchSize;
   }
   
   
   num screenToWorldY(num sx, num sy) {
      sy -= offsetY;
      num cy = (0.5 - minPatchY) * patchSize;
      return (cy - sy) / patchSize;      
   }
   
   
   int nextTurtleId() => TURTLE_ID++;
   
   num get minWorldY => minPatchY - 0.5;
   num get minWorldX => minPatchX - 0.5;
   num get maxWorldY => maxPatchY + 0.5;
   num get maxWorldX => maxPatchX + 0.5;
   int get worldWidth => maxPatchX - minPatchX + 1;
   int get worldHeight => maxPatchY - minPatchY + 1;
   
}