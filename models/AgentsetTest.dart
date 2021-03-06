library nettango;

import 'dart:html';
import 'dart:math';
import '../core/ntango.dart';

bool showingBackground = true;

void main() {
   AgentsetTestModel model = new AgentsetTestModel();
   model.restart();
   model.play(1);
}

void hideShowBackground(KeyboardEvent event) {
  CanvasElement patchesCanvas = document.query("#AgentsetTest-patches");
  if ( patchesCanvas.style.visibility == "hidden") {
    patchesCanvas.style.visibility = "visible";
  } else {
    patchesCanvas.style.visibility = "hidden";
  } 
}


class AgentsetTestModel extends Model { 
  
  Plot plot;
  
  final int TURTLE_COUNT = 25;
   
  AgentsetTestModel() : super("AgentsetTestuflage", "AgentsetTest") {  
    // Setting up plot
    plot = new Plot("AgentsetTest-color-plot");
    plot.title = "Mostly R, G, B";
    plot.labelX = "time";
    
    Pen redPen = new Pen("Red", "red");
    redPen.updater = (int ticks) { return turtles.where(mostlyRedtest).length; };
    plot.addPen(redPen);
    
    Pen greenPen = new Pen("Green", "green");
    greenPen.updater = (int ticks) { return turtles.where(mostlyGreentest).length; };
    plot.addPen(greenPen);
    
    Pen bluePen = new Pen("Blue", "blue");
    bluePen.updater = (int ticks) { return turtles.where(mostlyBluetest).length; };
    plot.addPen(bluePen);
    
    plot.minY = 0;
    plot.maxY = TURTLE_COUNT;
    plot.minX = 0;
    plot.maxX = 100;
    addPlot(plot);
    
  }
   
   
  void setup() {
    clearTurtles();
    for (int i=0; i<TURTLE_COUNT; i++) {
      AgentsetTestTurtle t = new AgentsetTestTurtle(this);
      addTurtle(t);
      t.setXY(Model.rnd.nextDouble() * worldWidth - worldWidth / 2, 
              Model.rnd.nextDouble() * worldHeight - worldHeight / 2);
      t.stayWithinBoundaries();
    }
  }

   
  void doTouchDown(Contact c) {
    for (int i=0; i<turtles.length; i++) {
      AgentsetTestTurtle t = turtles[i] as AgentsetTestTurtle;
      if (t.containsTouch(c)) {
        t.die();
        AgentsetTestTurtle ct = oneOfTurtles() as AgentsetTestTurtle;
        ct.reproduce();
        var reds = 0;
        var greens = 0;
        var blues = 0;
        for (AgentsetTestTurtle t in turtles){
          reds += (mostlyRedtest(t)) ? 0 : 1;
          blues += (mostlyBluetest(t)) ? 0 : 1;
          greens += (mostlyGreentest(t)) ? 0 : 1;
          
        }
        return;
      }
    }
  }

  int meanGreen(){
    int green = 0;
    for (AgentsetTestTurtle t in turtles){
      green += t.color.g;
    }
    print(green / turtles.length);
  }
   
  
}


class AgentsetTestTurtle extends Turtle {
   
   AgentsetTestTurtle(Model model) : super(model) {
      color.red = Turtle.rnd.nextInt(255);
      color.green = Turtle.rnd.nextInt(255);
      color.blue = Turtle.rnd.nextInt(255);
      color.alpha = 150;
   }
   
   
  void tick() { }
   
  
  void draw(var ctx) {
    drawLegs(ctx, 0, 0, 0.1);
    //roundRect(ctx, -0.1, -0.1, 0.2, 0.2, 0.1);
    ctx.beginPath();
    ctx.arc(0, 0, 0.1, 0, PI * 2, true);
    ctx.fillStyle = color.toString();
    ctx.fill();
    ctx.strokeStyle = color.toString();
    ctx.lineWidth = 0.05;
    ctx.stroke();
  }
  
  void drawLegs(CanvasRenderingContext2D ctx, num x, num y, num r) {
    //double d = Turtle.rnd.nextDouble() * 1.5 * r;
    double d = 1.5 * r;
    
    ctx.beginPath();
    ctx.moveTo(x+2*r,y+d);
    ctx.lineTo(x-2*r,y-d);
    ctx.moveTo(x+2*r,y);
    ctx.lineTo(x-2*r,y);
    ctx.moveTo(x+2*r,y-d);
    ctx.lineTo(x-2*r,y+d);
    ctx.lineWidth = 0.02;
    ctx.strokeStyle = color.toString();
    ctx.stroke();
  }
  
  void reproduce() {
    AgentsetTestTurtle copy = new AgentsetTestTurtle(model);
    copy.x = model.maxPatchX - 2 * model.maxPatchX * Turtle.rnd.nextDouble();
    copy.y = model.maxPatchY - 2 * model.maxPatchY * Turtle.rnd.nextDouble();
    copy.color = this.color.clone();
    copy.color.r += 5 - Turtle.rnd.nextInt(10);
    copy.color.g += 5 - Turtle.rnd.nextInt(10);
    copy.color.b += 5 - Turtle.rnd.nextInt(10);
    copy.stayWithinBoundaries();
    model.addTurtle(copy);
  }
  
  
  void stayWithinBoundaries(){
    if (x >= model.maxPatchX) {x--;}
    if (x <= model.minPatchX) {x++;}
    if (y >= model.maxPatchY) {y--;}
    if (y <= model.minPatchY) {y++;}
  }
  
  

}


bool mostlyRedtest(AgentsetTestTurtle turtle){
  bool mostlyRed;
  mostlyRed = turtle.color.r > turtle.color.g && turtle.color.r > turtle.color.b ? true : false;
  return mostlyRed;
}
bool mostlyGreentest(AgentsetTestTurtle turtle){
  bool mostlyGreen;
  mostlyGreen = turtle.color.g > turtle.color.r && turtle.color.g > turtle.color.b ? true : false;
  return mostlyGreen;
}
bool mostlyBluetest(AgentsetTestTurtle turtle){
  bool mostlyBlue;
  mostlyBlue = turtle.color.b > turtle.color.g && turtle.color.b > turtle.color.r ? true : false;
  return mostlyBlue;

}