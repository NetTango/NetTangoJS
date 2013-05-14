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
 * Fundamental syntactic building block of a NetTango program
 * (similar to a lisp s-expression).
 */
abstract class Expression {


  /**
   * Default constructor
   */
  Expression._default();
  

  /**
   * Factory constructor that creates a generic expression, an atom,
   * a "block", or one of the built-in control structures
   */
  factory Expression(var exp) {
    
    if (exp == null) {
      return null;
    }

    // Variable?
    else if (exp is String) {
      return new Variable(exp);
    }
    
    // If it's not a list it must be an atom
    else if (exp is! List) {
      return new Atom(exp);
    }

    List l = exp as List;
    
    if (l.length == 0) {
      return new Block(l);  // empty block
    } 
    else if (l[0] == "set") {
      return new SetStatement(l);
    }
    else if (l[0] == "if") {
      return new IfStatement(l);
    }
    else if (l[0] == "ask") {
      return new AskStatement(l);
    }
    else if (l[0] == "repeat") {
      return new RepeatStatement(l);
    }
    else if (l[0] == "forever") {
      return new ForeverStatement(l);
    }
    else if (l[0] is String) {
      return new Statement(l);
    }
    else {
      return new Block(l);
    }
  }
  
  
  dynamic eval(Interpreter interp);
}


/**
 * An expression that evaluates to a specific constant value
 */
class Atom extends Expression {

  var value = null;

  Atom(this.value) : super._default();


  dynamic eval(Interpreter interp) {
    return value;
  }
}


/**
 * An expression that evaluates to a variable value
 */
class Variable extends Expression {
  
  String name = null;
  
  Variable(this.name) : super._default();
  
  dynamic eval(Interpreter interp) {
    return interp.getVariable(name);
  }
}


/**
 * A list of expressions
 */
class Block extends Expression {
  
  List<Expression> list = new List<Expression>();
  
  
  Block(List l) : super._default() {
    for (int i=0; i<l.length; i++) {
      list.add(new Expression(l[i]));
    }
  }
  
  
  Expression operator[] (int i) {
    if (i < 0 || i >= list.length) {
      return null;
    } else {
      return list[i];
    }
  }

  
  dynamic eval(Interpreter interp) {
    return list;
  }
}


/**
 * An invokable command
 */
class Statement extends Expression {
  
  String name;
  
  List<Expression> args = new List<Expression>();
  
  
  Statement(List l) : super._default() {
    name = l[0];
    for (int i=1; i<l.length; i++) {
      args.add(new Expression(l[i]));
    }
  }
  
  
  dynamic eval(Interpreter interp) {
    
    // evaluate arguments
    List values = new List();
    for (int i=0; i<args.length; i++) {
      values.add(args[i].eval(interp));
    }
    
    // invoke command
    return interp.invoke(name, values);
  }
}


/**
 * Sets the value of a variable
 */
class SetStatement extends Statement {
  
  Variable lhs;
  Expression rhs;
  
  SetStatement(List l) : super(l) {
    lhs = args[0];
    rhs = args[1];
  }
  
  dynamic eval(Interpreter interp) {
    Variable v = args[0];
    interp.setVariable(lhs.name, rhs.eval(interp));
  }
}


abstract class ControlStatement extends Statement {
  
  ControlStatement(List l) : super(l);
  
  // called after a control statement has been executed 
  void onComplete(Interpreter interp) { }
}


/**
 * 1-way conditional
 */
class IfStatement extends ControlStatement {
  
  IfStatement(List l) : super(l);
  
  dynamic eval(Interpreter interp) {
    if (args[0].eval(interp)) {
      interp.pushFrame(args[1], null);
    }
  }
}


/**
 * Counting loop
 */
class RepeatStatement extends ControlStatement {
  
  int count = null;
  
  RepeatStatement(List l) : super(l);
  
  dynamic eval(Interpreter interp) {
    if (count == null) {
      count = args[0].eval(interp);
    }
    if (count > 0) {
      interp.ip--;  // FIXME: This is terrible!
      interp.pushFrame(args[1], null);
      count--;
    } else {
      count = null;
    }
  }
}


/**
 * Infinite loop
 */
class ForeverStatement extends ControlStatement {
  
  ForeverStatement(List l) : super(l);
  
  dynamic eval(Interpreter interp) {
    interp.ip--;  // FIXME: This is terrible!
    interp.pushFrame(args[0], null);
  }
}


/**
 * Pushes an agent set to operate on
 */
class AskStatement extends Statement {
  
  AskStatement(List l) : super(l);
  
  dynamic eval(Interpreter interp) {
    AgentSet aset = args[0].eval(interp);
    if (aset != null && aset.curr != null) {
      interp.pushFrame(args[1], aset);
    }
  }
}