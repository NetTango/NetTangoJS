import 'dart:html';
import 'dart:math';
import 'dart:json';
import '../core/ntango.dart';


Element _draggin = null;
String draggingLeaf = "";
CanvasElement canvas = document.query("#drift-pond-pads");
String turtleBehaviors = "";

var leafImage = document.query("#leafimage");
var BackInStackPoint = new Point(660,600);
int leafIndex = 0;
Map<String,Point> locationOfLeaf = new Map<String,Point>();

DriftModel model;
void main() {
  locationOfLeaf["-1"] = new Point(250,250);
  var leafstack = document.query("#leafstack");
  leafstack.onMouseDown.listen( dragStart );
  
  var topCanv = document.query("#drift-pond-turtles");
  topCanv.onMouseDown.listen( startAdjustingLeaf );
  
  window.onMouseUp.listen( dragStop );
  window.onMouseMove.listen(maybeMove); 
  
  model = new DriftModel("Drift Pond");
  model.restart();
  model.requestRedraw();
}

//move an already-placed leaf
void startAdjustingLeaf( MouseEvent evt ) {
  Point testPoint = new Point(evt.clientX - 110, evt.clientY - 100);
  String wLeaf = findClosestCenterTo(testPoint);
  num dist = testPoint.distanceTo(locationOfLeaf[wLeaf]);
  if ( dist < 50 ) {
    draggingLeaf = wLeaf;
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

//actually move the adjusted leaf
void repositionLeaf( nx, ny ) {
  locationOfLeaf[draggingLeaf] = new Point(nx, ny);
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
    model.requestRedraw();
  }
}


//the actual model class implementation
class DriftModel extends Model { 

  final int TURTLE_COUNT = 60;
  Plot plot;
   
  DriftModel(String name) : super(name, 'drift-pond') {
    plot = new Plot("drift-pond-plot");
    plot.title = "Number of Bugs";
    plot.labelX = "time";
    Pen pen = new Pen("bugs", "purple");
    pen.updater = (int ticks) { return turtles.length; };
    plot.addPen(pen);

    plot.minY = 0;
    plot.maxY = 100;
    plot.minX = 0;
    plot.maxX = 50;
    addPlot(plot);
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

    clearTurtles();
    clearPatches();
    initPatches();
      
    var colors = [
                new Color(255, 0, 0, 255),
                new Color(0, 255, 0, 255),
                new Color(0, 0, 255, 255),
                new Color(255, 255, 0, 255),
                new Color(0, 255, 255, 255)];
    
    //initialized here but given top-level scope.    
    turtleBehaviors = """
    [
      ["forward", 0.03],
      ["right", ["random", 20] ],
      ["left", ["random", 20] ],
      ["set", "energy", ["-", "energy", 0.2] ],
      ["if", [ "<=", "energy", 0], [ "die"] ],
      ["ask", ["patch-here"], [
          [ "if", [ ">", "plant-energy", 0 ], [
              [ "set", "plant-energy", [ "-", "plant-energy", 5 ] ],
              [ "set", "energy", [ "+", "energy", 4] ]
          ] ]
      ] ],
      ["if", [ ">", "energy", 90], [
          ["if", [ ">", ["random", 100], 95 ], [
              ["set", "energy", 50 ],
              [ "hatch" ]
          ] ]
      ] ]
    ]
    """;
    Expression behavior = new Expression(parse(turtleBehaviors));
    
    
    for (int i=0; i<TURTLE_COUNT; i++) {  
      PondTurtle t = new PondTurtle(this);
      t["energy"] = 100;
      t.color = colors[i % 5].clone();
      t.setBehavior(behavior);
      addTurtle(t);
    }
    
    String patchBehaviors = """
    [
      [ "set", "plant-energy", [ "+", "plant-energy", 1 ] ],
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
    
    var imdat = canvas.context2D.getImageData(xc, yc, 1, 1).data;
    if (imdat.indexOf(0) > -1) {
      if ( imdat[0] == 0 && imdat[1] == 0 && imdat[3] == 0  ) { 
         die(); 
       }
      else {
        right(180);
      }
    } 
  }
  
  void draw(var ctx) {
    drawLegs(ctx, 0, 0, 0.1);
    roundRect(ctx, -0.1, -0.1, 0.2, 0.2, 0.1);
    ctx.fillStyle = color.toString();
    ctx.fill();
    ctx.strokeStyle = "rgba(0, 0, 0, 0.5)";
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
    ctx.strokeStyle = "rgba(0, 0, 0, 1)";
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

