import 'dart:html';
import 'dart:math';
import 'dart:json';
import 'dart:async';
import '../core/ntango.dart';


void main() {
  DriftModel model = new DriftModel("Drift");
  model.restart();
  
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
    pen.updater = (int ticks) {
      double count = 0.0;
      for (Patch patch in patches) {
        count += patch["plant-energy"];
      }
      return count / patches.length;
    };
    plot.addPen(pen);
    plot.minY = 0;
    plot.maxY = 100;
    plot.minX = 0;
    plot.maxX = 50;
    addPlot(plot);

    //-----------------------------------------------------
    // This hides the status message when you click on it
    //-----------------------------------------------------    
    bindClickEvent("status", (event) {
      if (getHtmlOpacity("status") > 0) {
        setHtmlOpacity("status", 0.0);
        play();
      }
    });
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
      ["set", "energy", ["-", "energy", 1] ],
      ["if", [ "<=", "energy", 0], [ "die"] ],
      ["ask", ["patch-here"], [
          [ "if", [ ">", "plant-energy", 0 ], [
              [ "set", "plant-energy", [ "-", "plant-energy", 10 ] ],
              [ "set", "energy", [ "+", "energy", 2] ]
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
      Turtle t = new Turtle(this);
      t["energy"] = Turtle.rnd.nextInt(100);
      t.color = colors[i % 5].clone();
      t.setBehavior(behavior);
      addTurtle(t);
    }
    
    behaviors = """
    [
      [ "set", "plant-energy", [ "+", "plant-energy", 1 ] ],
      [ "if", [">", "plant-energy", 100 ], [
          [ "set", "plant-energy", 100 ]
      ] ],
      [ "set", "color-green", "plant-energy" ]
    ]
    """;
    behavior = new Expression(parse(behaviors));
    
    for (Patch patch in patches) {
      patch.color.setColor(0, 100, 0, 255);
      patch.setBehavior(behavior);
      patch["plant-energy"] = 100;
    }
  }


  void tick() {
    super.tick();
    if (ticks % 50 == 0) {
      pause();
      showStatusMessage("You've been watching for ${ticks} ticks.");
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