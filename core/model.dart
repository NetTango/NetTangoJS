/*
 * NetTango
 * Northwestern University
 * michael-horn@northwestern.edu
 * Copyright 2013, Michael S. Horn and Uri Wilensky
 *
 * This project was funded in part by the National Science Foundation.
 * Any opinions, findings and conclusions or recommendations expressed in this
 * material are those of the author(s) and do not necessarily reflect the views
 * of the National Science Foundation (NSF).
 */
part of NetTango;


abstract class Model {
  
  // Human-readable name of the model
  String name = "model";
  
  // Internal id prefix that links this model to associated HTML identifiers
  //   Turtle Canvas:  #${id}-turtles
  //   Patches Canvas: #${id}-patches
  //   Toolbar:        #${id}-toolbar
  String id = "model";
   
  // Dimensions of the canvas
  int width = 500, height = 500;
  
  // A collection of turtles in the model
  List<Turtle> turtles;
   
  // List of dead turtles
  List<Turtle> deadTurtles;
   
  // A list of patches
  List<Patch> patches;
  
  // List of plots associated with this model
  List<Plot> plots;
  
  // Global variables and properties (defined for the model)
  Map<String, dynamic> properties;
  
  // tick count
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
  
  // Manages the animation events
  Timer timer;

  // Size of a patch in pixels
  // TODO: Maybe patch size should vary according to world size rather than vice versa
  int patchSize = 40;
   
  // Dimensions of the world in patch coordinates
  int maxPatchX = 12;
  int minPatchX = -12;
  int maxPatchY = 12;
  int minPatchY = -12;
  
  // Used to generate unique agent id numbers
  int AGENT_ID = 1;
   
  static Random rnd = new Random();
   
  // Drawing context for turtles
  CanvasRenderingContext2D tctx = null;
   
  // Drawing context for patches
  CanvasRenderingContext2D pctx = null;

  // Control toolbar
  Toolbar toolbar;
  
   
  Model(this.name, this.id) {
    
    turtles = new List<Turtle>();
    deadTurtles = new List<Turtle>();
    toolbar = new Toolbar(this);
    patches = new List<Patch>();
    plots = new List<Plot>();
    properties = new Map<String, dynamic>();
    
    CanvasElement canvas;
    
    // Turtle canvas
    canvas = document.query("#${id}-turtles");
    width = canvas.width;
    height = canvas.height;
    tctx = canvas.getContext("2d");
    
    // Patch canvas
    canvas = document.query("#${id}-patches");
    if (canvas != null) {
      pctx = canvas.getContext("2d");
    }
 
    resize(width, height);    
  }
  

/*
 * Set up the model for a new run
 */
  void setup();
  
  
/*
 * Restart the simulation
 */
  void restart() {
    pause();
    ticks = 0;
    setup();
    toolbar.update();
    draw();
    for (Plot plot in plots) {
      plot.clear();
      plot.update(0);
    }
  }


/*
 * Advance the model by one tick
 */
  void tick() {
    
    // update the tick count
    ticks++;
    toolbar.update();
     
    // remove dead turtles
    for (int i=turtles.length - 1; i >= 0; i--) {
      Turtle t = turtles[i];
      if (t.dead) {
        turtles.removeAt(i);
        deadTurtles.add(t);
      }
    }
      
    // animate turtles
    for (int i=0; i<turtles.length; i++) {
      turtles[i].tick();
    }
      
    // animate patches
    for (var patch in patches) {
      patch.tick();
    }
    
    // update plots
    if (ticks % 10 == 0) {
      for (Plot plot in plots) {
        plot.update(ticks);
      }
    }
  }
   
   
/*
 * Start the simulation
 */
  void play(num speedup) {
    play_state = speedup;
    toolbar.update();
    animate();
  }
   

/*
 * Pause the simulation
 */
  void pause() {
    play_state = 0;
    toolbar.update();
  }
  
  
/*
 * Is the model paused
 */
  bool get isPaused {
    return play_state == 0;
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
    tick();
    draw();
  }
   
   
/*
 * Toggle fullscreen mode
 */
  void fullscreen() {
    restart();
    resize(window.innerWidth, window.innerHeight);
    draw();
  }
   
   
  void partscreen() {
    restart();
    resize(500, 500);
    draw();
  }
   
   
/*
 * advance the model, animate, and repaint
 */
  void animate() {
    if (play_state != 0) {
      for (int i=0; i<play_state; i++) {
        tick();
      }
      draw();
      new Timer(const Duration(milliseconds : 30), animate);
    }
  }

  
   
