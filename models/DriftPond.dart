import 'dart:html';
import 'dart:math';
import 'dart:json';
import '../core/ntango.dart';


num gameLength = 700;  //1000

Element _draggin = null;
Point latestDelta = new Point(0,0);
Point dragPointOffset = new Point(0,0);
String draggingLeaf = "";

CanvasElement canvas = document.query("#drift-pond-pads");
String turtleBehaviors = "";

var redscore = document.query("#red");
var yellowscore = document.query("#yellow");
var bluescore = document.query("#blue");
var greenscore = document.query("#green");
var skyscore = document.query("#sky");
var totalscore = document.query("#total");
var timescore = document.query("#time");


var leafImage = document.query("#leafimage");
bool paused = false;
var pauseResumeButton = document.query("#presume");
var BackInStackPoint = new Point(660,600);
int leafIndex = 0;
Map<String,Point> locationOfLeaf = new Map<String,Point>();
num zerox, zeroy;

DriftModel model;
var turtleColors;

bool colorsAreEqual( Color left, Color right ) {
  if (left.red == right.red) {
    if (left.green == right.green ) {
      if (left.blue == right.blue) {
        return true;
      }
    }
  }
  return false;
}
bool redTest(Turtle t) { return colorsAreEqual(t.color, turtleColors[0]); }
bool greenTest(Turtle t) { return colorsAreEqual(t.color, turtleColors[1]); }
bool blueTest(Turtle t) { return colorsAreEqual(t.color, turtleColors[2]); }
bool yellowTest(Turtle t) { return colorsAreEqual(t.color, turtleColors[3]); }
bool cyanTest(Turtle t) { return colorsAreEqual(t.color, turtleColors[4]); }

void main() {
  locationOfLeaf["-1"] = new Point(250,250);
  var leafstack = document.query("#leafstack");
  
  //uncomment these 2 lines and re-comment subsequent ones for default behavior
  /*
  leafstack.onMouseDown.listen( dragStart );
  leafstack.onTouchStart.listen( touchStart );
  */
  
  leafstack.style.visibility = "hidden";
  document.query("#leafmoving").style.visibility = "hidden";
  document.query("#leafimage").style.visibility = "hidden";
  locationOfLeaf["0"] = new Point(50,350);
  locationOfLeaf["1"] = new Point(350,50);
  locationOfLeaf["2"] = new Point(380,350);
  //end code to toggle
  
  locationOfLeaf["3"] = new Point(80, 50);
  locationOfLeaf["4"] = new Point(450,150);
  locationOfLeaf["5"] = new Point(150,400);
  
  pauseResumeButton.onTouchEnd.listen( pauseOrResumeTouch );
  pauseResumeButton.onMouseUp.listen( pauseOrResumeMouse );
  
  var topCanv = document.query("#drift-pond-turtles");
  topCanv.onMouseDown.listen( startAdjustingLeaf );
  topCanv.onTouchStart.listen( startTouchAdjustingLeaf );
  
  window.onMouseUp.listen( dragStop );
  window.onMouseMove.listen(maybeMove); 
  
  window.onTouchEnd.listen( touchStop );
  window.onTouchMove.listen(maybeTouchMove); 
  
  model = new DriftModel("Drift Pond");
  
  zerox = model.screenToWorldX(0, 0);
  zeroy = model.screenToWorldY(0, 0);
  
  model.restart();
  model.requestRedraw();
  model.updateScores();
 // showIntro();
}


void pauseOrResumeTouch(TouchEvent event) {
  pauseOrResume();
}

void pauseOrResumeMouse(MouseEvent event) {
  pauseOrResume();
}

void pauseOrResume() {
  if (paused) {
    model.play();
    pauseResumeButton.value="pause";
    pauseResumeButton.style.backgroundColor="#CCCC78";
  }
  else {
    model.pause();
    pauseResumeButton.value="resume";
    pauseResumeButton.style.backgroundColor="#54BB78";
  }
  paused = !paused;
}

void showIntro() {
  document.query("#drift-pond-toolbar").style.visibility = "hidden";
  pauseResumeButton.style.visibility="hidden";
  bindClickEvent("intro", (event) {
    if (getHtmlOpacity("intro") > 0) {
      setHtmlOpacity("intro", 0.0);
      document.query("#intro").style.visibility = "hidden";
      model.play();
      pauseResumeButton.style.visibility="visible";
    }
  });
  document.query("#intro").style.visibility = "visible";
  setHtmlOpacity("intro", 1.0);
}


