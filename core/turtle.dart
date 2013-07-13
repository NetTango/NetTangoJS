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


class Turtle extends Agent implements Touchable {
  
  
  static Random rnd = new Random();
  
  /* turtle coordinates in world space */
  num x = 0.0, y = 0.0;
  
  /* turtle size */
  num size = 1.0;
  
  /* turtle heading in radians */
  num heading = 0.0;
  
  /* does this turtle wrap around the edges of the model? */
  bool wrap = true;
  
  /* flag used to remove dead turtles from the model */
  bool dead = false;
  
  /* TODO: probably need something more sophisticated */
  String breed = "turtle";
  

  
  Turtle(Model model) : super(model) {
    heading = rnd.nextDouble() * PI * 2;
    color = new Color(255, 255, 0, 50);
    commands["forward"] = _doForward;
    commands["right"] = _doRight;
    commands["left"] = _doLeft;
    commands["die"] = _doDie;
    commands["hatch"] = _doHatch;
    commands["patch-here"] = _doPatchHere;
  }
  
  
  Turtle clone() {
    Turtle t = new Turtle(model);
    t.x = x;
    t.y = y;
    t.size = size;
    t.heading = heading;
    t.color = color.clone();
    t.dead = false;
    t.breed = breed;
    t.setBehavior(interp.program);
    
    // copy all of the properties
    for (String key in _props.keys) {
      t[key] = this[key];
    }
    return t;
  }
   
   
  void setXY(num x, num y) {
    if (wrap) {
      this.x = wrapX(x);
      this.y = wrapY(y);
    } else {
      this.x = x;
      this.y = y;
    }
  }
   
   
  void forward(num distance) {
    if (wrap) {
      x = wrapX(x - sin(heading) * distance);
      y = wrapY(y + cos(heading) * distance);
    } else {
      x -= sin(heading) * distance;
      y += cos(heading) * distance;
    }
  }
  
     
  void backward(num distance) {
    forward(-distance);
  }
  
  
  void left(num degrees) {
    heading += (degrees / 180) * PI;   
  }
  
  
  void right(num degrees) {
    left(-degrees);
  }
  
  
  void die() {
    dead = true;
  }
  
  
  Turtle hatch() {
    Turtle copy = clone();
    model.addTurtle(copy);
    return copy;
  }
  
  
  num wrapX(num tx) {
    while (tx < model.minWorldX) {
      tx += model.worldWidth;
    }
    while (tx > model.maxWorldX) {
      tx -= model.worldWidth;
    }
    return tx;
  }
  
  
  num wrapY(num ty) {
    while (ty < model.minWorldY) {
      ty += model.worldHeight;
    } 
    while (ty > model.maxWorldY) {
      ty -= model.worldHeight;
    } 
    return ty;
  }
  
  
  void draw(var ctx) {
    roundRect(ctx, -0.1, -0.1, 0.2, 0.2, 0.1);
    ctx.fillStyle = color.toString();
    ctx.fill();
    ctx.strokeStyle = "rgba(0, 0, 0, 0.5)";
    ctx.lineWidth = 0.05;
    ctx.stroke();
  }
  
 
  
 
  
  Patch patchHere() {
    return model.patchAt(x, y);
  }
  
  
  // returns a list of turtles here
  // uses the patch primitive/method of the same name
  AgentSet turtlesHere() {
    Patch p = patchHere();
    return p.turtlesHere();
  }
  
  
  // @todo
  AgentSet otherTurtlesHereWith(Map<String, dynamic> params) {
    AgentSet turtleshere = turtlesHere();
    AgentSet result = new AgentSet();
    for (Turtle t in turtleshere){
      // TODO
    }
    return result;
  }
  
  
  Patch patchAhead(distance) {
    num px = wrapX(x - sin(heading) * distance);
    num py = wrapY(y + cos(heading) * distance);
    return model.patchAt(x, y);
  }
  
  
  void roundRect(var ctx, num x, num y, num w, num h, num r) {
    ctx.beginPath();
    ctx.moveTo(x+r,y);
    ctx.arcTo(x+w,y,x+w,y+r,r);
    ctx.arcTo(x+w,y+h,x+w-r,y+h,r);
    ctx.arcTo(x,y+h,x,y+h-r,r);
    ctx.arcTo(x,y,x+r,y,r);
  }


  
  //-------------------------------------------------------------------
  // Interpreter commands
  //-------------------------------------------------------------------
  void _doForward(String command, List args) {
    if (args.length > 0) {
      forward(args[0]);
    }
  }
  
  void _doBackward(String command, List args) {
    if (args.length > 0) {
      backward(args[0]);
    }
  }
  
  void _doRight(String command, List args) {
    if (args.length > 0) {
      right(args[0]);
    }
  }
   
  void _doLeft(String command, List args) {
    if (args.length > 0) {
      left(args[0]);
    }
  }
  
  void _doDie(String command, List args) {
    die();
  }
  
  void _doHatch(String command, List args) {
    hatch();
  }
  
  AgentSet _doPatchHere(String command, List args) {
    return new AgentSet.fromAgent(patchHere());
  }
  
   
  
  //-------------------------------------------------------------------
  // Touchable implementation
  //-------------------------------------------------------------------
  bool containsTouch(Contact event) {
    double tx = model.screenToWorldX(event.touchX, event.touchY);
    double ty = model.screenToWorldY(event.touchX, event.touchY);
    return (tx >= x-size/2 && tx <= x+size/2 && ty >= y-size/2 && ty <= y+size/2);
  }
  
  
  bool touchDown(Contact event) {
    color.setColor(255, 0, 0, 255);
    return true;
  }
  
  
  void touchUp(Contact event) {
    color.setColor(0, 255, 0, 255);
  }
  
  
  void touchDrag(Contact event) {      
    double tx = model.screenToWorldX(event.touchX, event.touchY);
    double ty = model.screenToWorldY(event.touchX, event.touchY);
    x = tx;
    y = ty;
  }
  
  
  void touchSlide(Contact event) { }
}