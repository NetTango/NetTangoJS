library nettango;

import 'dart:html';
import 'dart:math';
import 'dart:convert';
import '../core/ntango.dart';

bool showingBackground = true;

void main() {
  window.onContextMenu.listen((event){event.preventDefault();});
   ArtificialModel model = new ArtificialModel();
   model.restart();
  // model.play(1);
}



class ArtificialModel extends Model { 
  
  Plot plot;
  int starvations = 0;
  int births = 0;
  final int TURTLE_COUNT = 30;
  //int patchSize = 60;
  
  // Dimensions of the world in patch coordinates 
  
  
   
  ArtificialModel() : super("Artificial Selection", "artificial") {  
   
    patchSize = 20;
    maxPatchX = 14;
    minPatchX = -15;
    maxPatchY = 14;
    minPatchY = -14;
    
    
    
    // Setting up plot
    plot = new Plot("artificial-plot");
    plot.title = "Population";
    plot.labelX = "time";
    
    Pen redPen = new Pen("Red", "red");
    redPen.updater = (int ticks) { return turtles.length; };
    plot.addPen(redPen);
   
    
    plot.minY = 0;
    plot.maxY = TURTLE_COUNT + 4;
    plot.minX = 0;
    plot.maxX = 100;
    addPlot(plot);
  }
  
  void anotherStarvation() {
    starvations++;
    //print(starvations.toString() + " starvations ");
  }
  
  void anotherBirth() {
    births++;
    //print(births.toString() + " births ");
  }
   
   
  void setup() {
    clearTurtles();
    clearPatches();
    initPatches();
    
    for (int i=0; i<TURTLE_COUNT; i++) {
      ArtificialTurtle t = new ArtificialTurtle(this);
      addTurtle(t);
      num safeWorldW = worldWidth - 2;
      num safeWorldH = worldHeight - 2;
      t.setXY(0, 0);
      t.setXY(Model.rnd.nextDouble() *  safeWorldW -  safeWorldW / 2, 
              Model.rnd.nextDouble() *  safeWorldH -  safeWorldH / 2 );
    }
    
    String behaviors = """
        [
        [ "set", "plant-energy", [ "+", "plant-energy", 1 ] ],
        [ "if", [">", "plant-energy", 100 ], [
        [ "set", "plant-energy", 100 ]
        ] ],
        [ "set", "color-green", "plant-energy" ]
        ]
        """;
    Expression behavior = new Expression(JSON.decode(behaviors));
    
    for (Patch patch in patches) {
      patch.color.setColor(0, 100, 0, 100);
      patch.setBehavior(behavior);
      patch["plant-energy"] = 100;
    }
  }

   
  void doTouchDown(Contact c) {
    for (int i=0; i<turtles.length; i++) {
      ArtificialTurtle t = turtles[i] as ArtificialTurtle;
      if (t.containsTouch(c)) {
        t.forward(1);
      }
    }
  }
  
  void tick() {
    super.tick();
    /*num excess = turtles.length - 200;
    while (excess > 0 ) {
      Turtle t = turtles[ Turtle.rnd.nextInt(turtles.length) ];
      t.die();
      excess--;
    }
    */
  }

  
  
}


class ArtificialTurtle extends Turtle {
   
    ArtificialTurtle(Model model) : super(model) {
      
      color.red = Turtle.rnd.nextInt(255);
      color.green = Turtle.rnd.nextInt(255);
      color.blue = Turtle.rnd.nextInt(255);
      color.alpha = 255;
      
  
      this["drawFunctions"] = new List<Function>();
      this["radius"] = 0.2 + Turtle.rnd.nextDouble() * .1;
      this["energy"] = 5;
      this["age"] = 10 - Turtle.rnd.nextInt(10);
      
      addDrawFunction(drawLegs);
   }
    
  
    void addDrawFunction( Function g ) {
      this["drawFunctions"].add( g );
    }
  
   
  void dummy (CanvasRenderingContext2D ctx, num x, num y, num r)  { 
    print("added this draw function");
  }
    