//touch-move an already-placed leaf
void startTouchAdjustingLeaf( TouchEvent event ) {
  if (event.changedTouches.length > 0 ) {
    Touch t = event.changedTouches[0];
    Point testPoint = new Point(t.client.x - 110, t.client.y - 100);
    String wLeaf = findClosestCenterTo(testPoint);
    num dist = testPoint.distanceTo(locationOfLeaf[wLeaf]);
    if ( dist < 50 ) {
      draggingLeaf = wLeaf;
      findDragPointOffset( testPoint );
    }
  }
}
//move an already-placed leaf
void startAdjustingLeaf( MouseEvent evt ) {
  Point testPoint = new Point(evt.clientX - 110, evt.clientY - 100);
  String wLeaf = findClosestCenterTo(testPoint);
  num dist = testPoint.distanceTo(locationOfLeaf[wLeaf]);
  if ( dist < 50 ) {
    draggingLeaf = wLeaf;
    findDragPointOffset( testPoint );
  }
}

String findClosestCenterTo(Point testPoint) {
  String ind = "-1";
  num minDist = testPoint.distanceTo(locationOfLeaf[ind]);
  for (var v in locationOfLeaf.keys) {
      num d = testPoint.distanceTo(locationOfLeaf[v]);
      if ( d < minDist ) {
        ind = v;
        minDist = d;
      }
  }
  return ind;
}

//dragHandlerForAllMouseInteractions
void maybeMove( MouseEvent event ) {
  if (_draggin != null) {
    updateDraggin( event.clientX, event.clientY );
  } else if ( draggingLeaf.length > 0 ) {
    repositionLeaf( event.clientX - 110, event.clientY - 100 );
  }
}

//dragHandlerForAllTouchInteractions
void maybeTouchMove( TouchEvent event ) {
  if (event.changedTouches.length > 0 ) {
    Touch t = event.changedTouches[0];
    if (_draggin != null) {
      updateDraggin( t.client.x, t.client.y );
    } else if ( draggingLeaf.length > 0 ) {
      repositionLeaf( t.client.x - 110, t.client.y - 100 );
    }
  }
}

void findDragPointOffset(Point clickPoint) {
  dragPointOffset = locationOfLeaf[draggingLeaf] - clickPoint;
}


//actually move the adjusted leaf
void repositionLeaf( nx, ny ) {
  Point oldLoc = locationOfLeaf[draggingLeaf];
  locationOfLeaf[draggingLeaf] = new Point(nx, ny) + dragPointOffset;
  latestDelta = locationOfLeaf[draggingLeaf] - oldLoc; 
  
 
  latestDelta = new Point (model.screenToWorldX(latestDelta.x, latestDelta.y) - zerox, model.screenToWorldY(latestDelta.x, latestDelta.y) - zeroy);
  
  model.requestRedraw();
}

//actually move the not-yet placed leaf div-icon
void updateDraggin(x, y) {
  _draggin.style.left = (x - 60).toString() + "px";
  _draggin.style.top = (y - 50).toString() + "px";
}


//set the dragging state information as appropriate.
void dragStart(MouseEvent event) {
  _draggin = document.query("#leafmoving"); 
  _draggin.style.zIndex="7";
  leafIndex++;
  locationOfLeaf[(leafIndex.toString()) ] = BackInStackPoint;
}

//set the dragging state information as appropriate.
void touchStart(TouchEvent event) {
  if (event.changedTouches.length > 0 ) {
    Touch t = event.changedTouches[0];
    _draggin = document.query("#leafmoving"); 
    _draggin.style.zIndex="7";
    leafIndex++;
    locationOfLeaf[(leafIndex.toString()) ] = BackInStackPoint;
  }
}

