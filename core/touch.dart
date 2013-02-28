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


class TouchManager {

  // A list of touchable objects on the screen
  static var touchables;
   
  // Bindings from event IDs to touchable objects
  static var touch_bindings;
   
  // Touch event frame from microsoft surface
  var pframe = null;
   
  // Is the mouse currently down
  bool mdown = false;
   
   
  TouchManager() {
    touchables = new List<Touchable>();
    touch_bindings = new Map<int, Touchable>();
  }
   

/*
 * The main class must call this method to enable mouse and touch input
 */ 
  void registerEvents(Element element) {
    element.onMouseDown.listen((e) => doMouseDown(e));
    element.onMouseUp.listen((e) => doMouseUp(e));
    element.onMouseMove.listen((e) => doMouseMove(e));
      
    // Events for iPad
    element.onTouchStart.listen((e) => doTouchDown(e));
    element.onTouchMove.listen((e) => doTouchDrag(e));
    element.onTouchEnd.listen((e) => doTouchUp(e));
      
    // Prevent screen from dragging on ipad
    document.onTouchMove.listen((e) => e.preventDefault());

      // Attempt to connect to the microsoft surface input stream
//      try {
//         var socket = new WebSocket("ws://localhost:405");
//         socket.on.open.add((evt) => print("connected to surface."));
//         socket.on.message.add((evt) => processTouches(evt.data));
//         socket.on.error.add((evt) => print("error in surface connection."));
//         socket.on.close.add((evt) => print("surface connection closed."));
//      }
//      catch (x) {
//         print("unable to connect to surface.");
//      }
   }
   
   
/*
 * Add a touchable object to the list
 */
  static void addTouchable(Touchable t) {
    touchables.add(t);
  }
   

/*
 * Remove a touchable object from the master list
 */
  static void removeTouchable(Touchable t) {
    for (int i=0; i<touchables.length; i++) {
      if (t == touchables[i]) {
        touchables.removeRange(i, 1);
        return;
      }
    }
  }
   
   
/*
 * Find a touchable object that intersects with the given touch event
 */
  Touchable findTouchTarget(Contact tp) {
    for (var t in touchables) {
      if (t.containsTouch(tp)) {
        return t;
      }
    }
    return null;
  }
   

/*
 * Convert mouseUp to touchUp events
 */
  void doMouseUp(MouseEvent evt) {
    var target = touch_bindings[-1];
    if (target != null) {
      target.touchUp(new Contact.fromMouse(evt));
      touch_bindings[-1] = null;
    }
    mdown = false;
  }
   
   
/*
 * Convert mouseDown to touchUp events
 */
  void doMouseDown(MouseEvent evt) {
    Contact t = new Contact.fromMouse(evt);
    var target = findTouchTarget(t);
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
  void doMouseMove(MouseEvent evt) {
    if (mdown) {
      Contact t = new Contact.fromMouse(evt);
      var target = touch_bindings[-1];
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
   
   
  void doTouchDown(var tframe) {
    for (Touch touch in tframe.changedTouches) {
      Contact t = new Contact.fromTouch(touch);
      var target = findTouchTarget(t);
      if (target != null) {
        if (target.touchDown(t)) {
          touch_bindings[t.id] = target;
        }
      }
    }
  }
   
   
  void doTouchUp(var tframe) {
    for (Touch touch in tframe.changedTouches) {
      Contact t = new Contact.fromTouch(touch);
      var target = touch_bindings[t.id];
      if (target != null) {
        target.touchUp(t);
        touch_bindings[t.id] = null;
      }
    }
    if (tframe.touches.length == 0) {
      touch_bindings = [];
    }
  }
   
   
  void doTouchDrag(var tframe) {
    for (Touch touch in tframe.changedTouches) {
      Contact t = new Contact.fromTouch(touch);
      var target = touch_bindings[t.id];
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
   

/*
 * Process JSON touch events from microsoft surface
 */
//   void processTouches(data) {
//      var frame = new JsonObject.fromJsonString(data);
//      
//      var changed = [];
//      bool down = false;
//      bool drag = false;
//      bool up = false;
//      
//      for (var t in frame.touches) {
//         if (t.down) {
//            changed.add(new TouchEvent.fromJSON(t));
//            down = true;
//         }
//         else if (t.drag) {
//            changed.add(new TouchEvent.fromJSON(t));
//            drag = true;
//         }
//         else if (t.up) {
//           print("t.up");
//            changed.add(new TouchEvent.fromJSON(t));
//            up = true;
//         }
//      }
//      
//      frame.changedTouches = changed;
//      if (down) touchDown(frame);
//      if (drag) touchDrag(frame);
//      if (up) touchUp(frame);
//      
//      pframe = frame;
//   }
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
    touchX = mouse.clientX;
    touchY = mouse.clientY;
    finger = true;
  }
  
  Contact.fromTouch(Touch touch) {
    id = touch.identifier;
    touchX = touch.clientX;
    touchY = touch.clientY;
    finger = true;
  }
  
  Contact.fromJSON(var json) {
    id = json.identifier;
    touchX = json.pageX;
    touchY = json.pageY;
    up = json.up;
    down = json.down;
    drag = json.drag;
    tag = json.tag;
    tagId = json.tagId;
  }
}
