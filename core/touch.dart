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


class TouchManager {

  /* A list of touchable objects on the screen */
  List<Touchable> touchables = new List<Touchable>();
   
  /* Bindings from event IDs to touchable objects */
  Map<int, Touchable> touch_bindings = new Map<int, Touchable>();
   
  /* Is the mouse currently down */
  bool mdown = false;
  
  /* Element that receives touch or mouse events */
  Element parent = null;
   
  TouchManager();
   

/*
 * The main class must call this method to enable mouse and touch input
 */ 
  void registerEvents(Element element) {
    parent = element;
    
    element.onMouseDown.listen((e) => _mouseDown(e));
    element.onMouseUp.listen((e) => _mouseUp(e));
    element.onMouseMove.listen((e) => _mouseMove(e));
    //element.onMouseOut.listen((e) => _mouseExit(e));
      
    // Events for iPad
    print("register events");
    /*
    element.onTouchStart.listen((e) => _touchDown(e));
    element.onTouchMove.listen((e) => _touchDrag(e));
    element.onTouchEnd.listen((e) => _touchUp(e));
    */
      
    // Prevent screen from dragging on ipad
    document.onTouchMove.listen((e) => e.preventDefault());
  }
   
   
/*
 * Add a touchable object to the list
 */
  void addTouchable(Touchable t) {
    touchables.add(t);
  }
   

/*
 * Remove a touchable object from the master list
 */
  void removeTouchable(Touchable t) {
    touchables.remove(t);
  }
   
   
/*
 * Find a touchable object that intersects with the given touch event
 */
  Touchable findTouchTarget(Contact tp) {
    for (int i=touchables.length - 1; i >= 0; i--) {
      if (touchables[i].containsTouch(tp)) {
        return touchables[i];
      }
    }
    return null;
  }
   

/*
 * Convert mouseUp to touchUp events
 */
  void _mouseUp(MouseEvent evt) {
    Touchable target = touch_bindings[-1];
    if (target != null) {
      target.touchUp(new Contact.fromMouse(evt));
    }
    touch_bindings[-1] = null;
    mdown = false;
  }
  
  
/*
 * Convert mouseOut to touchExit event
 */
  void _mouseExit(MouseEvent evt) {
    Touchable target = touch_bindings[-1];
    if (target != null) {
      target.touchUp(new Contact.fromMouse(evt));
      touch_bindings[-1] = null;
    }
    mdown = false;
  }
   
   
/*
 * Convert mouseDown to touchDown events
 */
  void _mouseDown(MouseEvent evt) {
    Contact t = new Contact.fromMouse(evt);
    Touchable target = findTouchTarget(t);
    if (target != null) {
      if (target.touchDown(t)) {
        touch_bindings[-1] = target;
      }
    }
    mdown = true;
  }
   
   
/*
 * Convert mouseMove to touchDrag events
 */
  void _mouseMove(MouseEvent evt) {
    if (mdown) {
      Contact t = new Contact.fromMouse(evt);
      Touchable target = touch_bindings[-1];
      if (target != null) {
        target.touchDrag(t);
      } else {
        target = findTouchTarget(t);
        if (target != null) {
          target.touchSlide(t);
        }
      }
    }
  }
   
   
  void _touchDown(var tframe) {
    for (Touch touch in tframe.changedTouches) {
      Contact t = new Contact.fromTouch(touch, parent);
      Touchable target = findTouchTarget(t);
      if (target != null) {
        if (target.touchDown(t)) {
          touch_bindings[t.id] = target;
        }
      }
    }
  }
   
   
  void _touchUp(var tframe) {
    for (Touch touch in tframe.changedTouches) {
      Contact t = new Contact.fromTouch(touch, parent);
      Touchable target = touch_bindings[t.id];
      if (target != null) {
        target.touchUp(t);
        touch_bindings[t.id] = null;
      }
    }
    if (tframe.touches.length == 0) {
      touch_bindings.clear();
    }
  }
   
   
  void _touchDrag(var tframe) {
    for (Touch touch in tframe.changedTouches) {
      Contact t = new Contact.fromTouch(touch, parent);
      Touchable target = touch_bindings[t.id];
      if (target != null) {
        target.touchDrag(t);
      } else {
        target = findTouchTarget(t);
        if (target != null) {
          target.touchSlide(t);
        }
      }
    }
  }
}  
  

/*
 * Objects on the screen must implement this interface to receive touch events
 */
abstract class Touchable {
  
  bool containsTouch(Contact event);
   
  // This gets fired if a touch down lands on the touchable object. 
  // Return true to 'own' the touch event for the duration 
  // Return false to ignore the event (e.g. if disabled or if you want slide events)
  bool touchDown(Contact event);
   
  void touchUp(Contact event);
   
  // This gets fired only after a touchDown lands on the touchable object
  void touchDrag(Contact event);
   
  // This gets fired when an unbound touch events slides over an object
  void touchSlide(Contact event);

}


class Contact {
  int id;
  int tagId = -1;
  num touchX = 0;
  num touchY = 0;
  bool tag = false;
  bool up = false;
  bool down = false;
  bool drag = false;
  bool finger = false;
  
  Contact(this.id);
  
  Contact.fromMouse(MouseEvent mouse) {
    id = -1;
    touchX = mouse.offset.x.toDouble();
    touchY = mouse.offset.y.toDouble();
    finger = true;
  }
  
  Contact.fromTouch(Touch touch, Element parent) {
    num left = window.pageXOffset;
    num top = window.pageYOffset;
    
    if (parent != null) {
      Rectangle box = parent.getBoundingClientRect();
      left += box.left;
      top += box.top;
    }
    
    id = touch.identifier;
    touchX = touch.page.x.toDouble() - left;
    touchY = touch.page.y.toDouble() - top;
    finger = true;
  }
  
  
  Contact.fromJSON(var json, Element parent) {
    num left = window.pageXOffset;
    num top = window.pageYOffset;
    
    if (parent != null) {
      Rectangle box = parent.getBoundingClientRect();
      left += box.left;
      top += box.top;
    }
    
    id = json["identifier"];
    touchX = json["pageX"] - left;
    touchY = json["pageY"] - top;
    up = json["up"];
    down = json["down"];
    drag = json["drag"];
    tag = json["tag"];
    tagId = json["tagId"];
  }
}
