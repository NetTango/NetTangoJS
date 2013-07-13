import 'dart:html';
import 'dart:math';
import 'dart:json';
import '../core/ntango.dart';

Element _draggin = null;
String draggingLeaf = "";
CanvasElement canvas = document.query("#drift-pond-pads");
Element sheen = document.query("#drift-pond-sheen");

var OutOfBoundsPoint = new Point(660,600);
int leafIndex = 0;
Map<String,Point> locationOfLeaf = new Map<String,Point>();

DriftModel model;
int dimbase = 50;
int dx = 5;
int dy = 5;

var leafImage = document.query("#leafimage");
void main() {
  locationOfLeaf["-1"] = new Point(250,250);
  var leafstack = document.query("#leafstack");
  
  leafstack.onMouseDown.listen( dragStart );
  var topCanv = document.query("#drift-pond-turtles");
  topCanv.onMouseDown.listen( repositionStart );
  
  window.onMouseUp.listen( dragStop );
  window.onMouseMove.listen(maybeMove); 
  
  model = new DriftModel("Drift Pond");
  model.restart();
  model.requestRedraw();
}

void repositionStart( MouseEvent evt ) {
  Point testPoint = new Point(evt.clientX - 110, evt.clientY - 100);
  String wLeaf = findClosestCenterTo(testPoint);
  num dist = testPoint.distanceTo(locationOfLeaf[wLeaf]);
//  print("distance is ${dist}");
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


void maybeMove( MouseEvent event ) {
  if (_draggin != null) {
    updateDraggin( event.clientX, event.clientY );
  } else if ( draggingLeaf.length > 0 ) {
    repositionLeaf( event.clientX - 110, event.clientY - 100 );
  }
}

void repositionLeaf( nx, ny ) {
  locationOfLeaf[draggingLeaf] = new Point(nx, ny);
  model.requestRedraw();
}

void updateDraggin(x, y) {
  _draggin.style.left = (x - 60).toString() + "px";
  _draggin.style.top = (y - 50).toString() + "px";
//  print("drag" + x.toString() + "," + y.toString() + " --> " + _draggin.style.left );
}


void dragStart(MouseEvent event) {
  _draggin = document.query("#leafmoving"); //new Element.html('<div class="leafmoving" style="top: 650px; left: 650px; height: 100px; width: 121px;" id="leafmoving" draggable="false"></div>');
  _draggin.style.zIndex="7";
  leafIndex++;
  locationOfLeaf[(leafIndex.toString()) ] = OutOfBoundsPoint;

 // print(_draggin.id);
}

void dragStop(MouseEvent event) {
  if (_draggin != null) {
    locationOfLeaf[(leafIndex.toString()) ] = new Point(event.clientX - 110, event.clientY - 100);
    _draggin.style.left = OutOfBoundsPoint.x.toString() + "px";
    _draggin.style.top = OutOfBoundsPoint.y.toString() + "px";
    _draggin.style.zIndex="5";
    _draggin = null;
    //print(locationOfLeaf.toString());
    model.requestRedraw();
  } else if (draggingLeaf.length > 0 ) {
    draggingLeaf = "";
    model.requestRedraw();
  }
}

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
      context.fillStyle="#000022";
      context.fillRect(destX - 4,destY - 4,destWidth + 8,destHeight + 8);
      context.fillStyle="#000122";
      
      context.fillRect(destX - 2,destY - 2,destWidth + 4,destHeight + 4);
      
 //     print("about to try to draw at " + destX.toString() + ", " + destY.toString() + "width=" + destWidth.toString() + ", height=" + destHeight.toString()  );
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
    
    String behaviors = """
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
    Expression behavior = new Expression(parse(behaviors));
    
    
    for (int i=0; i<TURTLE_COUNT; i++) {  
      PondTurtle t = new PondTurtle(this);
      t["energy"] = 100;
      t.color = colors[i % 5].clone();
      t.setBehavior(behavior);
      addTurtle(t);
    }
    
    behaviors = """
    [
      [ "set", "plant-energy", [ "+", "plant-energy", 1 ] ],
      [ "if", [">", "plant-energy", 100 ], [
          [ "set", "plant-energy", 100 ]
      ] ]
    ]
    """;
    
    //[ "set", "color-blue", "plant-energy" ]
    behavior = new Expression(parse(behaviors));
    
    for (Patch patch in patches) {
      patch.color.setColor(0, 0, 100, 128);
      patch.setBehavior(behavior);
      patch["plant-energy"] = 100;
    }
  }
}


class PondTurtle extends Turtle {
  
  PondTurtle(Model model) :super(model) {
    
  }
  
  void tick() {
    super.tick();
    var xc = model.worldToScreenX(x, y);
    var yc = model.worldToScreenY(x, y);
    //print("Image data for canvas at $xc, $yc");
    //print(canvas.context2D.getImageData(xc, yc, 1, 1).data);
    var imdat = canvas.context2D.getImageData(xc, yc, 1, 1).data;
   // print("image data for id ${id} is ${imdat}");
    if (imdat.indexOf(0) > -1) {
    //  print("image data for id ${id} is ${imdat}");
      if ( imdat[0] == 0 && imdat[1] == 0 && imdat[3] == 0  ) { 
    //     print("turtle id ${id} is dying b.c of ${imdat}");
         die(); 
       }
      else {
        right(180);
      }
    } 
    
  }
  
  PondTurtle clone() {
    PondTurtle t = new PondTurtle(model);
    t.x = x;
    t.y = y;
    t.size = size;
    t.heading = heading;
    t.color = color.clone();
    t["energy"] = 100;
    String behaviors = """
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
    Expression behavior = new Expression(parse(behaviors));
    
    t.setBehavior(behavior);
    return t;
  }
}





/*
  void tick() {
    forward(0.1);
    right(Turtle.rnd.nextInt(20));
    left(Turtle.rnd.nextInt(20));
    Patch p = patchHere();
      //if (energy < 1 && p.energy > 0.2) {
      //   energy += 0.03;
      //   p.energy -= 0.2;
     // }
    color.alpha = (255 * this["energy"]).toInt();
    this["energy"] -= 0.01;
    if (this["energy"] <= 0) {
         die();
    } else if (this["energy"] > 0.9 && Turtle.rnd.nextInt(100) > 95) {
      reproduce();
      
    }
  }
   
      copy.color.blue = color.blue;
      copy["energy"] = 0.5;
      this["energy"] = 0.5;
      model.addTurtle(copy);
   }
*/