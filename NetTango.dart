part of nettango;

class NetTango extends TouchManager {
      
   Model model;
   Toolbar toolbar = null;
   
   int width = 1000;
   int height = 700;
   
   // current tick count
   int ticks = 0;
   
   
   //-------------------------------------------
   // Play state
   //   -2 : play backward 2x
   //   -1 : play backward normal speed
   //   0  : paused
   //   1  : play forward normal speed
   //   2  : play forward 2x
   //   4  : play forward 4x ....
   //-------------------------------------------
   int play_state = 0; 

   
   NetTango(this.model) {
     
      // Canvas for drawing patches
      CanvasElement canvas = document.query("#patches");
      width = canvas.width;
      height = canvas.height;
      //canvas.width = width;
      //canvas.height = height;
      
      // Canvas for drawing turtles
      canvas = document.query("#turtles");
      //canvas.width = width;
      //canvas.height = height;
      
      // Resize the model
      model.resize(50, 50, width, height);
      
      // Event capture layer
      canvas = document.query("#events");
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
      registerEvents(canvas);
   }
   
   
   void resizeToFitScreen() {
      width = window.innerWidth;
      height = window.innerHeight;
      
      model.resize(0, 0, width, height);

      if (toolbar != null) {
         int w = toolbar.width;
         int h = toolbar.height;
         toolbar.x = width ~/ 2 - w ~/ 2;
         toolbar.y = height - h - 18;
         CanvasElement canvas = document.query("#toolbar");
         if (canvas != null) {
            canvas.style.left = "${toolbar.x}px";
            canvas.style.top = "${toolbar.y}px";
         }
      }
   }
   
   
/* Show the toolbar on the screen
 */
   void showToolbar() {
      toolbar = new Toolbar(this);
   }
 
 
/*
 * Restart the simulation
 */
   void restart() {
      pause();
      ticks = 0;
      model.setup();
      draw();
   }

   
/*
 * Tick: advance the model, animate, and repaint
 */
   void tick() {
      if (play_state != 0) {
         for (int i=0; i<play_state; i++) {
            ticks++;
            animate();
         }
         draw();
         window.setTimeout(tick, 20);
      }
   }
   
   
/*
 * Start the simulation
 */
   void play(num speedup) {
      play_state = speedup;
      tick();
   }
   

/*
 * Pause the simulation
 */
   void pause() {
      play_state = 0;
   }
   
   
/*
 * Speed up the simulation
 */
   void fastForward() {
      if (play_state < 16 && play_state > 0) {
         play_state *= 2;
      } else if (play_state == 0) {
         play(1);
      } else {
         play_state = 1;
      }
   }
   
   
/*
 * Step forward 1 tick 
 */
   void stepForward() {
      pause();
      ticks++;
      animate();
      draw();
   }
   
   
/*
 * Toggle fullscreen mode
 */
   void fullscreen() {
      restart();
      model.resize(0, 0, window.innerWidth, window.innerHeight);
      draw();
   }
   
   
   void partscreen() {
      restart();
      model.resize(50, 50, width, height);
      draw();
   }
   
   
   void animate() {
      model.tick(play_state);
   }


   void draw() {
      model.draw();
      if (toolbar != null) toolbar.draw();
   }
}
