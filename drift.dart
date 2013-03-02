import 'dart:html';
import 'dart:math';
import 'dart:json';
import 'core/ntango.dart';


void main() {
  DriftModel model = new DriftModel("Drift");
  model.restart();
  
  window.onMessage.listen((event) {
    /*
    print("message: ${event.data}");
    Interpreter interp = new Interpreter();
    interp.load(event.data);
    while (interp.step()) {
      print('.');
    }
    */
  });
}


class DriftModel extends Model { 
  
  final int TURTLE_COUNT = 60;
  Plot plot;
   
  DriftModel(String name) : super(name, 'drift') {
    plot = new Plot("drift-plot");
    plot.title = "Number of Bugs / Amount of Grass";
    plot.labelX = "time";
    Pen pen = new Pen("bugs", "purple");
    pen.updater = (int ticks) { return turtles.length; };
    plot.addPen(pen);
    
    pen = new Pen("grass", "green");
    pen.updater = (int ticks) { return 50.0; };
    plot.addPen(pen);
    plot.minY = 0;
    plot.maxY = 100;
    plot.minX = 0;
    plot.maxX = 50;
    addPlot(plot);
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
      ["forward", 0.1],
      ["right", ["random", 20] ],
      ["left", ["random", 20] ],
      ["set", "energy", ["-", "energy", 0.01] ],
      ["ask", ["patch-here"], [ [ "set", "color-blue", 100 ], [ "set", "color-alpha", 125 ] ] ],
      ["if", [ "<=", "energy", 0 ], [ "die" ] ],
      ["if", [ ">", "energy", 0.9],
        ["if", [ ">", ["random", 100], 95 ], [ ["set", "energy", 0.5 ], [ "hatch" ] ] ]
      ]
    ]
    """;
    Expression behavior = new Expression(parse(behaviors));
    
    
    for (int i=0; i<TURTLE_COUNT; i++) {
      Turtle t = new Turtle(this);
      t["energy"] = 0.5 + Turtle.rnd.nextDouble() * 0.5;
      t.color = colors[i % 5].clone();
      t.setBehavior(behavior);
      addTurtle(t);
    }
    
    for (Patch patch in patches) {
      patch["energy"] = 100;
    }
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