//reset state back to not-dragging (general mouse-up handler)
void dragStop(MouseEvent event) {
  if (_draggin != null) {
    locationOfLeaf[(leafIndex.toString()) ] = new Point(event.clientX - 110, event.clientY - 100);
    _draggin.style.left = BackInStackPoint.x.toString() + "px";
    _draggin.style.top = BackInStackPoint.y.toString() + "px";
    _draggin.style.zIndex="5";
    _draggin = null;
    model.requestRedraw();
  } else if (draggingLeaf.length > 0 ) {
    draggingLeaf = "";
    latestDelta = new Point(0,0);
    model.requestRedraw();
  }
}

//reset state back to not-dragging (general mouse-up handler)
void touchStop(TouchEvent event) {
  if (event.changedTouches.length > 0 ) {
    Touch t = event.changedTouches[0];
    if (_draggin != null) {
      locationOfLeaf[(leafIndex.toString()) ] = new Point(t.client.x - 110, t.client.y - 100);
      _draggin.style.left = BackInStackPoint.x.toString() + "px";
      _draggin.style.top = BackInStackPoint.y.toString() + "px";
      _draggin.style.zIndex="5";
      _draggin = null;
      model.requestRedraw();
    } else if (draggingLeaf.length > 0 ) {
      draggingLeaf = "";
      latestDelta = new Point(0,0);
      model.requestRedraw();
    }
  }
}

//the actual model class implementation
class DriftModel extends Model { 

  final int TURTLE_COUNT = 60;
  Plot plot;
   
  DriftModel(String name) : super(name, 'drift-pond') {
    plot = new Plot("drift-pond-plot");
    plot.title = "Number of Bugs of Each Color";
    plot.labelX = "time";

    Pen redPen = new Pen("bugs", "red");
    redPen.updater = (int ticks) { return turtles.where(redTest).length; };
    plot.addPen(redPen);
    
    Pen greenPen = new Pen("bugs", "green");
    greenPen.updater = (int ticks) { return turtles.where(greenTest).length; };
    plot.addPen(greenPen);
    
    Pen bluePen = new Pen("bugs", "blue");
    bluePen.updater = (int ticks) { return turtles.where(blueTest).length; };
    plot.addPen(bluePen);
    
    Pen yellowPen = new Pen("bugs", "orange");
    yellowPen.updater = (int ticks) { return turtles.where(yellowTest).length; };
    plot.addPen(yellowPen);
    
    Pen cyanPen = new Pen("bugs", "cyan");
    cyanPen.updater = (int ticks) { return turtles.where(cyanTest).length; };
    plot.addPen(cyanPen);

    plot.minY = 0;
    plot.maxY = 30;
    plot.minX = 0;
    plot.maxX = 50;
    addPlot(plot);
  }
  
  void tick() {
    super.tick();
    updateScores(); 
    checkForEndGame();
  }
  
  void updateScores() {
    redscore.text = turtles.where(redTest).length.toString();
    yellowscore.text = turtles.where(yellowTest).length.toString();
    greenscore.text = turtles.where(greenTest).length.toString();
    bluescore.text = turtles.where(blueTest).length.toString();
    skyscore.text = turtles.where(cyanTest).length.toString();
    timescore.text = (gameLength - ticks).toString();
    totalscore.text = turtles.length.toString();
  }
  
  void checkForEndGame() {
    if (ticks >= gameLength) {
      pauseResumeButton.style.visibility = "hidden";
      int species = 0;
      num reds = turtles.where(redTest).length;
      num yellows = turtles.where(yellowTest).length;
      num greens = turtles.where(greenTest).length;
      num blues = turtles.where(blueTest).length;
      num skys = turtles.where(cyanTest).length;
      
      if (reds > 0) { species++; }
      if (yellows > 0) { species++; }
      if (greens > 0) { species++; }
      if (blues > 0) { species++; }
      if (skys > 0) { species++; }
      String all = "";
      if (species == 5 ) { all = "ALL "; }
      String fullLengthMessage = "<div id='title'>GAME OVER!</div><br><br>At the end of the game,<br>you have protected:<br><br>"+redscore.text + " red bugs<br>"+yellowscore.text + " orange bugs<br>"+greenscore.text + " green bugs<br>"+bluescore.text + " blue bugs<br>and<br>"+skyscore.text + " sky bugs.<br><br><b>So, you saved "+all+"${species} species<br>and<br>" + totalscore.text + " bugs in all.</b>";
      pause();
      bindClickEvent("status", (event) {
        if (getHtmlOpacity("status") > 0) {
          setHtmlOpacity("status", 0.0);
          document.query("#drift-pond-toolbar").style.visibility = "hidden";
          setupRestartButton();
        }
      });
      document.query("#status").style.visibility = "visible";
      showStatusMessage(fullLengthMessage);
    } else if ( turtles.length == 0  ) {
      String allDiedMessage = "<div id='title'><p><p><p>GAME OVER!</div><br><br><p><p>Sadly,<br>all of your bugs died!";
      pause();
      bindClickEvent("status", (event) {
        if (getHtmlOpacity("status") > 0) {
          setHtmlOpacity("status", 0.0);
          document.query("#drift-pond-toolbar").style.visibility = "hidden";
          setupRestartButton();
        }
      });
      document.query("#status").style.visibility = "visible";
      showStatusMessage(allDiedMessage);
    }
  }
   
