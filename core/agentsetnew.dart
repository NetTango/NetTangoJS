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

class AgentSetNew implements Set<String>{
  
  Set<String> _set;
  
  int get length => _set.length;
  
  AgentSetNew(): _set = new Set<String>();
  
  AgentSetNew.from(Iterable<String> e) : _set = new Set.from(e);
  
  void removeAll(Iterable<Object> elements){
    _set.removeAll(elements);
  }
  
  void addAll(Iterable<Object> elements){
    _set.addAll(elements);
  
  Iterable<String> where(bool f (String element)){
    return _set.where(f);
  }
  
}
  


main() {
  String t = "hep";
  String t2 = "hep";
  String t3 = "hep3";

  var tl = new List<String>();
  
  tl.addAll([t, t2, t3]);
  var tl2 = new AgentSetNew.from(tl);

  print(tl.length);
  print(tl2.length);
  
  print(tl2.where((i) => i == 'hep').length);
}

  
//  Set turtles = new Set<Turtle>();
//  
//  AgentSet.empty() {
//    
//  }
//  AgentSet.fromAgentSet(AgentSet aset){
//    
//  }
//  
//  
//  
//  void add(Turtle t){
//    turtles.add(t);
//  }
//  
//  Turtle oneOf(){
//    return turtles.elementAt(Turtle.rnd.nextInt(turtles.length));
//  }
//  
//  AgentSet turtlesWith(var aTest){
//    AgentSet newSet = AgentSet.fromAgentSet(turtles.where(aTest));
//    return newSet;
//    
//  }
//  
  
