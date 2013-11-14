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

class AgentSetNew implements Set<Turtle>{
  
  Set<Turtle> _set = new Set<Turtle>();
  
  // standard getters/setters stuff
  int get length => _set.length;
  bool get isEmpty => _set.isEmpty;
  
  
  AgentSetNew.fromEmpty() {}
  
  AgentSetNew.fromAgentSet(Iterable<Turtle> e) : _set = new Set.from(e);
  
  AgentSetNew.fromAgent(Turtle t)  
  {
    _set.add(t);
  }
    
  void removeAll(Iterable<Object> elements){
    _set.removeAll(elements);
  }
  
  void addAll(Iterable<Object> elements){
    _set.addAll(elements);
  }  
  Iterable<Turtle> where(bool f (Turtle element)){
    return _set.where(f);
  }
  
  AgentSetNew shuffleAndReturn() {
    var random = new Random();

    // Go through all elements.
    for (var i = _set.length - 1; i > 0; i--) {

      // Pick a pseudorandom number according to the list length
      var n = random.nextInt(_set.length);

      var temp = _set.elementAt(i);
      _set[i] = items[n];
      items[n] = temp;
    }

    return this;
  }
  
  AgentSetNew with(){
    
  }

  

  
}