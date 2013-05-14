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


/**
 * Abstract baseclass for Turtles and Patches
 */
abstract class Agent {
  
  /* all agents have a (model) unique id number */
  int id;
  
  /* reference to the containing model */
  Model model;
  
  /* agent's color */
  Color color = new Color(255, 255, 0, 255);
  
  /* agent-specific variables (e.g. turtles-own) */
  Map _props = new Map();
  
  /* Runtime behavior interpreter */
  Interpreter interp;
  
  /* repaint this agent? */
  bool dirty = false;

  /* Implementation of interpreter commands */
  Map<String, Function> commands = new Map<String, Function>();


  
  Agent(this.model) {
    id = model.nextAgentId();
    interp = new Interpreter(this);
  }


  /*
   * Access an agent-specific property
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
   * Set an agent-specific property
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
    while (interp.step()) {
    }
  }

  
  /*
   * This gets called every clock tick for every agent
   */
  void draw(CanvasRenderingContext2D ctx);
  
}
