import 'dart:html';
import 'dart:math';
import '../packages/json/json.dart' as json;
import '../core/ntango.dart';


num gameLength = 500;  //1000
bool onComputer = true;
bool goForever = false;

num suicides = 0;

//defaults for the standard leaf
num xDragOffset = 60;
num yDragOffset = 50;
num scrOffset = 10;

Element _draggin = null;
Point latestDelta = new Point(0,0);
Point dragPointOffset = new Point(0,0);
String draggingLeaf = "";
Map<int,String>touchDraggingLeaves = new Map<int, String>();
Map<int, Point>touchPointOffsets = new Map<int, Point>();
Map<String, Point>latestTouchDelta = new Map<String, Point>();


CanvasElement canvas = document.querySelector("#drift-pond-pads");
String turtleBehaviors = "";

var redscore = document.querySelector("#red");
var yellowscore = document.querySelector("#yellow");
var bluescore = document.querySelector("#blue");
var greenscore = document.querySelector("#green");
var skyscore = document.querySelector("#sky");
var totalscore = document.querySelector("#total");
var timescore = document.querySelector("#time");


var leafImage = document.querySelector("#leafimage");
bool paused = false;
var pauseResumeButton = document.querySelector("#presume");
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
  window.onContextMenu.listen((event){event.preventDefault();});
  
  locationOfLeaf["-1"] = new Point(250 + xDragOffset,250+yDragOffset);
  var leafstack = document.querySelector("#leafstack");
  
  //uncomment these 2 lines and re-comment subsequent ones for default behavior
  /*
  leafstack.onMouseDown.listen( dragStart );
  leafstack.onTouchStart.listen( touchStart );
  */
  
  window.onKeyDown.listen( changeChallenge );
  
  leafstack.style.visibility = "hidden";
  document.querySelector("#leafmoving").style.visibility = "hidden";
  document.querySelector("#leafimage").style.visibility = "hidden";
  locationOfLeaf["0"] = new Point(50+xDragOffset,350+yDragOffset);
  locationOfLeaf["1"] = new Point(350+xDragOffset,50+yDragOffset);
  locationOfLeaf["2"] = new Point(380+xDragOffset,350+yDragOffset);
  
  locationOfLeaf["3"] = new Point(80+xDragOffset, 50+yDragOffset);
  locationOfLeaf["4"] = new Point(450+xDragOffset,150+yDragOffset);
  locationOfLeaf["5"] = new Point(150+xDragOffset,400+yDragOffset);
  
  //end code to toggle

  
  pauseResumeButton.onTouchEnd.listen( pauseOrResumeTouch );
  pauseResumeButton.onMouseUp.listen( pauseOrResumeMouse );
  
  var topCanv = document.querySelector("#drift-pond-turtles");
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

void changeChallenge(KeyboardEvent event) {
  int theKey = event.keyCode;
  if (theKey == 90) {
    gameLength += 500;
    model.updateScores();
  }
  if (theKey >= 49 && theKey <= 51) {
    int num = theKey - 48;
    document.querySelector("#bodytext").innerHtml = "<p><b>Game 2</b><p><u>Your Goal</u>:  Preserve <br><b>exactly ${num}</b> species.";
  }
  if (theKey == 52) {
    document.querySelector("#bodytext").innerHtml = "<p><b>Game 3</b><p><u>Your Goal</u>:  Create <b>2</b> populated islands,<br>each with <b>exactly two</b> species.";
  }

  if (theKey == 53) {
    document.querySelector("#bodytext").innerHtml = "<p><b>Game 4</b><p><u>Your Goal</u>:  Create <b>5</b> populated islands,<br>each with <b>only one</b> species.";
  }
  //
}


void pauseOrResumeTouch(TouchEvent event) {
  pauseOrResume();
}

void pauseOrResumeMouse(MouseEvent event) {
  if (onComputer){
    pauseOrResume(); 
  }
}

