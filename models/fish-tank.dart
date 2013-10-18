library nettango;

import 'dart:html';
import '../core/ntango.dart';



//bool showingBackground = true;

void main() {
   FishTankModel model = new FishTankModel();
   model.restart();
   model.play(1);
}

void hideShowBackground(KeyboardEvent event) {
  CanvasElement patchesCanvas = document.query("#fishtank-patches");
  if ( patchesCanvas.style.visibility == "hidden") {
    patchesCanvas.style.visibility = "visible";
  } else {
    patchesCanvas.style.visibility = "hidden";
  } 
}


class FishTankModel extends Model { 
  
  final int TURTLE_COUNT = 25;
  
  AgentsetNew aset = new AgentsetNew();
   
  FishTankModel() : super("FishTank", "fishtank") {  
    
  }
   
  void tick(){
    // call model.tick() to run boilerplate stuff
    super.tick();
  }
   
  void setup() {
    clearTurtles();
    /* We need some code here that sets up the correct turtles from the start. But 
    // since they go in the non-model-view divs, Iam not sure we do this from the code.
    */ 
  }
}


class FishTankTurtle extends Turtle {
   
   FishTankTurtle(Model model) : super(model) {
     // Here we give it a bunch of drawing functions
     // Save them in a list so we can just iterate over it and draw them all
     List<Function> bodyparts = new List(5);
     this['body-parts'] = bodyparts;
     
     // Now we have to populate
   }
   
   
  void tick() { 
    // 1% chance of reproducing
    if (rnd.nextInt(100) + 1 > 98){
      reproduce();
    }
    // wiggle and move forward
    this.right(rnd.nextInt(15));
    this.left(rnd.nextInt(15));
    this.forward(1);
  }
   
  
  void draw(var ctx) {
    // Need to do drawing stuff first
    for (Function f in ['bodyparts']){
      f();
    }
  }
  
  void reproduce() {
    // Create a new fishtank turtle
    FishTankTurtle offspring = new FishTankTurtle(this.model);
    // then pick a random mate in the fishtank    
    FishTankTurtle aMate = this.model.oneOfTurtles();
    // Here's where the reproduction takes place. For now, 50/50 of getting stuff from dad or dad.
    for (int i in this['bodyparts'].iterator()){
      offspring['bodyparts'][i] = rnd.nextDouble() > .5 ? this['body-parts'][i] : aMate['body-parts'][i];
    }
    
  }
}