  void setupRestartButton() {
    InputElement restrt = document.query("#restart_button");
    restrt.style.visibility = "visible";
    bindClickEvent("restart_button", (event) {
      window.location.reload();
    });
  }
 
  //these three methods relate to maintaining fresh drawing of the leaf layer
  //i have left them within the model class b/c turtles are interacting with it. 
  //but its state is only changed by the mouse events.
  
  //this will draw leaf layer (which is actually above the patch canvas).
  void drawPatchesOnce(CanvasRenderingContext2D context) {
    context.clearRect(0, 0, 600, 600);
    context.globalAlpha = 0.0;
    context.fillStyle="#000000";
    context.fillRect(0,0,600,600);
    
    for (var v in locationOfLeaf.keys) {
      var destX = locationOfLeaf[v].x;
      var destY = locationOfLeaf[v].y;
      var destWidth = 121;
      var destHeight = 100;
      var source = leafImage;
      context.globalAlpha = 0.0;
      
      //make these two concentric (and fully transparent) regions 
      //around the leaves to improve the bugs' ability
      //to stay on the leaves -- not really working at the moment
      context.fillStyle="#000022";
      context.fillRect(destX - 4,destY - 4,destWidth + 8,destHeight + 8);
      
      context.fillStyle="#000122";
      context.fillRect(destX - 2,destY - 2,destWidth + 4,destHeight + 4);
      
      //draw the leaf now.
      context.globalAlpha = 1;
      context.drawImage(source, destX, destY);//, destWidth, destHeight);
    }
    
  }
  
  void paintOnce(num _) {
    drawPatchesOnce(canvas.context2D);
  }
  
  void requestRedraw() {
    window.requestAnimationFrame(paintOnce);
  }
  
  
  //setup the model. 
  void setup() {
    showIntro();
    
    clearTurtles();
    clearPatches();
    initPatches();
      
    turtleColors = [
                new Color(255, 0, 0, 255),
                new Color(0, 234, 30, 255),
                new Color(0, 0, 255, 255),
                new Color(255, 153, 0, 255),
                new Color(0, 255, 255, 255)];
    
    //initialized here but given top-level scope.    
    turtleBehaviors = """
    [
      ["forward", 0.1],
      ["right", ["random", 20] ],
      ["left", ["random", 20] ],
      ["set", "energy", ["-", "energy", 0.2] ],
      ["if", [ "<=", "energy", 43], [ "die"] ],
      ["ask", ["patch-here"], [
          [ "if", [ ">", "plant-energy", 0 ], [
              [ "set", "plant-energy", [ "-", "plant-energy", 7 ] ],
              [ "set", "energy", [ "+", "energy", 4] ]
          ] ]
      ] ],
      ["if", [ ">", "energy", 90], [
          ["if", [ ">", ["random", 100], 94 ], [
              ["set", "energy", 50 ],
              [ "hatch" ]
          ] ]
      ] ]
    ]
    """;
    Expression behavior = new Expression(parse(turtleBehaviors));
    
    
    for (int i=0; i<TURTLE_COUNT / 3; i++) {  
      PondTurtle t = new PondTurtle(this);
      t["energy"] = 85;
      t.color = turtleColors[i % 5].clone();
      t.setBehavior(behavior);
      addTurtle(t);
    }
    
    for (int i=0; i<TURTLE_COUNT / 3; i++) {  
      PondTurtle t = new PondTurtle(this);
      t["energy"] = 85;
      t.color = turtleColors[i % 5].clone();
      t.setBehavior(behavior);
      t.x = this.screenToWorldX(400,100);
      t.y = this.screenToWorldY(400,100);
      
      addTurtle(t);
    }
    
    String patchBehaviors = """
    [
      [ "set", "plant-energy", [ "+", "plant-energy", 2 ] ],
      [ "if", [">", "plant-energy", 100 ], [
          [ "set", "plant-energy", 100 ]
      ] ]
    ]
    """;
    
    //remove patch coloration for plant energy indication.
    //[ "set", "color-blue", "plant-energy" ]  
    behavior = new Expression(parse(patchBehaviors));
    
    for (Patch patch in patches) {
      patch.color.setColor(0, 0, 100, 128);
      patch.setBehavior(behavior);
      patch["plant-energy"] = 100;
    }
  }
}





