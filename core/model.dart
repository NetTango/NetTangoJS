/*
 * NetTango
 * Northwestern University
 *
 * This project was funded in part by the National Science Foundation.
 * Any opinions, findings and conclusions or recommendations expressed in this
 * material are those of the author(s) and do not necessarily reflect the views
 * of the National Science Foundation (NSF).
 */
part of NetTango;


abstract class Model {
  
  /* Human-readable name of the model */
  String name = "model";

  /*  
   * Internal id prefix that links this model to associated HTML identifiers
   *   Turtle Canvas:  #${id}-turtles
   *   Patches Canvas: #${id}-patches
   *   Toolbar:        #${id}-toolbar
   */
  String id = "model";
   
  /* Dimensions of the canvas for the world view */
  int width = 500, height = 500;
  
  /* A collection of turtles in the model */
  List<Turtle> turtles = new List<Turtle>();
   
  /* List of dead turtles */
  List<Turtle> deadTurtles = new List<Turtle>();
   
  /* A list of patches */
  List<Patch> patches = new List<Patch>();
  
  /* List of plots associated with this model */
  List<Plot> plots = new List<Plot>();
  
  /* Global variables and properties (defined for the model) */
  Map<String, dynamic> properties = new Map<String, dynamic>();
  
  /* Current tick count */
  int ticks = 0;
  
  /*
   * Play state
   *   -2 : play backward 2x
   *   -1 : play backward normal speed
   *   0  : paused
   *   1  : play forward normal speed
   *   2  : play forward 2x
   *   4  : play forward 4x ....
   */
  int play_state = 0; 
  
  /* Manages the animation events */
  Timer timer;

  /* Size of a patch in pixels */
  // TODO: Maybe patch size should vary according to world size rather than vice versa
  int patchSize = 40;
   
  /* Dimensions of the world in patch coordinates */
  int maxPatchX = 12;
  int minPatchX = -12;
  int maxPatchY = 12;
  int minPatchY = -12;
  
  /* Used to generate unique agent id numbers */
  int AGENT_ID = 1;
   
  /* Random number generator */
  static Random rnd = new Random();
  
  /* Turtle canvas needed for touch event processing */
  CanvasElement canvas;
   
  /* Drawing context for turtles */
  CanvasRenderingContext2D tctx = null;
   
  /* Drawing context for patches */
  CanvasRenderingContext2D pctx = null;

  /* Control toolbar */
  Toolbar toolbar;
  
  /* Is the mouse or finger down? */
  bool down = false;
  
   
  Model(this.name, this.id) {
    
    // Turtle canvas
    canvas = document.query("#${id}-turtles");
    width = canvas.width;
    height = canvas.height;
    tctx = canvas.getContext("2d");
    
    // Register mouse events
    canvas.onMouseDown.listen((e) => _mouseDown(e));
    canvas.onMouseUp.listen((e) => _mouseUp(e));
    canvas.onMouseMove.listen((e) => _mouseMove(e));

    // Register touch events
    canvas.onTouchStart.listen((e) => _touchDown(e));
    canvas.onTouchMove.listen((e) => _touchDrag(e));
    canvas.onTouchEnd.listen((e) => _touchUp(e));    
    
    // Patch canvas
    CanvasElement pcanvas = document.query("#${id}-patches");
    if (pcanvas != null) pctx = pcanvas.getContext("2d");
 
    // Toolbar
    toolbar = new Toolbar(this);
    
    resize(width, height);    
  }
  

/*
 * Set up the model for a new run (abstract)
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
    ticks++;  // update the tick count
    toolbar.update();
     
    // remove dead turtles
    for (int i=turtles.length - 1; i >= 0; i--) {
      Turtle t = turtles[i];
      if (t.dead) {
        turtles.removeAt(i);
        deadTurtles.add(t);
      }
    }
    
    _tickTurtles();
    _tickPatches();
    _updatePlots();
  }
  

/*
 * Animate the turtles
 */
  void _tickTurtles() {
    for (int i=0; i<turtles.length; i++) {
      turtles[i].tick();
    }
  }
  
  
/*
 * Animate the patches
 */
  void _tickPatches() {
    for (var patch in patches) {
      patch.tick();
    }    
  }
  

/*
 * Update the plots
 */
  void _updatePlots() {
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
    _animate();
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
  void _animate() {
    if (play_state != 0) {
      for (int i=0; i<play_state; i++) {
        tick();
      }
      draw();
      new Timer(const Duration(milliseconds : 30), _animate);
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
    patches = new List(worldWidth * worldHeight);    
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
    if (pctx != null) _drawPatches(pctx);
    _drawTurtles(tctx);
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
  
  
  void _drawTurtles(var ctx) {
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
   
   
  void _drawPatches(CanvasRenderingContext2D ctx) {
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
  
  
  /**
   * Subclasses can override these methods to do touch processing
   */
  void doTouchDown(Contact c) {
    // Here are some examples
    // num tx = screenToWorldX(c.touchX, c.touchY);
    // num ty = screenToWorldY(c.touchX, c.touchY);
    // Patch p = patchAt(tx, ty);
    
    // ...
    // List<Turtle> turtles = new List<Turtle>();
    // for (Turtle t in turtles) {
    //   if (t.containsTouch(c)) {
    //     turtles.add(t);
    // }
  }
  
  void doTouchUp(Contact c) { }
  
  void doTouchDrag(Contact c) { }
  
  
  void _mouseUp(MouseEvent evt) {
    down = false;
    doTouchUp(new Contact.fromMouse(evt));
  }
  
  
  void _mouseDown(MouseEvent evt) {
    down = true;
    doTouchDown(new Contact.fromMouse(evt));
  }
   
  
  void _mouseMove(MouseEvent evt) {
    if (down) doTouchDrag(new Contact.fromMouse(evt));
  }
  
  
  void _touchDown(TouchEvent tframe) {
    for (Touch touch in tframe.changedTouches) {
      doTouchDown(new Contact.fromTouch(touch, canvas));
    }
  }
  
  
  void _touchUp(TouchEvent tframe) {
    for (Touch touch in tframe.changedTouches) {
      doTouchUp(new Contact.fromTouch(touch, canvas));
    }
  }
  
  
  void _touchDrag(TouchEvent tframe) {
    for (Touch touch in tframe.changedTouches) {
      doTouchDrag(new Contact.fromTouch(touch, canvas));
    }
  }  
}

