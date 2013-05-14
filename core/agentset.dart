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
 * A collection of agents
 */
class AgentSet {


  /* List of agents */
  List<Agent> agents = new List<Agent>();
  
  /* Internal iterator count */
  int _index = 0;
  
  /* Random number generator */
  Random rand = new Random();

  
  /**
   * Create an empty agent set
   */
  AgentSet() {}

  
  /**
   * Create an agent set from a single agent
   */
  AgentSet.fromAgent(Agent a) {
    if (a != null) agents.add(a);
  }
  
  
  /**
   * Is this an empty agentset?
   */
  bool get isEmpty {
    return (agents.length == 0);
  }
  
  
  int get length {
    return agents.length;
  }
  
  
  /**
   * Resets the iterator to the first agent
   */
  void reset() {
    _index = 0;
  }
  
  
  /**
   * Retrieve the next agent in the set and advance the iterator. Returns
   * null if there are no remaining agents. (TODO Randomize order)
   */
  Agent next() {
    _index++;
    return curr();
  }
  
  
  /**
   * Current agent in the iterator. Does not advance iterator. Returns null
   * if there are no remaining agents.
   */
  Agent curr() {
    if (_index >= agents.length) {
      return null;
    } else {
      return agents[_index];
    }
  }
  
  
  /**
   * Iterator is complete
   */
  bool get hasNext {
    return (_index < agents.length - 1);
  }
  

  /**
   * Add an agent to the set
   */
  void add(Agent agent) {
    agents.add(agent);
  }
  
  
  /**
   * Remove all agents
   */
  void clear() {
    agents.clear();
    _index = 0;
  }
  
  
  /**
   * Return an agent set consisting of just one agent selected at random
   */
  AgentSet oneOf() {
    if (agents.length == 0) {
      return null;
    } else {
      return new AgentSet.fromAgent(agents[rand.nextInt(agents.length)]);
    }
  }
}