void pauseOrResume() {
  if (paused) {
    model.play();
    pauseResumeButton.value="Freeze Bugs";
    pauseResumeButton.style.backgroundColor="#CCCC78";
  }
  else {
    model.pause();
    pauseResumeButton.value="Unfreeze Bugs";
    pauseResumeButton.style.backgroundColor="#54BB78";
  }
  paused = !paused;
}

void showIntro() {
  document.querySelector("#drift-pond-toolbar").style.visibility = "hidden";
  pauseResumeButton.style.visibility="hidden";
  bindClickEvent("intro", (event) {
    if (getHtmlOpacity("intro") > 0) {
      setHtmlOpacity("intro", 0.0);
      document.querySelector("#intro").style.visibility = "hidden";
      model.play();
      pauseResumeButton.style.visibility="visible";
    }
  });
  document.querySelector("#intro").style.visibility = "visible";
  setHtmlOpacity("intro", 1.0);
}



//touch-move an already-placed leaf
void startTouchAdjustingLeaf( TouchEvent event ) {
  
  for ( Touch t  in event.changedTouches ) {
    Point testPoint = new Point(t.client.x - scrOffset, t.client.y - scrOffset);
    String wLeaf = findClosestCenterTo(testPoint);
    num dist = testPoint.distanceTo(locationOfLeaf[wLeaf]);
    if ( dist < 50 ) {
      touchDraggingLeaves[t.identifier] = wLeaf;
      findTouchPointOffset( t.identifier, wLeaf,  new Point(testPoint.x + scrOffset, testPoint.y + scrOffset)  );
    }
  }  
}


//mouse-move an already-placed leaf
void startAdjustingLeaf( MouseEvent evt ) {
  Point testPoint = new Point(evt.client.x - scrOffset, evt.client.y - scrOffset);
  String wLeaf = findClosestCenterTo(testPoint);
  num dist = testPoint.distanceTo(locationOfLeaf[wLeaf]);
  if ( dist < 50 ) {
    draggingLeaf = wLeaf;
    findDragPointOffset( new Point(testPoint.x + scrOffset, testPoint.y + scrOffset) );
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
    updateDraggin( event.client.x, event.client.y );
  } else if ( draggingLeaf.length > 0 ) {
    repositionLeaf( event.client.x, event.client.y  );
  }
}

//dragHandlerForAllTouchInteractions
void maybeTouchMove( TouchEvent event ) {
  for (Touch t in event.changedTouches ) {
    if (_draggin != null) {
      updateDraggin( t.client.x, t.client.y );
    } else if ( touchDraggingLeaves[t.identifier] != null ) {
      repositionTouchLeaf(t.identifier, touchDraggingLeaves[t.identifier], t.client.x , t.client.y  );
    }
  }
}

void findDragPointOffset(Point clickPoint) {
  dragPointOffset = locationOfLeaf[draggingLeaf] - clickPoint;
}

void findTouchPointOffset(int identifier, String theLeaf, Point clickPoint) {
  touchPointOffsets[identifier] = locationOfLeaf[theLeaf] - clickPoint;
}

void repositionTouchLeaf( int id, String theLeaf, num nx, num ny) {
  Point oldLoc = locationOfLeaf[theLeaf];
  locationOfLeaf[theLeaf] = new Point(nx, ny) + touchPointOffsets[id];
  Point temp = locationOfLeaf[theLeaf] - oldLoc; 
  latestTouchDelta[theLeaf] = new Point (model.screenToWorldX(temp.x, temp.y) - zerox, model.screenToWorldY(temp.x, temp.y) - zeroy);
  
  model.requestRedraw();
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
  _draggin.style.left = (x - xDragOffset).toString() + "px";
  _draggin.style.top = (y - yDragOffset).toString() + "px";
}


//THESE TWO NOT USED in version WHEN LEAVES ARE ALREADY PLACED
/*
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
*/

