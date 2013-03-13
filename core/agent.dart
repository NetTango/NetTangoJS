/*
 * NetTango
 * Northwestern University
 * michael-horn@northwestern.edu
 * Copyright 2013, Michael S. Horn and Uri Wilensky
 *
 * This project was funded in part by the National Science Foundation.
 * Any opinions, findings and conclusions or recommendations expressed in this
 * material are those of the author(s) and do not necessarily reflect the views
 * of the National Science Foundation (NSF).
 */
part of NetTango;


abstract class Agent {
  
  int id;               // all agents have a unique id number
  Model model;          // reference to the containing model
  Color color;          // agent color
  Map _props;           // user-defined agent variables (e.g. turtles-own)
  Interpreter interp;   // runtime interpreter
  bool dirty = false;   // repaint this agent?

  // implementation of interpreter commands
  Map<String, Function> commands = new Map<String, Function>();


  
  Agent(this.model) {
    id = model.nextAgentId();
    color = new Color(255, 255, 0, 255);
    _props = new Map();
    interp = new Interpreter(this);
  }


  /*
   * Access a property
   */
  dynamic operator[](String key) {
    if (key == "color-red") {
      return color.red;
    } else if (key == "color-green") {
      return color.green;
    } else if (key == "color-blue") {
      return color.blue;
    } else if (key == "color-alpha") {
      return color.alpha;
    }
    return _props[key];
  }

  
  /*
   * Set a property
   */
  void operator[]=(String key, var value) {
    if (key == "color-red") {
      color.red = value.toInt();
      dirty = true;
    } else if (key == "color-green") {
      color.green = value.toInt();
      dirty = true;
    } else if (key == "color-blue") {
      color.blue = value.toInt();
      dirty = true;
    } else if (key == "color-alpha") {
      color.alpha = value.toInt();
      dirty = true;
    } else {
      _props[key] = value;
    }
  }
  
  
  /*
   * Is the named variable defined for this agent?
   */
  bool isDefined(String name) {
    return (name == "color-red" ||
            name == "color-green" ||
            name == "color-blue" ||
            name == "color-alpha" ||
            _props.containsKey(name));
  }
  
  
  /*
   * Set the agent's behavior (program code)
   */
  void setBehavior(Expression behavior) {
    interp.load(behavior);
  }
   
  
  /*
   * This gets called every clock tick for every agent
   */
  void tick() {
    interp.restart();
    while(interp.step()) { }
  }

  
  /*
   * This gets called every clock tick for every agent
   */
  void draw(CanvasRenderingContext2D ctx);
}