  void initPatches() { 
    patches = new List(worldWidth * worldHeight);
    for (int j=0; j < worldHeight; j++) {
      for (int i=0; i < worldWidth; i++) {
        patches[j * worldWidth + i] = new Patch(this, i + minPatchX, j + minPatchY);
      }
    }
  }
  
  
  void addPlot(Plot plot) {
    plots.add(plot);
  }
   
   
  void addTurtle(Turtle t) {
    turtles.add(t);
  }
   
   
  void clearTurtles() {
    turtles.clear();
    deadTurtles.clear();
  }
   
   
  void clearPatches() {
    patches.clear();
  }
   
   
  Turtle oneOfTurtles() {
    return turtles[rnd.nextInt(turtles.length)];
  }
   
    
  void resize(int w, int h) {
    int hpatches = w ~/ patchSize;
    int vpatches = h ~/ patchSize;
    maxPatchX = hpatches ~/ 2;
    maxPatchY = vpatches ~/ 2;
    minPatchX = maxPatchX - hpatches + 1;
    minPatchY = maxPatchY - vpatches + 1;
    
    if (patches.length > 0) {
      clearPatches();
      initPatches();
    }
  }
   
   
  void draw() {
    if (pctx != null) drawPatches(pctx);
    drawTurtles(tctx);
  }
 
   
  void drawTurtles(var ctx) {
    ctx.clearRect(0, 0, width, height);
    num cx = (0.5 - minPatchX) * patchSize;
    num cy = (0.5 - minPatchY) * patchSize;
    ctx.save();
    ctx.translate(cx, cy);
    ctx.scale(patchSize, -patchSize);
    for (var turtle in turtles) {
      ctx.save();
      ctx.translate(turtle.x, turtle.y);
      ctx.rotate(turtle.heading);
      turtle.draw(ctx);
      ctx.restore();
    }
    ctx.restore();
  }
   
   
  void drawPatches(CanvasRenderingContext2D ctx) {
    if (patches == null) return;
    num cx = (0.5 - minPatchX) * patchSize;
    num cy = (0.5 - minPatchY) * patchSize;
    ctx.save();
    ctx.translate(cx, cy);
    ctx.scale(patchSize, -patchSize);
    for (Patch patch in patches) {
      patch.draw(ctx);
    }
    ctx.restore();
  }
   
   
  Patch patchAt(num tx, num ty) {
    int i = tx.round().toInt() - minPatchX;
    int j = ty.round().toInt() - minPatchY;
    int index = j * worldWidth + i;
    if (index < patches.length) {
      return patches[index];
    } else {
      return null;
    }
  }
   
   
  num screenToWorldX(num sx, num sy) {
    num cx = (0.5 - minPatchX) * patchSize;
    return (sx - cx) / patchSize;
  }
   
   
  num screenToWorldY(num sx, num sy) {
    num cy = (0.5 - minPatchY) * patchSize;
    return (cy - sy) / patchSize;      
  }
  
  
  num worldToScreenX(num wx, num wy) {
    num cx = (0.5 - minPatchX) * patchSize;
    return wx * patchSize + cx;
  }
  
  
  num worldToScreenY(num wx, num wy) {
    num cy = (0.5 - minPatchY) * patchSize;
    return wy * patchSize * -1 + cy;
  }
   
   
  int nextAgentId() => AGENT_ID++;
   
  num get minWorldY => minPatchY - 0.5;
  num get minWorldX => minPatchX - 0.5;
  num get maxWorldY => maxPatchY + 0.5;
  num get maxWorldX => maxPatchX + 0.5;
  int get worldWidth => maxPatchX - minPatchX + 1;
  int get worldHeight => maxPatchY - minPatchY + 1;
}