//reset state back to not-dragging (general mouse-up handler)
void dragStop(MouseEvent event) {
  if (_draggin != null) {
    locationOfLeaf[(leafIndex.toString()) ] = new Point(event.client.x , event.client.y );
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
      locationOfLeaf[(leafIndex.toString()) ] = new Point(t.client.x , t.client.y );
      _draggin.style.left = BackInStackPoint.x.toString() + "px";
      _draggin.style.top = BackInStackPoint.y.toString() + "px";
      _draggin.style.zIndex="5";
      _draggin = null;
      model.requestRedraw();
    } else if (touchDraggingLeaves[t.identifier] != null ) {
      String theLeaf = touchDraggingLeaves[t.identifier];
      latestTouchDelta.remove(theLeaf);
      touchDraggingLeaves.remove(t.identifier);
      touchPointOffsets.remove(t.identifier);
      model.requestRedraw();
    }
  }
}

//the actual model class implementation
class DriftModel extends Model { 

  final int TURTLE_COUNT = 20;
  Plot plot;
   
  DriftModel(String name) : super(name, 'drift-pond') {
    
     patchSize = 60;
    
   // Dimensions of the world in patch coordinates 
     maxPatchX = 50;
     minPatchX = -50;
     maxPatchY = 50;
     minPatchY = -50;
    
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
    plot.maxY = 25;
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
    int r, y, g, b, s;
    r = turtles.where(redTest).length;
    y = turtles.where(yellowTest).length;
    g = turtles.where(greenTest).length;
    b = turtles.where(blueTest).length;
    s = turtles.where(cyanTest).length;
        
    redscore.text = r.toString();
    if (r == 0){ redscore.style.backgroundColor="#94A3B8"; }
    
    yellowscore.text = y.toString();
    if (y == 0){ yellowscore.style.backgroundColor="#94A3B8"; }
    
    greenscore.text = g.toString();
    if (g == 0){ greenscore.style.backgroundColor="#94A3B8"; }
    
    bluescore.text = b.toString();
    if (b == 0){ bluescore.style.backgroundColor="#94A3B8"; }
    
    skyscore.text = s.toString();
    if (s == 0){ skyscore.style.backgroundColor="#94A3B8"; }
    
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
          document.querySelector("#drift-pond-toolbar").style.visibility = "hidden";
          setupRestartButton();
        }
      });
      document.querySelector("#status").style.visibility = "visible";
      showStatusMessage(fullLengthMessage);
    } else if ( turtles.length == 0  ) {
      String allDiedMessage = "<div id='title'><p><p><p>GAME OVER!</div><br><br><p><p>Sadly,<br>all of your bugs died!";
      pause();
      bindClickEvent("status", (event) {
        if (getHtmlOpacity("status") > 0) {
          setHtmlOpacity("status", 0.0);
          document.querySelector("#drift-pond-toolbar").style.visibility = "hidden";
          setupRestartButton();
        }
      });
      document.querySelector("#status").style.visibility = "visible";
      showStatusMessage(allDiedMessage);
    }
  }
   
  void setupRestartButton() {
    InputElement restrt = document.querySelector("#restart_button");
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
      var destX = locationOfLeaf[v].x - xDragOffset;
      var destY = locationOfLeaf[v].y - yDragOffset;
      var destWidth = xDragOffset * 2;
      var destHeight = yDragOffset * 2;
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
      context.drawImageScaled(source, destX, destY, destWidth, destHeight);//, destWidth, destHeight);
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
      ["if", [ ">", "energy", 30], [ ["forward", 0.08]  ] ],
      ["if", [ "<=", "energy", 60], [ ["forward", 0.04]  ] ],
      ["right", ["random", 20] ],
      ["left", ["random", 20] ],
      ["set", "energy", ["+", "energy", 1] ],
      ["ask", ["patch-here"], [
          [ "if", [ ">", "plant-energy", 5 ], [
              [ "set", "plant-energy", [ "-", "plant-energy", 1 ] ],
              [ "set", "energy", [ "-", "energy", 1] ]
          ] ]
      ] ],
      ["if", [ ">", "energy", 60], [ 
          [ "if", [ ">", ["random", 100], 89 ], [
              [ "die" ]
          ] ]
      ] ],
      ["if", [ ">", "energy", 30], [
          ["if", [ "<", "energy", 55], [
              ["if", [ ">", ["random", 100], 96 ], [
                  [ "hatch" ]
              ] ]
          ] ]
      ] ]
    ]
    """;
    Expression behavior = new Expression(json.parse(turtleBehaviors));
    
    
    for (int i=0; i<TURTLE_COUNT / 2; i++) {  
      PondTurtle t = new PondTurtle(this);
      t["energy"] = 0;
      t.color = turtleColors[i % 5].clone();
      t.setBehavior(behavior);
      t.x = this.screenToWorldX(300,300);
      t.y = this.screenToWorldY(300,300);
      addTurtle(t);
    }
    
    for (int i=0; i<TURTLE_COUNT / 2; i++) {  
      PondTurtle t = new PondTurtle(this);
      t["energy"] = 0;
      t.color = turtleColors[i % 5].clone();
      t.setBehavior(behavior);
      t.x = this.screenToWorldX(400,100);
      t.y = this.screenToWorldY(400,100);
      
      addTurtle(t);
    }
    
    String patchBehaviors = """
    [
      [ "set", "plant-energy", [ "+", "plant-energy", 0.1 ] ],
      [ "if", [">", "plant-energy", 10 ], [
          [ "set", "plant-energy", 10 ]
      ] ]
    ]
    """;
    
    //remove patch coloration for plant energy indication.
    //[ "set", "color-blue", "plant-energy" ]  
    behavior = new Expression(json.parse(patchBehaviors));
    
    for (Patch patch in patches) {
      patch.color.setColor(0, 0, 100, 128);
      patch.setBehavior(behavior);
      patch["plant-energy"] = 100;
    }
  }
}




double weightedAverage( num one, num two, num weightOfOne ) {
  return (one * weightOfOne + two) / (weightOfOne + 1);
}



//PondTurtle class.  I had some trouble getting this implementation to be able to access the
//private variables of Turtle.  I think this is because of the "library private" nature of 
//those variables.  Perhaps they should be declared with different access?
class PondTurtle extends Turtle {
  
  static Random rnd = new Random();
  
  PondTurtle(Model model) :super(model) {
    
  }
  
  //used for the "fuel tank visualization" which is no longer in the active version.
  num percentDrainedOfEnergy(  ) {
    num energy = this["energy"];
    if (energy > 94 ) { return 0.0; }
    if (energy < 45 ) { return 1.0; }
    return 1 - (energy - 45) / 50;
  }
  
  //overriding TICK because i need to work with conditions that are not "netlogo-native"
  void tick() {
    super.tick();
  
    var xc = model.worldToScreenX(x, y);
    var yc = model.worldToScreenY(x, y);
    
    
    
    if (draggingLeaf.length > 0 && (latestDelta.x != 0 || latestDelta.y != 0) ) {
      Point whereIAM = new Point(xc,yc);
      String myLeaf = findClosestCenterTo(whereIAM);
      if ( myLeaf == draggingLeaf)
      {        
        if ( locationOfLeaf[draggingLeaf].distanceTo(new Point(xc, yc)) > 35 ) {
          Point leafCenter = locationOfLeaf[draggingLeaf];
          Point newSpot = new Point(weightedAverage( xc, leafCenter.x, 2 ), weightedAverage( yc, leafCenter.y, 2 ));
          x = model.screenToWorldX( newSpot.x, newSpot.y );
          y = model.screenToWorldY( newSpot.x, newSpot.y );
        }
      } 
    }
    
    if ( touchDraggingLeaves.keys.isNotEmpty ) {
      Point whereIAM = new Point(xc,yc);
      String myLeaf = findClosestCenterTo(whereIAM);
      if ( latestTouchDelta[myLeaf] != null ) {
        num dx = latestTouchDelta[myLeaf].x;
        num dy = latestTouchDelta[myLeaf].y;
        if ( dx != 0 || dy > 0 ) {
          if ( locationOfLeaf[myLeaf].distanceTo(new Point(xc, yc)) > 35 ) {
            Point leafCenter = locationOfLeaf[myLeaf];
            Point newSpot = new Point(weightedAverage( xc, leafCenter.x, 2 ), weightedAverage( yc, leafCenter.y, 2 ));
            x = model.screenToWorldX( newSpot.x, newSpot.y );
            y = model.screenToWorldY( newSpot.x, newSpot.y );
          }
        }
      } 
    }
      
   
    
    //if (this["energy"] < 45){ print("would die at 45: " + this["energy"].toString()); }
    var imdat = canvas.context2D.getImageData(xc, yc, 1, 1).data;
    if (imdat.indexOf(0) > -1) {
      forward(-0.2);
      xc = model.worldToScreenX(x, y);
      yc = model.worldToScreenY(x, y);
      imdat = canvas.context2D.getImageData(xc, yc, 1, 1).data;
      if ( imdat[0] == 0 && imdat[1] == 0 && imdat[3] == 0  ) { 
        suicides++;
        print(suicides.toString() + " suicides");
         die(); 
       }
      else {
        right(175 + rnd.nextInt(10));
      }
    } 
  }
  
  void drawBody(CanvasRenderingContext2D ctx, num age) {
    num myrad = 0.10;
    var color = this.color;
    if ( age < 30 ) {
      ctx.beginPath();
      roundRect(ctx, -myrad/2.0, -myrad, myrad, 2.0*myrad, myrad/2.0);
      //ctx.arc(0, 0, myrad, 0, PI * 2, true);
      ctx.fillStyle = color.toString();
      ctx.fill();
     // ctx.stroke();
      ctx.closePath();
    } else if (age < 60 ) {
      drawLegs(ctx, 0, 0, myrad);
      ctx.beginPath();
      ctx.arc(0, 0, myrad, 0, PI * 2, true);
      ctx.fillStyle = color.toString();
      ctx.fill();
      ctx.stroke();
      ctx.closePath();
    } else {
      drawLegs(ctx, 0, 0, myrad);
      ctx.beginPath();
      ctx.fillStyle = color.toString();
      ctx.fillRect(-0.6*myrad, -myrad, 1.2*myrad ,  2.0*myrad);
      ctx.strokeRect(-0.6*myrad, -myrad, 1.2*myrad ,  2.0*myrad);
      ctx.closePath();
    }
    
  }
  
  void draw(CanvasRenderingContext2D  ctx) {
   
    
    
/*    ctx.fillStyle = "#000";
    ctx.arc(0, 0, myrad, 0, PI * 2, true);
    ctx.fill();
    ctx.closePath();
    
    ctx.save();
    ctx.beginPath();
    ctx.rect(-.1,-.1,0.2,0.2*percentDrainedOfEnergy());
    ctx.clip();
  
    ctx.beginPath(); */
    drawBody(ctx, this["energy"]);
    
    //ctx.closePath();
    
    
  /*  ctx.restore();
    
    ctx.strokeStyle = "rgba(10, 10, 10, 0.5)";
    ctx.lineWidth = 0.05;
    ctx.beginPath();
    ctx.arc(0, 0, myrad, 0, PI * 2, true);*/
    
  }
  
  void drawLegs(CanvasRenderingContext2D ctx, num x, num y, num r) {
    double d = rnd.nextDouble() * 1.2 * r + 0.3*r;
    double s = 1.5 * r;
    ctx.beginPath();
    ctx.moveTo(x+s,y+d);
    ctx.lineTo(x-s,y-d);
    ctx.moveTo(x+s,y);
    ctx.lineTo(x-s,y);
    ctx.moveTo(x+s,y-d);
    ctx.lineTo(x-s,y+d);
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
    t["energy"] = 0;
    //print("birth from bug of age "+this["energy"].toString());
    Expression behavior = new Expression(json.parse(turtleBehaviors));
    
    t.setBehavior(behavior);
    return t;
  }
}

