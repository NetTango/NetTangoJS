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


class Interpreter {
  
  /* Agent that owns this interpreter */
  Agent owner = null;
  
  /* Agent currently being acted on */
  Agent agent = null;
  
  /* Current agent set */
  AgentSet agents = null;
  
  /* Entire program (typically a block) */
  Expression program = null;

  /* Currrently executing expression */
  Expression curr = null;

  /* Points to expression index in a block */
  int ip = 0;

  /* Expression stack for nested blocks of code */
  List<StackFrame> stack = new List<StackFrame>();

  /* Implementation for expressions */
  Map<String, Function> commands = new Map<String, Function>();

  /* Random number generator */
  Random rand = new Random();

  
  Interpreter(this.owner) {
    agent = owner;
    commands["random"] = _doRandom;
    commands["-"] = _doSubtraction;
    commands["+"] = _doAddition;
    commands["<"] = _doComp;
    commands[">"] = _doComp;
    commands["<="] = _doComp;
    commands[">="] = _doComp;
  }


  void load(Expression expression) {
    program = expression;
    restart();
  }
  
  
  void restart() {
    agent = owner;
    agents = new AgentSet.fromAgent(owner);
    curr = program;
    ip = 0;
    stack.clear();
  }

  
  dynamic getVariable(String name) {
    return (agent != null)? agent[name] : null;
  }
  
  
  void setVariable(String name, var value) {
    if (agent != null) agent[name] = value;
  }


  /**
   * Steps through the code one expression at a time
   */
  bool step() {
    
    // curr is null?  exit the program
    if (curr == null) return false;
    

    // curr is a code block
    else if (curr is Block) {
      Block b = curr as Block;
      Expression s = b[ip++];
      if (s != null) {
        s.eval(this);
      } else {
        popFrame();
      }
    }

    // curr is not a block
    else {
      curr.eval(this);
      popFrame();
    }
    
    return true;
  }


  dynamic invoke(String command, List args) {
    
    // built-in interpreter commands
    if (commands.containsKey(command)) {
      Function f = commands[command];
      return f(command, args);
    }
    else if (agent != null && agent.commands.containsKey(command)) {
      Function f = agent.commands[command];
      return f(command, args);
    }
    return null;
  }


  void pushFrame(Expression exp, AgentSet aset) {
    if (aset != null && aset.curr() == null) return; // don't push an empty agent set
    
    stack.add(new StackFrame(curr, ip, agents));
    curr = exp;
    ip = 0;
    if (aset != null) {
      agents = aset;
      agent = agents.curr();
    }
  }


  void popFrame() {
    
    // stack empty? end the program
    if (stack.isEmpty) {
      ip = -1;
      curr = null;
    }
    
    // restart this code block for the next agent?
    else if (agents.hasNext) {
      ip = 0;
      agent = agents.next();
      assert(agent != null);
    }
    
    // otherwise pop the stack
    else {
      ip = stack.last.ip;
      curr = stack.last.exp;
      agents = stack.last.agents;
      agent = agents.curr();
      assert(agent != null);
      stack.removeLast();
    }
  }


  num _doRandom(String command, List args) {
    if (args.length > 0) {
      return rand.nextDouble() * args[0];
    } else {
      return rand.nextDouble();
    }
  }
  
  num _doSubtraction(String command, List args) {
    if (args.length == 2) {
      return args[0] - args[1];
    } else if (args.length == 1) {
      return args[0] * -1;
    } else {
      return 0;
    }
  }
  
  num _doAddition(String command, List args) {
    num sum = 0;
    for (var arg in args) {
      if (arg is num) sum += arg;
    }
    return 0;
  }
  
  bool _doComp(String command, List args) {
    num a = args[0];
    num b = args[1];
    if (command == "<") return a < b;
    else if (command == ">") return a > b;
    else if (command == "<=") return a <= b;
    else if (command == ">=") return a >= b;
    else return false;
  }
}


class StackFrame {
  
  Expression exp = null;    // code to execute
  int ip = 0;               // instruction pointer
  AgentSet agents = null;   // agent set being acted on (via "ask" statement)
  
  StackFrame(this.exp, this.ip, this.agents) { }
}