  bool notMe( Turtle maybeOther ) {
    return maybeOther.id != id;
  }
  
  void tick() { 
    if (this["age"] > 20) {
      right( Turtle.rnd.nextInt(20) );
      left( Turtle.rnd.nextInt(20) );
      forward(.2);
      this["energy"] -= 2;
      
      Patch p = patchHere();
      num ener = p["plant-energy"];
      if (ener - 8 > 10) {
        p["plant-energy"] = ener - 8;
        this["energy"] += 3;
      }
      
      if ( this["energy"] < 0) {
        //print("dying for lack of energy");
        die();
        (model as ArtificialModel).anotherStarvation();
      }
      AgentSet others = this.turtlesHere();
      if ( others.length == 2)
      {
        for ( Turtle t in others.agents ) {
          ArtificialTurtle at = t as ArtificialTurtle;
          if ( notMe(at) ) {
            if( this["energy"] > 15 && at["energy"] > 15 && at["age"] > 20 ) {
              reproduceWith(at);
              (model as ArtificialModel).anotherBirth();
            }
            return;
          }
        }      
      }
    }
    this["age"]++;
  }
   
  
  void draw(var ctx) {
    if (this["age"] > 15) {
      //START with the custom draw functions.
      for ( Function f in (this["drawFunctions"]) ) {
        f(ctx, 0, 0, this["radius"]);
      }
    }
    
    //then the basic circular body.
    ctx.beginPath();
    ctx.arc(0, 0, this["radius"], 0, PI * 2, true);
    ctx.fillStyle = color.toString();
    ctx.fill();
    ctx.strokeStyle = color.toString();
    ctx.lineWidth = 0.05;
    ctx.stroke();
  }
  
  void drawLegs(CanvasRenderingContext2D ctx, num x, num y, num r) {
    double d = Turtle.rnd.nextDouble() * r + 0.5*r;
    //double d = 1.5 * r;
    
    ctx.beginPath();
    ctx.moveTo(x+2*r,y+d);
    ctx.lineTo(x-2*r,y-d);
    ctx.moveTo(x+2*r,y);
    ctx.lineTo(x-2*r,y);
    ctx.moveTo(x+2*r,y-d);
    ctx.lineTo(x-2*r,y+d);
    ctx.lineWidth = 0.02;
    ctx.strokeStyle = "#000"; //color.toString();
    ctx.stroke();
  }
  
  void reproduceWith( ArtificialTurtle mate ) {
    
    this["energy"] = this["energy"] / 2;
    mate["energy"] = mate["energy"] / 2;
    ArtificialTurtle offspring = new ArtificialTurtle(model);
    
    offspring.x = x ;
    offspring.y = y ;
    offspring.heading = heading + 180;
    
    offspring.color = this.color.clone();
    offspring.color.r =  averageAndMutateInt(color.r, mate.color.r, 10);
    offspring.color.g =  averageAndMutateInt( color.g, mate.color.g , 10);
    offspring.color.b = averageAndMutateInt(color.b, mate.color.b, 10);
    
    offspring.addDrawFunction(drawLegs);
    
    offspring["radius"] = averageAndMutateNum( this["radius"], mate["radius"], .1);  
    if (offspring["radius"] < .075) { offspring["radius"] = .075; }
 
    offspring["energy"] = (this["energy"] + mate["energy"] ) / 3;
    offspring["age"] = 0;
    model.addTurtle(offspring);
  }
  
  
  int averageAndMutateInt( int left, int right, int maxMutate) {
   return ((left + right ) / 2).round()  + Turtle.rnd.nextInt(maxMutate) - Turtle.rnd.nextInt(maxMutate);
  }
  
  num averageAndMutateNum( num left, num right, num maxMutate) {
    return ((left + right ) / 2.0)  + Turtle.rnd.nextDouble() * maxMutate - Turtle.rnd.nextDouble() * maxMutate;
  }
  
  
  

}