//PondTurtle class.  I had some trouble getting this implementation to be able to access the
//private variables of Turtle.  I think this is because of the "library private" nature of 
//those variables.  Perhaps they should be declared with different access?
class PondTurtle extends Turtle {
  
  static Random rnd = new Random();
  
  PondTurtle(Model model) :super(model) {
    
  }
  
  //overriding TICK because i need to work with conditions that are not "netlogo-native"
  void tick() {
    super.tick();
   
    var xc = model.worldToScreenX(x, y);
    var yc = model.worldToScreenY(x, y);
    
    /*
    
    if (draggingLeaf.length > 0 && latestDelta.x != 0 && latestDelta.y != 0) {
      Point whereIAM = new Point(xc,yc);
      if ( findClosestCenterTo(whereIAM) == draggingLeaf)
      {        
       // x = model.screenToWorldX(locationOfLeaf[draggingLeaf].x, locationOfLeaf[draggingLeaf].y) + 110;
      //  y = model.screenToWorldY(locationOfLeaf[draggingLeaf].x, locationOfLeaf[draggingLeaf].y) + 100;
        //x += latestDelta.x;
        //y += latestDelta.y;
      }
    }
    */
   
    
    //if (this["energy"] < 45){ print("would die at 45: " + this["energy"].toString()); }
    var imdat = canvas.context2D.getImageData(xc, yc, 1, 1).data;
    if (imdat.indexOf(0) > -1) {
      forward(-0.05);
      xc = model.worldToScreenX(x, y);
      yc = model.worldToScreenY(x, y);
      imdat = canvas.context2D.getImageData(xc, yc, 1, 1).data;
      if ( imdat[0] == 0 && imdat[1] == 0 && imdat[3] == 0  ) { 
         die(); 
       }
      else {
        right(175 + rnd.nextInt(10));
      }
    } 
  }
  
  void draw(var ctx) {
    drawLegs(ctx, 0, 0, 0.1);
    //roundRect(ctx, -0.1, -0.1, 0.2, 0.2, 0.1);
    ctx.beginPath();
    ctx.arc(0, 0, 0.1, 0, PI * 2, true);
    ctx.fillStyle = color.toString();
    ctx.fill();
    ctx.strokeStyle = "rgba(10, 10, 10, 0.5)";
    ctx.lineWidth = 0.05;
    ctx.stroke();
  }
  
  void drawLegs(CanvasRenderingContext2D ctx, num x, num y, num r) {
    double d = rnd.nextDouble() * 1.5 * r;
    ctx.beginPath();
    ctx.moveTo(x+2*r,y+d);
    ctx.lineTo(x-2*r,y-d);
    ctx.moveTo(x+2*r,y);
    ctx.lineTo(x-2*r,y);
    ctx.moveTo(x+2*r,y-d);
    ctx.lineTo(x-2*r,y+d);
    ctx.lineWidth = 0.02;
    ctx.strokeStyle = "rgba(10, 10, 10, 1)";
    ctx.stroke();
  }
  
  PondTurtle clone() {
    PondTurtle t = new PondTurtle(model);
    t.x = x;
    t.y = y;
    t.size = size;
    t.heading = heading;
    t.color = color.clone();
    t["energy"] = 100;
    
    Expression behavior = new Expression(parse(turtleBehaviors));
    
    t.setBehavior(behavior);
    return t;
  }
}

